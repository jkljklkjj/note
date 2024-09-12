### 什么是 Spring Cloud Stream？

用于构建事件驱动型 Spring Boot 微服务以进行实时流处理的框架。您可以从 [project-site](https://spring.io/projects/spring-cloud-stream)、[documentation](https://spring.io/projects/spring-cloud-stream#learn) 和 [samples](https://github.com/spring-cloud/spring-cloud-stream-samples) 中了解有关该框架的更多信息。

- name-source：定期发布 String 以启动流。在此示例中，将名称发布为 String。
- name-processor：使用 name-source 发布的 String 并以某种方式转换数据。将结果发布到其他交易所。在此示例中，使用名称 String 创建记录并添加时间戳。
- name-sink：使用 name-processor 的结果并执行操作。在这种情况下，将结果打印到 standard out。

使用这个流的方法是安装RabbitMQ[[RabbitMQ/入门|入门]]，具体方式不再赘述

我们定义一个Sink应用程序
```java
@Bean
public Consumer<Person> nameSink() {
  return person -> {
    System.out.println(person.name());
    System.out.println(person.processedTimestamp());
  };
}
```

在不配置交换名称的情况下启动此应用程序会自动生成一个在 RabbitMQ 中命名的交换。我们希望自定义此交换，以便以后可以将处理器挂接到接收器`nameSink-in-0`
```java
spring.cloud.stream.function.bindings.nameSink-in-0=sinkinput
```

然后我们构建一个处理器
```java
@Bean
public Function<String, Person> processName() {
  return name -> new Person(name, new Date().getTime());
}
```
此函数将 String 值作为输入，并创建一个新的 Person 记录，该记录添加处理数据时的时间戳。运行此应用程序会在 RabbitMQ 中创建两个新的交换：和 。与我们应用于 sink 应用程序的配置类似，我们希望更改这些 exchange 名称，以便它们可以挂接到 sink 中，并很快挂接到供应商
```java
spring.cloud.stream.function.bindings.processName-in-0=processorinput 
spring.cloud.stream.function.bindings.processName-out-0=sinkinput
```

源应用程序
```java
@Bean
public Supplier<String> supplyName() {
  return () -> "Christopher Pike";
}
```
与我们将处理器输出连接到接收器输入的方式类似，我们必须执行相同的操作并将源输出连接到处理器输入
```java
spring.cloud.stream.function.bindings.supplyName-out-0=processorinput
```