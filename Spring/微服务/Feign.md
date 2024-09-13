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
@FeignClient(value = "eurekaclient")
public interface ApiService {

    @RequestMapping(value = "/index",method = RequestMethod.GET)
    String index();
}
```
