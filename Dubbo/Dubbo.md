# 一，分布式基础概念

## 1，分布式系统

“分布式系统是若干独立计算机的集合，这些计算机对于用户来说就像单个相关系统”

分布式系统（distributed system）是建立在网络之上的软件系统。

## 2，发展

### 单一应用框架

当网站流量很小时，只需一个应用，将所有功能都部署在一起，以减少部署节点和成本。此时，用于简化增删改查工作量的数据访问框架(ORM)是关键。

![image-20200725070644057](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725070644057.png)

适用于小型网站，小型管理系统，将所有功能都部署到一个功能里，简单易用。

缺点： 1、性能扩展比较难

   		 2、协同开发问题

 		   3、不利于升级维护



### 垂直应用框架

当访问量逐渐增大，单一应用增加机器带来的加速度越来越小，将应用拆成互不相干的几个应用，以提升效率。

此时，用于加速前端页面开发的Web框架(MVC)是关键。

![image-20200725070936412](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725070936412.png)

通过切分业务来实现各个模块独立部署，降低了维护和部署的难度，团队各司其职更易管理，性能扩展也更方便，更有针对性。

缺点： 公用模块无法重复利用，开发性的浪费



### 分布式服务框架

当垂直应用越来越多，应用之间交互不可避免，将核心业务抽取出来，作为独立的服务，逐渐形成稳定的服务中心，使前端应用能更快速的响应多变的市场需求。

此时，用于提高业务复用及整合的**分布式服务框架**(RPC)是关键

![image-20200725071128955](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725071128955.png)



### 流动计算框架

当服务越来越多，容量的评估，小服务资源的浪费等问题逐渐显现，此时需增加一个调度中心基于访问压力实时管理集群容量，提高集群利用率。

此时，用于**提高机器利用率的资源调度和治理中心**(SOA)[ Service Oriented Architecture]是关键

![image-20200725071221374](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725071221374.png)



## 3，RPC

RPC【Remote Procedure Call】

是指远程过程调用，是一种进程间通信方式，他是一种技术的思想，而不是规范。它允许程序调用另一个地址空间（通常是共享网络的另一台机器上）的过程或函数，而不用程序员显式编码这个远程调用的细节。即程序员无论是调用本地的还是远程的函数，本质上编写的调用代码基本相同。

![image-20200725071400024](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725071400024.png)

# 二，Dubbo

Apache Dubbo (incubating) |ˈdʌbəʊ| 是一款高性能、轻量级的开源Java RPC框架



它提供了三大核心能力：面向接口的远程方法调用，智能容错和负载均衡，以及服务自动注册和发现。

## 1，环境搭建

### 下载zookeeper

网址  https://archive.apache.org/dist/zookeeper/zookeeper-3.4.13/

### 解压

复制`conf`下的`zoo_sample.cfg`文件，把名字改为`zoo.cfg`

### 运行

运行`zkServer.cmd`，再运行`zkCli.cmd`

### 安装admin管理控制台

下载 https://github.com/apache/incubator-dubbo-ops

修改 `src\main\resources\application.properties` 指定zookeeper地址

```properties
spring.guest.password=guest
dubbo.registry.address=zookeeper://127.0.0.1:2181
```

打包

```
mvn clean package -Dmaven.test.skip=true
```

运行

```
java -jar dubbo-admin-0.0.1-SNAPSHOT.jar
```







## 2，使用

### 提供者

导入`pom`文件

```xml
<!-- 引入dubbo -->
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>dubbo</artifactId>
			<version>2.6.2</version>
		</dependency>
<!-- 
dubbo 2.6以前的版本引入zkclient操作zookeeper 
dubbo 2.6及以后的版本引入curator操作zookeeper
下面两个zk客户端根据dubbo版本2选1即可
-->
		<dependency>
			<groupId>com.101tec</groupId>
			<artifactId>zkclient</artifactId>
			<version>0.10</version>
		</dependency>

		<!-- curator-framework -->
		<dependency>
			<groupId>org.apache.curator</groupId>
			<artifactId>curator-framework</artifactId>
			<version>2.12.0</version>
		</dependency>
```

配置文件

```xml
	<!--当前应用的名字  -->
	<dubbo:application name="gmall-user"></dubbo:application>
	<!--指定注册中心的地址  -->
    <dubbo:registry address="zookeeper://118.24.44.169:2181" />
    <!--使用dubbo协议，将服务暴露在20880端口  -->
    <dubbo:protocol name="dubbo" port="20880" />


    <!-- 指定需要暴露的服务 -->
    <dubbo:service interface="com.atguigu.gmall.service.UserService" ref="userServiceImpl" />
```

注解暴露服务

```java
@Service
//使用Dubbo的Service注解
```



### 消费者

`pom`文件

