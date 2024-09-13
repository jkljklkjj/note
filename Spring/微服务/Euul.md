**网关**

在实际的项目中，一个项目可能会包含很多个服务，每个服务的端口和 IP 都可能不一样。那么，如果我们以这种形式提供接口给外部调用，代价是非常大的。从安全性上考虑，系统对外提供的接口应该进行合法性校验，防止非法请求，如果按照这种形式，那每个服务都要写一遍校验规则，维护起来也很麻烦。

这个时候，我们需要统一的入口，接口地址全部由该入口进入，而服务只部署在局域网内供这个统一的入口调用，这个入口就是我们通常说的服务网关。

Spring Cloud 给我们提供了这样一个解决方案，那就是 zuul，它的作用就是进行路由转发、异常处理和过滤拦截。下面，我将演示如果使用 zuul 创建一个服务网关。

构建依赖
```java
<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zuul</artifactId>
        </dependency>
    </dependencies>
```

配置启动类
```java
@SpringBootApplication
@EnableEurekaClient
@EnableZuulProxy
public class Application {
 
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

配置application.yml
```java
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8080
spring:
  application:
    name: gateway
zuul:
  routes:
    api:
      path: /api/**
      serviceId: eurekaclient
```

我们可以看到，服务网关的配置多了几项，具体含义如下。

zuul.routes.api.path：指定请求基础地址，其中 API 可以是任何字符。

serviceId：转发到的服务 ID，也就是指定服务的 application.name，上述实例的含义表示只要包含 /api/ 的地址，都自动转发到 eurekaclient 的服务去。

然后我们启动服务注册中心、服务提供者、服务网关，访问地址：http://localhost:8080/api/index，我们可以看到和之前的界面完全一样。其实只要引入了 zuul，它就会自动帮我们实现反向代理和负载均衡。配置文件中的地址转发其实就是一个反向代理，那它如何实现负载均衡呢？

我们修改服务提供者的 Controller 如下
```java
RestController
public class HelloController {
 
    @Value("${server.port}")
    private int port;
 
    @RequestMapping("index")
    public String index(){
        return "Hello World!,端口："+port;
    }
}
```

最后在Eureka可以看到配置好了
由此可以得出，当一个服务启动多个端口时，zuul 服务网关会依次请求不同端口，以达到负载均衡的目的
![](https://i-blog.csdnimg.cn/blog_migrate/53bca8bbe4d475c9b0d3262bca9a3665.png)

**服务拦截**
前面我们提到，服务网关还有个作用就是接口的安全性校验，这个时候我们就需要通过 zuul 进行统一拦截，zuul 通过继承过滤器 ZuulFilter 进行处理，下面请看具体用法。

新建一个类 ApiFilter 并继承 ZuulFilter：

```java
@Component
public class ApiFilter extends ZuulFilter {
 
    @Override
    public String filterType() {
        return "pre";
    }
 
    @Override
    public int filterOrder() {
        return 0;
    }
 
    @Override
    public boolean shouldFilter() {
        return true;
    }
 
    @Override
    public Object run() {
        //这里写校验代码
        return null;
    }
}
```
其中：
- filterType 为过滤类型，可选值有 pre（路由之前）、routing（路由之时）、post（路由之后）、error（发生错误时调用）。
- filterOrdery 为过滤的顺序，如果有多个过滤器，则数字越小越先执行
- shouldFilter 表示是否过滤，这里可以做逻辑判断，true 为过滤，false 不过滤
- run 为过滤器执行的具体逻辑，在这里可以做很多事情，比如：权限判断、合法性校验等。

下面，来做一个简单的安全验证：
```java
@Override
    public Object run() {
        //这里写校验代码
        RequestContext context = RequestContext.getCurrentContext();
        HttpServletRequest request = context.getRequest();
        String token = request.getParameter("token");
        if(!"12345".equals(token)){
            context.setSendZuulResponse(false);
            context.setResponseStatusCode(401);
            try {
                context.getResponse().getWriter().write("token is invalid.");
            }catch (Exception e){}
        }
        return null;
    }
```

启动 gateway，在浏览器输入地址：http://localhost:8080/api/index，可以看到以下界面
![](https://i-blog.csdnimg.cn/blog_migrate/d66db33ad1f83915af50b83fb95fa8e9.png)
再通过浏览器输入地址：http://localhost:8080/api/index?token=12345,可以看到以下界面：
![](https://i-blog.csdnimg.cn/blog_migrate/882d99b0a3b5ec36e1d806bc7ca07a41.png)
**错误拦截**
在一个大型系统中，服务是部署在不同的服务器下面的，我们难免会遇到某一个服务挂掉或者请求不到的时候，如果不做任何处理，服务网关请求不到会抛出500错误，对用户是不友好的。

我们为了提供用户的友好性，需要返回友好性提示，zuul 为我们提供了一个名叫 ZuulFallbackProvider 的接口，通过它我们就可以对这些请求不到的服务进行错误处理。

新建一个类 ApiFallbackProvider 并且实现 ZuulFallbackProvider 接口：
```java
@Component
public class ApiFallbackProvider implements ZuulFallbackProvider{
 
    @Override
    public String getRoute() {
        return "eurekaclient";
    }
 
    @Override
    public ClientHttpResponse fallbackResponse() {
        return new ClientHttpResponse() {
            @Override
            public HttpStatus getStatusCode() throws IOException {
                return HttpStatus.OK;
            }
 
            @Override
            public int getRawStatusCode() throws IOException {
                return 200;
            }
 
            @Override
            public String getStatusText() throws IOException {
                return "{code:0,message:\"服务器异常！\"}";
            }
 
            @Override
            public void close() {
 
            }
 
            @Override
            public InputStream getBody() throws IOException {
                return new ByteArrayInputStream(getStatusText().getBytes());
            }
 
            @Override
            public HttpHeaders getHeaders() {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                return headers;
            }
        };
    }
```
其中，getRoute 方法返回要处理错误的服务名，fallbackResponse 方法返回错误的处理规则。

现在开始测试这部分代码，首先停掉服务提供者 eurekaclient，再重启 gateway，请求地址：http://localhost:8080/api/index?token=12345，即可出现以下界面：
![](https://i-blog.csdnimg.cn/blog_migrate/3135065d8a2f06f2c09f4274a5648029.png)
