Web Service 的三个要素分别是：

1. SOAP（Simple Object Access Protoco） 简单对象访问协议；
    
2. WSDL（Web Services Description Language） 网络服务描述语言；
    
3. UDDI（Universal Description Discovery and Integration）一个用来发布和搜索 WEB 服务的协议（非必须）

SOAP 用来描述传递信息的格式规范， WSDL 用来描述如何访问具体的接口（比如它会告诉你该服务有哪些接口可以使用，参数是什么等等）， UDDI 用来管理、分发和查询 Web Service。下面我们将逐一详细介绍这三个要素，并通过结合实例来进行阐释

**SOAP**
它是一个协议，可以简单的理解为：它定义了一个基于 XML 的可扩展消息信封格式。因为客户端与服务器进行交互，由于大家的平台和应用程序都不一样，所以大家约定都采用 SOAP 这个协议来规范交互时的需要传递的消息

请求接口时，发送的消息例子
```java
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <qqCheckOnline xmlns="http://WebXml.com.cn/">
            <qqCode>8698053</qqCode>
        </qqCheckOnline>
    </soap:Body>
</soap:Envelope>
```

接口响应时，返回的消息例子
```java
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <qqCheckOnlineResponse xmlns="http://WebXml.com.cn/">
            <qqCheckOnlineResult>Y</qqCheckOnlineResult>
        </qqCheckOnlineResponse>
    </soap:Body>
</soap:Envelope>
```

下面，我们解析这些XML形式的信息

XML声明
该行是 XML 声明。它定义 XML 的版本 (1.0) 和所使用的编码（utf-8）
```java
<?xml version="1.0" encoding="utf-8"?>
```

Envelop元素
```java
<soap:Envelope
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    ....
</soap:Envelope>
```
`Envelope` 元素是 SOAP 消息的固定根元素，SOAP 协议规定的，不能变，其中 `xmlns` 是 XML Namespace 的缩写，表示 XML 命名空间。`xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"` 是 `Envelope`的一个属性，它表示定义个以 `soap` 为前缀的命名空间 `http://schemas.xmlsoap.org/soap/envelope/`，即命名空间的名字是：`http://schemas.xmlsoap.org/soap/envelope/`，而它的前缀是 `soap`，这样子就把 `soap` 前缀与该命名空间进行了绑定。即任何用 `soap` 为前缀的元素都属于该命名空间的，包括根元素 `Envelope`

Body元素
```java
<soap:Body>
    <qqCheckOnline xmlns="http://WebXml.com.cn/">
        <qqCode>8698053</qqCode>
    </qqCheckOnline>
</soap:Body>
```
`Body` 元素里面，一般都是放一些请求和响应的内容。`qqCheckOnline` 表示要调用的接口方法，而 `qqCode` 就是调用该方法时，传入的参数，当然参数可以有多个