```xml
<!-- 引入dubbo -->
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>dubbo</artifactId>
			<version>2.6.2</version>
		</dependency>

<!-- 由于我们使用zookeeper作为注册中心，所以需要引入zkclient和curator操作zookeeper -->
		<dependency>
			<groupId>com.101tec</groupId>
			<artifactId>zkclient</artifactId>
			<version>0.10</version>
		</dependency>

<!-- curator-framework -->
		<dependency>
			<groupId>org.apache.curator</groupId>
			<artifactId>curator-framework</artifactId>
			<version>2.12.0</version>
		</dependency>
```

配置文件

```xml
	<!-- 应用名 -->
	<dubbo:application name="gmall-order"></dubbo:application>
	<!-- 指定注册中心地址 -->
	<dubbo:registry address="zookeeper://118.24.44.169:2181" />
	<!-- 生成远程服务代理，可以和本地bean一样使用demoService -->
	<dubbo:reference id="userService" interface="com.atguigu.gmall.service.UserService"></dubbo:reference>
```

也可以使用注解引用远程暴露服务

```java
@Reference
private Userservice userservice;
```



## 3，整合Spring-Boot

导入`pom`文件

需要`spring-boot`，`dubbo`，`curator`

```xml
<dependency>
    <groupId>com.alibaba.boot</groupId>
    <artifactId>dubbo-spring-boot-starter</artifactId>
    <version>0.2.0</version>
</dependency>
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>2.6.2</version>
</dependency>
<dependency>
    <groupId>org.apache.curator</groupId>
    <artifactId>curator-framework</artifactId>
    <version>2.12.0</version>
</dependency>
```

注意版本

![image-20200725074140667](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725074140667.png)



配置文件

提供者

```properties
#application.name就是服务名，不能跟别的dubbo提供端重复
dubbo.application.name=gmall-user

#registry.protocol 是指定注册中心协议
dubbo.registry.protocol=zookeeper

#registry.address 是注册中心的地址加端口号
dubbo.registry.address=192.168.67.159:2181

#base-package  注解方式要扫描的包
dubbo.scan.base-package=com.atguigu.gmall

#protocol.name 是分布式固定是dubbo,不要改。
dubbo.protocol.name=dubbo
```



**如果没有在配置中写`dubbo.scan.base-package`,还需要使用`@EnableDubbo`注解**



消费者

```properties
dubbo.application.name=gmall-order
dubbo.registry.protocol=zookeeper
dubbo.registry.address=192.168.67.159:2181
dubbo.scan.base-package=com.atguigu.gmall
dubbo.protocol.name=dubbo
```



剩下的就是使用注解



## 4，配置规则

![image-20200725074645306](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725074645306.png)

> JVM 启动 -D 参数优先，这样可以使用户在部署和启动时进行参数重写，比如在启动时需改变协议的端口。
>
> XML 次之，如果在 XML 中有配置，则 dubbo.properties 中的相应配置项无效。
>
> Properties 最后，相当于缺省值，只有 XML 没有配置时，dubbo.properties 的相应配置项才会生效，通常用于共享公共配置，比如应用名。



`dubbo`推荐在Provider上尽量多配置Consumer端属性

1、作服务的提供者，比服务使用方更清楚服务性能参数，如调用的超时时间，合理的重试次数，等等

2、在Provider配置后，Consumer不配置则会使用Provider的配置值，即Provider配置可以作为Consumer的缺省值。否则，Consumer会使用Consumer端的全局设置，这对于Provider不可控的，并且往往是不合理的



配置的覆盖规则：

1) 方法级配置别优于接口级别，即小Scope优先 

2) Consumer端配置 优于 Provider配置 优于 全局配置，

3) 最后是Dubbo Hard Code的配置值

![image-20200725075302195](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200725075302195.png)

## 5，相关配置

重启次数

失败自动切换，当出现失败，重试其它服务器，但重试会带来更长延迟

```xml
<dubbo:service retries="2" />
或
<dubbo:reference retries="2" />
或
<dubbo:reference>
    <dubbo:method name="findFoo" retries="2" />
</dubbo:reference>
```



超时时间

由于网络或服务端不可靠，会导致调用出现一种不确定的中间状态（超时）。为了避免超时导致客户端资源（线程）挂起耗尽，必须设置超时时间

消费端

```xml
全局超时配置
<dubbo:consumer timeout="5000" />

指定接口以及特定方法超时配置
<dubbo:reference interface="com.foo.BarService" timeout="2000">
    <dubbo:method name="sayHello" timeout="3000" />
</dubbo:reference>
```

服务端

```xml
全局超时配置
<dubbo:provider timeout="5000" />

指定接口以及特定方法超时配置
<dubbo:provider interface="com.foo.BarService" timeout="2000">
    <dubbo:method name="sayHello" timeout="3000" />
</dubbo:provider>
```



## 6，版本号

当一个接口实现，出现不兼容升级时，可以用版本号过渡，版本号不同的服务相互间不引用。

