

1. Spring框架管理这些Bean的创建工作，即由用户管理Bean转变为框架管理Bean，这个就叫**控制反转 - Inversion of Control (IoC)**
2. Spring 框架托管创建的Bean放在哪里呢？ 这便是**IoC Container**;
3. Spring 框架为了更好让用户配置Bean，必然会引入**不同方式来配置Bean？ 这便是xml配置，Java配置，注解配置**等支持
4. Spring 框架既然接管了Bean的生成，必然需要**管理整个Bean的生命周期**等；
5. 应用程序代码从Ioc Container中获取依赖的Bean，注入到应用程序中，这个过程叫 **依赖注入(Dependency Injection，DI)** ； 所以说控制反转是通过依赖注入实现的，其实它们是同一个概念的不同角度描述。通俗来说就是**IoC是设计思想，DI是实现方式**
6. 在依赖注入时，有哪些方式呢？这就是构造器方式，@Autowired, @Resource, @Qualifier... 同时Bean之间存在依赖（可能存在先后顺序问题，以及**循环依赖问题**等）



Spring里面的bean就类似是定义的一个组件，而这个组件的作用就是实现某个功能的，这里所定义的bean就相当于给了你一个更为简便的方法来调用这个组件去实现你要完成的功能。

### 

ioc

即“控制反转”，**不是什么技术，而是一种设计思想**

著作权归https://pdai.tech所有。 链接：https://pdai.tech/md/spring/spring-x-framework-ioc.html

- **谁控制谁，控制什么**？

传统Java SE程序设计，我们直接在对象内部通过new进行创建对象，是程序主动去创建依赖对象；而IoC是有专门一个容器来创建这些对象，即由Ioc容器来控制对 象的创建；谁控制谁？当然是IoC 容器控制了对象；控制什么？那就是主要控制了外部资源获取（不只是对象包括比如文件等）。

- **为何是反转，哪些方面反转了**?

有反转就有正转，传统应用程序是由我们自己在对象中主动控制去直接获取依赖对象，也就是正转；而反转则是由容器来帮忙创建及注入依赖对象；为何是反转？因为由容器帮我们查找及注入依赖对象，对象只是被动的接受依赖对象，所以是反转；哪些方面反转了？依赖对象的获取被反转了



有了IoC容器后，**把创建和查找依赖对象的控制权交给了容器，由容器进行注入组合对象，所以对象与对象之间是 松散耦合，这样也方便测试，利于功能复用，更重要的是使得程序的整个体系结构变得非常灵活**。



**IoC是设计思想，DI是实现方式**。



## Ioc 配置的三种方式

### xml 配置

### Java 配置

### 注解配置



## 依赖注入的三种方式

### setter方式

###  构造函数

### 注解注入



### 我在使用构造器注入方式时注入了太多的类导致Bad Smell怎么办？

比如当你一个Controller中注入了太多的Service类，Sonar会给你提示相关告警



@Autowired和@Resource以及@Inject等注解注入有何区别？



@Autowired是Spring自带的注解，通过AutowiredAnnotationBeanPostProcessor 类实现的依赖注入

2、@Autowired可以作用在CONSTRUCTOR、METHOD、PARAMETER、FIELD、ANNOTATION_TYPE

3、@Autowired默认是根据类型（byType ）进行自动装配的

4、如果有多个类型一样的Bean候选者，需要指定按照名称（byName ）进行装配，则需要配合@Qualifier。

指定名称后，如果Spring IOC容器中没有对应的组件bean抛出NoSuchBeanDefinitionException。也可以将@Autowired中required配置为false，如果配置为false之后，当没有找到相应bean的时候，系统不会抛异常



@Resource是JSR250规范的实现，在javax.annotation包下

2、@Resource可以作用TYPE、FIELD、METHOD上

3、@Resource是默认根据属性名称进行自动装配的，如果有多个类型一样的Bean候选者，则可以通过name进行指定进行注入





1、@Inject是JSR330 (Dependency Injection for Java)中的规范，需要导入javax.inject.Inject jar包 ，才能实现注入

2、@Inject可以作用CONSTRUCTOR、METHOD、FIELD上

3、@Inject是根据类型进行自动装配的，如果需要按名称进行装配，则需要配合@Named；





1、@Autowired是Spring自带的，@Resource是JSR250规范实现的，@Inject是JSR330规范实现的

2、@Autowired、@Inject用法基本一样，不同的是@Inject没有required属性

3、@Autowired、@Inject是默认按照类型匹配的，@Resource是按照名称匹配的

4、@Autowired如果需要按照名称匹配需要和@Qualifier一起使用，@Inject和@Named一起使用，@Resource则通过name进行指定



## 体系结构

