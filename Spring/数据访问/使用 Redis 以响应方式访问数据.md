创建一条记录，表示我们希望在咖啡目录中储存的咖啡类型
```java
package com.example.demo;

public record Coffee(String id, String name) {
}
```

创建一个包含支持反应式 Redis 操作的 Spring Beans 的类
```java
package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.ReactiveRedisConnectionFactory;
import org.springframework.data.redis.core.ReactiveRedisOperations;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

// 表示这是一个Spring配置类，用于定义Bean
@Configuration
public class CoffeeConfiguration {
	// 用于执行Reactive Redis操作
  @Bean
  ReactiveRedisOperations<String, Coffee> redisOperations(ReactiveRedisConnectionFactory factory) {
	  // 用于将`Coffee`对象序列化为JSON格式
    Jackson2JsonRedisSerializer<Coffee> serializer = new Jackson2JsonRedisSerializer<>(Coffee.class);

	// 用于构建Redis序列化上下文
    RedisSerializationContext.RedisSerializationContextBuilder<String, Coffee> builder =
        RedisSerializationContext.newSerializationContext(new StringRedisSerializer());

    RedisSerializationContext<String, Coffee> context = builder.value(serializer).build();

    return new ReactiveRedisTemplate<>(factory, context);
  }

}
```

创建一个 Spring Bean，以便在启动时为应用程序加载示例数据
```java
package com.example.demo;

import org.springframework.data.redis.connection.ReactiveRedisConnectionFactory;
import org.springframework.data.redis.core.ReactiveRedisOperations;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;

import jakarta.annotation.PostConstruct;
import java.util.UUID;

// Spring启动后该类也会启动
@Component
public class CoffeeLoader {
	// 创建Reactive Redis连接
  private final ReactiveRedisConnectionFactory factory;
  // 执行Reactive Redis操作
  private final ReactiveRedisOperations<String, Coffee> coffeeOps;

  public CoffeeLoader(ReactiveRedisConnectionFactory factory, ReactiveRedisOperations<String, Coffee> coffeeOps) {
    this.factory = factory;
    this.coffeeOps = coffeeOps;
  }

	// Spring完成依赖注入后自动调用
  @PostConstruct
  public void loadData() {
    factory.getReactiveConnection().serverCommands().flushAll().thenMany(
        Flux.just("Jet Black Redis", "Darth Redis", "Black Alert Redis")
            .map(name -> new Coffee(UUID.randomUUID().toString(), name))
            .flatMap(coffee -> coffeeOps.opsForValue().set(coffee.id(), coffee)))
        .thenMany(coffeeOps.keys("*")
            .flatMap(coffeeOps.opsForValue()::get))
        .subscribe(System.out::println);
  }
}
```

创建控制器来使用
```java
package com.example.demo;

import org.springframework.data.redis.core.ReactiveRedisOperations;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
public class CoffeeController {
  private final ReactiveRedisOperations<String, Coffee> coffeeOps;

  CoffeeController(ReactiveRedisOperations<String, Coffee> coffeeOps) {
    this.coffeeOps = coffeeOps;
  }

  @GetMapping("/coffees")
  public Flux<Coffee> all() {
    return coffeeOps.keys("*")
        .flatMap(coffeeOps.opsForValue()::get);
  }
}
```