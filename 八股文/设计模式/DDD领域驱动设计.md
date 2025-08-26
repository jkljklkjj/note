https://blog.csdn.net/bookssea/article/details/127248954
最好的面向对象方法
DDD 不是架构，而是一种架构设计方法论，它通过边界划分将复杂业务领域简单化，帮我们设计出清晰的领域和应用边界，可以很容易地实现架构演进。

#### 基础概念
##### 领域
领域就是用来确定范围的，范围即边界，这也是 DDD 在设计中不断强调边界的原因。简言之，DDD 的领域就是这个边界内要解决的业务问题域。

领域可以进一步划分为**子领域**。我们把划分出来的多个子领域称为子域，每个子域对应一个更小的问题域或更小的业务范围。领域可以拆分为多个子领域。一个领域相当于一个问题域，领域拆分为子域的过程就是大问题拆分为小问题的过程。

在领域不断划分的过程中，领域会细分为不同的子域，子域可以根据自身重要性和功能属性划分为三类子域，它们分别是：核心域、通用域和支撑域。

决定产品和公司核心竞争力的子域是**核心域**，它是业务成功的主要因素和公司的核心竞争力。没有太多个性化的诉求，同时被多个子域使用的通用功能子域是**通用域**。还有一种功能子域是必需的，但既不包含决定产品和公司核心竞争力的功能，也不包含通用功能的子域，它就是**支撑域**。

这三类子域相较之下，核心域是最重要的，我们下面讲目的的时候还会以核心域为例详细介绍。通用域和支撑域如果对应到企业系统，举例来说的话，通用域则是你需要用到的通用系统，比如认证、权限等等，这类应用很容易买到，没有企业特点限制，不需要做太多的定制化。而支撑域则具有企业特性，但不具有通用性，例如数据代码类的数据字典等系统。

**聚合根与领域服务**负责封装实现业务逻辑。领域服务负责对聚合根进行调度和封装，同时可以对外提供各种形式的服务，对于不能直接通过聚合根完成的业务操作就需要通过领域服务。例如支付这个步骤，订单聚合不可能支付，所以在订单聚合上架一层领域服务也就是订单服务，在领域服务中实现支付逻辑，然后应用服务调用领域服务。

1. 同限界上下文内的聚合之间的领域服务可直接调用
2. 两个限界上下文的交互必须通过应用服务层抽离接口->适配层适配。

例子，用户升职，上级领导要变，上级领导的下属要变
如果是普通的实现，我们都会在用户服务里修改员工的领导，在领导服务里增加下属
通过适配层，我们直接把两个方法聚合到了一个方法中
```java
/**
 * @Author WDYin
 * @Date 2022/5/15
 **/
@Service
public class UserDomainServiceImpl implements UserDomainService {

    @Override
    public void promote(User user, User leader) {

        //保存领导
        user.saveLeader(leader);

        //领导增加下属
        leader.increaseSubordination(user);
    }
}
```

##### 限界上下文
我们可以将限界上下文拆解为两个词：限界和上下文。限界就是**领域的边界**，而上下文则是**语义环境**。通过领域的限界上下文，我们就可以在统一的领域边界内用统一的语言进行交流，简单来说限界上下文可以理解为语义环境。

综合一下，我认为限界上下文的定义就是：用来封装通用语言和领域对象，提供上下文环境，保证在领域之内的一些术语、业务相关对象等（通用语言）有一个确切的含义，没有二义性。这个边界定义了模型的适用范围，使团队所有成员能够明确地知道什么应该在模型中实现，什么不应该在模型中实现。

在一个明媚的早晨，孩子起床问妈妈：“今天应该穿几件衣服呀？”妈妈回答：“穿多少衣服就穿多少！”那到底是穿多还是穿少呢？

如果没有具体的语义环境，还真不太好理解。但是，**如果你已经知道了这句话的语义环境，比如是寒冬腊月或者是炎炎夏日，那理解这句话的涵义就会很容易了**。

而业务的通用语言就有它的业务边界，我们不大可能用一个简单的术语没有歧义地去描述一个复杂的业务领域。限界上下文就是用来细分领域，从而定义通用语言所在的边界。

正如电商领域的商品一样，商品在不同的阶段有不同的术语，在销售阶段是商品，而在运输阶段则变成了货物。**同样的一个东西，由于业务领域的不同，赋予了这些术语不同的涵义和职责边界，这个边界就可能会成为未来微服务设计的边界。看到这，我想你应该非常清楚了，领域边界就是通过限界上下文来定义的。**