- **BeanFactory： 工厂模式定义了IOC容器的基本功能规范**
- **BeanRegistry： 向IOC容器手工注册 BeanDefinition 对象的方法**



**BeanFactory作为最顶层的一个接口类，它定义了IOC容器的基本功能规范**，BeanFactory 有三个子类：ListableBeanFactory、HierarchicalBeanFactory 和AutowireCapableBeanFactory。

#### BeanFactory为何要定义这么多层次的接口？定义了哪些接口？

主要是为了**区分在 Spring 内部在操作过程中对象的传递和转化过程中，对对象的数据访问所做的限制**。



- **ListableBeanFactory**：该接口定义了访问容器中 Bean 基本信息的若干方法，如查看Bean 的个数、获取某一类型 Bean 的配置名、查看容器中是否包括某一 Bean 等方法；
- **HierarchicalBeanFactory**：父子级联 IoC 容器的接口，子容器可以通过接口方法访问父容器； 通过 HierarchicalBeanFactory 接口， Spring 的 IoC 容器可以建立父子层级关联的容器体系，子容器可以访问父容器中的 Bean，但父容器不能访问子容器的 Bean。Spring 使用父子容器实现了很多功能，比如在 Spring MVC 中，展现层 Bean 位于一个子容器中，而业务层和持久层的 Bean 位于父容器中。这样，展现层 Bean 就可以引用业务层和持久层的 Bean，而业务层和持久层的 Bean 则看不到展现层的 Bean。
- **ConfigurableBeanFactory**：是一个重要的接口，增强了 IoC 容器的可定制性，它定义了设置类装载器、属性编辑器、容器初始化后置处理器等方法；
- **ConfigurableListableBeanFactory**: ListableBeanFactory 和 ConfigurableBeanFactory的融合；
- **AutowireCapableBeanFactory**：定义了将容器中的 Bean 按某种规则（如按名字匹配、按类型匹配等）进行自动装配的方法；



#### 如何将Bean注册到BeanFactory中？BeanRegistry

Spring 配置文件中每一个`<bean>`节点元素在 Spring 容器里都通过一个 BeanDefinition 对象表示，它描述了 Bean 的配置信息。而 BeanDefinitionRegistry 接口提供了向容器手工注册 BeanDefinition 对象的方法。



### BeanDefinition

**BeanDefinition 定义了各种Bean对象及其相互的关系**

SpringIOC容器管理了我们定义的各种Bean对象及其相互的关系，Bean对象在Spring实现中是以BeanDefinition来描述的

**BeanDefinitionReader 这是BeanDefinition的解析器**

Bean 的解析过程非常复杂，功能被分的很细，因为这里需要被扩展的地方很多，必须保证有足够的灵活性，以应对可能的变化。Bean 的解析主要就是对 Spring 配置文件的解析。

**BeanDefinitionHolder 这是BeanDefination的包装类，用来存储BeanDefinition，name以及aliases等。**

BeanDefinitionHolder 这是BeanDefination的包装类，用来存储BeanDefinition，name以及aliases等



### ApplicationContext

IoC容器的接口类是ApplicationContext，很显然它必然继承BeanFactory对Bean规范（最基本的ioc容器的实现）进行定义。而ApplicationContext表示的是应用的上下文，除了对Bean的管理外，还至少应该包含了

- **访问资源**： 对不同方式的Bean配置（即资源）进行加载。(实现ResourcePatternResolver接口)
- **国际化**: 支持信息源，可以实现国际化。（实现MessageSource接口）
- **应用事件**: 支持应用事件。(实现ApplicationEventPublisher接口)

#### ApplicationContext接口的实现

在考虑ApplicationContext接口的实现时，关键的点在于，不同Bean的配置方式（比如xml,groovy,annotation等）有着不同的资源加载方式，这便衍生除了众多ApplicationContext的实现类。

**第一，从类结构设计上看， 围绕着是否需要Refresh容器衍生出两个抽象类**：

- **GenericApplicationContext**： 是初始化的时候就创建容器，往后的每次refresh都不会更改
- **AbstractRefreshableApplicationContext**： AbstractRefreshableApplicationContext及子类的每次refresh都是先清除已有(如果不存在就创建)的容器，然后再重新创建；AbstractRefreshableApplicationContext及子类无法做到GenericApplicationContext**混合搭配从不同源头获取bean的定义信息**

**第二， 从加载的源来看（比如xml,groovy,annotation等）， 衍生出众多类型的ApplicationContext, 典型比如**:

