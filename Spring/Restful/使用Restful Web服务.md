Spring 提供了一个方便的模板类，称为[`RestTemplate`](http://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/web/client/RestTemplate.html)。 使与大多数 RESTful 服务的交互成为一行咒语。它甚至可以将该数据绑定到自定义域类型。
```java
package com.example.consumingrest;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

// 创建一个record模版类，只储存成员变量
@JsonIgnoreProperties(ignoreUnknown = true)
public record Quote(String type, Value value) { }
```

然后，可以把一个json放进另一个里面从而嵌套
```java
package com.example.consumingrest;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record Value(Long id, String quote) { }
```

现在，需要向运行类中添加一些其他内容，以使其显示来自我们的 RESTful 源代码的引文。您需要添加：`ConsumingRestApplication`
- 一个记录器，用于将输出发送到日志（在本例中为控制台）。
    
- A ，它使用 Jackson JSON 处理库来处理传入数据。`RestTemplate`
    
- A 在启动时运行 （并因此获取我们的报价单）。`CommandLineRunner``RestTemplate`
```java
package com.example.consumingrest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;

@SpringBootApplication
public class ConsumingRestApplication {

	private static final Logger log = LoggerFactory.getLogger(ConsumingRestApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(ConsumingRestApplication.class, args);
	}

	// 标记一个方法，该方法返回的对象应该被Spring的应用上下文管理。这意味着Spring会负责这个对象的生命周期，并且你可以在其他地方通过依赖注入（DI）来使用这个对象。
	// 在其他地方可以用@Autowired来注入这个方法对象
	@Bean
	public RestTemplate restTemplate(RestTemplateBuilder builder) {
		return builder.build();
	}

	// 在Spring运行后Bean也会运行
	// 这里向这个网址获取Quote对象的内容，并输出
	@Bean
	@Profile("!test")
	public CommandLineRunner run(RestTemplate restTemplate) throws Exception {
		return args -> {
			Quote quote = restTemplate.getForObject(
					"http://localhost:8080/api/random", Quote.class);
			log.info(quote.toString());
		};
	}
}
```