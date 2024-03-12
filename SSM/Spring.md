# Spring

## 概述

Spring是分层的 Java SE/EE应用 full-stack **轻量级开源框架**，

以 **IoC（Inverse Of Control： 反转控制）和 AOP（Aspect Oriented Programming：面向切面编程）为内核**，

提供了展现层 Spring MVC 和持久层 Spring JDBC 以及业务层事务管理等众多的企业级应用技术

还能整合开源世界众多 著名的第三方框架和类库，逐渐成为使用最多的Java EE 企业应用开源框架

>  可能出现的面试题：为啥要用Spring？

Spring 充当一个很好的组件容器，减少我们的编码压力，更加专注于业务

## 组成

- Spring Core: 核心容器提供 Spring 框架的基本功能
- Spring 上下文：Spring 上下文是一个配置文件，向 Spring 框架提供上下文信息。Spring 上下文包括企业服务，例如 JNDI、EJB、电子邮件、国际化、校验和调度功能。
- Spring AOP：Spring AOP 模块为基于 Spring 的应用程序中的对象提供了事务管理服务。通过使用 Spring AOP，不用依赖 EJB 组件，就可以将声明性事务管理集成到应用程序中。
- Spring DAO：JDBC DAO 抽象层提供了有意义的异常层次结构，可用该结构来管理异常处理和不同数据库供应商抛出的错误消息。异常层次结构简化了错误处理，并且极大地降低了需要编写的异常代码数量（例如打开和关闭连接）。Spring DAO 的面向 JDBC 的异常遵从通用的 DAO 异常层次结构。
- Spring ORM：Spring 框架插入了若干个 ORM 框架，从而提供了 ORM 的对象关系工具，其中包括 JDO、Hibernate 和 iBatis SQL Map
- Spring Web 模块：Web 上下文模块建立在应用程序上下文模块之上，为基于 Web 的应用程序提供了上下文。所以，Spring 框架支持与 Jakarta Struts 的集成。Web 模块还简化了处理多部分请求以及将请求参数绑定到域对象的工作。
- Spring MVC 框架：MVC 框架是一个全功能的构建 Web 应用程序的 MVC 实现。通过策略接口，MVC 框架变成为高度可配置的，MVC 容纳了大量视图技术，其中包括 JSP、Velocity、Tiles、iText 和 POI。



## Spring容器

1. BeanFactory：是最简答的容器，提供了基本的DI支持。最常用的BeanFactory实现就是XmlBeanFactory类，它根据XML文件中的定义加载beans，该容器从XML文件读取配置元数据并用它去创建一个完全配置的系统或应用。
2. ApplicationContext应用上下文：基于BeanFactory之上构建，并提供面向应用的服务。



## ApplicationContext通常的实现

- ClassPathXmlApplicationContext：从类路径下的XML配置文件中加载上下文定义，把应用上下文定义文件当做类资源。
- FileSystemXmlApplicationContext：读取文件系统下的XML配置文件并加载上下文定义。
- XmlWebApplicationContext：读取Web应用下的XML配置文件并装载上下文定义。



## 优势

**1，方便解耦，简化开发**  (控制反转)

通过 Spring提供的 **IoC容器**，可以将**对象间的依赖关系交由 Spring进行控制**，**避免硬编码所造成的过度程序耦合**。用户也不必再为单例模式类、属性文件解析等这些很底层的需求编写代码，可以更专注于上层的应用

**2，AOP编程的支持**  

通过 Spring的 **AOP 功能**，**方便进行面向切面的编程**

**3，声明式事务的支持**  

可以将我们从单调烦闷的事务管理代码中解脱出来，通过**声明式方式灵活的进行事务的管理**， 提高开发效率和质量。 

**4，方便程序的测试** 

可以用非容器依赖的编程方式进行几乎所有的测试工作，测试不再是昂贵的操作，而是随手可做的事情

**5，方便集成各种优秀框架**  

Spring可以降低各种框架的使用难度，提供了对各种优秀框架（Struts、Hibernate、Hessian、Quartz 等）的直接支持

 **6，降低 JavaEE API的使用难度**  

Spring对 JavaEE API（如 JDBC、JavaMail、远程调用等）进行了薄薄的封装层，使这些 API 的 使用难度大为降低。

**7，Java源码是经典学习范例** 

 Spring的源代码设计精妙、结构清晰、匠心独用，处处体现着大师对Java 设计模式灵活运用以 及对 Java技术的高深造诣。它的源代码无意是 Java 技术的最佳实践的范例



## 入门

1，下载

```
http://spring.io/
```

2，导入下载的包的依赖

```properties
aopalliance-1.0.jar
commons-logging-1.2.jar
spring-aop-5.2.3.RELEASE.jar、
# 包含在应用中使用Spring的AOP特性时所需的类
spring-aspects-5.2.3.RELEASE.jar
# Spring提供的对AspectJ框架的整合 
spring-beans-5.2.3.RELEASE.jar
# 包含访问配置文件、创建和管理bean以及进行IoC/DI操作相关的所有类,如果只需基本的IoC/DI支持，引入spring-core.jar及spring-beans.jar文件就可以了。
spring-context-5.2.3.RELEASE.jar
# 为Spring核心提供了大量扩展
spring-context-support-5.2.3.RELEASE.jar
# Spring context的扩展支持，用于MVC方面
spring-core-5.2.3.RELEASE.jar
# 包含Spring框架基本的核心工具类，Spring其它组件要都要使用到这个包里的类，是其它组件的基本核心，当然你也可以在自己的应用系统中使用这些工具类
spring-expression-5.2.3.RELEASE.jar
# Spring表达式语言 
spring-instrument-5.2.3.RELEASE.jar
# Spring对服务器的代理接口 
spring-jdbc-5.2.3.RELEASE.jar
# 包含对Spring对JDBC数据访问进行封装的所有类
spring-jms-5.2.3.RELEASE.jar
# 为简化jms api的使用而做的简单封装 
spring-messaging-5.2.3.RELEASE.jar
spring-orm-5.2.3.RELEASE.jar
# 包含Spring对DAO特性集进行了扩展
spring-oxm-5.2.3.RELEASE.jar
# Spring对于object/xml映射的支持，可以让JAVA与XML之间来回切换
spring-test-5.2.3.RELEASE.jar
# 对JUNIT等测试框架的简单封装
spring-tx-5.2.3.RELEASE.jar
# 为JDBC、Hibernate、JDO、JPA等提供的一致的声明式和编程式事务管理
```