```xml
老版本服务提供者配置：
<dubbo:service interface="com.foo.BarService" version="1.0.0" />
新版本服务提供者配置：
<dubbo:service interface="com.foo.BarService" version="2.0.0" />


老版本服务消费者配置：
<dubbo:reference id="barService" interface="com.foo.BarService" version="1.0.0" />
新版本服务消费者配置：
<dubbo:reference id="barService" interface="com.foo.BarService" version="2.0.0" />

如果不需要区分版本，可以按照以下的方式配置：
<dubbo:reference id="barService" interface="com.foo.BarService" version="*" />
```



## 7，高可用

1、zookeeper宕机与`dubbo`直连，即zookeeper注册中心宕机，还可以消费`dubbo`暴露的服务

```properties
监控中心宕掉不影响使用，只是丢失部分采样数据
数据库宕掉后，注册中心仍能通过缓存提供服务列表查询，但不能注册新服务
注册中心对等集群，任意一台宕掉后，将自动切换到另一台

# 注册中心全部宕掉后，服务提供者和服务消费者仍能通过本地缓存通讯

服务提供者无状态，任意一台宕掉后，不影响使用
服务提供者全部宕掉后，服务消费者应用将无法使用，并无限次重连等待服务提供者恢复
```



2、集群下`dubbo`负载均衡配置

负载均衡的策略都类似，随机，轮询。。。



## 8，整合Hystrix

### 服务降级

向注册中心写入动态配置覆盖规则

```java
RegistryFactory registryFactory = ExtensionLoader.getExtensionLoader(RegistryFactory.class).getAdaptiveExtension();

Registry registry = registryFactory.getRegistry(URL.valueOf("zookeeper://10.20.153.10:2181"));

registry.register(URL.valueOf("override://0.0.0.0/com.foo.BarService?category=configurators&dynamic=false&application=foo&mock=force:return+null"));
```



l mock=force:return+null 表示消费方对该服务的方法调用都直接返回 null 值，不发起远程调用。用来屏蔽不重要服务不可用时对调用方的影响。

l 还可以改为 mock=fail:return+null 表示消费方对该服务的方法调用在失败后，再返回 null 值，不抛异常。用来容忍不重要服务不稳定时对调用方的影响。



### 集群容错

在集群调用失败时，Dubbo 提供了多种容错方案

```xml
Failover Cluster
失败自动切换，当出现失败，重试其它服务器。通常用于读操作，但重试会带来更长延迟。可通过 retries="2" 来设置重试次数(不含第一次)。

重试次数配置如下：
<dubbo:service retries="2" />
或
<dubbo:reference retries="2" />
或
<dubbo:reference>
    <dubbo:method name="findFoo" retries="2" />
</dubbo:reference>

Failfast Cluster
快速失败，只发起一次调用，失败立即报错。通常用于非幂等性的写操作，比如新增记录。

Failsafe Cluster
失败安全，出现异常时，直接忽略。通常用于写入审计日志等操作。

Failback Cluster
失败自动恢复，后台记录失败请求，定时重发。通常用于消息通知操作。

Forking Cluster
并行调用多个服务器，只要一个成功即返回。通常用于实时性要求较高的读操作，但需要浪费更多服务资源。可通过 forks="2" 来设置最大并行数。

Broadcast Cluster
广播调用所有提供者，逐个调用，任意一台报错则报错 [2]。通常用于通知所有提供者更新缓存或日志等本地资源信息。

集群模式配置
按照以下示例在服务提供方和消费方配置集群模式
<dubbo:service cluster="failsafe" />
或
<dubbo:reference cluster="failsafe" />
```



`pom`文件

配置`spring-cloud-starter-netflix-hystrix`

```xml
<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
            <version>1.4.4.RELEASE</version>
</dependency>
```

然后在Application类上增加`@EnableHystrix`来启用`hystrix starter`

```java
@SpringBootApplication
@EnableHystrix
public class ProviderApplication {}
```



提供者

在`Dubbo`的Provider上增加`@HystrixCommand`配置，这样子调用就会经过`Hystrix`代理

```java
@Service(version = "1.0.0")
public class HelloServiceImpl implements HelloService {
    @HystrixCommand(commandProperties = {
    @HystrixProperty(name = "circuitBreaker.requestVolumeThreshold", value = "10"),
    @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds", value = "2000") })
    @Override
    public String sayHello(String name) {
        // System.out.println("async provider received: " + name);
        // return "annotation: hello, " + name;
        throw new RuntimeException("Exception to show hystrix enabled.");
    }
}
```

消费者

对于Consumer端，则可以增加一层method调用，并在method上配置`@HystrixCommand`。当调用出错时，会走到`fallbackMethod = "reliable"`的调用里

```java
    @Reference(version = "1.0.0")
    private HelloService demoService;

    @HystrixCommand(fallbackMethod = "reliable")
    public String doSayHello(String name) {
        return demoService.sayHello(name);
    }
    public String reliable(String name) {
        return "hystrix fallback value";
    }
```

