**服务异常处理**

SpringCloud 集成了 Netflix 开源的 Hystrix 组件，该组件实现了熔断器模型，它使得我们很方便地实现熔断器。

在实际项目中，一个请求调用多个服务是比较常见的，如果较底层的服务发生故障将会发生连锁反应。这对于一个大型项目是灾难性的。因此，我们需要利用 Hystrix 组件，当特定的服务不可用达到一个阈值（Hystrix 默认5秒20次），将打开熔断器，即可避免发生连锁反应。

配置application.yml（Feign集成）
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
#开启熔断器
feign:
  hystrix:
    enabled: true
```

新建一个类 ApiServiceError.java 并实现 ApiService
```java
@Component
public class ApiServiceError implements ApiService {
 
    @Override
    public String index() {
        return "服务发生故障！";
    }
}
```

然后在 ApiService 的注解中指定 fallback
```java
@FeignClient(value = "eurekaclient",fallback = ApiServiceError.class)
public interface ApiService {
 
    @RequestMapping(value = "/index",method = RequestMethod.GET)
    String index();
}
```

最后创建Controller
```java
@RestController
public class ApiController {
 
    @Autowired
    private ApiService apiService;
 
    @RequestMapping("index")
    public String index(){
        return apiService.index();
    }
}
```

访问一个关闭的接口，显示成功
![](https://i-blog.csdnimg.cn/blog_migrate/58c028627a8cde115fe68308a9053f04.png)
