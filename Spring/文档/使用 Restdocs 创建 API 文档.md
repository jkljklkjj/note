API文档很重要。在前后端进行交流时，前端工作人员只需要知道每个接口的作用，以及输入和输出就能接入后端，使用后端的功能

首先简单创建一个Spring应用
```java
package com.example.testingrestdocs;

import java.util.Collections;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

	@GetMapping("/")
	public Map<String, Object> greeting() {
		return Collections.singletonMap("message", "Hello, World");
	}

}
```

```java
package com.example.testingrestdocs;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class TestingRestdocsApplication {

	public static void main(String[] args) {
		//表明要用到这个Restdocs
		SpringApplication.run(TestingRestdocsApplication.class, args);
	}
}
```

导入需要的依赖
```java
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.3.0</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>com.example</groupId>
	<artifactId>demo</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>gs-testing-restdocs</name>
	<description>Demo project for Spring Boot</description>
	<properties>
		<java.version>17</java.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<!-- tag::test[] -->
		<dependency>
		  <groupId>org.springframework.restdocs</groupId>
		  <artifactId>spring-restdocs-mockmvc</artifactId>
		  <scope>test</scope>
		</dependency>
		<!-- end::test[] -->
	</dependencies>

	<build>
		<plugins>
			<!-- tag::asciidoc[] -->
			<plugin>
				<groupId>org.asciidoctor</groupId>
				<artifactId>asciidoctor-maven-plugin</artifactId>
				<version>1.5.8</version>
				<executions>
					<execution>
						<id>generate-docs</id>
						<phase>prepare-package</phase>
						<goals>
							<goal>process-asciidoc</goal>
						</goals>
						<configuration>
							<backend>html</backend>
							<doctype>book</doctype>
						</configuration>
					</execution>
				</executions>
				<dependencies>
					<dependency>
						<groupId>org.springframework.restdocs</groupId>
						<artifactId>spring-restdocs-asciidoctor</artifactId>
						<version>${spring-restdocs.version}</version>
					</dependency>
				</dependencies>
			</plugin>
			<!-- end::asciidoc[] -->
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
			</plugin>
		</plugins>
	</build>

</project>
```

还应该编写一些测试来断言我们应用程序的行为。一种有用的方法是仅测试 MVC 层，其中 Spring 处理传入的 HTTP 请求并将其传递给控制器。为此，你可以使用 Spring 的 Token，并通过在测试用例上使用 Comments 来请求注入它。
```java
package com.example.testingrestdocs;

import org.junit.jupiter.api.Test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.restdocs.AutoConfigureRestDocs;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.document;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// 表示这是一个针对`HomeController`类的Web层测试
// 会自动配置一个测试环境，这个环境只包含`HomeController`和与之相关的Bean
// 表示这个测试类会生成REST文档。生成的文档片段将被保存在"target/snippets"目录
@WebMvcTest(HomeController.class)
@AutoConfigureRestDocs(outputDir = "target/snippets")
public class WebLayerTest {

	@Autowired
	private MockMvc mockMvc;

	@Test
	public void shouldReturnDefaultMessage() throws Exception {
		this.mockMvc.perform(get("/")).andDo(print()).andExpect(status().isOk())
				.andExpect(content().string(containsString("Hello, World")))
				.andDo(document("home"));
	}
}
```