理论上限界上下文就是微服务的边界。我们将限界上下文内的领域模型映射到微服务，就完成了从问题域到软件的解决方案。

可以说，**限界上下文是微服务设计和拆分的主要依据**。在领域模型中，如果不考虑技术异构、团队沟通等其它外部因素，一个限界上下文理论上就可以设计为一个微服务。

##### 贫血模型和充血模型

贫血模型具有一堆属性和set get方法，存在的问题就是通过pojo这个对象上看不出业务有哪些逻辑，一个pojo可能被多个模块调用，只能去上层各种各样的service来调用，这样以后当梳理这个实体有什么业务，只能一层一层去搜service，也就是贫血失忆症，不够面向对象。

充血模型比如如下user用户有改密码，改手机号，修改登录失败次数等操作，都**内聚在这个user实体中，每个实体的业务都是清晰的**，就是充血模型，充血模型的内存计算会多一些，内聚核心业务逻辑处理。

说白了就是，不只是有贫血模型中setter getter方法，还有其他的一些业务方法，这才是面向对象的本质，通过user实体就能看出有哪些业务存在。
```java
@NoArgsConstructor
@Getter
public class User extends Aggregate<Long, User> {

    /**
     * 用户名
     */
    private String userName;

    /**
     * 姓名
     */
    private String realName;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 密码
     */
    private String password;

    /**
     * 锁定结束时间
     */
    private Date lockEndTime;

    /**
     * 登录失败次数
     */
    private Integer failNumber;

    /**
     * 用户角色
     */
    private List<Role> roles;

    /**
     * 部门
     */
    private Department department;

    /**
     * 用户状态
     */
    private UserStatus userStatus;

    /**
     * 用户地址
     */
    private Address address;

    public User(String userName, String phone, String password) {
        saveUserName(userName);
        savePhone(phone);
        savePassword(password);
    }

    /**
     * 保存用户名
     * @param userName
     */
    private void saveUserName(String userName) {
        if (StringUtils.isBlank(userName)){
            Assert.throwException("用户名不能为空！");
        }

        this.userName = userName;
    }

    /**
     * 保存电话
     * @param phone
     */
    private void savePhone(String phone) {
        if (StringUtils.isBlank(phone)){
            Assert.throwException("电话不能为空！");
        }

        this.phone = phone;
    }

    /**
     * 保存密码
     * @param password
     */
    private void savePassword(String password) {
        if (StringUtils.isBlank(password)){
            Assert.throwException("密码不能为空！");
        }

        this.password = password;
    }

    /**
     * 保存用户地址
     * @param province
     * @param city
     * @param region
     */
    public void saveAddress(String province,String city,String region){
        this.address = new Address(province,city,region);
    }

    /**
     * 保存用户角色
     * @param roleList
     */
    public void saveRole(List<Role> roleList) {

        if (CollectionUtils.isEmpty(roles)){
            Assert.throwException("角色不能为空！");
        }

        this.roles = roleList;
    }
}
```

##### 实体和值对象
实体和值对象这两个概念都是领域模型中的领域对象。实体和值对象是组成领域模型的基础单元。

**实体**
在代码模型中，实体的表现形式是实体类，这个类包含了实体的属性和方法，通过这些方法实现实体自身的业务逻辑。在 DDD 里，这些实体类通常采用充血模型，与这个实体相关的所有业务逻辑都在实体类的方法中实现，跨多个实体的领域逻辑则在领域服务中实现。

实体以 DO（领域对象）的形式存在，每个实体对象都有唯一的 ID。比如商品是商品上下文的一个实体，通过唯一的商品 ID 来标识，**不管这个商品的数据如何变化，商品的 ID 一直保持不变**，它始终是同一个商品。

在某些场景中，有些实体只是暂驻静态内存的一个运行态 实体，它不需要持久化。比如，基于多个价格配置数据计算后生成的折扣实体。