3，也可以使用Idea自动创建spring项目，会自动下载jar包并导入



# AOP

AOP  , 直译过来就是 面向切面编程。

AOP 是一种编程思想，是面向对象编程（OOP）的一种补充。面向对象编程将程序抽象成各个层次的对象，而面向切面编程是将程序抽象成各个切面。

AOP 要达到的效果是，保证开发者不修改源代码的前提下，去为系统中的业务组件添加某种通用功能

## 分类

- 静态 AOP 实现， AOP 框架在编译阶段对程序源代码进行修改，生成了静态的 AOP 代理类（生成的 *.class 文件已经被改掉了，需要使用特定的编译器），比如 AspectJ。
- 动态 AOP 实现， AOP 框架在运行阶段对动态生成代理对象（在内存中以 JDK 动态代理，或 CGlib 动态地生成 AOP 代理类），如 SpringAOP。

> 那么这里就涉及到静态代理和动态代理

**静态代理和动态代理的区别是什么？什么是静态代理？什么是动态代理？**

**静态代理**

代理类和被代理的类实现了同样的接口，代理类同时持有被代理类的引用，这样，当我们需要调用被代理类的方法时，可以通过调用代理类的方法来做到

**动态代理**

动态代理的根据实现方式的不同可以分为 ：JDK 动态代理 和 CGlib 动态代理

JDK 动态代理：利用反射机制生成一个实现代理接口的类，在调用具体方法前调用InvokeHandler来处理

```java
public class Work implements InvocationHandler {
    private Object object;

    public Work(Object object) {
        this.object = object;
    }
   //定义类实现InvocationHandler接口，并实现invoke方法 
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("object: " + object.getClass().getSimpleName());//被代理的对象名
        System.out.println("proxy: " + proxy.getClass().getSimpleName());//代理对象名

        if ("meeting".equals(method.getName())) {
            System.out.println("代理先准备会议材料...");
            return method.invoke(object, args);
        } 
        return null;
    }
}

//调用
//这样当使用proxy调用meeting方法时，实际上是通过反射产生的代理类执行
Leader leader = new Leader();
IWork proxy = (IWork) Proxy.newProxyInstance(Leader.class.getClassLoader(),
                		new Class[]{IWork.class}, new WorkInvocationHandler(leader));
proxy.meeting();
```



CGlib 动态代理：利用ASM（开源的Java字节码编辑库，操作字节码）开源包，将代理对象类的class文件加载进来，通过修改其字节码生成子类来处理



```java
public class CglibProxy implements MethodInterceptor {
    @Override
    public Object intercept(Object o, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
        System.out.println("before " + methodProxy.getSuperName());
        System.out.println(method.getName());
        Object o1 = methodProxy.invokeSuper(o, args);
        System.out.println("before " + methodProxy.getSuperName());
        return o1;
    }
}



//使用
public class Main2 {
    public static void main(String[] args) {
        CglibProxy cglibProxy = new CglibProxy();
 
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(UserServiceImpl.class);
        enhancer.setCallback(cglibProxy);
 
        UserService o = (UserService)enhancer.create();
        o.getName(1);
        o.getAge(1);
    }
}
```



区别：

JDK代理只能对实现接口的类生成代理；

CGlib是针对类实现代理，对指定的类生成一个子类，并覆盖其中的方法，这种通过继承类的实现方式，不能代理final修饰的类

## Aop术语

- 通知（Advice）: AOP 框架中的增强处理。通知描述了切面何时执行以及如何执行增强处理，即**被用来增强方法的方法**
- 连接点（join point）: 连接点表示应用执行过程中能够插入切面的一个点，这个点可以是方法的调用、异常的抛出。在 Spring AOP 中，连接点总是方法的调用，即**被增强的方法**
- 切点（PointCut）: 可以插入增强处理的连接点，即**没有被增强的方法**。
- 切面（Aspect）: 切面是通知和切点的结合。
- 引入（Introduction）：引入允许我们向现有的类添加新的方法或者属性。
- 织入（Weaving）: 将增强处理添加到目标对象中，并创建一个被增强的对象，这个过程就是织入。
- Target(目标对象):   代理的目标对象
- Proxy（代理）:   一个类被 AOP 织入增强后，就产生一个结果代理类



## Spring AOP的使用

spring 对 aop 做了封装，使得aop的使用更加方便，只需要简单的配置或者注解就能实现aop

首先得明确切入点表达式的写法

关键字：execution(表达式)

```java
表达式：访问修饰符  返回值  包名.包名.包名...类名.方法名(参数列表)

标准的表达式写法：
public void com.itheima.service.impl.AccountServiceImpl.saveAccount(int a,int b)
    
//访问修饰符可以省略
//包名可以使用..表示当前包及其子包
2 * *..AccountServiceImpl.saveAccount()
```



额外：环绕通知

1，它是spring框架**为我们提供的一种可以在代码中手动控制增强方法何时执行的方式。**

2，Spring框架为我们提供了一个**接口：ProceedingJoinPoint**。

3，该接口有一个方法**proceed()**，此方法就相当于**明确调用切入点方法**。

4，该接口可以作为环绕通知的方法参数，在程序执行时，spring框架会为我们提供该接口的实现类供我们使用

（下面有两种形式的环绕通知配置）



使用之前需要注意aop需要的jar包

> aopalliance-1.0
>
> aspectjweaver-1.8.7
>
> spring-aop-5.0.2.RELEASE
>
> spring-aspects-5.0.2.RELEASE



### 基于xml形式的

1，配置文件,导入约束

```
<?xml version="1.0" encoding="UTF-8"?> 
<beans xmlns="http://www.springframework.org/schema/beans"        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:aop="http://www.springframework.org/schema/aop"        xsi:schemaLocation="http://www.springframework.org/schema/beans               http://www.springframework.org/schema/beans/spring-beans.xsd 
             http://www.springframework.org/schema/aop               http://www.springframework.org/schema/aop/spring-aop.xsd"> 
</beans>
```



