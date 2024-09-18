**服务消费者**

Feign 是一个声明式的 HTTP 客户端，它简化了 HTTP 客户端的开发。使用 Feign，只需要创建一个接口并注解，就能很轻松的调用各服务提供的 HTTP 接口。Feign 默认集成了 Ribbon，默认实现了负载均衡。

创建配置
```java
<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-feign</artifactId>
        </dependency>
    </dependencies>
```

配置application.yml
```java
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8081
spring:
  application:
    name: feign
```

创建启动类
```java
@SpringBootApplication
@EnableEurekaClient
@EnableFeignClients
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

进行测试
首先创建一个接口 ApiService，并且通过注解配置要调用的服务地址：

```java
// 表明需要使用名字为eurekaclient的服务
@FeignClient(value = "eurekaclient")
public interface UserFeignClient {
	// get请求这个服务的对应路径
    @RequestMapping(value = "/index",method = RequestMethod.GET)
    String index();
}
```

然后就能在控制器类里面使用这个对象
```java
@SpringBootApplication  
@EnableDiscoveryClient  
@EnableFeignClients(basePackages = "com.example.Config")  
@RestController  
public class Server2Application {  
	// 获取这个控制器对象
    private final UserFeignClient userFeignClient;  
  
    public Server2Application(UserFeignClient userFeignClient) {  
        // 注入UserFeignClient  
        // 从而能使用这个控制器对象来调用Server服务的控制器方法  
        this.userFeignClient = userFeignClient;  
    }  
  
    public static void main(String[] args) {  
        SpringApplication.run(Server2Application.class, args);  
    }  
  
    @Value("${server.port}")  
    String port;  
  
    @RequestMapping("/hello")  
    public String home(@RequestParam String name) {  
        return "hello "+name+",i am from port:" +port;  
    }  
  
    @RequestMapping("/feign-test")  
    public String feignTest() {  
        // 通过控制器对象调用Server服务的控制器方法  
        return userFeignClient.hello();  
    }  
}
```