而在有些复杂场景下，实体与持久化对象则可能是一对多或者多对一的关系。比如，用户 user 与角色 role 两个持久化对象可生成权限实体，一个实体对应两个持久化对象，这是一对多的场景。再比如，有些场景为了避免数据库的联表查询，提升系统性能，会将客户信息 customer 和账户信息 account 两类数据保存到同一张数据库表中，客户和账户两个实体可根据需要从一个持久化对象中生成，这就是多对一的场景。
```java
@NoArgsConstructor
@Getter
public class User extends Aggregate<Long, User> {

    /**
     * 用户id-聚合根唯一标识
     */
    private UserId userId;

    /**
     * 用户名
     */
    private String userName;

    /**
     * 姓名
     */
    private String realName;

    /**
     * 手机号
     */
    private String phone;

    /**
     * 密码
     */
    private String password;

    /**
     * 锁定结束时间
     */
    private Date lockEndTime;

    /**
     * 登录失败次数
     */
    private Integer failNumber;

    /**
     * 用户角色
     */
    private List<Role> roles;

    /**
     * 部门
     */
    private Department department;

    /**
     * 领导
     */
    private User leader;

    /**
     * 下属
     */
    private List<User> subordinationList = new ArrayList<>();

    /**
     * 用户状态
     */
    private UserStatus userStatus;

    /**
     * 用户地址
     */
    private Address address;

    public User(String userName, String phone, String password) {

        saveUserName(userName);
        savePhone(phone);
        savePassword(password);
    }

    /**
     * 保存用户名
     * @param userName
     */
    private void saveUserName(String userName) {
        if (StringUtils.isBlank(userName)){
            Assert.throwException("用户名不能为空！");
        }

        this.userName = userName;
    }

    /**
     * 保存电话
     * @param phone
     */
    private void savePhone(String phone) {
        if (StringUtils.isBlank(phone)){
            Assert.throwException("电话不能为空！");
        }

        this.phone = phone;
    }

    /**
     * 保存密码
     * @param password
     */
    private void savePassword(String password) {
        if (StringUtils.isBlank(password)){
            Assert.throwException("密码不能为空！");
        }

        this.password = password;
    }

    /**
     * 保存用户地址
     * @param province
     * @param city
     * @param region
     */
    public void saveAddress(String province,String city,String region){
        this.address = new Address(province,city,region);
    }

    /**
     * 保存用户角色
     * @param roleList
     */
    public void saveRole(List<Role> roleList) {

        if (CollectionUtils.isEmpty(roles)){
            Assert.throwException("角色不能为空！");
        }

        this.roles = roleList;
    }

    /**
     * 保存领导
     * @param leader
     */
    public void saveLeader(User leader) {
        if (Objects.isNull(leader)){
            Assert.throwException("leader不能为空！");
        }
        this.leader = leader;
    }

    /**
     * 增加下属
     * @param user
     */
    public void increaseSubordination(User user) {

        if (null == user){
            Assert.throwException("leader不能为空！");
        }

        this.subordinationList.add(user);
    }
}
```

**值**
简单来说，值对象本质上就是一个集。那这个集合里面有什么呢？若干个用于描述目的、具有整体概念和不可修改的属性。那这个集合存在的意义又是什么？在领域建模的过程中，值对象可以保证属性归类的清晰和概念的完整性，避免属性零碎。
```java
/**
 * 地址数据
 */
@Getter
public class Address extends ValueObject {
    /**
     * 省
     */
    private String province;

    /**
     * 市
     */
    private String city;

    /**
     * 区
     */
    private String region;

    public Address(String province, String city, String region) {
        if (StringUtils.isBlank(province)){
            Assert.throwException("province不能为空！");
        }
        if (StringUtils.isBlank(city)){
            Assert.throwException("city不能为空！");
        }
        if (StringUtils.isBlank(region)){
            Assert.throwException("region不能为空！");

        }
        this.province = province;
        this.city = city;
        this.region = region;
    }
}
```