```xml
//配置前置通知：在切入点方法执行之前执行
<aop:before method="" pointcut-ref="pt1" ></aop:before>
//配置后置通知：在切入点方法正常执行之后值。它和异常通知永远只能执行一个
<aop:after-returning method="" pointcut-ref="pt1"></aop:after-returning>-->
//配置异常通知：在切入点方法执行产生异常之后执行。它和后置通知永远只能执行一个
<aop:after-throwing method="" pointcut-ref="pt1"></aop:after-throwing>-->
//配置最终通知：无论切入点方法是否正常执行它都会在其后面执行
<aop:after method="" pointcut-ref="pt1"></aop:after>


//此标签写在aop:aspect标签内部只能当前切面使用。
//它还可以写在aop:aspect外面，此时就变成了所有切面可用
<aop:pointcut id="pt1" 
            expression="execution(* com.tutu.test1.buy(..))">
</aop:pointcut>
//这样写就说明是这个包下的所有类的所有方法执行时都会执行通知
```

2，开启aop支持

```xml
<aop:aspectj-autoproxy/> 
```



环绕通知配置文件

```xml
<aop:config>
<!--aop:pointcut：就是配置各种通知-->    
<aop:pointcut expression="execution()" id="pt1"/>  
    <aop:aspect id="txAdvice" ref="txManager"> 
        <!-- 配置环绕通知 -->  
        <aop:around method="" pointcut-ref="pt1"/> 
   	</aop:aspect> 
</aop:config> 
<!--method：指定通知中方法的名称--> 
<!--pointct：定义切入点表达式-->  
<!--pointcut-ref：指定切入点表达式的引用--> 
```

使用

- 缺少在增强时获取方法信息
- 优先级的使用

```java
public Object aroundPringLog(ProceedingJoinPoint pjp){
        Object rtValue = null;
        try{
            Object[] args = pjp.getArgs();//得到方法执行所需的参数

            System.out.println("Logger类中的aroundPringLog前置");

            rtValue = pjp.proceed(args);//明确调用业务层方法（切入点方法）

            System.out.println("Logger类中的aroundPringLog后置");

            return rtValue;
        }catch (Throwable t){
            System.out.println("Logger类中的aroundPringLog异常");
            throw new RuntimeException(t);
        }finally {
            System.out.println("Logger类中的aroundPringLog最终");
        }
    }
}
```



### 基于注解形式的

1，导入jar包

2，配置通知类

```java
@Component("txManager") 
@Aspect //表明当前类是一个切面类
public class TransactionManager { 
    //开启事务  
    @Before("execution(* com.service.impl.*.*(..))") 
    public void beginTransaction() {}
    //提交事务  
    @AfterReturning("execution(* com.service.impl.*.*(..))")  
    public void commit() {  }
    //回滚事务
    @AfterThrowing("execution(* com.service.impl.*.*(..))") 
    public void rollback() { }
    //释放资源  
    @After("execution(* com.service.impl.*.*(..))")  
    public void release() { }
}
```

3，开启spring对aop支持

```java
@EnableAspectJAutoProxy
puclic class MainApplication{}
```



环绕通知配置

```java
@Around("execution(* com.itheima.service.impl.*.*(..))") 
public Object transactionAround(ProceedingJoinPoint pjp) { 
  //定义返回值   
  Object rtValue = null;  
   try { 
   		//获取方法执行所需的参数    
		Object[] args = pjp.getArgs(); 
   		//前置通知：开启事务    
		beginTransaction(); 
   		//执行方法    
		rtValue = pjp.proceed(args); 
  		//后置通知：提交事务    
		commit();   
   }catch(Throwable e) { 
   		//异常通知：回滚事务    
		rollback();   
    	e.printStackTrace();   
   }finally {    
    	//最终通知：释放资源   
		release();  
   }   
return rtValue; 
```



### 切入点表达式注解

```java
//里面还有很多属性进行设置
@Pointcut("execution(* com.itheima.service.impl.*.*(..))") 
private void pt1() {} 

@Around("pt1()")//注意：千万别忘了写括号，参数有的话也要带上 
public Object transactionAround(ProceedingJoinPoint pjp) {}
```



# 控制反转（IOC）

控制反转（Inversion of Control，缩写为IoC，是面向对象编程中的一种设计原则，**可以用来减低计算机代码之间的耦合度**，把创建对象的权力交给框架

通过控制反转，对象在被创建的时候，由一个调控系统内所有对象的外界实体将其所依赖的对象的引用传递给它。也可以说，依赖被注入到对象中

> 其中最常见的方式叫做**依赖注入**（Dependency Injection，简称**DI**），还有一种方式叫“依赖找”（DependencyLookup）

```java
//一般的声明对象方式
private AccountDao dao = new AccountDaoImpl();

//控制反转，把这个类的权利交给其他类，让这个类去创建对象
private AccountDao dao = (AccountDao) beanFactory.getBean("accountDao");
```



## 耦合性

1，耦合性(Coupling)，也叫**耦合度**，**是对模块间关联程度的度量**

2，**耦合的强弱**取决于模块间接口的复杂性、调用模块的方式以及通过界面传送数据的多少

3，**模块间的耦合度**是指模块之间的依赖关系，包括控制关系、调用关系、数据传递关系。模块间联系越多，其耦合性越强，同时表明其独立性越差

（**划分模块的一个 准则就是高内聚低耦合**）



## 耦合分类

（1） 内容耦合

当一个模块**直接修改或操作另一个模块的数据**时，或一个模块不通过正常入口而转入另 一个模块时，这样的耦合被称为内容耦合。内容耦合是最高程度的耦合，应该避免使用之

（2） 公共耦合

两个或两个以上的模块**共同引用一个全局数据项**，这种耦合被称为公共耦合。在具有大 量公共耦合的结构中，确定究竟是哪个模块给全局变量赋了一个特定的值是十分困难的

（3） 外部耦合 

一组模块都访问同一全局简单变量而不是同一全局数据结构，而且不是通过参数表传 递该全局变量的信息，则称之为外部耦合

（4） 控制耦合 

一个模块通过接口向另一个模块传递一个控制信号，接受信号的模块根据信号值而进 行适当的动作，这种耦合被称为控制耦合

（5） 标记耦合 

