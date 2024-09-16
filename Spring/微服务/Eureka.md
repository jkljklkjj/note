**服务发现**

配置依赖
首先是服务发现，这里我们采用 Eureka
```java
<parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.9.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
	</dependencies>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Dalston.SR5</version>
                <type>pom</type>
                <scope>import</scope>
                <exclusions>
                </exclusions>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

同时配置application.yml
```java
server:
  port: 8761
spring:
  profiles:
    active: dev
eureka:
  server:
    enable-self-preservation: false
  instance:
    preferIpAddress: true
    hostname: ${spring.cloud.client.ipAddress}
    instanceId: ${spring.cloud.client.ipAddress}:${server.port}
  client:
    registerWithEureka: false
    fetchRegistry: false
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```

同时启动类要引入Eureka
```java
@SpringBootApplication
// 现在更新了，用@EnableDiscoveryClient取代
@EnableEurekaServer
public class Application {
 
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

实现服务提供者
```java
<parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.9.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Dalston.SR5</version>
                <type>pom</type>
                <scope>import</scope>
                <exclusions>
                </exclusions>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

增加application.yml，表示给它发现
```java
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
server:
  port: 8762
spring:
  application:
    name: hello
```

最后启动类允许消息提供
*目前EnableEurekaClient已经被弃用，请换到EnableDiscoveryClient使用（血的教训）*
```java
@SpringBootApplication
@EnableEurekaClient
@RestController
public class HelloController {
 
    public static void main(String[] args) {
        SpringApplication.run(HelloController.class, args);
    }
 
    @Value("${server.port}")
    String port;
    @RequestMapping("/hello")
    public String home(String name) {
        return "hi "+name+",i am from port:" +port;
    }
 
}
```