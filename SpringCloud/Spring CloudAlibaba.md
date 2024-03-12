# Spring CloudAlibaba

**之所以有Spring CloudAlibaba,是因为Spring Cloud Netflix项目进入维护模式**

**也就是,就不是不更新了,不会开发新组件了**

==支持的功能==

![](./图片/Alibaba的1.png)



Spring Cloud alibaba 主要功能及对应组件

  (一）服务的注册与发现(对标Netflix的Eureka译音尤利卡)： Nacos

（二）负载均衡Ribbo

（三）声明式HTTP客户端Feign

  (四）服务容错Sentinel

  (五）消息驱动RocketMQ

  (六）API网关GateWay( 可以集成开源的Soul网关或者 spring Cloud Gateway）

 (七）配置管理Nacos

 (八）调用链监控Sleuth

 (九）服务限流降级（即熔断限流，对标Hystrix）：Sentinel：把流量作为切入点，从流量控制、熔断降级、系统负载保护等多个维度保护服务的稳定性。

（十）分布式配置管理：Alibaba Cloud ACM：一款在分布式架构环境中对应用配置进行集中管理和推送的应用配置中心产品。

（十一）分布式事务： Seata：阿里巴巴开源产品，一个易于使用的高性能微服务分布式事务解决方案。

（十二）阿里云对象存储（收费）： Alibaba Cloud OSS: 阿里云对象存储服务（Object Storage Service，简称 OSS），是阿里云提供的海量、安全、低成本、高可靠的云存储服务

（十三）分布式任务调度（收费）：Alibaba Cloud SchedulerX: 阿里中间件团队开发的一款分布式任务调度产品，提供秒级、精准、高可靠、高可用的定时（基于 Cron 表达式）任务调度服务。

（十四）阿里云短信服务（收费）：Alibaba Cloud SMS: 覆盖全球的短信服务，友好、高效、智能的互联化通讯能力，帮助企业迅速搭建客户触达通道。

（十五）用户认证与授权




## Nacos

**服务注册和配置中心的组合**：Nacos=erueka+config+bus

**为什么Nacos支持负载均衡?**

​				Nacos直接集成了Ribon,所以有负载均衡

### 安装Nacos

1，需要java8  和 Mavne

```
https://github.com/alibaba/nacos/tags
```

2,启动Nacos，进入bin目录，cmd运行 startup.cmd

3,访问Nacos

账号密码:默认都是nacos

```
localhost:8848/nacos
```

其实，启动了nacos就已经是作为服务注册中心了

版本选择 

https://github.com/alibaba/spring-cloud-alibaba/wiki/%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E

### 提供者

名字: cloudalibaba-pay-9001

父项目管理alibaba的依赖:

```xml
<!--spring cloud 阿里巴巴-->
<dependency>
  <groupId>com.alibaba.cloud</groupId>
  <artifactId>spring-cloud-alibaba-dependencies</artifactId>
  <version>2.1.0.RELEASE</version>
  <type>pom</type>
  <scope>import</scope>
</dependency>
```

看了一下官方Nacos文档，SpringCloud 整合Naocs，官方的依赖不一样

父项目依赖

```xml
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-dependencies</artifactId>
  <version>${spring-cloud.version}</version>
  <type>pom</type>
  <scope>import</scope>
</dependency>
```

子项目依赖

```xml
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
  <version>0.2.1.RELEASE</version>
</dependency>
<!--服务注册和发现-->
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
  <version>0.2.1.RELEASE</version>
</dependency>
```

-

> 如果是这么写的，那么就需要注意了
>
> 子项目依赖中nacos需要有一个bootstrap.properties文件，来配置Nacos信息
>
> 不然就爆出配置文件缺失的is null 异常
>
> 第二种是只需要springcloudalibab的nacos

配置文件

```yml
server:
  port: 9001

spring:
  application:
    name: nacos-payment-provider 
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 #配置Nacos地址

management:
  endpoints:
    web:
      exposure:
        include: '*'
```

说明：之所以需要配置 `spring.application.name` ，是因为它是构成 Nacos 配置管理 `dataId`字段的一部分。

在 Nacos Spring Cloud 中，`dataId` 的完整格式如下：

```plain
${prefix}-${spring.profiles.active}.${file-extension}
```

- `prefix` 默认为 `spring.application.name` 的值，也可以通过配置项 `spring.cloud.nacos.config.prefix`来配置。
- `spring.profiles.active` 即为当前环境对应的 profile，详情可以参考 [Spring Boot文档](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-profiles.html#boot-features-profiles)。 **注意：当 `spring.profiles.active` 为空时，对应的连接符 `-` 也将不存在，dataId 的拼接格式变成 `${prefix}.${file-extension}`**
- `file-exetension` 为配置内容的数据格式，可以通过配置项 `spring.cloud.nacos.config.file-extension` 来配置。目前只支持 `properties` 和 `yaml` 类型。



启动类

```java
@RefreshScope
@SpringBootApplication
@EnableDiscoveryClient
public class OrderApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
}
```

注意

> SpringCloud 使用 `@RefreshScope`注解，实现配置文件的动态加载。

controller

```java
@RestController
// Spring Cloud 原生注解
@RefreshScope
public class PaymentController
{
    @Value("${useLocalCache:true}")
    private boolean useLocalCache;

    @GetMapping("/get")
    public BaseResponse get(){
        return BaseResponse.success(useLocalCache);
    }

}
```



### 消费者

配置文件

```yml
server:
  port: 83
spring:
  application:
    name: nacos-order-consumer
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848


#消费者将要去访问的微服务名称(注册成功进nacos的微服务提供者)
service-url:
  nacos-user-service: http://nacos-payment-provider
```

**这个server-url的作用是,我们在controller,需要使用RestTempalte远程调用9001,** **这里是指定9001的地址**

主启动类

```java
@EnableDiscoveryClient
@SpringBootApplication
public class OrderNacosMain83
{
    public static void main(String[] args)
    {
        SpringApplication.run(OrderNacosMain83.class,args);
    }
}
```

编写配置类

==因为Naocs要使用Ribbon进行负载均衡,那么就需要使用RestTemplate==

```java
@Configuration
public class ApplicationContextConfig
{
    @Bean
    @LoadBalanced
    public RestTemplate getRestTemplate()
    {
        return new RestTemplate();
    }
}
```

controller

```java
@RestController
@Slf4j
public class OrderNacosController
{
    @Resource
    private RestTemplate restTemplate;

    @Value("${service-url.nacos-user-service}")
    private String serverURL;

    @GetMapping(value = "/consumer/payment/nacos/{id}")
    public String paymentInfo(@PathVariable("id") Long id)
    {
        return restTemplate.getForObject(serverURL+"/payment/nacos/"+id,String.class);
    }

}
```

测试

启动83,访问9001,9002,可以看到,实现了负载均衡





### 与其他服务注册的对比

Nacos它既可以支持CP,也可以支持AP,可以切换

![](./图片/Alibaba的12.png)

![](./图片/Alibaba的13.png)



==下面这个curl命令,就是切换模式==



### 配置中心

![](./图片/Alibaba的14.png)



**==需要创建配置中心的客户端模块==**



pom

配置文件

这里需要配置两个配置文件,application.yml和bootstarp.yml，主要是为了可以与spring clodu config无缝迁移

bootstarp.yml

```yml
# nacos配置
server:
  port: 3377

spring:
  application:
    name: nacos-config-client
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848 #Nacos服务注册中心地址
      config:
        server-addr: localhost:8848 #Nacos作为配置中心地址
        file-extension: yaml #指定yaml格式的配置
        group: DEV_GROUP
        namespace: 7d8f0f5a-6a53-4785-9686-dd460158e5d4


# ${spring.application.name}-${spring.profile.active}.${spring.cloud.nacos.config.file-extension}
# nacos-config-client-dev.yaml

# nacos-config-client-test.yaml   ----> config.info
```

application.yml

```yml
spring:
  profiles:
    active: dev # 表示开发环境
    #active: test # 表示测试环境
    #active: info
```

主启动类

```java
@EnableDiscoveryClient
@SpringBootApplication
public class NacosConfigClientMain3377
{
    public static void main(String[] args) {
        SpringApplication.run(NacosConfigClientMain3377.class, args);
    }
}
```

controller

```java
@RestController
@RefreshScope //支持Nacos的动态刷新功能。
public class ConfigClientController
{

    @GetMapping("/config/info")
    public String getConfigInfo() {
        return "configInfo";
    }
}
```



```java
可以看到,这里也添加了@RefreshScope
  		之前在Config配置中心,也是添加这个注解实现动态刷新的	
```



在Nacos添加配置信息:

**Nacos的配置规则:**

**配置规则,就是我们在客户端如何指定读取配置文件,配置文件的命名的规则**

默认的命名方式:

![](./图片/Alibaba的21.png)

```java
prefix: 默认就是当前服务的服务名称,即spring.application.name的值
        也可以通过spring.cloud.necos.config.prefix配置
    
spring.profile.active:
	   就是我们在application.yml中指定的,当前是开发环境还是测试等环境，dev,test等等
       这个可以不配置,如果不配置,那么前面的 -  也会没有

file-extension：
     就是当前文件的格式(后缀),目前只支持yml和properties
```



![](./图片/Alibaba的25.png)



配置文件不需要像cloud config一样，通过github挂载配置文件，nacos自带配置中心



注意,DataId就是配置文件名字:

​		名字一定要按照上面的==规则==命名,否则客户端会读取不到配置文件



注意，默认就开启了自动刷新

此时我们修改了配置文件

客户端是可以立即更新的

因为Nacos支持Bus总线,会自动发送命令更新所有客户端



#### 分类配置



![](./图片/Alibaba的29.png)

NameSpace默认有一个:public名称空间

这三个类似java的: 包名 + 类名 + 方法名

NameSpace区分部署环境

默认是: Namespace=public，Group=DEFAULT_GROUP，Cluster=DEFAULT

一个service可以包含多个Cluster(集群)，集群是对指定微服务的一个虚拟划分，比如杭州机房的Service微服务叫一个集群名（HZ），广州的叫（GZ）



#### DataId

只需要修改配置规则中的 {spring.profile.active} 就可以了

例子

```
nacos-config-dev.yaml
nacos-config-test.yaml
```

通过配置文件,实现多环境的读取:

在application.yml文件中配置

```
spring.profiles.active = test
```

配置test就是使用test的，配置dev就是使用dev的





#### GroupID

直接在新建配置文件时指定组



在客户端配置,使用指定组的配置文件:

**两个配置文件都要修改**

![](./图片/Alibaba的38.png)

​	

#### 命名空间

先创建一个命名空间，再去指定的空间下创建配置文件

客户端配置使用不同名称空间:

![](./图片/Alibaba的41.png)





### Nacos集群和持久化配置:

![](./图片/Alibaba的45.png)

Nacos默认有自带嵌入式数据库,derby,但是如果做集群模式的话,就不能使用自己的数据库

​			不然每个节点一个数据库,那么数据就不统一了,需要使用外部的mysql

![](./图片/Alibaba的43.png)



#### 一,切换mysql数据库

**1,nacos默认自带了一个sql文件,在nacos的conf目录下**

**2,修改Nacos安装目录下的安排application.properties,添加:**

```properties
#*************** Config Module Related Configurations ***************#
### If user MySQL as datasource:
spring.datasource.platform=mysql

### Count of DB:
db.num=1

### Connect URL of DB:
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true
db.user=root
db.password=wstujunjie2
```





#### Linux上配置Nacos集群+Mysql数据库

==官方架构图:==

![](./图片/Alibaba的45.png)

**需要一个Nginx作为VIP**



1,下载安装Nacos的Linux版安装包

2,进入安装目录,现在执行自带的sql文件

​			进入mysql,执行sql文件

3.修改配置文件,切换为我们的mysql

​			就是上面windos版要修改的几个属性

4,修改cluster.conf,指定哪几个节点是Nacos集群

​			这里使用3333,4444,5555作为三个Nacos节点监听的端口

![](./图片/Alibaba的47.png)

5,我们这里就不配置在不同节点上了,就放在一个节点上

​			既然要在一个节点上启动不同Nacos实例,就要修改startup.sh,使其根据不同端口启动不同Nacos实例

![](./图片/Alibaba的48.png)

![](./图片/Alibaba的49.png)

可以看到,这个脚本就是通过jvm启动nacos

​		所以我们最后修改的就是,nohup java -Dserver.port=3344





6,配置Nginx:

​			![](./图片/Alibaba的50.png)

7,启动Nacos:
			./startup.sh -p 3333

​			./startup.sh -p 4444

​			./startup.sh -p 5555

7,启动nginx

8,测试:

​		访问192.168.159.121:1111

​		如果可以进入nacos的web界面,就证明安装成功了





9,将微服务注册到Nacos集群:
![](./图片/Alibaba的51.png)

10,进入Nacos的web界面

​		可以看到,已经注册成功

![](./图片/Alibaba的52.png)











## Sentinel

实现熔断与限流,就是Hystrix

![](./图片/Alibaba的53.png)



### 使用sentinel



1,下载sentinel的jar包

2,运行sentinel

由于是一个jar包,所以可以直接java -jar运行	

> 注意，默认sentinel占用8080端口
>

3,访问sentinel

```
localhost:8080
```





### 微服务整合sentinel:

##### 1,启动Nacos

##### 2,新建一个项目,8401,主要用于配置cloud-sentinel-8041

1. pom
2. 配置文件

```yaml
server:
  port: 8401
spring:	
  application:
    name: cloudalibaba-sentinel-service
  cloud:
    nacos:
      discovery:
        server-addr: localhost:3333
      sentinel:
        transport:
          dasnboard: localhost:8080
          port: 8719
management:
  endpoints:
    web:
      exposure:
        include: '*'
```



1. 主启动类

   ```java
   @EnableDiscoveryClient
   @SpringBootApplication
   public class MainApp8401 {
       public static void main(String[] args) {
           SpringApplication.run(MainApp8401.class,args);
       }
   }
   ```

2. controller

```java
@RestController
public class a {
    @GetMapping("/ta")
    public String tA(){
        return "tq";
    }
}
```

到这里就可以启动8401，但是控制台第一次不会显示，需要我们 访问一次接口了才会有

> sentinel是懒加载
>



### 流控规则

流量限制控制规则

资源名：唯一的名称，默认请求路径

阈值类型/单击阈值

1，QPS（每秒钟的请求量）：当调用API的QPS打到一定的阈值时，就会进行限流

2，线程数：调用API的线程数达到一定的阈值进行限流

> 比如a请求过来,处理很慢,在一直处理,此时b请求又过来了
> 此时因为a占用一个线程,此时要处理b请求就只有额外开启一个线程
> 那么就会报错

#### 流控模式

1，直接：达到条件，直接限流



2，关联：关联的资源达到条件时，就限流自己

> 应用场景:  比如**支付接口**达到阈值,就要限流下**订单的接口**,防止一直有订单



3，链路：指定资源入口进来的流量，达到阈值就限流

#### 流控效果

1，快速失败：直接失败

2，Warm up：当突然有大量的请求时，会根据CodeFactor(冷加载因子的值，3)，通过计算阈值除以CodeFactor的值得出预热时间，在这段时间内，慢慢的达到设定的阈值

> 应用场景：秒杀系统在开启的一瞬间就会有很多的流量，很有可以使系统瘫痪，这个时候就需要预热，慢慢的放流量

3，排队等待:	匀速排队，请求均匀通过，阈值类型必须设置为QPS，否者无效

> 若超过就等待，等待的超时时间





### 降级规则

**熔断降级**



![](./图片/sentinel的22.png)

![](./图片/sentinel的23.png)



#### 1,RT配置:

这里配置的PT,默认是秒级的平均响应时间

默认计算平均时间是: 1秒类进入5个请求,并且响应的平均值超过阈值(这里的200ms),就报错]

​			1秒5请求是Sentinel默认设置的

#### 2,异常比例:

即当资源的每秒请求量>=5，并且出现异常的请求占所有通过的请求数的壁纸大于阈值，就会降级

如果没触发熔断,就会正常抛出异常

#### 3, 异常数:

一分钟内异常数超过阈值就会熔断

若timewindow小于60s，则熔断结束后任有可能进入通断状态

所以要设置时间窗口大于60s







### 热点规则

对于经常访问的数据，我们可能会在某个时间段内对具体的数据进行限流

> 商品ID为参数，针对在统一时间内内最常购买的商品ID进行限制
>
> 用户ID为参数，针对在统一时间内内频繁访问的用户ID进行限制



自定义降级方法,而不是默认的抛出异常，也就是兜底方法



**使用@SentinelResource直接实现降级方法,它等同Hystrix的@HystrixCommand**

```java
 	@GetMapping("/ta")
    @SentinelResource(value = "tA",blockHandler = "deal")
    public String tA(){
        return "tq";
    }

    public String deal(){
        return "失败";
    }
```

定义热点规则:

 即当带有参数索引对应的参数的请求超过了阈值，就会降级![](./图片/sentinel的40.png)





设置热点规则中的其他选项

当我们期望参数是某个特定值时，阈值可以改变，这时就需要参数例外项

![](./图片/sentinel的45.png)



**注意:**

参数类型只支持,8种基本类型+String类



注意:

如果我们程序出现异常,是不会走blockHander的降级方法的,因为这个方法只配置了热点规则,没有配置限流规则

我们这里配置的降级方法是sentinel针对热点规则配置的

只有触发热点规则才会降级







### 系统规则:

系统自适应限流:
			从整体维度对应用入口进行限流

对整体限流,比如设置qps到达100,这里限流会限制整个系统

![](./图片/sentinel的52.png)



### @SentinelResource注解:

**用于配置降级等功能**

1,环境搭建

1. 为8401添加依赖

   添加我们自己的commone包的依赖，可以使用payment支付Entity

2. 创建一个controller类

   ​	![](./图片/sentinel的56.png)

    

3. 配置限流

   **注意,我们这里配置规则,资源名指定的是@SentinelResource注解value的值,**

   **这样也是可以的,也就是不一定要指定访问路径**

   

5. 此时我们关闭8401服务，可以看到,这些定义的规则是临时的,关闭服务,规则就没有了




**可以看到,上面配置的降级方法,又出现Hystrix遇到的问题了**

​			降级方法与业务方法耦合

​			每个业务方法都需要对应一个降级方法

#### 自定义限流处理逻辑:

1. 单独创建一个类,用于处理限流

   ![](./图片/sentinel的的1.png)

2. 在controller中,指定使用自定义类中的方法作为降级方法

   ![](./图片/sentinel的的2.png)


#### @SentinelResource注解的其他属性:

@SentinelResource 注解

> 注意：注解方式埋点不支持 private 方法。

`@SentinelResource` 用于定义资源，并提供可选的异常处理和 fallback 配置项。 `@SentinelResource` 注解包含以下属性：

- `value`：资源名称，必需项（不能为空）
- `entryType`：entry 类型，可选项（默认为 `EntryType.OUT`）
- `blockHandler` / `blockHandlerClass`: `blockHandler` 对应处理 `BlockException` 的函数名称，可选项。blockHandler 函数访问范围需要是 `public`，返回类型需要与原方法相匹配，参数类型需要和原方法相匹配并且最后加一个额外的参数，类型为 `BlockException`。blockHandler 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `blockHandlerClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 static 函数，否则无法解析

```
用来处理配置异常
```



- `fallback/fallbackClass`：fallback 函数名称，可选项，用于在抛出异常的时候提供 fallback 处理逻辑。fallback 函数可以针对所有类型的异常（除了exceptionsToIgnore里面排除掉的异常类型）进行处理。fallback 函数签名和位置要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要和原函数一致，或者可以额外多一个 `Throwable` 类型的参数用于接收对应的异常。
  - fallback 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `fallbackClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 static 函数，否则无法解析

```
用来处理java异常
```



- `defaultFallback`（since 1.6.0）：默认的 fallback 函数名称，可选项，通常用于通用的 fallback 逻辑（即可以用于很多服务或方法）。默认 fallback 函数可以针对所有类型的异常（除了exceptionsToIgnore里面排除掉的异常类型）进行处理。若同时配置了 fallback 和 defaultFallback，则只有 fallback 会生效。defaultFallback 函数签名要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要为空，或者可以额外多一个 `Throwable` 类型的参数用于接收对应的异常。
  - defaultFallback 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 `fallbackClass` 为对应的类的 `Class` 对象，注意对应的函数必需为 static 函数，否则无法解析。
- `exceptionsToIgnore`（since 1.6.0）：用于指定哪些异常被排除掉，不会计入异常统计中，也不会进入 fallback 逻辑中，而是会原样抛出。













### 服务熔断:

1. **启动nacos和sentinel**

2. **新建两个pay模块  9003和9004**

   1. pom

   2. 配置文件

      ![](./图片/sentinel的的8.png)*

   3. 主启动类 

      ```java
      @SpringBootApplication
      @EnableDiscoveryClient
      public class PaymentMain9003 {
      
          public static void main(String[] args) {
              SpringApplication.run(PaymentMain9003.class,args);
          }
      }
       
      
      ```

   4. controller

      ![](./图片/sentinel的的9.png)

       **然后启动9003.9004**

3. **新建一个order-84消费者模块:**

   1. pom

      与上面的pay一模一样

   2. 配置文件

      ![](./图片/sentinel的的10.png)

   3. 主启动类

      ![](./图片/sentinel的的11.png)

   4. 配置类

      ![](./图片/sentinel的的12.png)

   5. controller

      ![](./图片/sentinel的的13.png)

      

   6. **==为业务方法添加fallback来指定降级方法==**:

      ![](./图片/sentinel的的14.png)

      ​	==重启order==

      测试:

      ![](./图片/sentinel的的15.png)

       

       ==所以,fallback是用于管理异常的,当业务方法发生异常,可以降级到指定方法==

      ​			注意,我们这里==并没有使用sentinel配置任何规则==,但是却降级成功,就是因为

      ​			fallback是用于管理异常的,当业务方法发生异常,可以降级到指定方法==

      

   7. **==为业务方法添加blockHandler,看看是什么效果==**

      ![](./图片/sentinel的的16.png)

      **重启84,访问业务方法:**

      ![](./图片/sentinel的的17.png)

       可以看到.,直接报错了,并没有降级

      ​				也就是说,blockHandler==只对sentienl定义的规则降级==

       

   8. **==如果fallback和blockHandler都配置呢?==**]

      ![](./图片/sentinel的的18.png)

      **设置qps规则,阈值1**

      ![](./图片/sentinel的的19.png)

      ==测试:==

      ![](./图片/sentinel的的20.png)

       

       可以看到,当两个都同时生效时,==blockhandler优先生效==

   9. **==@SentinelResource还有一个属性,exceptionsToIgnore==**

       ![](./图片/sentinel的的21.png)

       **exceptionsToIgnore指定一个异常类,**

      ​					**表示如果当前方法抛出的是指定的异常,不降级,直接对用户抛出异常**

       ![](./图片/sentinel的的22.png)

       

       

   



### sentinel整合ribbon+openFeign+fallback



1. 修改84模块,使其支持feign

   1. pom

      ![](./图片/sentinel的的23.png)

   2. 配置文件

      ![](./图片/sentinel的的24.png)

   3. 主启动类,也要修改

      ![](./图片/sentinel的的25.png)

   4. 创建远程调用pay模块的接口

      ![](./图片/sentinel的的26.png)

   5. 创建这个接口的实现类,用于降级

      ![](./图片/sentinel的的27.png)

   6. 再次修改接口,指定降级类

      ![](./图片/sentinel的的28.png)

   7. controller添加远程调用

      ![](./图片/sentinel的的29.png)

   8. 测试

      启动9003,84

   9. 测试,如果关闭9003.看看84会不会降级

      ![](./图片/sentinel的的30.png)

      **可以看到,正常降级了**

      

**熔断框架比较**

![](./图片/sentinel的的31.png)









### sentinel持久化规则

默认规则是临时存储的,重启sentinel就会消失

![](./图片/sentinel的的32.png)

**这里以之前的8401为案例进行修改:**

1. 修改8401的pom

   ```xml
   添加:
   <!-- SpringCloud ailibaba sentinel-datasource-nacos 持久化需要用到-->
   <dependency>
       <groupId>com.alibaba.csp</groupId>
       <artifactId>sentinel-datasource-nacos</artifactId>
   </dependency>
    
   ```

   

2. 修改配置文件:

   添加:

    ![](./图片/sentinel的的33.png)

    **实际上就是指定,我们的规则要保证在哪个名称空间的哪个分组下**

    			这里没有指定namespace, 但是是可以指定的

   ​			**注意,这里的dataid要与8401的服务名一致**

3. **在nacos中创建一个配置文件,dataId就是上面配置文件中指定的**

   ![](./图片/sentinel的的34.png)

   ==json中,这些属性的含义:==

   ​	![](./图片/sentinel的的35.png)

    

   

4. 启动8401:

   ![](./图片/sentinel的的36.png)

   可以看到,直接读取到了规则

5. 关闭8401

   ![](./图片/sentinel的的37.png)

6. 此时重启8401,如果sentinel又可以正常读取到规则,那么证明持久化成功

   可以看到,又重新出现了

    ![](./图片/sentinel的的38.png)

   























## Seata:

是一个分布式事务的解决方案,

**分布式事务中的一些概念,也是seata中的概念:**

​		![](./图片/seala.png)

![](./图片/seala的2.png)

![](./图片/seala的3.png)





### seata安装:

1. **下载安装seata的安装包**

2. **修改file.conf**

    ```properties
    store {
      ## store mode: file、db
      mode = "db" # 表示使用哪种数据库存储事务
    ```

    

    ```properties
    service {
      #transaction service group mapping
      vgroup_mapping.my_test_tx_group = "fsp_tx_group"  # 随便取一个组名
      #only support when registry.type=file, please don't set multiple addresses
      default.grouplist = "127.0.0.1:8091"
      #disable seata
      disableGlobalTransaction = false
    }
    ```

    

    ```properties
    db {
        ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp) etc.
        datasource = "dbcp"
        ## mysql/oracle/h2/oceanbase etc.
        db-type = "mysql"
        driver-class-name = "com.mysql.jdbc.Driver"
        url = "jdbc:mysql://127.0.0.1:3306/seata"
        user = "root"
        password = "wstujunjie2"
      }
    ```

    

3. **mysql建库建表**

   1,上面指定了数据库为seata,所以创建一个数据库名为seata

   2,建表,在seata的安装目录下有一个db_store.sql,运行即可

4. **继续修改配置文件,修改registry.conf**

   配置seata作为微服务,指定注册中心

   

   ```properties
   # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
     type = "nacos" 
     # 选择注册中心
   
     nacos {
     # 指定地址
       serverAddr = "localhost:8848" 
       namespace = ""
       cluster = "default"
     }
   ```

5. 启动

   先启动nacos

   在启动seata-server(运行安装目录下的,seata-server.bat)

   

**业务说明**

下单--->库存--->账号余额



1. 创建三个数据库

   ![](./图片/seala的9.png)

2. 创建对应的表

   ![](./图片/seala的10.png)

3. 创建回滚日志表,方便查看

   ![](./图片/seala的11.png)

   **注意==每个库都要执行一次==这个sql,生成回滚日志表**

4. ==每个业务都创建一个微服务,也就是要有三个微服务,订单,库存,账号==

   ​     ==订单==,seta-order-2001

   1. pom

   2. 配置文件

      ```yaml
      server:
        port: 2001
      
      spring:
        application:
          name: seata-order-service
        cloud:
          alibaba:
            seata:
              # 自定义事务组名称需要与seata-server中的对应,我们之前在seata的配置文件中配置的名字
              tx-service-group: fsp_tx_group
          nacos:
            discovery:
              server-addr: 127.0.0.1:8848
        datasource:
          # 当前数据源操作类型
          type: com.alibaba.druid.pool.DruidDataSource
          # mysql驱动类
          driver-class-name: com.mysql.cj.jdbc.Driver
          url: jdbc:mysql://localhost:3306/seata_order?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=GMT%2B8
          username: root
          password: root
      feign:
        hystrix:
          enabled: false
      logging:
        level:
          io:
            seata: info
      
      mybatis:
        mapperLocations: classpath*:mapper/*.xml
      
       
       
      
      ```

      还要额外创建其他配置文件,创建一个file.conf:

       ```.conf
      transport {
        # tcp udt unix-domain-socket
        type = "TCP"
        #NIO NATIVE
        server = "NIO"
        #enable heartbeat
        heartbeat = true
        #thread factory for netty
        thread-factory {
          boss-thread-prefix = "NettyBoss"
          worker-thread-prefix = "NettyServerNIOWorker"
          server-executor-thread-prefix = "NettyServerBizHandler"
          share-boss-worker = false
          client-selector-thread-prefix = "NettyClientSelector"
          client-selector-thread-size = 1
          client-worker-thread-prefix = "NettyClientWorkerThread"
          # netty boss thread size,will not be used for UDT
          boss-thread-size = 1
          #auto default pin or 8
          worker-thread-size = 8
        }
        shutdown {
          # when destroy server, wait seconds
          wait = 3
        }
        serialization = "seata"
        compressor = "none"
      }
      service {
        #vgroup->rgroup
        # 事务组名称
        vgroup_mapping.fsp_tx_group = "default"
        #only support single node
        default.grouplist = "127.0.0.1:8091"
        #degrade current not support
        enableDegrade = false
        #disable
        disable = false
        #unit ms,s,m,h,d represents milliseconds, seconds, minutes, hours, days, default permanent
        max.commit.retry.timeout = "-1"
        max.rollback.retry.timeout = "-1"
      }
       
      client {
        async.commit.buffer.limit = 10000
        lock {
          retry.internal = 10
          retry.times = 30
        }
        report.retry.count = 5
        tm.commit.retry.count = 1
        tm.rollback.retry.count = 1
      }
       
      ## transaction log store
      store {
        ## store mode: file、db
        #mode = "file"
        mode = "db"
       
        ## file store
        file {
          dir = "sessionStore"
       
          # branch session size , if exceeded first try compress lockkey, still exceeded throws exceptions
          max-branch-session-size = 16384
          # globe session size , if exceeded throws exceptions
          max-global-session-size = 512
          # file buffer size , if exceeded allocate new buffer
          file-write-buffer-cache-size = 16384
          # when recover batch read size
          session.reload.read_size = 100
          # async, sync
          flush-disk-mode = async
        }
       
        ## database store
        db {
          ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp) etc.
          datasource = "dbcp"
          ## mysql/oracle/h2/oceanbase etc.
          db-type = "mysql"
          driver-class-name = "com.mysql.jdbc.Driver"
          url = "jdbc:mysql://127.0.0.1:3306/seata"
          user = "root"
          password = "root"
          min-conn = 1
          max-conn = 3
          global.table = "global_table"
          branch.table = "branch_table"
          lock-table = "lock_table"
          query-limit = 100
        }
      }
      lock {
        ## the lock store mode: local、remote
        mode = "remote"
       
        local {
          ## store locks in user's database
        }
       
        remote {
          ## store locks in the seata's server
        }
      }
      recovery {
        #schedule committing retry period in milliseconds
        committing-retry-period = 1000
        #schedule asyn committing retry period in milliseconds
        asyn-committing-retry-period = 1000
        #schedule rollbacking retry period in milliseconds
        rollbacking-retry-period = 1000
        #schedule timeout retry period in milliseconds
        timeout-retry-period = 1000
      }
       
      transaction {
        undo.data.validation = true
        undo.log.serialization = "jackson"
        undo.log.save.days = 7
        #schedule delete expired undo_log in milliseconds
        undo.log.delete.period = 86400000
        undo.log.table = "undo_log"
      }
       
      ## metrics settings
      metrics {
        enabled = false
        registry-type = "compact"
        # multi exporters use comma divided
        exporter-list = "prometheus"
        exporter-prometheus-port = 9898
      }
       
      support {
        ## spring
        spring {
          # auto proxy the DataSource bean
          datasource.autoproxy = false
        }
      }
      
       ```

      创建registry.conf:

      ```conf
      registry {
        # file 、nacos 、eureka、redis、zk、consul、etcd3、sofa
        type = "nacos"
       
        nacos {
          #serverAddr = "localhost"
          serverAddr = "localhost:8848"
          namespace = ""
          cluster = "default"
        }
        eureka {
          serviceUrl = "http://localhost:8761/eureka"
          application = "default"
          weight = "1"
        }
        redis {
          serverAddr = "localhost:6379"
          db = "0"
        }
        zk {
          cluster = "default"
          serverAddr = "127.0.0.1:2181"
          session.timeout = 6000
          connect.timeout = 2000
        }
        consul {
          cluster = "default"
          serverAddr = "127.0.0.1:8500"
        }
        etcd3 {
          cluster = "default"
          serverAddr = "http://localhost:2379"
        }
        sofa {
          serverAddr = "127.0.0.1:9603"
          application = "default"
          region = "DEFAULT_ZONE"
          datacenter = "DefaultDataCenter"
          cluster = "default"
          group = "SEATA_GROUP"
          addressWaitTime = "3000"
        }
        file {
          name = "file.conf"
        }
      }
       
      config {
        # file、nacos 、apollo、zk、consul、etcd3
        type = "file"
       
        nacos {
          serverAddr = "localhost"
          namespace = ""
        }
        consul {
          serverAddr = "127.0.0.1:8500"
        }
        apollo {
          app.id = "seata-server"
          apollo.meta = "http://192.168.1.204:8801"
        }
        zk {
          serverAddr = "127.0.0.1:2181"
          session.timeout = 6000
          connect.timeout = 2000
        }
        etcd3 {
          serverAddr = "http://localhost:2379"
        }
        file {
          name = "file.conf"
        }
      }
      
      ```

      ==实际上,就是要将seata中的我们之前修改的两个配置文件复制到这个项目下==

   3. **主启动类**

      ```java
      @SpringBootApplication(exclude = DataSourceAutoConfiguration.class) //取消数据源的自动创建
      @EnableDiscoveryClient
      @EnableFeignClients
      public class SeataOrderMain2001 {
      
          public static void main(String[] args) {
              SpringApplication.run(SeataOrderMain2001.class,args);
          }
      }
      ```

      

   4. **service层**

      ```xml
      public interface OrderService {
      
          /**
           * 创建订单
           * @param order
           */
          void create(Order order);
      }
      ```

      ```xml
      @FeignClient(value = "seata-storage-service")
      public interface StorageService {
      
          /**
           * 减库存
           * @param productId
           * @param count
           * @return
           */
          @PostMapping(value = "/storage/decrease")
          CommonResult decrease(@RequestParam("productId") Long productId, @RequestParam("count") Integer count);
      }
      ```

      ```xml
      @FeignClient(value = "seata-account-service")
      public interface AccountService {
      
          /**
           * 减余额
           * @param userId
           * @param money
           * @return
           */
          @PostMapping(value = "/account/decrease")
          CommonResult decrease(@RequestParam("userId") Long userId, @RequestParam("money") BigDecimal money);
      }
       
       
      
      ```

      ```xml
      @Service
      @Slf4j
      public class OrderServiceImpl implements OrderService {
      
          @Resource
          private OrderDao orderDao;
          @Resource
          private AccountService accountService;
          @Resource
          private StorageService storageService;
      
          /**
           * 创建订单->调用库存服务扣减库存->调用账户服务扣减账户余额->修改订单状态
           * 简单说:
           * 下订单->减库存->减余额->改状态
           * GlobalTransactional seata开启分布式事务,异常时回滚,name保证唯一即可
           * @param order 订单对象
           */
          @Override
          ///@GlobalTransactional(name = "fsp-create-order", rollbackFor = Exception.class)
          public void create(Order order) {
              // 1 新建订单
              log.info("----->开始新建订单");
              orderDao.create(order);
      
              // 2 扣减库存
              log.info("----->订单微服务开始调用库存,做扣减Count");
              storageService.decrease(order.getProductId(), order.getCount());
              log.info("----->订单微服务开始调用库存,做扣减End");
      
              // 3 扣减账户
              log.info("----->订单微服务开始调用账户,做扣减Money");
              accountService.decrease(order.getUserId(), order.getMoney());
              log.info("----->订单微服务开始调用账户,做扣减End");
      
              // 4 修改订单状态,从0到1,1代表已完成
              log.info("----->修改订单状态开始");
              orderDao.update(order.getUserId(), 0);
      
              log.info("----->下订单结束了,O(∩_∩)O哈哈~");
          }
      }
      ```

      

       

       

       

       

       

       

   5. **dao层,也就是接口**

      ```java
      @Mapper
      public interface OrderDao {
          /**
           * 1 新建订单
           * @param order
           * @return
           */
          int create(Order order);
      
          /**
           * 2 修改订单状态,从0改为1
           * @param userId
           * @param status
           * @return
           */
          int update(@Param("userId") Long userId, @Param("status") Integer status);
      }
      ```

       ==在resource下创建mapper文件夹,编写mapper.xml==

      ```xml
      <?xml version="1.0" encoding="UTF-8" ?>
      <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
              "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
      <mapper namespace="com.eiletxie.springcloud.alibaba.dao.OrderDao">
      
          <resultMap id="BaseResultMap" type="com.eiletxie.springcloud.alibaba.domain.Order">
              <id column="id" property="id" jdbcType="BIGINT"></id>
              <result column="user_id" property="userId" jdbcType="BIGINT"></result>
              <result column="product_id" property="productId" jdbcType="BIGINT"></result>
              <result column="count" property="count" jdbcType="INTEGER"></result>
              <result column="money" property="money" jdbcType="DECIMAL"></result>
              <result column="status" property="status" jdbcType="INTEGER"></result>
          </resultMap>
      
          <insert id="create" parameterType="com.eiletxie.springcloud.alibaba.domain.Order" useGeneratedKeys="true"
                  keyProperty="id">
              insert into t_order(user_id,product_id,count,money,status) values (#{userId},#{productId},#{count},#{money},0);
          </insert>
      
          <update id="update">
              update t_order set status =1 where user_id =#{userId} and status=#{status};
         </update>
      </mapper>
       
      ```

   6. **controller层**

      ```java
      @RestController
      public class OrderController {
          @Resource
          private OrderService orderService;
      
      
          /**
           * 创建订单
           *
           * @param order
           * @return
           */
          @GetMapping("/order/create")
          public CommonResult create(Order order) {
              orderService.create(order);
              return new CommonResult(200, "订单创建成功");
          }
      
      
      }
      ```

      

   7. **entity类(也叫domain类)**

      ```java
      @Data
      @AllArgsConstructor
      @NoArgsConstructor
      public class CommonResult<T> {
          private Integer code;
          private String message;
          private T data;
      
          public CommonResult(Integer code, String message) {
              this(code, message, null);
          }
      }
       
      ```

      ![](./图片/seala的12.png)

       

       

      

   8. config配置类

      ```java
      @Configuration
      @MapperScan({"com.eiletxie.springcloud.alibaba.dao"})		指定我们的接口的位置
      public class MyBatisConfig {
      
      
      }
       
       
      
      ```

      ```java
      
      /**
       * @Author EiletXie
       * @Since 2020/3/18 21:51
       * 使用Seata对数据源进行代理
       */
      @Configuration
      public class DataSourceProxyConfig {
      
          @Value("${mybatis.mapperLocations}")
          private String mapperLocations;
      
          @Bean
          @ConfigurationProperties(prefix = "spring.datasource")
          public DataSource druidDataSource() {
              return new DruidDataSource();
          }
      
          @Bean
          public DataSourceProxy dataSourceProxy(DataSource druidDataSource) {
              return new DataSourceProxy(druidDataSource);
          }
      
          @Bean
          public SqlSessionFactory sqlSessionFactoryBean(DataSourceProxy dataSourceProxy) throws Exception {
              SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
              bean.setDataSource(dataSourceProxy);
              ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
              bean.setMapperLocations(resolver.getResources(mapperLocations));
              return bean.getObject();
          }
      }
       
       
      
      ```

      

   9. 

   10. 

   11. 

     ==库存==,seta-storage-2002

   **==看脑图==**

   1.    pom   
   2.    配置文件
   3.    主启动类
   4.    service层
   5.    dao层
   6.    controller层
   7.    
   8.    

    

    ==账号==,seta-account-2003

   **==看脑图==**

   1.    pom     
   2.    配置文件
   3.    主启动类
   4.    service层
   5.    dao层
   6.    controller层
   7.    
   8.    

5. **全局创建完成后,首先测试不加seata**

   ![](./图片/seala的14.png)

   

   ![](./图片/seala的13.png)

​    

​    

​     

6. 使用seata:

   **在==订单模块==的serviceImpl类中的==create方法==添加启动分布式事务的注解**

   ```java
   /**
   	这里添加开启分布式事务的注解,name指定当前全局事务的名称
   	rollbackFor表示,发生什么异常需要回滚
   	noRollbackFor:表示,发生什么异常不需要回滚
   */
   @GlobalTransactional(name = "fsp-create-order",rollbackFor = Exception.class)
   ///@GlobalTransactional(name = "fsp-create-order", rollbackFor = Exception.class)
   public void create(Order order) {
       // 1 新建订单
       log.info("----->开始新建订单");
       orderDao.create(order);
   
       // 2 扣减库存
       log.info("----->订单微服务开始调用库存,做扣减Count");
       storageService.decrease(order.getProductId(), order.getCount());
       log.info("----->订单微服务开始调用库存,做扣减End");
   
       // 3 扣减账户
       log.info("----->订单微服务开始调用账户,做扣减Money");
       accountService.decrease(order.getUserId(), order.getMoney());
       log.info("----->订单微服务开始调用账户,做扣减End");
   
       // 4 修改订单状态,从0到1,1代表已完成
       log.info("----->修改订单状态开始");
       orderDao.update(order.getUserId(), 0);
   
       log.info("----->下订单结束了,O(∩_∩)O哈哈~");
   }
   
   ```

    

7. 此时在测试

   发现,发生异常后,直接回滚了,前面的修改操作都回滚了

 



### setat原理:

![](./图片/seala的15.png)

![](./图片/seala的16.png)



**seata提供了四个模式:**

![](./图片/seala的17.png)



![](./图片/seala的18.png)

==第一阶段:==

![](./图片/seala的20.png)

​	![](./图片/seala的19.png)





==二阶段之提交==:

![](./图片/seala的21.png)



==二阶段之回滚:==

![](./图片/seala的22.png)

![](./图片/seala的23.png)







==断点==:

![](./图片/seala的24.png)

**可以看到,他们的xid全局事务id是一样的,证明他们在一个事务下**





![](./图片/seala的25.png)

**before 和 after的原理就是**

![](./图片/seala的26.png)

**在更新数据之前,先解析这个更新sql,然后查询要更新的数据,进行保存**