若一个模块 A 通过接口向两个模块 B 和 C 传递一个公共参数，那么称模块 B 和 C 之间 存在一个标记耦合

（6） 数据耦合

模块之间通过参数来传递数据，那么被称为数据耦合。数据耦合是最低的一种耦合形 式，系统中一般都存在这种类型的耦合，因为为了完成一些有意义的功能，往往需要将某些模块的输出数据作为另

一些模块的输入数据

（7） 非直接耦合 

两个模块之间没有直接关系，它们之间的联系完全是通过主模块的控制和调用来实 现的

​                                                                                                                                                                                                                                                                                                                                                                                                                               

**总结**：  耦合是影响软件复杂程度和设计质量的一个重要因素，在设计上我们应采用以下原则：

如果模块间必须 存在耦合，就尽量使用数据耦合，少用控制耦合，限制公共耦合的范围，尽量避免使用内容耦合



## 内聚与耦合 

**内聚标志一个模块内各个元素彼此结合的紧密程度**，它是信息隐蔽和局部化概念的自然扩展。

内聚是从 功能角度来度量模块内的联系，一个好的内聚模块应当恰好做一件事。它描述的是模块内的功能联系。耦合是软件结构中各模块之间相互连接的一种度量，耦合强弱取决于模块间接口的复杂程度、进入或访问一个模块的点以及通过接口的数据。 程序讲究的是低耦合，高内聚。就是同一个模块内的各个元素之间要高度紧密，但是各个模块之 间的相互依存度却要不那么紧密。 内聚和耦合是密切相关的，同其他模块存在高耦合的模块意味着低内聚，而高内聚的模块意味着该模块同其他模块之间是低耦合。在进行软件设计时，应力争做到高内聚，低耦合。 



## 工厂模式解耦

```java
//什么是工厂
//工厂就是负责给我们从容器中获取指定对象的类
package com.tutu.factury;

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class beanFactory {
    private static Properties properties;
    //定义一个Map,用于存放我们要创建的对象。我们把它称之为容器
    private static Map<String,Object> beans;

    static {
        properties = new Properties();
        InputStream is = beanFactory.class.getClassLoader().getResourceAsStream("Bean.properties");
        try {
            properties.load(is);
            beans =  new HashMap<String, Object>();
            //取出配置文件中所有的Key
            Enumeration keys = properties.keys();
            while (keys.hasMoreElements()){
                //取出每个Key
                String key = keys.nextElement().toString();
                //根据key获取value
                String beanPath = properties.getProperty(key);
                //反射创建对象
                Object value = Class.forName(beanPath).newInstance();
            }
        } catch (IOException | ClassNotFoundException e) {
            //初始化异常
            throw new ExceptionInInitializerError("初始化properties失败！");
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InstantiationException e) {
            e.printStackTrace();
        }
    }
    public static Object getBean(String BeanName){
        return beans.get(BeanName);
    }
}



accountService=com.tutu.service.Impl.AccountServiceImpl
accountDao=com.tutu.dao.impl.AccountDaoImpl


private AccountDao dao = (AccountDao) beanFactory.getBean("accountDao");


```



## Bean

### 创建Bean的三种方式

Bean标签属性

```properties
factory-bean:工厂类的名称
factory-method:工厂类种的方法   
id: Bean的id
class: Bean所对应的类
scope: 指定bean的作用范围
init-method: 在bean对象创建时执行的方法
destroy-method: 在bean对象销毁时执行的方法
```

第一种：使用默认构造

在spring的配置文件中使用bean标签，配以**id和class属性之后**，且**没有其他属性和标签时**，采用的就是默认构造函数创建bean对象，此时如果**类**中**没有默认构造函数，则对象无法创建**

```xml
<bean id="accountdao" class="com.dao.impl.AccountdaoImpl"></bean>
```



第二种：使用普通工厂类中的方法创建

一般这种方式是针对，很多无法修改的jar包，**其中很多构造方法都被使用**，所以需要一个**工厂类，用来创建需要类的对象**

```xml
<bean id="instanceFactory" class="com.factory.InstanceFactory"></bean>
<bean id="accountdao" 
        factory-bean="instanceFactory" factory-method="getAccountdaoe"></bean>
```

工厂类

```java
public class Factory{
    public void getAccountdaoe(){ return new AccountDaoImpl();}
}
```





第三种：使用工厂中的静态方法创建对象

```xml
<bean id="accountService" class="com.factory.StaticFactory" 
                            factory-method="getAccountService"></bean>
```

工厂类

```java
public class Factory{
    public void static getAccountdaoe(){ return new AccountDaoImpl();}
}

```

### Bean的作用范围

bean标签的**scope**属性：

​            作用：**用于指定bean的作用范围**

​            取值： 常用的就是单例的和多例的

```properties
singleton():单例的（默认值）
prototype():多例的
request():作用于web应用的请求范围
session():作用于web应用的会话范围
global-session:作用于集群环境的会话范围（全局会话范围）
//当不是集群环境时，它就是session
```

例子

```xml
<bean id="" class="" scope="prototype"></bean>
```



### Bean的生命周期

**单例对象**

 出生：当**容器创建**时对象出生

1，创建Bean实例

2，属性注入

3，初始化：激活Aware方法，处理器的应用(BeanPostProcessor接口)，激活自定义的init方法（init-method & 自定义实现InitializingBean接口）

​                存活：只要**容器还在，对象一直存活**

​                死亡：**容器销毁**，对象消亡

​                总结：单例对象的生命周期和容器相同

**多例对象**

​                出生：当我们**使用对象时**spring框架为我们创建

​                存活：对象只要是在**使用过程中就一直活着**

​                死亡：**当对象长时间不用，且没有别的对象引用时，由Java的垃圾回收器回收**

```
<bean scope="" init-method="init" destroy-method="destroy"></bean>
```





## IOC的使用

### 基于xml形式

------

1，xml配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd">
</beans>
```

2，把对象的创建交给spring来管理

```xml
<bean id="accountDao" class="com.tutu.dao.Impl.AccountDaoImpl"></bean>
```



3，获取ioc容器

方式一

```java
ApplicationContext ac =new ClassPathXmlApplicationContext("bean.xml");
//path:指的是xml文件的绝对路径 C:\\Users\\Desktop\\bean.xml
//直接写bean.xml就是说这个xml文件在根目录下，也就是src
ApplicationContext ac = new FileSystemXmlApplicationContext("path");

