```java
/**
 * Indicates a {@link Configuration configuration} class that declares one or more
 * {@link Bean @Bean} methods and also triggers {@link EnableAutoConfiguration
 * auto-configuration} and {@link ComponentScan component scanning}. This is a convenience
 * annotation that is equivalent to declaring {@code @Configuration},
 * {@code @EnableAutoConfiguration} and {@code @ComponentScan}.
 *
 * @author Phillip Webb
 * @author Stephane Nicoll
 * @since 1.2.0
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = {
        @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
        @Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
 
    /**
     * Exclude specific auto-configuration classes such that they will never be applied.
     * @return the classes to exclude
     */
    @AliasFor(annotation = EnableAutoConfiguration.class, attribute = "exclude")
    Class<?>[] exclude() default {};
 
    /**
     * Exclude specific auto-configuration class names such that they will never be
     * applied.
     * @return the class names to exclude
     * @since 1.3.0
     */
    @AliasFor(annotation = EnableAutoConfiguration.class, attribute = "excludeName")
    String[] excludeName() default {};
 
    /**
     * Base packages to scan for annotated components. Use {@link #scanBasePackageClasses}
     * for a type-safe alternative to String-based package names.
     * @return base packages to scan
     * @since 1.3.0
     */
    @AliasFor(annotation = ComponentScan.class, attribute = "basePackages")
    String[] scanBasePackages() default {};
 
    /**
     * Type-safe alternative to {@link #scanBasePackages} for specifying the packages to
     * scan for annotated components. The package of each class specified will be scanned.
     * <p>
     * Consider creating a special no-op marker class or interface in each package that
     * serves no purpose other than being referenced by this attribute.
     * @return base packages to scan
     * @since 1.3.0
     */
    @AliasFor(annotation = ComponentScan.class, attribute = "basePackageClasses")
    Class<?>[] scanBasePackageClasses() default {};
 
}
```
可以看到，除了最基础的注解外，还增加了三个 `@SpringBootConfiguration`、`@EnableAutoConfiguration`、`@ComponentScan`

@SpringBootConfiguration
一个非常普通的Configuration
```java
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.context.annotation.Configuration;
 
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Configuration
public @interface SpringBootConfiguration {
}
```

@EnableAutoConfiguration
这个注解尤为重要，它的作用是自动将 JavaConfig 中的 Bean 装载到 IoC 容器中

@ComponentScan
这个注解的作用是自动扫描并加载符合条件的组件（如：Component、Bean 等），我们可以通过 basePakcages 来指定其扫描的范围，如果不指定，则默认从标注了 `@ComponentScan` 注解的类所在包开始扫描

我们知道，启动类先调用了 SpringApplication 的静态方法 run，跟踪进去后发现，它会先实例化 SpringApplication，然后调用 run 方法。
```java
/**
     * Static helper that can be used to run a {@link SpringApplication} from the
     * specified sources using default settings and user supplied arguments.
     * @param sources the sources to load
     * @param args the application arguments (usually passed from a Java main method)
     * @return the running {@link ApplicationContext}
     */
    public static ConfigurableApplicationContext run(Object[] sources, String[] args) {
        return new SpringApplication(sources).run(args);
    }
```
所以，要分析它的启动源码，首先要分析 SpringApplicaiton 的构造过程

SpringApplication 构造器
在 SpringApplication 构造函数内部，它会调用内部的一个定义为 private 的方法 initialize
```java
public SpringApplication(Object... sources) {
    initialize(sources);
}
 
private void initialize(Object[] sources) {
        if (sources != null && sources.length > 0) {
            this.sources.addAll(Arrays.asList(sources));
        }
        this.webEnvironment = deduceWebEnvironment();
        setInitializers((Collection) getSpringFactoriesInstances(
                ApplicationContextInitializer.class));
        setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
        this.mainApplicationClass = deduceMainApplicationClass();
    }
```

通过上述代码，我们分析到 SpringApplication 实例化时有以下几个步骤：

1.将所有 sources 加入到全局 sources 中，目前只有一个 Application。

2.判断是否为 Web 程序（javax.servlet.Servlet、org.springframework.web.context.ConfigurableWebApplicationContext 这两个类必须存在于类加载器中）。
```java
private static final String[] WEB_ENVIRONMENT_CLASSES = new String[]{"javax.servlet.Servlet", "org.springframework.web.context.ConfigurableWebApplicationContext"};
private boolean deduceWebEnvironment() {
        for (String className : WEB_ENVIRONMENT_CLASSES) {
            if (!ClassUtils.isPresent(className, null)) {
                return false;
            }
        }
        return true;
    }
```

3.设置应用程序初始化器 ApplicationContextInitializer，做一些初始化的工作。

4.设置应用程序事件监听器 ApplicationListener。

5.找出启动类，设置到 mainApplicationClass 中。

在构造完这个类后，还会执行run方法
```java
public ConfigurableApplicationContext run(String... args) {
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        ConfigurableApplicationContext context = null;
        FailureAnalyzers analyzers = null;
        configureHeadlessProperty();
        SpringApplicationRunListeners listeners = getRunListeners(args);
        listeners.starting();
        try {
            ApplicationArguments applicationArguments = new DefaultApplicationArguments(
                    args);
            ConfigurableEnvironment environment = prepareEnvironment(listeners,
                    applicationArguments);
            Banner printedBanner = printBanner(environment);
            context = createApplicationContext();
            analyzers = new FailureAnalyzers(context);
            prepareContext(context, environment, listeners, applicationArguments,
                    printedBanner);
            refreshContext(context);
            afterRefresh(context, applicationArguments);
            listeners.finished(context, null);
            stopWatch.stop();
            if (this.logStartupInfo) {
                new StartupInfoLogger(this.mainApplicationClass)
                        .logStarted(getApplicationLog(), stopWatch);
            }
            return context;
        }
        catch (Throwable ex) {
            handleRunFailure(context, listeners, analyzers, ex);
            throw new IllegalStateException(ex);
        }
    }
```

- 初始化 StopWatch，调用其 start 方法开始计时。
- 调用 configureHeadlessProperty 设置系统属性 java.awt.headless，这里设置为 true，表示运行在服务器端，在没有显示器和鼠标键盘的模式下工作，模拟输入输出设备功能。
 - 遍历 SpringApplicationRunListeners 并调用 starting 方法。
- 创建一个 DefaultApplicationArguments 对象，它持有 args 参数，就是 main 函数传进来的参数调用 prepareEnvironment 方法。
- 打印 banner。
- 创建 Spring Boot 上下文。
- 初始化 FailureAnalyzers。
- 调用 prepareContext。
- 调用 AbstractApplicationContext 的 refresh 方法，并注册钩子。
- 在容器完成刷新后，依次调用注册的 Runners。
- 调用 SpringApplicationRunListeners 的 finished 方法。
- 启动完成并停止计时。
- 初始化过程中出现异常时调用 handleRunFailure 进行处理，然后抛出 IllegalStateException 异常。