- **FileSystemXmlApplicationContext**：	从文件系统下的一个或多个xml配置文件中加载上下文定义，也就是说系统盘符中加载xml配置文件。
- **ClassPathXmlApplicationContext**：	从类路径下的一个或多个xml配置文件中加载上下文定义，适用于xml配置的方式。
- **AnnotationConfigApplicationContext**：	从一个或多个基于java的配置类中加载上下文定义，适用于java注解的方式。
- **ConfigurableApplicationContext**： 扩展于 ApplicationContext，它新增加了两个主要的方法： refresh()和 close()，让 ApplicationContext 具有启动、刷新和关闭应用上下文的能力。在应用上下文关闭的情况下调用 refresh()即可启动应用上下文，在已经启动的状态下，调用 refresh()则清除缓存并重新装载配置信息，而调用close()则可关闭应用上下文。这些接口方法为容器的控制管理带来了便利，但作为开发者，我们并不需要过多关心这些方法。

![img](https://pdai.tech/_images/spring/springframework/spring-framework-ioc-source-71.png)







初始化流程

### 初始化的入口

对于xml配置的Spring应用，在main()方法中实例化ClasspathXmlApplicationContext即可创建一个IoC容器。我们可以从这个构造方法开始，探究一下IoC容器的初始化过程。

```
 // create and configure beans
ApplicationContext context = new ClassPathXmlApplicationContext("aspects.xml", "daos.xml", "services.xml");

```

进入

```
public ClassPathXmlApplicationContext(String... configLocations) throws BeansException {
    this(configLocations, true, (ApplicationContext)null);
}

public ClassPathXmlApplicationContext(String[] configLocations, boolean refresh, @Nullable ApplicationContext parent) throws BeansException {
    // 设置Bean资源加载器
    super(parent);

    // 设置配置路径
    this.setConfigLocations(configLocations);

    // 初始化容器
    if (refresh) {
        this.refresh();
    }
}

```

### 设置资源解析器和环境

调用父类容器AbstractApplicationContext的构造方法(`super(parent)`方法)为容器设置好Bean资源加载器

```
public AbstractApplicationContext(@Nullable ApplicationContext parent) {
    // 默认构造函数初始化容器id, name, 状态 以及 资源解析器
    this();

    // 将父容器的Environment合并到当前容器
    this.setParent(parent);
}
```

通过AbstractApplicationContext默认构造函数初始化容器id, name, 状态 以及 资源解析器

```
public AbstractApplicationContext() {
    this.logger = LogFactory.getLog(this.getClass());
    this.id = ObjectUtils.identityToString(this);
    this.displayName = ObjectUtils.identityToString(this);
    this.beanFactoryPostProcessors = new ArrayList();
    this.active = new AtomicBoolean();
    this.closed = new AtomicBoolean();
    this.startupShutdownMonitor = new Object();
    this.applicationStartup = ApplicationStartup.DEFAULT;
    this.applicationListeners = new LinkedHashSet();
    this.resourcePatternResolver = this.getResourcePatternResolver();
}
// Spring资源加载器
protected ResourcePatternResolver getResourcePatternResolver() {
    return new PathMatchingResourcePatternResolver(this);
}

```

通过AbstractApplicationContext的`setParent(parent)`方法将父容器的Environment合并到当前容器

```
public void setParent(@Nullable ApplicationContext parent) {
    this.parent = parent;
    if (parent != null) {
        Environment parentEnvironment = parent.getEnvironment();
        if (parentEnvironment instanceof ConfigurableEnvironment) {
            this.getEnvironment().merge((ConfigurableEnvironment)parentEnvironment);
        }
    }
}

```

在设置容器的资源加载器之后，接下来FileSystemXmlApplicationContet执行setConfigLocations方法通过调用其父类AbstractRefreshableConfigApplicationContext的方法进行对Bean定义资源文件的定位

```
public void setConfigLocations(@Nullable String... locations) {
    if (locations != null) {
        Assert.noNullElements(locations, "Config locations must not be null");
        this.configLocations = new String[locations.length];

        for(int i = 0; i < locations.length; ++i) {
            // 解析配置路径
            this.configLocations[i] = this.resolvePath(locations[i]).trim();
        }
    } else {
        this.configLocations = null;
    }
}
protected String resolvePath(String path) {
    // 从上一步Environment中解析
    return this.getEnvironment().resolveRequiredPlaceholders(path);
}

```



aop

spring将AOP的思想引入框架之中,通过**预编译方式**和**运行期间动态代理**实现程序的统一维护的一种技术,

Spring 框架通过定义切面, 通过拦截切点实现了不同业务模块的解耦，这个就叫**面向切面编程 - Aspect Oriented Programming (AOP)**

为什么@Aspect注解使用的是aspectj的jar包呢？这就引出了**Aspect4J和Spring AOP的历史渊源**，只有理解了Aspect4J和Spring的渊源才能理解有些注解上的兼容设计

如何支持**更多拦截方式**来实现解耦， 以满足更多场景需求呢？ 这就是@Around, @Pointcut... 等的设计

那么Spring框架又是如何实现AOP的呢？ 这就引入**代理技术，分静态代理和动态代理**，动态代理又包含JDK代理和CGLIB代理等



![img](https://pdai.tech/_images/spring/springframework/spring-framework-aop-2.png)



术语

著作权归https://pdai.tech所有。 链接：https://pdai.tech/md/spring/spring-x-framework-aop.html

**连接点（Jointpoint）**：表示需要在程序中插入横切关注点的扩展点，**连接点可能是类初始化、方法执行、方法调用、字段调用或处理异常等等**，Spring只支持方法执行连接点，在AOP中表示为**在哪里干**；

**切入点（Pointcut）**： 选择一组相关连接点的模式，即可以认为连接点的集合，Spring支持perl5正则表达式和AspectJ切入点模式，Spring默认使用AspectJ语法，在AOP中表示为**在哪里干的集合**；

**通知（Advice）**：在连接点上执行的行为，通知提供了在AOP中需要在切入点所选择的连接点处进行扩展现有行为的手段；包括前置通知（before advice）、后置通知(after advice)、环绕通知（around advice），在Spring中通过代理模式实现AOP，并通过拦截器模式以环绕连接点的拦截器链织入通知；在AOP中表示为**干什么**；

**方面/切面（Aspect）**：横切关注点的模块化，比如上边提到的日志组件。可以认为是通知、引入和切入点的组合；在Spring中可以使用Schema和@AspectJ方式进行组织实现；在AOP中表示为**在哪干和干什么集合**；

**引入（inter-type declaration）**：也称为内部类型声明，为已有的类添加额外新的字段或方法，Spring允许引入新的接口（必须对应一个实现）到所有被代理对象（目标对象）, 在AOP中表示为**干什么（引入什么）**；

**目标对象（Target Object）**：需要被织入横切关注点的对象，即该对象是切入点选择的对象，需要被通知的对象，从而也可称为被通知对象；由于Spring AOP 通过代理模式实现，从而这个对象永远是被代理对象，在AOP中表示为**对谁干**；

**织入（Weaving）**：把切面连接到其它的应用程序类型或者对象上，并创建一个被通知的对象。这些可以在编译时（例如使用AspectJ编译器），类加载时和运行时完成。Spring和其他纯Java AOP框架一样，在运行时完成织入。在AOP中表示为**怎么实现的**；

**AOP代理（AOP Proxy）**：AOP框架使用代理模式创建的对象，从而实现在连接点处插入通知（即应用切面），就是通过代理来对目标对象应用切面。在Spring中，AOP代理可以用JDK动态代理或CGLIB代理实现，而通过拦截器模型应用切面。在AOP中表示为**怎么实现的一种典型方式**；



通知类型

**前置通知（Before advice）**：在某连接点之前执行的通知，但这个通知不能阻止连接点之前的执行流程（除非它抛出一个异常）。

**后置通知（After returning advice）**：在某连接点正常完成后执行的通知：例如，一个方法没有抛出任何异常，正常返回。

**异常通知（After throwing advice）**：在方法抛出异常退出时执行的通知。

**最终通知（After (finally) advice）**：当某连接点退出的时候执行的通知（不论是正常返回还是异常退出）。

**环绕通知（Around Advice）**：包围一个连接点的通知，如方法调用。这是最强大的一种通知类型。环绕通知可以在方法调用前后完成自定义的行为。它也会选择是否继续执行连接点或直接返回它自己的返回值或抛出异常来结束执行。



- **Spring AOP和AspectJ是什么关系**？

1. AspectJ是更强的AOP框架，是实际意义的**AOP标准**；
2. Spring为何不写类似AspectJ的框架？ Spring AOP使用纯Java实现, 它不需要专门的编译过程, 它一个**重要的原则就是无侵入性（non-invasiveness）**; Spring 小组完全有能力写类似的框架，只是Spring AOP从来没有打算通过提供一种全面的AOP解决方案来与AspectJ竞争。Spring的开发小组相信无论是基于代理（proxy-based）的框架如Spring AOP或者是成熟的框架如AspectJ都是很有价值的，他们之间应该是**互补而不是竞争的关系**。
3. Spring小组喜欢@AspectJ注解风格更胜于Spring XML配置； 所以**在Spring 2.0使用了和AspectJ 5一样的注解，并使用AspectJ来做切入点解析和匹配**。**但是，AOP在运行时仍旧是纯的Spring AOP，并不依赖于AspectJ的编译器或者织入器（weaver）**。
4. Spring 2.5对AspectJ的支持：在一些环境下，增加了对AspectJ的装载时编织支持，同时提供了一个新的bean切入点。