IAccountService as  = (IAccountService)factory.getBean("accountService");
```

方式二

```java
//注意导包
import org.springframework.core.io.Resource;

Resource resource = new ClassPathResource("bean.xml");
BeanFactory factory = new XmlBeanFactory(resource);

AccountDao dao = factory.getBean("accountDao", AccountDao.class);
```



两者的区别

BeanFactory 才是 Spring 容器中的顶层接口， ApplicationContext 是它的子接口。 

ApplicationContext：只要一读取配置文件，默认情况下就会创建对象，BeanFactory：什么使用什么时候创建对象



4，使用容器



### 基于注解形式

------

1，省略了xml文件，直接使用注解管理资源

```java
@Component("accountdao")
public class AccountDaoImpl implements IAccountDao {}
```

2，在xml文件中开启对注解的支持

同时xml的开头也需要更换

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"  xmlns:context="http://www.springframework.org/schema/context" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"     xsi:schemaLocation="http://www.springframework.org/schema/beans         http://www.springframework.org/schema/beans/spring-beans.xsd 
        http://www.springframework.org/schema/context         http://www.springframework.org/schema/context/spring-context.xsd"> 
```



```xml
<!-- 告知 spring 创建容器时要扫描的包 -->  
<context:component-scan base-package="tutu.demo"></context:component-scan> 
```

或者在主启动类中添加注解

```
 @ComponentScan() 
```



3，使用容器

> @Controller：一般用于表现层的注解
>
> @Service：一般用于业务层的注解
>
> @Repository：一般用于持久层的注解。 



# 依赖注入（DI）	

> Dependency Injection

1，平常的java开发中，程序员在某个类中需要依赖其它类的方法，则通常是new一个依赖类再调用类实例的方法，这种开发存在的问题是不好统一管理

2，spring容器帮我们new指定实例并且将实例注入到需要该对象的类中



## 注入类型

1，基本类型和String

2，其他bean类型（在配置文件中或者注解配置过的bean）

3，复杂类型/集合类型



## 注入方式

### 基于构造函数

构造函数注入就是通过Bean类的构造方法，将Bean所依赖的对象注入，即需要构造方法

Bean类

```java
public class Message{
	private ErrorMessage errormessage;    
	public Message(ErrorMessage errormessage){
    	this.errormessage = errormessage;	    
    }
}
```

配置文件

```xml
<bean id="errormessage" class="com.tutu.ErrorMessage">
	<property msg="msg" value="错误信息"></property>
</bean>
<bean id="Message" class="com.tutu.Message">
	<constructor-org ref="errormessage">
</bean>
```

constructor-org 标签中的属性

​            **type**：用于指定要注入的数据的数据类型，该数据类型也是构造函数中某些参数的类型

​            **index**：用于指定要注入的数据给**构造函数**中**指定索引位置的参数赋值**,**索引的位置是从0开始**

​            **name**：用于指定给构造函数中**指定名称的参数赋值**

==================**以上三个用于指定给构造函数中哪个参数赋值**=======================

​            **value**：用于提供**基本类型和String类型的数据**

​			**ref**：用于**指定其他的bean类型数据**,通常指的是方法的参数也是个对象

**注意：value中的值是String，遇到类中的参数类型不匹配时，spring会自动转换**

​            

**优势**：在获取bean对象时，注入数据是必须的操作，否则对象无法创建成功

**弊端**：改变了bean对象的实例化方式，使我们在创建对象时，如果用不到这些数据，也必须提供。



### 基于Set函数

也就是通过Bean类的Set方法注入

Bean类

```java
public class Message{
	private ErrorMessage errormessage;    
    public void SetErrorMessage(ErrorMessage errormessage){
        this.errormessage = errormessage;
    }
}
```

配置文件

```xml
<bean id="errormessage" class="com.tutu.ErrorMessage">
	<property msg="msg" value="错误信息"></property>
</bean>
<bean id="Message" class="com.tutu.Message">
	 <property name="errormessage" ref="errormessage" ></property>
</bean>
```



Spring IOC容器除了向Bean注入简单对象外，也可以向Bean注入集合对象。如map、list、set、数组等集合对象

比如

```java
public void SetErrorMessage(List<ErrorMessage> errormessages){
        this.errormessage = errormessage;
    }
```

那么配置文件为

```xml
<bean id="Message" class="com.tutu.Message">
	 <property name="errormessages">
	 	<set>
        	<value></value>
        </set>
	 </property>
</bean>
```



```xml
 <bean id="" class="">
        <property name="">
            <set> <value>AAA</value> </set>
        </property>

        <property name="">
            <array> <value>AAA</value> </array>
        </property>

        <property name="">
            <list> <value>AAA</value> </list>
        </property>

        <property name="">
            <props> <prop key="testC">ccc</prop> </props>
        </property>

        <property name="">
            <map>
                <entry key="testA" value="aaa"></entry>
                <entry key="testB"> <value>BBB</value></entry>
            </map>
        </property>
</bean>
```



### 自动注入

> 自动装配最大的问题在于匹配失败后，Spring容器将不会向Bean注入任何依赖对象，就会导致Bean获取不到所依赖的对象，当Bean使用该依赖对象时，就会发生错误。因此，在可能的情况下尽可能使用手动装配

xml形式的自动注入，bean标签中的atutowire就是开启自动装配

```xml
<bean id="Message" atutowire="ByType" class="com.tutu.Message">
	 <property name="errormessage" ref="errormessage" ></property>
</bean>
```



注解形式的自动注入

```java
@Autowired
private ErrorMessage errormessage;
```



额外注意：需要开启注解功能

即在配置文件中注册注解驱动

```xml
<context:annotation-config/>
```

或者在启动类中扫描注解

```java
@ComponentScan(basePackages = {"com.*"}) // springboot 扫描指定包下面的注解

@SectionScan(basePackages={"com.migu.*"}) // 扫描指定包的下的注解
```



# 常用注解

在使用注解之前，需要开启spring注解的支持

xml开启

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

<context:component-scan base-package="com.tutu"></context:component-scan>