![](https://i-blog.csdnimg.cn/blog_migrate/bc0b88768520e87baaf2e61941d97f82.png)

在领域建模时，我们可以将部分对象设计为值对象，保留对象的业务涵义，同时又减少了实体的数量；在数据建模时，我们可以将值对象嵌入实体，减少实体表的数量，简化数据库设计。

同样的对象在不同的场景下，可能会设计出不同的结果。有些场景中，地址会被某一实体引用，它只承担描述实体的作用，并且它的值只能整体替换，这时候你就可以将地址设计为值对象，比如收货地址。而在某些业务场景中，地址会被经常修改，地址是作为一个独立对象存在的，这时候它应该设计为实体，比如行政区划中的地址信息维护。

##### 聚合
实体和值对象是很基础的领域对象。实体一般对应业务对象，它具有业务属性和业务行为；而值对象主要是属性集合，对实体的状态和特征进行描述。但实体和值对象都只是个体化的对象，它们的行为表现出来的是**个体的能力**。
![](https://i-blog.csdnimg.cn/blog_migrate/ba4b1b156e6b94045b7f9512259cf5c5.png)

聚合就是由业务和逻辑紧密关联的实体和值对象组合而成的，聚合是数据修改和持久化的基本单元，每一个聚合对应一个仓储，实现数据的持久化。

聚合在 DDD 分层架构里属于领域层，领域层包含了多个聚合，共同实现核心业务逻辑。

**聚合根**
如果把聚合比作组织，那聚合根就是这个组织的负责人。聚合根也称为根实体，它不仅是实体，还是聚合的管理者。

首先它作为实体本身，拥有实体的属性和业务行为，实现自身的业务逻辑。
其次它作为聚合的管理者，在聚合内部负责协调实体和值对象按照固定的业务规则协同完成共同的业务逻辑。
最后在聚合之间，它还是聚合对外的接口人，以聚合根 ID 关联的方式接受外部任务和请求，在上下文内实现聚合之间的业务协同。也就是说，聚合之间通过聚合根 ID 关联引用，如果需要访问其它聚合的实体，就要先访问聚合根，再导航到聚合内部实体，外部对象不能直接访问聚合内实体。

![](https://i-blog.csdnimg.cn/blog_migrate/39452da8026ec5f8f0f4667c12621d92.png)
![](https://i-blog.csdnimg.cn/blog_migrate/413da9f5f10e1395607be3bf06e7f798.png)

##### 领域事件
举例来说的话，领域事件可以是业务流程的一个步骤，比如投保业务缴费完成后，触发投保单转保单的动作；也可能是定时批处理过程中发生的事件，比如批处理生成季缴保费通知单，触发发送缴费邮件通知操作；或者一个事件发生后触发的后续动作，比如密码连续输错三次，触发锁定账户的动作。

在做用户旅程或者场景分析时，我们要捕捉业务、需求人员或领域专家口中的关键词：“如果发生……，则……”“当做完……的时候，请通知……”“发生……时，则……”等。在这些场景中，如果发生某种事件后，会触发进一步的操作，那么这个事件很可能就是领域事件。

领域事件相关案例
一个保单的生成，经历了很多子域、业务状态变更和跨微服务业务数据的传递。这个过程会产生很多的领域事件，这些领域事件促成了保险业务数据、对象在不同的微服务和子域之间的流转和角色转换。在下面这张图中，我列出了几个关键流程，用来说明如何用领域事件驱动设计来驱动承保业务流程。
![](https://i-blog.csdnimg.cn/blog_migrate/b9069b8877a7b3eeac67316ba5ba904b.png)
![](https://i-blog.csdnimg.cn/blog_migrate/7c489e6282e3065a3d6eb34afadfd63a.png)

一个完整的领域事件 = 事件发布 + 事件存储 + 事件分发 + 事件处理。

事件发布：构建一个事件，需要唯一标识，然后发布；
事件存储：发布事件前需要存储，因为接收后的事件也会存储，可用于重试或对账等；就是每次执行一次具体的操作时，把行为记录下来，执行持久化。
事件分发：服务内的应用服务或者领域服务直接发布给订阅者，服务外需要借助消息中间件，比如Kafka，RabbitMQ等，支持同步或者异步。
事件处理：先将事件存储，然后再处理。
当然了，实际开发中事件存储和事件处理不是必须的。

```java
/**
 * 用户注册事件
 * @Author WDYin
 **/
public class UserRegisterEvent extends ApplicationEvent {
    
    public UserRegisterEvent(Object source) {
        super(source);
    }
}


/**
 * 用户监听事件
 * @Author WDYin
 **/
@Component
public class UserListener {

    @EventListener(UserRegisterEvent.class)
    public void userRegister(UserRegisterEvent event) {
        User user = (User) event.getSource();
        System.out.println("用户注册。。。发送短信。。。" + user);
        System.out.println("用户注册。。。发送邮件。。。" + user);
    }

    @EventListener(UserCancelEvent.class)
    public void userCancelEvent(UserCancelEvent event) {
        User user = (User) event.getSource();
        System.out.println("用户注销。。。" + user);
    }
    
}

/**
 * 发布用户注册事件
 * @Author : WDYin
 */
@RunWith(value = SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = DemoApplication.class)
public class MyClient {

    @Autowired
    private ApplicationContext applicationContext;

    @Test
    public void test() {
        User user = new User();
        //发布事件
        applicationContext.publishEvent(new UserRegisterEvent(user));
    }
}
```

##### 事件风暴
![](https://i-blog.csdnimg.cn/blog_migrate/52fbb1018218f845d5f1dc9230acf050.png)

#### DDD分层
![](https://i-blog.csdnimg.cn/blog_migrate/bb361d5a0a71a71ce8da7df1c183dce6.png)

