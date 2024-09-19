使用@Restcontroller
该注解是一个控制器
能够接收信息并返回Json
```java
package com.example.restservice; 
import java.util.concurrent.atomic.AtomicLong; 
import org.springframework.web.bind.annotation.GetMapping; 
import org.springframework.web.bind.annotation.RequestParam; 
import org.springframework.web.bind.annotation.RestController; 
@RestController 
public class GreetingController { 
	private static final String template = "Hello, %s!"; 
	private final AtomicLong counter = new AtomicLong(); 
	// 标记一个路由，接收Get请求
	// 要求传入参数的形式，并设定了一个默认值
	@GetMapping("/greeting") 
	public Greeting greeting(@RequestParam(value = "name", defaultValue = "World") String name) {
	// 返回一个对象，对象的所有成员变量名作为键，值为值
	return new Greeting(counter.incrementAndGet(), String.format(template, name)); 
	}
}
```