</beans>
```

注解开启

```
@ComponentScan
```



## 1，**@Component**

作用：用于把当前类对象存入spring容器中，**也就是创建Bean对象**

属性：

value：用于指定bean的id。当我们不写时，它的默认值是当前类名，且首字母改小写



**@Controller**：一般用在表现层

**@Service**：一般用在业务层

**@Repository**：一般用在持久层

三个是spring框架为我们提供明确的三层使用的注解，使我们的三层对象更加清晰



## 2，**@Autowired**

作用：**自动按照类型注入**

只要容器中有唯一的一个bean对象类型和要注入的变量类型匹配，就可以注入成功，如果ioc容器中没有任何bean的类型和要注入的变量类型匹配，则报错



**注意**：如果Ioc容器中有多个类型匹配时，程序就会报错，提示有两个同类型的对象



## 3，**@Qualifier**

作用：在按照类中注入的基础之上再按照名称注入，是**@Autowired**的进化，**可以自定义类名称**

**它在给类成员注入时不能单独使用，但是在给方法参数注入时可以**

属性：value：用于指定注入bean的id

```java
@Autowired
@Qualifier("accountDao")
private IAccountDao accountDao = null;
```



## 4，**@Resource**

作用：直接按照bean的id注入，它可以独立使用，也就是**@Qualifier**和**@Autowired**的结合

```java
@Resource(name = "accountDao")
private IAccountDao accountDao = null;
```



> **基本类型和String类型无法使用上述注解实现，另外，集合类型的注入只能通过XML来实现**



## 5，**@Value**

作用：用于注入基本类型和String类型的数据

它可以使用spring中SpEL(spring的el表达式）**SpEL的写法：${表达式}**

```java
@Value("${properties.name}") 
private Stirng name;
```

或者

```java
@Value("#{2+2}") 
private int age;
```

**注意：**

**不支持松散绑定，不支持数据检验:JSR303，不支持复杂的数据类型：map，所以一般般适用于只是简单的去获取某一个值时**



## 6，**@Scope**

作用：**用于指定bean的作用范围**

属性：value：指定范围的取值

> singleton：单例
>
> prototype：多例



## 7，**@PreDestroy**

用于指定销毁方法，和生命周期有关



## **8，@PostConstruct**

用于指定初始化方法，和生命周期有关



## 9，**@Configuration**

**声明这个类为配置类**



## 10，**@Bean**

仅仅把这个类声明为配置类是不够的，其中方法创建的对象时没有用的，原因是：没有将创建的对象存入到ioc容器中

```java
@Bean("runner")
public Runner createRunner(){
    return new Runner();
}
//加入了这个注解之后，返回的Runner，Spring就会在ioc容器中找
    //有没有“runner”的Bean对象
```

## 11，**@Import**

**用于导入其他的配置类，就可以区分每个类不同的作用**

当我们使用Import的注解之后，有Import注解的类就父配置类，而导入的都是子配置类



## 12，**@PropertySource**

**用于指定properties文件的位置**

```java
@PropertySource(value = "classpath : jdbcConfig.properties")
```



## 13，**@RunWith**

@RunWith就是一个运行器

> @RunWith(JUnit4.class)就是指用JUnit4来运行
>
> @RunWith(SpringJUnit4ClassRunner.class),让测试运行于Spring测试环境
>
> @RunWith(Suite.class)的话就是一套测试集合



## 14，**@ContextConfiguration**

locations 属性：用于指定配置文件的位置。如果是类路径下，需要用 classpath:表明 

classes 属性：用于指定注解的类。当不使用 xml 配置时，需要用此属性指定注解类的位置。 



## 15，**@ComponentScan**



## 16，**@Targe**

用于设定注解使用范围

> java.lang.annotation.ElementType
>
> Target通过ElementType来指定注解可使用范围的枚举集合



## 17，**@**Retention

注解@Retention可以用来修饰注解，是注解的注解，称为元注解

> Retention注解有一个属性value，是RetentionPolicy类型的，Enum RetentionPolicy是一个枚举类型，
>
> 这个枚举决定了Retention注解应该如何去保持，也可理解为Rentention 搭配 RententionPolicy使用。

RetentionPolicy有3个值：CLASS RUNTIME  SOURCE

按生命周期来划分可分为3类：

1、RetentionPolicy.SOURCE：注解只保留在源文件，当Java文件编译成class文件的时候，注解被遗弃；

2、RetentionPolicy.CLASS：注解被保留到class文件，但jvm加载class文件时候被遗弃，这是默认的生命周期；

3、RetentionPolicy.RUNTIME：注解不仅被保存到class文件中，jvm加载class文件之后，仍然存在；



## 18，**@Documented**

Documented注解表明这个注释是由 javadoc记录的，在默认情况下也有类似的记录工具。 如果一个类型声明被注释了文档化，它的注释成为公共API的一部分



## 19，**@AutoConﬁgurationPackage**

自动配置包



## 20，**@Validated**

简单来讲就是被修饰的类会有数据校验，来控制数据



# 八，Spring整合Junit

在测试方法中，unit不知道使用了spring，所以一些注解不会生效，不用xml的原因是测试类仅仅只是测试使用，项目中不参与其中的逻辑，会造成资源浪费



所以需要整合

第一步

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-test</artifactId>
    <version>5.0.2.RELEASE</version>
</dependency>

<dependency>
    <groupId>commons-dbutils</groupId>
    <artifactId>commons-dbutils</artifactId>
    <version>1.4</version>
</dependency>
```

第二步：使用@RunWith 注解替换原有运行器 

> @RunWith需要导入junit4的包



```java
@RunWith(SpringJUnit4ClassRunner.class)
public class AccountServiceTest {} 
//这样就不会使用util运行了
```

第三步：用@ContextConfiguration 指定 spring 配置文件的位置

```java
@RunWith(SpringJUnit4ClassRunner.class) 
@ContextConfiguration(locations= {"classpath:bean.xml"})
public class AccountServiceTest { 
    //这样spring运行这个类的时候就会创建容器
} 
```

第四步：@Autowired 给测试类中的变量注入数据 

```java
public class AccountServiceTest { 
   @Autowired 
   private IAccountService as ;
   //这个时候as就可以使用，使用xml的前提是xml中已经注入了数据
} 
```



