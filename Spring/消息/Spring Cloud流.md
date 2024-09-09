### 什么是 Spring Cloud Stream？

用于构建事件驱动型 Spring Boot 微服务以进行实时流处理的框架。您可以从 [project-site](https://spring.io/projects/spring-cloud-stream)、[documentation](https://spring.io/projects/spring-cloud-stream#learn) 和 [samples](https://github.com/spring-cloud/spring-cloud-stream-samples) 中了解有关该框架的更多信息。

- name-source：定期发布 String 以启动流。在此示例中，将名称发布为 String。
- name-processor：使用 name-source 发布的 String 并以某种方式转换数据。将结果发布到其他交易所。在此示例中，使用名称 String 创建记录并添加时间戳。
- name-sink：使用 name-processor 的结果并执行操作。在这种情况下，将结果打印到 standard out。