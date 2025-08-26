SPI简单来讲，就是一个插件机制
我们定义了一个接口，那么就能通过spi，传入对应名称，就能轻松选择需要的实现类

先定义一个SPI注解，用于标注对应的接口
```java
@Documented  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.TYPE)  
public @interface SPI {  
    String value() default "";  
}
```

然后定义一个SPIClass注解，标注对应的实现类
```java
@Documented  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.TYPE)  
public @interface SPIClass {  
}
```

然后使用SPI注解到一个接口
里面写一下接口的默认实现类的SPI名称
```java
/**  
 * 负载均衡策略接口  
 * @param <T>  
 */  
@SPI(RpcConstants.SERVICE_LOAD_BALANCER_RANDOM)  
public interface ServiceLoadBalancer<T> {  
    /**  
     * 以负载均衡方式选取一个服务提供者  
     * @param servers 服务提供者列表  
     * @param hashCode Hash值  
     * @return 选取的服务节点  
     */  
    T select (List<T> servers, int hashCode);  
}
```

然后实现类实现这个接口，使用SPIClass注解
```java
/**  
 * 基于随机算法的负载均衡策略  
 * @param <T>  
 */  
@SPIClass  
public class RandomServiceLoadBalancer<T> implements ServiceLoadBalancer<T> {  
    private final Logger logger = LoggerFactory.getLogger(RandomServiceLoadBalancer.class);  
  
    @Override  
    public T select(List<T> servers, int hashCode){  
        logger.info("基于随机算法的负载均衡策略");  
        if(servers==null || servers.isEmpty()){  
            return null;  
        }  
        Random random = new Random();  
        int index = random.nextInt(servers.size());  
        return servers.get(index);  
    }  
}
```

然后，在实现类对应的resources文件夹，创建META-INF/任意名称/internal 文件夹
这个文件夹用来存放对应的接口SPI文件

这个文件的名称为接口的引用地址（接口所在包+接口名）
比如说我们平时引入一个接口，会使用import接口的引用地址
```java
import io.binghe.rpc.loadbalancer.api.ServiceLoadBalancer
```
那么，SPI文件的名称就为`io.binghe.rpc.loadbalancer.api.ServiceLoadBalancer`

值得注意的是，如果接口和实现类在不同模块，那需要在接口模块依赖实现类
也就是接口能import实现类的时候，SPI才有效果

然后，文件里面存放的信息为`SPI名称=实现类引用地址`
```
random=io.binghe.rpc.loadbalancer.random.RandomServiceLoadBalancer
```

之后，就能通过ExtensionLoader的对应方法来获取接口实现类
```java
/**  
 * 直接获取想要的类实例  
 * @param clazz 接口的Class实例  
 * @param name SPI名称  
 * @param <T> 泛型类型  
 * @return 泛型实例  
 */  
public static <T> T getExtension(final Class<T> clazz, String name){  
    return StringUtils.isEmpty(name) ? getExtensionLoader(clazz).getDefaultSpiClassInstance() : getExtensionLoader(clazz).getSpiClassInstance(name);  
}
```

```java
ServiceLoadBalancer serviceLoadBalancer = ExtensionLoader.getExtension(ServiceLoadBalancer.class, "random")
```

这里的`serviceLoadBalancer`即为`RandomServiceLoadBalancer`，也就是实现类

通过SPI，我们能进一步把工厂设计模式进行松耦合
```java
public static ServiceLoadBalancer<T> getInterfaceImpl(String name){
	// name对应SPI名称
	swicth(name){
		case "random":
			return new RandomServiceLoadBalancer<T>();
		case "other":
			return new OtherServiceLoadBalancer<T>();
	}
	// 默认实现类
	return RandomServiceLoadBalancer<T>();
}
```