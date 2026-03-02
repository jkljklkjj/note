#RabbitMQ
RabbitMQ相对于其它的消息队列，有非常多的路由

#### HelloWorld模式
![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2fe427aa437e49fd9020630160301ced~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
没有交换机，只有一个队列和一个消费者

#### work模式
![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8360dc1ef4b543f1aed13059c82f99b6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
没有交换机，只有一个队列，有多个消费者
多个消费者共同工作，按照负载均衡策略接收队列里的信息

- **🚗轮询分发**：一个消费者消费一条，**按均分配**，woek模式下默认是采用轮询分发方式。轮询分发就不写代码演示了，比较简单，比如生产费者发送了6条消息到队列中，如果有3个消费者同时监听着这一个队列，那么这3个消费者每人就会分得2条消息。下面主要介绍公平分发。
    
- **✈公平分发**：根据消费者的消费能力进行公平分发，处理得快的分得多，处理的慢的分得少，**能者多劳**。

用于实现负载均衡，大幅提高消费者的消费能力

#### publish/subscribe发布订阅模式
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0242c264be847aeaa09e5aaf871cfae~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
有一个交换机和多个队列。每次发送消息所有队列都能收到

如在一个用户注册服务中，用户提交注册信息后，将信息发送到RabbitMQ中，由短信服务和邮件服务分别中队列中获取用户信息，完成用户注册后的短信和邮件发送

#### routing路由模式
![](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff661525a4fd4cec95f6d53d99d80479~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

消息首先发给交换机，然后交换机根据routingKey发送给特定的队列

#### topic主题模式
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f8106cf5c29744cdabfbaf68f06268f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
消息首先发给交换机，然后交换机将消息同时发送给符合匹配规则的所有队列

#### RPC模式
![](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f391b77eaff44c4c9ca903bf8fc71324~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
调用方和服务提供方都绑定一个队列，和普通的rpc的区别是网络需要通过队列中转