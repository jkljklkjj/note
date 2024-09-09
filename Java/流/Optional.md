Optional<\T>返回的是基本类型T的包装器对象
实现了基本类型转换成对象的操作

**获取Optinal值**
也可以设定它的默认值
```java
String result = optionalString.orElse("");
```
或者在没有值的时候抛出异常
```java
String result = optionalString.orElseThrow(IllegalStateException::new);
```

**使用Optional值**
如果Optional存在就处理
```java
optionalValue.ifPresent(v -> Process v);
```

**管道化Optional值**
可以用管道化来解包处理Optional值
```java
Optional<String> transformed = optionalString.map(String::toUpperCase);
```