# 九，JDBCTemplate

额外的jar包

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-jdbc</artifactId>
    <version>4.2.5.RELEASE</version>
    <scope>compile</scope>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-tx</artifactId>
    <version>4.2.5.RELEASE</version>
    <scope>compile</scope>
</dependency
```

2个配置文件，一个实体类

1，db.properties配置文件

```properties
jdbc.user=root
jdbc.password=root
jdbc.driverClass=
jdbc.jdbcUrl=
```

2，applicationContext.xml配置文件

```xml
<!-- 读取配置文件 -->
    <context:property-placeholder location="classpath:db.properties" />
    
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="user" value="${jdbc.user}"></property>
        <property name="password" value="${jdbc.password}"></property>
        <property name="driverClass" value="${jdbc.driverClass}"></property>
        <property name="jdbcUrl" value="${jdbc.jdbcUrl}"></property>
    </bean>

    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"></property>
    </bean>
```



使用

```java
//一般这两步比较常用，会放在静态方法中加载类的时候就加载
private ApplicationContext ctx = new ClassPathXmlApplicationContext("ApplicationContext.xml");
private JdbcTemplate jdbcTemplate = (JdbcTemplate) ctx.getBean("jdbcTemplate");
```

插入

```java
String sql = "INSERT INTO xwj_user(id, last_name, age) VALUES(?, ?, ?)";
jdbcTemplate.update(sql, "1", "tutu", 0);
```

更新

```java
String sql = "UPDATE xwj_user SET last_name = ? WHERE id = ?";
jdbcTemplate.update(sql, "tutu", 1);
```

删除

```java
String sql = "DELETE from xwj_user WHERE id = ?";
jdbcTemplate.update(sql, 1);
```



其中，从数据库中获取一条记录，实际得到对应的一个对象时

```java
String sql = "SELECT id, last_name lastName, email FROM xwj_user WHERE ID = ?";
RowMapper<User> rowMapper = new BeanPropertyRowMapper<>(User.class);
// 在将数据装入对象时需要调用set方法。
User user = jdbcTemplate.queryForObject(sql, rowMapper, 2);
```

当次查的是多个对象时

```java
RowMapper<User> rowMapper = new BeanPropertyRowMapper<>(User.class);  
        List<User> userList = jdbcTemplate.query(sql, rowMapper, 1);  
        if (!CollectionUtils.isEmpty(userList)) {
            userList.forEach(user -> {
                System.out.println(user);
            });
        }
```



# 十，事务

## ACID

1. Atomic原子性：事务是由一个或多个活动所组成的一个工作单元。原子性确保事务中的所有操作全部发生或者全部不发生。
2. Consistent一致性：一旦事务完成，系统必须确保它所建模的业务处于一致的状态
3. Isolated隔离线：事务允许多个用户对象头的数据进行操作，每个用户的操作不会与其他用户纠缠在一起。
4. Durable持久性：一旦事务完成，事务的结果应该持久化，这样就能从任何的系统崩溃中恢复过来。

## Spring事务的配置方式

Spring支持编程式事务管理以及声明式事务管理两种方式



### 1. 编程式事务管理

编程式事务管理是侵入性事务管理，使用TransactionTemplate或者直接使用PlatformTransactionManager，对于编程式事务管理，Spring推荐使用TransactionTemplate



### 2. 声明式事务管理

声明式事务管理建立在AOP之上，其本质是对方法前后进行拦截，然后在目标方法开始之前创建或者加入一个事务，执行完目标方法之后根据执行的情况提交或者回滚。
编程式事务每次实现都要单独实现，但业务量大功能复杂时，使用编程式事务无疑是痛苦的，而声明式事务不同，声明式事务属于无侵入式，不会影响业务逻辑的实现，只需要在配置文件中做相关的事务规则声明或者通过注解的方式，便可以将事务规则应用到业务逻辑中。

唯一不足的地方就是声明式事务管理的粒度是方法级别，而编程式事务管理是可以到代码块的，但是可以通过提取方法的方式完成声明式事务管理的配置

spring中基于XML的声明式事务控制配置步骤   

#### xml实现   

1、配置事务管理器，数据源

```xml
<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"></property>
</bean>
```

​      

2、配置事务的通知  

配置事务的属性                

> isolation：用于指定事务的隔离级别。默认值是DEFAULT，表示使用数据库的默认隔离级别。                
>
> propagation：用于指定事务的传播行为。默认值是REQUIRED，表示一定会有事务，增删改的选择。查询方法可以选择SUPPORTS。                
>
> read-only：用于指定事务是否只读。只有查询方法才能设置为true。默认值是false，表示读写。                
>
> timeout：用于指定事务的超时时间，默认值是-1，表示永不超时。如果指定了数值，以秒为单位。               
>
> rollback-for：用于指定一个异常，当产生该异常时，事务回滚，产生其他异常时，事务不回滚。没有默认值。表示任何异常都回滚。                
>
> no-rollback-for：用于指定一个异常，当产生该异常时，事务不回滚，产生其他异常时事务回滚。没有默认值。表示任何异常都回滚。

   

```xml
<!-- 配置事务的通知-->
    <tx:advice id="txAdvice" transaction-manager="transactionManager">
        <tx:attributes>
            <tx:method name="*" propagation="REQUIRED" read-only="false"/>
            <tx:method name="find*" propagation="SUPPORTS" read-only="true"></tx:method>
        </tx:attributes>
    </tx:advice>
```



3、配置AOP中的通用切入点表达式

4、建立事务通知和切入点表达式的对应关系

```xml
 <!-- 配置aop-->
    <aop:config>
        <!-- 配置切入点表达式-->
        <aop:pointcut id="pt1" expression="execution(* com.itheima.service.impl.*.*(..))"></aop:pointcut>
        <!--建立切入点表达式和事务通知的对应关系 -->
        <aop:advisor advice-ref="txAdvice" pointcut-ref="pt1"></aop:advisor>
    </aop:config>
