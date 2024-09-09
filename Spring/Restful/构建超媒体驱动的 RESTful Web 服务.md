HATEOAS，全称是Hypermedia As The Engine Of Application State，是REST架构风格中的一个约束。它的主要思想是，客户端只需要知道一个初始的URL，后续的操作都可以通过服务器返回的信息来进行。

在HATEOAS中，服务器返回的信息中不仅包含了资源的状态，还包含了可以进行的操作。这些操作通常是以**链接**的形式提供的，因此被称为HATEOAS链接。

其中，最典型的超媒体就是HTML

首先创建一个包含媒体对象的类
```java
package com.example.resthateoas;

import org.springframework.hateoas.RepresentationModel;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

// 继承自`RepresentationModel<Greeting>表示一个可以通过HATEOAS链接进行富化的资源模型
public class Greeting extends RepresentationModel<Greeting> {

	private final String content;

	// 在反序列化JSON时指定如何创建`Greeting`对象
	@JsonCreator
	public Greeting(@JsonProperty("content") String content) {
		this.content = content;
	}

	public String getContent() {
		return content;
	}
}
```

创建一个RestController
```java
package com.example.resthateoas;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.*;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
public class GreetingController {

	private static final String TEMPLATE = "Hello, %s!";

	@RequestMapping("/greeting")
	public HttpEntity<Greeting> greeting(
		@RequestParam(value = "name", defaultValue = "World") String name) {

		Greeting greeting = new Greeting(String.format(TEMPLATE, name));
		greeting.add(linkTo(methodOn(GreetingController.class).greeting(name)).withSelfRel());

		return new ResponseEntity<>(greeting, HttpStatus.OK);
	}
}
```