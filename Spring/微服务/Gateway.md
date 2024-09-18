和[[Euul]]差不多，是原生SpringCloud

这里解释如何进行配置
```java
spring:  
  cloud:  
    gateway:  
      routes:  
        - id: api_route  
          uri: lb://gate  
          predicates:  
            - Path=/order-service/**  
          filters:  
            - StripPrefix=1  
            - name: ApiFilter
```
- 匹配所有以order-service开头的路由
- 获取名为ApiFilter的类作为过滤器
- 导航到去除order-service的路径
- 导航并到所有名为gate的服务

细节方面，要先访问Gateway所在ip+端口，将其视作一个普通的控制器，方可使用