```

5，开启事务支持

```xml
<tx:annotation-driven transaction-manager="transactionManager"></tx:annotation-driven>
```



6，在service层使用dao局可以使用通知方法进行事务控制



#### 注解实现

配置文件

不要忘记配数据源

```xml
<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"></property>
</bean>
<tx:annotation-driven transaction-manager="transactionManager"></tx:annotation-driven>
<context:component-scan base-package="com.thit.servicImpl"></context:component-scan>
```

在需要控制事务的方法上添加

```java
@Transactional(propagation=Propagation.REQUIRED,readOnly=false,isolation=Isolation.REPEATABLE_READ)
public void addOrder( Order order) {
    //这个方法中再调用一些方法
    orderDao.insert(order);
    productDao.update(p);
}
```







## 事务的传播机制

> 来自网上博客内容

事务的传播性一般用在事务嵌套的场景，比如一个事务方法里面调用了另外一个事务方法，那么两个方法是各自作为独立的方法提交还是内层的事务合并到外层的事务一起提交，这就是需要事务传播机制的配置来确定怎么样执行

- PROPAGATION_REQUIRED

  ```
  Spring默认的传播机制，能满足绝大部分业务需求，如果外层有事务，则当前事务加入到外层事务，一块提交，一块回滚。如果外层没有事务，新建一个事务执行
  ```

- PROPAGATION_REQUES_NEW

  ```
  该事务传播机制是每次都会新开启一个事务，同时把外层事务挂起，当当前事务执行完毕，恢复上层事务的执行。如果外层没有事务，执行当前新开启的事务即可
  ```

- PROPAGATION_SUPPORT

  ```
  如果外层有事务，则加入外层事务，如果外层没有事务，则直接使用非事务方式执行。完全依赖外层的事务
  ```

- PROPAGATION_NOT_SUPPORT

  ```
  该传播机制不支持事务，如果外层存在事务则挂起，执行完当前代码，则恢复外层事务，无论是否异常都不会回滚当前的代码
  ```

- PROPAGATION_NEVER

  ```
  该传播机制不支持外层事务，即如果外层有事务就抛出异常
  ```

- PROPAGATION_MANDATORY

  ```
  与NEVER相反，如果外层没有事务，则抛出异常
  ```

- PROPAGATION_NESTED

  ```
  该传播机制的特点是可以保存状态保存点，当前事务回滚到某一个点，从而避免所有的嵌套事务都回滚，即各自回滚各自的，如果子事务没有把异常吃掉，基本还是会引起全部回滚的
  ```

  

## 事务的隔离级别

事务的隔离级别定义一个事务可能受其他并发务活动活动影响的程度，可以把事务的隔离级别想象为这个事务对于事物处理数据的自私程度

在一个典型的应用程序中，多个事务同时运行，经常会为了完成他们的工作而操作同一个数据。并发虽然是必需的，但是会导致以下问题：

1. 脏读（Dirty read）

   ```
   脏读发生在一个事务读取了被另一个事务改写但尚未提交的数据时。如果这些改变在稍后被回滚了，那么第一个事务读取的数据就会是无效的
   ```

2. 不可重复读（Nonrepeatable read）

   ```
   不可重复读发生在一个事务执行相同的查询两次或两次以上，但每次查询结果都不相同时。这通常是由于另一个并发事务在两次查询之间更新了数据
   ```

   3.幻读（Phantom reads）

```
幻读和不可重复读相似。当一个事务（T1）读取几行记录后，另一个并发事务（T2）插入了一些记录时，幻读就发生了。在后来的查询中，第一个事务（T1）就会发现一些原来没有的额外记录
```

在理想状态下，事务之间将完全隔离，从而可以防止这些问题发生。然而，完全隔离会影响性能，因为隔离经常涉及到锁定在数据库中的记录（甚至有时是锁表）。

完全隔离要求事务相互等待来完成工作，会阻碍并发，因此，可以根据业务场景选择不同的隔离级别。

| 隔离级别                   | 含义                                                         |
| -------------------------- | ------------------------------------------------------------ |
| ISOLATION_DEFAULT          | 使用后端数据库默认的隔离级别                                 |
| ISOLATION_READ_UNCOMMITTED | 允许读取尚未提交的更改。可能导致脏读、幻读或不可重复读。     |
| ISOLATION_READ_COMMITTED   | （Oracle 默认级别）允许从已经提交的并发事务读取。可防止脏读，但幻读和不可重复读仍可能会发生。 |
| ISOLATION_REPEATABLE_READ  | （MYSQL默认级别）对相同字段的多次读取的结果是一致的，除非数据被当前事务本身改变。可防止脏读和不可重复读，但幻读仍可能发生。 |
| ISOLATION_SERIALIZABLE     | 完全服从ACID的隔离级别，确保不发生脏读、不可重复读和幻影读。这在所有隔离级别中也是最慢的，因为它通常是通过完全锁定当前事务所涉及的数据表来完成的。 |

## 只读

如果一个事务只对数据库执行读操作，那么该数据库就可能利用那个事务的只读特性，采取某些优化措施。通过把一个事务声明为只读，可以给后端数据库一个机会来应用那些它认为合适的优化措施。由于只读的优化措施是在一个事务启动时由后端数据库实施的， 因此，只有对于那些具有可能启动一个新事务的传播行为（PROPAGATION_REQUIRES_NEW、PROPAGATION_REQUIRED、 ROPAGATION_NESTED）的方法来说，将事务声明为只读才有意义。

## 事务超时

为了使一个应用程序很好地执行，它的事务不能运行太长时间。因此，声明式事务的下一个特性就是它的超时。

假设事务的运行时间变得格外的长，由于事务可能涉及对数据库的锁定，所以长时间运行的事务会不必要地占用数据库资源。这时就可以声明一个事务在特定秒数后自动回滚，不必等它自己结束。

由于超时时钟在一个事务启动的时候开始的，因此，只有对于那些具有可能启动一个新事务的传播行为（PROPAGATION_REQUIRES_NEW、PROPAGATION_REQUIRED、ROPAGATION_NESTED）的方法来说，声明事务超时才有意义。

## 回滚规则

在默认设置下，事务只在出现运行时异常（runtime exception）时回滚，而在出现受检查异常（checked exception）时不回滚（这一行为和EJB中的回滚行为是一致的）。
不过，可以声明在出现特定受检查异常时像运行时异常一样回滚。同样，也可以声明一个事务在出现特定的异常时不回滚，即使特定的异常是运行时异常。