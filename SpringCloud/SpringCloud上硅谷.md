# SpringCloud升级,部分组件停用

1,Eureka停用,可以使用zk作为服务注册中心

2,服务调用,Ribbon准备停更,代替为LoadBalance

3,Feign改为OpenFeign

4,Hystrix停更,改为resilence4或者阿里巴巴的sentienl

5.Zuul改为gateway

6,服务配置Config改为  Nacos

7,服务总线Bus改为Nacos





# 环境搭建



## 一，创建父工程及pom依赖

```xml
<!--表示是父工程--> 
<packaging>pom</packaging>

<!--dependenceManages和dependences的区别-->
1，dependenceManages只会出现在父工程，作为锁定版本，不引入依赖
2，子类工程写了版本后就生效，不写就用父工程
3，子项目不写就不引入
```

问题一：

![image-20200605155016310](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200605155016310.png)



## 二，服务提供者：pay模块

1，子模块名字：cloud_provider-payment8001



构建完成后就会父工程的pom文件中就会出现

```xml
<modules>
    <module>cloud_provider-payment8001</module>
</modules>
```

2，导入pom依赖

3，application.yml

```yml
server:
	port: 8001   
spring:
	application:
		name: cloud-payment-service
	datasource:
    # 当前数据源操作类型
    type: com.alibaba.druid.pool.DruidDataSource
    # mysql驱动类
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/db2019?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=GMT%2B8			
    username: root
    password: root
mybatis:			
    mapper-locations: classpath*:mapper/*.xml
   	type-aliases-package: com.eiletxie.springcloud.entities
	# 它一般对应我们的实体类所在的包，这个时候会自动取对应包中不包括包名的简单类名作为包括包名的别名
	# 多个package之间可以用逗号或者分号等来进行分隔（value的值一定要是包的全）
```

4，主启动类    

```java
@SpringBootApplication
public class Main {
    public static void main(String[] args) {
        SpringApplication.run(Main.class,args);
    }
}
```

5，业务类

​	1,创建数据库

​	2,实体类

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Payment implements Serializable {
    private Long id;
    private String serial;
}
```



> 这里涉及到一个lombok，是针对实体类中过多的繁琐的getting/setting/toString，用以优化，就可以不用再写那些了
>
> 1，导入lombok依赖
>
> 2，在setting中下载lombok插件



​	3，entity类

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ComonResult<T> {
    private Integer code;
    private String message;
    private  T data;

    public ComonResult(Integer code, String message){
        this(code,message,null);
    }

}
```

​	4，dao层

```java
@Mapper
public interface PaymentDao {

    public int create(Payment payment);

    public  Payment getPaymentById(@Param("id") Long id);
}
```



**问题一：这里的param有什么用**



​	5,mapper配置文件类

​				**在resource下,创建mapper/PaymentMapper.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >

<mapper namespace="tutu.demo.dao.PaymentDao">

<insert id="create" parameterType="Payment" useGeneratedKeys="true" keyProperty="id">
    insert  into payment(serial) values (#{serial})
</insert>

<resultMap id="BaseResultMap" type="tutu.demo.entities.Payment">
    <id column="id" property="id" jdbcType="BIGINT"/>
    <id column="serial" property="serial" jdbcType="VARCHAR"/>
</resultMap>
<select id="getPaymentById" parameterType="Long" resultMap="BaseResultMap">
    select * from payment where id=#{id};
</select>

</mapper>
```



6,service和serviceImpl

```java
public interface PaymentService
{
    public int create(Payment payment);

    public Payment getPaymentById(@Param("id") Long id);
}
```



```java
@Service
public class PaymentServiceImpl implements PaymentService
{
    @Resource
    private PaymentDao paymentDao;

    public int create(Payment payment)
    {
        return paymentDao.create(payment);
    }

    public Payment getPaymentById(Long id)
    {
        return paymentDao.getPaymentById(id);
    }
}

```

7,controller

```java
@RestController
@Slf4j
public class PaymentController
{
    @Resource
    private PaymentService paymentService;

    @Value("${server.port}")
    private String serverPort;

    @Resource
    private DiscoveryClient discoveryClient;

    @PostMapping(value = "/payment/create")
    public ComonResult create(@RequestBody Payment payment)
    {
        int result = paymentService.create(payment);
        log.info("*****插入结果："+result);

        if(result > 0)
        {
            return new ComonResult(200,"插入数据库成功,serverPort: "+serverPort,result);
        }else{
            return new ComonResult(444,"插入数据库失败",null);
        }
    }

    @GetMapping(value = "/payment/get/{id}")
    public ComonResult<Payment> getPaymentById(@PathVariable("id") Long id)
    {
        Payment payment = paymentService.getPaymentById(id);

        if(payment != null)
        {
            return new ComonResult(200,"查询成功,serverPort:  "+serverPort,payment);
        }else{
            return new ComonResult(444,"没有对应记录,查询ID: "+id,null);
        }
    }

}

```



注意：运行时会有很多错误，我的错误来源于有些东西是拷贝的，一些地址没改

1，mysql账号密码

2，扫描的包的位置



## 三，热部署:

![](.\图片\sc的13.png)

![](.\图片\sc的14.png)



## 四，服务消费者：order模块

**1,pom**		

**2,yml配置文件**

```
# consul服务端口号
server:
  port:80
```

**3,主启动类**

**4.复制pay模块的实体类,entity类**

**5,写controller类**

​		因为这里是消费者类,主要是消费,那么就没有service和dao,需要调用pay模块的方法

​		并且这里还没有微服务的远程调用,那么如果要调用另外一个模块,则需要使用基本的api调用

使用RestTemplate调用pay模块

​	![](.\图片\order模块2.png)

将restTemplate注入到容器

```java
@Configuration
public class ApplicationContextConfig
{
    @Bean
    public RestTemplate getRestTemplate()
    {
        return new RestTemplate();
    }
}
```

编写controller:

```java
@RestController
@Slf4j
@EnableAutoConfiguration
public class OrderConsulController
{
    public static final String INVOKE_URL = "http://localhost:8001";

    @Resource
    private RestTemplate restTemplate;

//    @GetMapping(value = "/consumer/payment/consul")
//    public String paymentInfo()
//    {
//        String result = restTemplate.getForObject(INVOKE_URL+"/payment/consul",String.class);
//        return result;
//    }
    @GetMapping("/consumer/payment/create")
    public ComonResult<Payment> create(Payment payment){

        return restTemplate.postForObject(INVOKE_URL+"/payment/create",payment,ComonResult.class);
    }

}
```



## 五，重构

新建一个模块,将重复代码抽取到一个公共模块中

1,创建commons模块

2,抽取公共pom

![](.\图片\commons模块.png)

3,entity和实体类放入commons中

![](.\图片\commons模块2.png)

4,使用mavne,将commone模块打包(install),

​		其他模块引入commons







# 服务注册与发现



## 1，Eureka:

前面我们没有服务注册中心,也可以服务间调用,为什么还要服务注册?

当服务很多时,单靠代码手动管理是很麻烦的,需要一个公共组件,统一管理多服务,包括服务是否正常运行,等

Eureka用于**==服务注册==**,目前官网**已经停止更新**

​	![](.\图片\Eureka的1.png)



![](.\图片\Eureka的2.png)

![](.\图片\Eureka的3.png)



 ![](.\图片\Eureka的4.png)



### **单机版eureka:**

1,创建项目cloud_eureka_server_7001

2,引入pom依赖

eurka最新的依赖发生了改变

```xml
# 老版本
<artifactId>spring-cloud-starter-eureka</artifactId>


# 新版本
<artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
```

3,配置文件:

```yml
server:
  port: 7001
eureka:
  instance:
    hostname: localhost # 服务名
  client:
    # 设置不用检索服务
    fetch-registry: false
    # 不向注册中心注册自己
    register-with-eureka: false
    service-url:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
```

4,主启动类	

```java
@SpringBootApplication
//表示这个是Eureka的服务祖册中心
@EnableEurekaServer
public class MainEureka {
    public static void main(String[] args) {
        SpringApplication.run(MainEureka.class,args);
    }
}
```

5,其他服务注册到eureka:

1.主启动类上,加注解,表示当前是eureka客户端

![](.\图片\Eureka的10.png)

2,修改pom,引入

![](.\图片\Eureka的8.png)

3,修改配置文件:

```yml
spring:
  application:
    name: cloud-order-service
    
eureka:
  client:
    #表示是否将自己注册进EurekaServer默认为true。
    register-with-eureka: true
    #是否从EurekaServer抓取已有的注册信息，默认为true。单节点无所谓，集群必须设置为true才能配合ribbon使用负载均衡
    fetchRegistry: true
    service-url:
      #单机
      defaultZone: http://localhost:7001/eureka
      # 集群
      # defaultZone: http://eureka7001.com:7001/eureka,http://eureka7002.com:7002/eureka  # 集群版
```



### 集群版eureka:

#### 集群原理:

![](.\图片\Eureka的11.png)

 ```java
1,就是pay模块启动时,注册自己,并且自身信息也放入eureka
2.order模块,首先也注册自己,放入信息,当要调用pay时,先从eureka拿到pay的调用地址
3.通过HttpClient调用
 	并且还会缓存一份到本地,每30秒更新一次
 ```

![](.\图片\Eureka的12.png)

**集群构建原理:**

​		互相注册

![](.\图片\Eureka的13.png)



#### **构建新erueka项目**

名字:cloud_eureka_server_7002

1,pom文件

2,配置文件

先要修改修改一下主机的hosts文件   C:\Windows\System32\drivers\etc

```
##################SpringCloud###################
127.0.0.1	eureka7001.com
127.0.0.1	eureka7002.com
```

两个注册中心相互注册

```yml
#7001
eureka:
  instance:
    hostname: eureka7001.com # 服务名
 defaultZone: http://${eureka.instance.hostname}:7002/dureka/    
 
 
#7002
eureka:
  instance:
    hostname: eureka7002.com # 服务名
 defaultZone: http://${eureka.instance.hostname}:7001/dureka/    
```



3,主启动类

4,访问

```
rureka:7001.com:7001
rureka:7002.com:7002
```





将模块注册到eureka集群中

1,修改配置文件的defaultZone

```yml
defaultZone: http://eureka7001.com:7001/eureka,http://eureka7002.com:7002/eureka  # 集群版
```





## 2，提供者集群模式

1，创建新模块：名称: cloud_pay_8002

2，pom文件，和8001保持一致

3，配置文件，和8001保持一致

> ​		端口改为800
>

4，主启动类

5,mapper,service,controller

​		然后就启动服务即可



6，注意修改消费者的controller类，提供者集群后，注册中心是通过名称来定位服务提供者的

```
public static final String INVOKE_URL = "http://CLOUD-PAYMENT-SERVICE";
```

**注意这样还不可以,需要让RestTemplate开启负载均衡注解,还可以指定负载均衡算法,默认轮询**

```java
 	@Bean
    @LoadBalanced
    public RestTemplate getRestTemplate()
    {
        return new RestTemplate();
    }
```



7,修改服务主机名和ip在eureka的web上显示

添加配置信息

```yml
eureka:
  instance:
    instance-id: payment8001
    prefer-ip-address: true # 显示IP地址
```





## 3，eureka服务发现

![](.\图片\Eureka的21.png)



1,添加暴露服务的对象

```java
@Resource
private DiscoveryClient client;
```

2，使用

```java
@GetMapping("/payment/discovery")
    public  Object discovery(){
        // 获取注册服务名
        List<String> services = client.getServices();
        // 拿到服务的注册信息，端口，ip等等
        List<ServiceInstance> instances = client.getInstances("CLOUD-PAYMENT-SERVICE");
        return this.client;
    }
```

```json
{"discoveryClients":[{"services":["cloud-payment-service"],"order":0},
                 
                     
{"services":[],"order":0}],"services":["cloud-payment-service"],"order":0}
```



2,在主启动类上添加@EnableDiscoveryClient

```java
//@EnableDiscoveryClient 
//该注解用于向使用consul或者zookeeper作为注册中心时注册服务
@SpringBootApplication
@EnableEurekaClient
@EnableDiscoveryClient
public class OrderConsulMain80
{
    public static void main(String[] args) {
            SpringApplication.run(OrderConsulMain80.class, args);
    }
}

```



## 4，Eureka自我保护

显示以下信息就说明Eureka开启了自我保护

![](.\图片\Eureka的26.png)

![](.\图片\Eureka的27.png)

![](.\图片\Eureka的25.png)



![](.\图片\Eureka的28.png)



**eureka服务端配置:**

![](.\图片\Eureka的29.png)

![](.\图片\Eureka的30.png)

​			**设置接受心跳时间间隔**



**客户端(比如pay模块):**

![](.\图片\Eureka的31.png)





**此时启动erueka和pay.此时如果直接关闭了pay,那么erueka会直接删除其注册信息**









## 5，Zookeeper服务注册与发现:

pay模块

1,启动zk,到linux上

```
1,下载
2，传递到Linux中
3，在/usr/local下安装
4，复制zoo.cfg文件
5，环境变量
6，zkServer.sh start
7,zkCli.sh
```

2,创建新的pay模块，单独用于注册到zk中  名字 : cloud_payment_zookeeper8003

3,pom依赖

4,配置文件

```yml
server:
  port: 8003
spring:
  application:
    name: cloud-provider-payment
  cloud:
    zookeeper:
      connect-string: 192.168.91.129:2181
```

5,主启动类

```java
@SpringBootApplication
@EnableDiscoveryClient
public class Mainpayment8003
{
    public static void main(String[] args) {
        SpringApplication.run(Mainpayment8003.class,args);
    }
}
```

6,controller

```java
public class PaymentController {
    @Value("${server.port}")
    private String serverPort;


    @GetMapping(value = "/payment/zk")
    public String paymentzk()
    {
        return serverPort+UUID.randomUUID().toString();
    }
}
```



**此时启动,会报错,因为jar包与我们的zk版本不匹配**

解决:
		修改pom文件,改为与我们zk版本匹配的jar包

![](.\图片\zookeeper的4.png)

**此时8003就注册到zk中了**

```java
我们在zk上注册的node是临时节点,当我们的服务一定时间内没有发送心跳
  	那么zk就会`将这个服务的node删除了
```



**order模块**

1,创建项目

名字: cloud_consumer-order-zk80

2,pom

3,配置文件

```yml
server:
  port: 8003
spring:
  application:
    name: cloud-provider-payment
  cloud:
    zookeeper:
      connect-string: 192.168.91.129:2181
```

4主启动类

```java
@SpringBootApplication
@EnableDiscoveryClient
public class OrderConsulMainzk80 {
    public static void main(String[] args) {
        SpringApplication.run(OrderConsulMainzk80.class,args);
    }
}
```

5,配置类RestTemolate

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

6,controller

```java
@RestController
@Slf4j
public class OrderConsulController
{
    public static final String INVOKE_URL = "http://cloud-provider-payment";

    @Resource
    private RestTemplate restTemplate;
    
    @GetMapping("/consumer/payment/zk")
    public ComonResult<Payment> paymentInfo()
    {
        return restTemplate.getForObject(INVOKE_URL+"/payment/zk",ComonResult.class);
    }

}
```



7,集群版zk注册，只需要将配置文件中connect-string这里用逗号隔开，再添加端口





## 7，Consul服务注册和发现

![](.\图片\consul的1.png)



![](.\图片\consul的2.png)





1,下载

2，启动是一个命令行界面,需要输入consul agen-dev启动，然后访问http://localhost:8500



3，创建新的pay模块,8004

​	3.1，pom依赖

​	3.2，配置文件

```yml
server:
  port: 8004
spring:
  application:
    name: consul-provider-payment
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        # 对外暴露的名称
        service-name: ${spring.application.name}
```

​	3.3，主启动类

​	3.4，controller

```java
@RestController
public class PaymentController {
    @Value("${server.port}")
    private String serverPort;


    @GetMapping(value = "/payment/consul")
    public String paymentzk()
    {
        return serverPort+UUID.randomUUID().toString();
    }
}
```



4,创建新order模块

1,pom文件

2,配置文件

```java
server:
  port: 80
spring:
  application:
    name: cloud-consumer-order
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        service-name: ${spring.application.name}
```

3,主启动类

4,RestTemplate注册

5,controller

```java
 @GetMapping("/consumer/payment/consul")
    public String paymentInfo()
    {
        return restTemplate.getForObject(INVOKE_URL+"/payment/consul",String.class);
    }
```



## 8，三个注册中心的异同:

![](.\图片\consul的9.png)

![](.\图片\consul的10.png)

![](.\图片\consul的11.png)



# 

# 服务调用



## 1，Ribbon负载均衡

![](.\图片\Ribbon.png)

**Ribbon目前也进入维护,基本上不准备更新了**

![](.\图片\Ribbon的2.png)

**进程内LB(本地负载均衡)**

![](.\图片\Ribbon的5.png)





**集中式LB(服务端负载均衡)**

![](.\图片\Ribbon的4.png)







**区别**

![](.\图片\Ribbon的3.png)



**Ribbon就是负载均衡+RestTemplate**

![](.\图片\Ribbon的6.png)



![](.\图片\Ribbon的7.png)



![](.\图片\Ribbon的8.png)







1,默认我们使用eureka的新版本时,它默认集成了ribbon:

也可以手动引入ribbon

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
</dependency>
```

**放到order模块中,因为只有order访问pay时需要负载均衡**





2,RestTemplate类的使用

1，getForObject:返回的是响应体中数据转化的对象，即json

2，getForEntity:返回的是ResponseEntity对象，包含很多响应信息



3，Ribbon常用负载均衡算法

**IRule接口,Riboon使用该接口,根据特定算法从所有服务中,选择一个服务,**

**Rule接口有7个实现类,每个实现类代表一个负载均衡算法**

![](.\图片\Ribbon的14.png)





**使用Ribbon**

> 注意
>
> 官方给出，不能放在@ComponentScan所扫描的当前包以及子包下
>
> 所以需要再创建一个package





1，创建一个包，配置信息，指定负载均衡算法

```java
@Configuration
public class MyselfRule {
    @Bean
    public IRule myRule(){
        return new RandomRule();
    }
}
```



2，在主启动类上加一个注解

```
@RibbonClient(name = "cloud-payment-service",configuration = MyselfRule.class)
```

**表示,访问cloud-payment-service的服务时,使用我们自定义的负载均衡算法**





## 2，自定义负载均衡算法

1,原理

![](.\图片\Ribbon的19.png)

![](.\图片\Ribbon的21.png)



2,自定义负载均衡算法

**1,给**pay模块(8001,8002),的controller方法添加一个方法,返回当前节点端口

![](.\图片\Ribbon的23.png)

![](.\图片\Ribbon的22.png)

**2,修改order模块**，去掉@LoadBalanced



3,自定义接口，LoadBalancer



4,接口实现

```java
public class MyLb {
    //默认第一个为0
    private AtomicInteger atomicInteger = new AtomicInteger(0);

    //获取下一个要调用服务的id
    public final int getAndIncrement(){
        int current;
        int next;//下一个调用服务的id
        do{
            current = this.atomicInteger.get();
            System.out.println("获取的current为："+current);
            next = current>=Integer.MAX_VALUE ? 0 : current+1;

        }while (!this.atomicInteger.compareAndSet(current,next));//到调用cas，进行自旋，每次next+1
        System.out.println("下一个为："+next);
        return next;
    }
    public ServiceInstance instances(List<ServiceInstance> serviceInstances){
        //getAndIncrement () 拿到id
        //serviceInstances.size()所有的服务数量
        int index = getAndIncrement() % serviceInstances.size();
        //通过位置找到访问的端口
        return serviceInstances.get(index);
    }
}
```



5,修改controller

![](.\图片\Ribbon的27.png)

![](.\图片\Ribbon的28.png)











## 3，OpenFeign



![](.\图片\Feign的1.png)

**是一个声明式的web客户端,只需要创建一个接口,添加注解即可完成微服务之间的调用**



![](.\图片\Feign的2.png)

==就是A要调用B,Feign就是在A中创建一个一模一样的B对外提供服务的的接口,我们调用这个接口,就可以服务到B==



**Feign与OpenFeign区别**

![](.\图片\Feign的3.png)





使用OpenFeign

```java
之前的服务间调用,我们使用的是ribbon+RestTemplate，现在改为使用Feign
```

1,新建一个order项目

2,pom文件

3,配置文件

```java
server:
  port: 80
eureka:
  client:
    register-with-eureka: false
    service-url:
      defaultZone: http://eureka7001.com:7001/eureka,http://eureka7002.com:7002/eureka
```



4,主启动类

```java
@SpringBootApplication
@EnableFeignClients//开启feign功能
public class FeignOrderMain80 {
    public static void main(String[] args) {
        SpringApplication.run(FeignOrderMain80.class,args);
    }
}
```



5,编写需要调用服务的接口

```java
@FeignClient(value = "cloud-payment-service")//需要调用的服务名称
@Component
public interface PaymentFeignService {
    //这里的GetMapping和提供者的一直，方法也是一致，只是这里是客户端，所以返回的应该是一个
    @GetMapping("/payment/{id}")
    public ComonResult<Payment>  getPaymentById(@Param("id") Long id);
}
```



6,controller

```java
@RestController
public class OrderFeginController {
    private PaymentFeignService service;
    @GetMapping("/consumer/payment/get/{id}")
    public ComonResult<Payment> getPayment(@PathVariable("id") Long id){
        return service.getPaymentById(id);
    }
}
```



**Feign默认使用ribbon实现负载均衡**





### OpenFeign超时机制

==OpenFeign默认等待时间是1秒,超过1秒,直接报错==

设置超时时间,修改配置文件

**因为OpenFeign的底层是ribbon进行负载均衡,所以它的超时时间是由ribbon控制**

```YML
#ribbon的超时时间
ribbon:
  ReadTimeout: 30000
  ConnectTimeout: 30000
```



### OpenFeign日志

![](.\图片\Feign的9.png)



**OpenFeign的日志级别有:**
![](.\图片\Feign的10.png)



1,使用

**实现在配置类中添加OpenFeign的日志类**

```JAVA
public class FeignConfig{
	Logger.Level feinLoggerLevel(){
		return Logger.Level.FULL;
	}
}
```

2,为指定类设置日志级别:

![](.\图片\Feign的13.png)

**配置文件中:**

![](.\图片\Feign的12.png)



# 服务降级:



## 1，Hystrix服务降级

![](.\图片\Hystrix的2.png)



![](.\图片\Hystrix的3.png)





![](.\图片\Hystrix的4.png)



1,服务降级

比如当某个服务繁忙,不能让客户端的请求一直等待,应该立刻返回给客户端一个备选方案

2,服务熔断

当某个服务出现问题,卡死了,不能让用户一直等待,需要关闭所有对此服务的访问,然后调用服务降级

3,服务限流

限流,比如秒杀场景,不能访问用户瞬间都访问服务器,限制一次只可以有多少请求





使用

1,创建带降级机制的pay模块 

2,pom文件

3,配置文件

```yml
server:
  port: 8005
spring:
  application:
    name: cloud-provider-hystrix
eureka:
  client:
    register-with-eureka: false
    fetch-registry: true
    service-url: http://eureka7001.com:7001/eureka
```

4,主启动类

```java
@SpringBootApplication
@EnableEurekaClient
public class PaymentHystrix8005
{
    public static void main(String[] args) {
        SpringApplication.run(PaymentHystrix8005.class,args);
    }
}
```

5,service

```java
@Service
public class PaymentService {

    public String OK(Integer id){
        return "线程池成功案例"+Thread.currentThread().getName();
    }

    public String Time_Out(Integer id){
        try {
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return "线程池失败案例"+Thread.currentThread().getName();
    }
}
```

6,controller

```JAVA
@RestController
public class PaymentController {
    @Resource
    private PaymentService service;
    @GetMapping("/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id){
        String result = service.OK(id);
        return  result;
    }

    @GetMapping("/payment/hystrix/timeout/{id}")
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id){
        String result = service.Time_Out(id);
        return  result;
    }
}
```

```java
此时使用压测工具,并发20000个请求,请求会延迟的那个方法,
		压测中,发现,另外一个方法并没有被压测,但是我们访问它时,却需要等待
		这就是因为被压测的方法它占用了服务器大部分资源,导致其他请求也变慢了
```





2,创建带降级的order模块

1,名字:  cloud-hystrix-order-80

2,pom

3,配置文件

```yml
server:
  port: 80

eureka:
  client:
    register-with-eureka: false
    service-url:
      deaultZone: http://eureka7001.com:7001/eureka
```

4,主启动类

```java
@SpringBootApplication
@EnableFeignClients
public class HystrixOrder80 {
    public static void main(String[] args) {
        SpringApplication.run(HystrixOrder80.class,args);
    }
}
```



5,远程调用pay模块的接口

```java
@Component
@FeignClient("cloud-provider-hystrix")
public interface PaymentService {
    @GetMapping("/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id);

    @GetMapping("/payment/hystrix/timeout/{id}")
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id);
}
```

6,controller

```java
@RestController
public class PaymentController
{
    @Resource
    private PaymentService service;
    @GetMapping("/consumer/payment/hystrix/ok/{id}")
    public String paymentInfo_OK(@PathVariable("id") Integer id){
        return service.paymentInfo_OK(id);
    }

    @GetMapping("/consumer/payment/hystrix/timeout/{id}")
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id){
        return service.paymentInfo_TimeOut(id);
    }
}
```



​			启动order模块,访问pay

​			再次压测2万并发,发现order访问也变慢了

![](.\图片\Hystrix的14.png)



**解决:**

![](.\图片\Hystrix的15.png)

##### ![](.\图片\Hystrix的16.png)



为了解决上述的情况，所以需要给提供方配置服务降级，但是一般情况下都是在客户端进行服务降级，这里是演示有这样的操作



## **2，对服务器端进行降级**



1,为service的指定方法(会延迟的方法)添加@HystrixCommand注解，

​		**注意，指定的方法要和会发生降级的方法的参数一致**

```java
 @GetMapping("/consumer/payment/hystrix/timeout/{id}")
    @HystrixCommand(fallbackMethod = "paymentInfo_TimeOutMethod",commandProperties = {
            //表示调用此方法的线程只能等待3秒钟
            @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds",value = "2000")
    })
    public String paymentInfo_TimeOut(@PathVariable("id") Integer id){
        return service.paymentInfo_TimeOut(id);
    }
    public String paymentInfo_TimeOutMethod(Integer id){
        return "对不起，客服端错误出错了，错误代码为：  "+id;
    }
```

2,主启动类上,添加激活hystrix的注解@EnableCircuitBreaker



## **3，对客户端进行服务降级**



一般服务降级,都是放在客户端(order模块)

1,修改配置文件

```yml
feign:
  hystrix:
    enabled: true
```

2,主启动类添加注解@EnableHystrix,启用hystrix

3,修改controller,添加降级方法



 

>
> ​		1,降级方法与业务方法写在了一块,耦合度高
>
> ​		2.每个业务方法都写了一个降级方法,重复代码多





## 4，全局降级方法

**所有方法都可以走这个降级方法,至于某些特殊的方法,需要单独创建方法**

1,创建一个全局方法

```java
 public String paymen_global_method(){
        return "全局处理异常";
    }
```



2,使用注解指定其为全局降级方法(默认降级方法)

```
@RestController
@DefaultProperties(defaultFallback = "paymen_global_method")
public class PaymentController{}
```



而对于一些特定的方法使用默认降级方法，即在方法上加上注解

```java
@HystrixCpmmand(fallbackMethod="方法名")
```





## 5，解决代码耦合度

有些注解和方法在ctroller类中，这样有时候需要用同一个方法，这样就会造耦合

所以就需要一个类去统一管理，统一处理异常

1,编写一个类去继承提供方法的接口

一个方法，对应着一个处理的方法，这样就是统一的管理这种异常处理的方法

```java
public class PaymentServiceMethod implements PaymentService{
    @Override
    public String paymentInfo_OK(Integer id) {
        return "错误处理";
    }

    @Override
    public String paymentInfo_TimeOut(Integer id) {
        return "错误处理";
    }
}
```

2,修改配置文件，开启hystrix

```yml
feign:
  hystrix:
    enabled: true
```



3,让继承接口的类的方法生效

```java
@Component
@FeignClient(value = "CLOUD-PROVIDER-HYSTRIX" ,fallback = PaymentServiceMethod.class)
public interface PaymentService {
```



```java
它的运行逻辑是:
	当请求过来,首先还是通过Feign远程调用pay模块对应的方法
    但是如果pay模块报错,调用失败,那么就会调用PayMentFalbackService类的
    当前同名的方法,作为降级方法
```

​		

**这样虽然解决了代码耦合度问题,但是又出现了过多重复代码的问题,每个方法都有一个降级方法**







# 服务熔断



![](.\图片\Hystrix的35.png)



## 1，提供者模块配置

1,修改Payservice接口,添加服务熔断相关的方法

```java
@HystrixCommand(fallbackMethod = "fallb",commandProperties = {
    @HystrixProperty(name = "circuitBreaker.enabled",value = "true"),//开启熔断
        //请求失败次数超过10就会开启熔断
    @HystrixProperty(name = "circuitBreaker.requestVolumeThreshold",value = "10"),
        //在这个时间范围内若服务又能启动，就会从半开状态转换到关闭状态
    @HystrixProperty(name = "circuitBreaker.sleepWindowInMillisecond",value = "10000"),
        //请求失败率超过60%就会开启熔断
    @HystrixProperty(name = "circuitBreaker.errorThresholdPercentage",value = "60")

})
    public String paymentCirBreaker(@PathVariable("id")Integer id){
        if(id<0){
            throw new RuntimeException("不能为负数");
        }
        return "流水号"+ IdUtil.simpleUUID();

    }

    public String fallb(@PathVariable("id")Integer id){
            return "不能为负数";
    }
```





```java
1,并发此时是否达到我们指定的阈值
2,错误百分比,比如我们配置了60%,那么如果并发请求中,10次有6次是失败的,就开启断路器
3,上面的条件符合,断路器改变状态为open(开启)
4,这个服务的断路器开启,所有请求无法访问
5,在我们的时间窗口期,期间,尝试让一些请求通过(半开状态),如果请求还是失败,证明断路器还是开启状态,服务没有恢复
  		如果请求成功了,证明服务已经恢复,断路器状态变为close关闭状态
```



2,修改controller，添加一个测试各个的service方法

```java
@GetMapping("/payment/circuit/{id}")
    public String paymentBreaker(@PathVariable("id") Integer id){
        String result = service.paymentCirBreaker(id);
        return result;
    }
```



3,测试

一直访问出错的方法，让错误率上升，这样就会自动开启熔断







## 2，Hystrix所有可配置的属性

在@HystrixProperty这个属性中可以设置的属性可以在HystrixCommandProperties.java中查找



总结:

![](.\图片\Hystrix的42.png)

**==当断路器开启后:==**

​	![](.\图片\Hystrix的44.png)





**熔断整体流程:**

```java
1请求进来,首先查询缓存,如果缓存有,直接返回
  	如果缓存没有,--->2
2,查看断路器是否开启,如果开启的,Hystrix直接将请求转发到降级返回,然后返回
  	如果断路器是关闭的,
				判断线程池等资源是否已经满了,如果已经满了
  					也会走降级方法
  			如果资源没有满,判断我们使用的什么类型的Hystrix,决定调用构造方法还是run方法
        然后处理请求
        然后Hystrix将本次请求的结果信息汇报给断路器,因为断路器此时可能是开启的
          			(因为断路器开启也是可以接收请求的)
        		断路器收到信息,判断是否符合开启或关闭断路器的条件,
				如果本次请求处理失败,又会进入降级方法
        如果处理成功,判断处理是否超时,如果超时了,也进入降级方法
        最后,没有超时,则本次请求处理成功,将结果返回给controller
         
 
```





# Hystrix服务监控

#### HystrixDashboard

![](.\图片\Hystrix的51.png)使用

1,创建项目

名字: cloud_hystrixdashboard_9001

2,pom文件

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
	<artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
</dependency>
```



3,配置文件

```yml
server:
  port: 9001
```



4,主启动类

```java
@SpringBootApplication
@EnableHystrixDashboard//开启Dashboard
public class HystrixDashboardMain9001 {
    public static void main(String[] args) {
        SpringApplication.run(HystrixDashboardMain9001.class,args);
    }
}
```



5,给所有的提供者加上一个依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```



6,启动,访问: **localhost:9001/hystrix**



7,注意,此时仅仅是可以访问HystrixDashboard,并不代表已经监控了8001,8002

​							如果要监控,还需要配置

![](.\图片\Hystrix的55.png)



启动7001,8001,9001

**然后在web界面,指定9001要监控8001:**

##### ![](.\图片\Hystrix的56.png)



![](.\图片\Hystrix的57.png)

![](.\图片\Hystrix的59.png)

![](.\图片\Hystrix的58.png)

![](.\图片\Hystrix的60.png)

![](.\图片\Hystrix的61.png)

![](.\图片\Hystrix的62.png)

























# 服务配置

## 一，Spring Config分布式配置中心

==微服务面临的问题==

```java
可以看到,每个微服务都需要一个配置文件,并且,如果有几个微服务都需要连接数据库
		那么就需要配4次数据库相关配置,并且当数据库发生改动,那么需要同时修改4个微服务的配置文件才可以
```

所以有了springconfig配置中心

提供集中化的外部配置支持，为不同微服务应用的所有环境提供一个中心化的外部配置

分为：服务端和客户端

服务端：分布式配置中心，是一个独立的微服务应用，用来连接配置服务器并为客户端提供获取配置信息，加密/解密信息等访问接口

客户端：通过指定配置信息管理应用资源等配置内容，启动时从配置中心获取配置信息（git存储）



![](.\图片\springconfig的4.png)





## 二，使用配置中心（没有使用过）

1,使用github作为配置中心的仓库:

git@github.com:FFFamily/springcloud-config.git

​	1，新建一个仓库,里面有不同环境的配置文件

​	2，本地克隆



2,新建config模块，名字:   cloud-config-3344

2,pom

3,配置文件

```yml
server:
  port: 3344

spring:
  application:
    name: cloud-config-center # 注册服务器的服务名

  cloud:
    config:
      server:
        git:
          uri: git@github.com:FFFamily/springcloud-config.git
          # 表示需要扫描的目录
          search-paths:
            - springcloud-config

eureka:
  client:
    service-url:
      defaultZone: http:localhost:7001/eureka
```

4,主启动类

```java
@SpringBootApplication
//启动配置中心的服务端
@EnableConfigServer
public class ConfigCenterMain3344 {
    public static void main(String[] args) {
        SpringApplication.run(ConfigCenterMain3344.class,args);
    }
}
```

5,修改windows下的hosts文件，增加域名映射，就像之前的rureka

不配，就使用localhost



值得注意的是

由于访问git时，使用https（例如：https://github.com/用户名/仓库地址.git）的uri访问不用进行验证，但是使用ssh（例如：git@github.com:用户名/仓库地址.git）的uri访问时需要进行验证，所以需要修改一下配置中心的配置文件



6,测试

localhost:3344/master/config-dev.yml



7,读取配置文件的规则

![](.\图片\springconfig的10.png)



==2,==

![](.\图片\springconfig的11.png)

**这里默认会读取master分支,因为我们配置文件中配置了**

```
label:master
```



==3==

![](.\图片\springconfig的13.png)

注意,这个方式读取到的配置是==json格式==的

**所有规则:**

![](.\图片\springconfig的14.png)



## 三，创建配置中心客户端（未使用）

1,创建config客户端项目

名字: 	cloud-config-client-3355

2,pom

3,配置文件

注意这个配置文件就不是application.yml

​			而是bootstrap.yml

这个配置文件的作用是,先到配置中心加载配置,然后加载到application.yml中，其优先级更高

```yml
server:
  port: 3355
spring:
  application:
    name: config-client
  cloud:
    config:
      label: master # 分支名称
      name: config # 配置文件名
      profile: dev # 后缀名
      uri: http://localhost:3344
      # 这四个所表达的是：http:localhost:3344/master/config-dev.yml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:7001/eureka
```





4,主启动类:

```java
@SpringBootApplication
@EnableEurekaClient
public class ConfigClientMain3355 {
    public static void main(String[] args) {
        SpringApplication.run(ConfigClientMain3355.class,args);
    }
}
```

5,controller类

配置完了就可以访问客户端

```java
@RestController
public class ConfigController {
    @Value("${config.info}")
    private String Info;

    @GetMapping("/configinfo")
    public String getInfo(){
        return Info;
    }
}
```







存在的问题，如果配置文件修改了，服务端的配置类是能直接获取到改变的配置文件，而客户端就访问不到，除非将其重启，但是微服务中的重启的代价是昂贵的，所以就有了动态刷新



## 四，客户端的动态刷新

1,修改客户端,添加一个pom依赖

注意，凡是和这样客户端刷新的就得引入actuator依赖

```xml
<!--监控-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```

2,修改配置文件

```yml
 # 暴露监控端点，暴露所有接口，包括refresh接口
management:
  endpoints:
    web:
      exposure:
        include: "*"
```

3,修改controller，类上添加一个注解

```
@RefreshScope
```



此时重启服务，**此时3355还不可以动态获取**

还需要运维工作人员切手动的发送一个post刷新请求，这样就能获取到最新的请求

```
curl -X POST "http://localhost:3355/actuator/refresh"
```





# 消息总线

上面的服务配置又留下了一个问题，要是有多个客户端怎么办，不可能每一个都去刷新一次，所以可不可以去使用广播，一次性通知，这就有了Bus

## 一，SpringCloud Bus

1,管理和传播分布式系统之间的消息

2，Spring Cloud Bus 和 Spring Cloud Config 实现配置的动态刷新

3，两种广播方式

​	它是Bus直接通知给其中一个客户端,由这个客户端开始蔓延,传播给其他所有客户端，这样做会增加客户端的压力，他除了做业务，还需要给其他的客户端广播

​	它是通知给配置中心的服务端,有服务端广播给所有客户端

![](.\图片\springconfig的26.png)









**为什么被称为总线?**

![](.\图片\springconfig的28.png)

```java
就是通过消息队列达到广播的效果
  		我们要广播每个消息时,主要放到某个topic中,所有监听的节点都可以获取到
```





## 使用Bus

1,配置rabbitmq环境:

![](.\图片\springconfig的29.png)



2,复制3355，创建一个新的客户端





3,使用Bus实现全局广播

****



![](.\图片\springconfig的33.png)





**配置第二种方式:**

**1,配置3344(配置中心服务端):**

1,添加配置文件:

```
rabbitmq:
  host: localhost
  port: 5672
  username: guest
  password: guest
  
management:
  endpoints:
    web:
      exposure:
        include: 'bus-refresh'
```



2,添加pom

**springboot的监控组件,和消息总线**

```xml
 <!-- 添加消息总线RabbitMQ支持 -->
dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bus-amqp</artifactId>
</dependency>
 <!--监控-->
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```



2,修改3355(配置中心的客户端)

1,pom:

```
<!--监控-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
<!-- 添加消息总线RabbitMQ支持 -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-amqp</artifactId>
        </dependency>
```

2,配置文件:

```yml
rabbitmq:
  host: localhost
  port: 5672
  username: guest
  password: guest
```



3,修改3366(也是配置中心的客户端)



4,测试

启动7001,3344,3355,3366

```
curl -X POST "http://localhost:3344/actuator/bus-refresh"
```



其原理就是:

![](.\图片\Bus的7.png)

**所有客户端都监听了一个rabbitMq的topic,我们将信息放入这个topic,所有客户端都可以送到,从而实时更新**









## 配置定点通知

​		就是只通知部分服务,比如只通知3355,不通知3366

```
curl -X POST "http://localhost:3344/actuator/bus-refresh/config-client:3355"      微服务的名称+端口号
```







# 消息驱动

### Spring Cloud Stream:

```java
现在一个很项目可能分为三部分:
			前端--->后端---->大数据
			而后端开发使用消息中间件,可能会使用RabbitMq
			而大数据开发,一般都是使用Kafka,
			那么一个项目中有多个消息中间件,对于程序员,因为人员都不友好
```

而Spring Cloud Stream就类似jpa,屏蔽底层消息中间件的差异,程序员主要操作Spring Cloud Stream即可

​			不需要管底层是kafka还是rabbitMq

![](.\图片\SpringCloudStream的1.png)

==什么是Spring Cloud Stream==

![](.\图片\SpringCloudStream的2.png)





![](.\图片\SpringCloudStream的3.png)

![](.\图片\SpringCloudStream的4.png)

![](.\图片\SpringCloudStream的5.png)





==**Spring Cloud Stream是怎么屏蔽底层差异的?**==

![](.\图片\SpringCloudStream的6.png)





**绑定器:**

![](.\图片\SpringCloudStream的7.png)

![](.\图片\SpringCloudStream的8.png)

![](.\图片\SpringCloudStream的9.png)





**Spring Cloud Streamd 通信模式:**

![](.\图片\SpringCloudStream的10.png)![](.\图片\SpringCloudStream的11.png)





Spring Cloud Stream的业务流程:

![](.\图片\SpringCloudStream的12.png)

![](.\图片\SpringCloudStream的14.png)

![](.\图片\SpringCloudStream的13.png)

```java
类似flume中的channel,source,sink  估计是借鉴(抄袭)的
  	source用于获取数据(要发送到mq的数据)
  	channel类似SpringCloudStream中的中间件,用于存放source接收到的数据,或者是存放binder拉取的数据	
```







常用注解和api:

![](.\图片\SpringCloudStream的15.png)





### 使用SpringCloudStream

需要创建三个项目,一个生产者,两个消费者

![](.\图片\SpringCloudStream的16.png)

### 1，创建生产者

1,pom

2,配置文件

![image-20200415114816133](.\图片\SpringCloudStream的17)

![](.\图片\SpringCloudStream的18.png)

3,主启动类

```java
@SpringBootApplication
public class StreamMain8801 {
    public static void main(String[] args) {
        SpringApplication.run(StreamMain8801.class,args);
    }
}
```



4,业务类

service定义发送消息

```java
public interface IMessageProvider {
    public String send();
}
```



```java
@EnableBinding(Source.class)
public class IMessageProviderImpl implements IMessageProvider {

    @Resource
    private MessageChannel output;

    @Override
    public String send() {
        String message = UUID.randomUUID().toString();
        //build方法会返回一个Message类对象
        output.send(MessageBuilder.withPayload(message).build());
        System.out.println(message);
        return null;
    }
}
```

**这里,就会调用send方法,将消息发送给channel,**

​				**然后channel将消费发送给binder,然后发送到rabbitmq中**

5,controller

```java
@RestController
public class SendMessageController
{
    @Resource
    private IMessageProvider messageProvider;

    @GetMapping(value = "/sendMessage")
    public String sendMessage()
    {
        return messageProvider.send();
    }

}
```

6,可以测试

启动rabbitmq，7001,8801

​		确定8801后,会在rabbitmq中创建一个Exchange,就是我们配置文件中配置的exchange

**访问8801的/sendMessage**







### 2，创建消费者

1,pom文件

2,配置文件

```yml
server:
  port: 8802

spring:
  application:
    name: cloud-stream-consumer
  cloud:
      stream:
        binders: # 在此处配置要绑定的rabbitmq的服务信息；
          defaultRabbit: # 表示定义的名称，用于于binding整合
            type: rabbit # 消息组件类型
            environment: # 设置rabbitmq的相关的环境配置
              spring:
                rabbitmq:
                  host: localhost
                  port: 5672
                  username: guest
                  password: guest
        bindings: # 服务的整合处理
          input: # 这个名字是一个通道的名称
            destination: studyExchange # 表示要使用的Exchange名称定义
            content-type: application/json # 设置消息类型，本次为对象json，如果是文本则设置“text/plain”
            binder: defaultRabbit # 设置要绑定的消息服务的具体设置

eureka:
  client: # 客户端进行Eureka注册的配置
    service-url:
      defaultZone: http://localhost:7001/eureka
  instance:
    lease-renewal-interval-in-seconds: 2 # 设置心跳的时间间隔（默认是30秒）
    lease-expiration-duration-in-seconds: 5 # 如果现在超过了5秒的间隔（默认是90秒）
    instance-id: receive-8802.com  # 在信息列表时显示主机名称
    prefer-ip-address: true     # 访问的路径变为IP地址
```



3,主启动类

```java
@SpringBootApplication
public class StreamMQMain8802
{
    public static void main(String[] args)
    {
        SpringApplication.run(StreamMQMain8802.class,args);
    }
}
```



4,业务类(消费数据)

```java
@Component
@EnableBinding(Sink.class)
public class ReceiveMessageListenerController
{
    @Value("${server.port}")
    private String serverPort;


    @StreamListener(Sink.INPUT)
    public void input(Message<String> message)
    {
        System.out.println("消费者1号,----->接受到的消息: "+message.getPayload()+"\t  port: "+serverPort);
    }
}
```

5,测试:

启动7001.8801.8802



### 3，重复消费问题



在默认情况下，stream会给消费者不同的分组，导致了生产者每产生一条消息，多个消费者都会收到消息，这就是重复消费



若手动的去给予分组，将不同的消费者分在一个组中，那么每当生产者产生一条消息，同一组中的消费者就会竞争，只会有一个应用消费



1,自定义分组

修改消费者的配置文件,将他们分为同一个组

```yml
  bindings:
        output:
          destination: my-destination
          content-type: application/json
          binder: defaultRabbit
          group: groupA
```







### 4，持久化问题

就是当服务挂了,怎么消费没有消费的数据，这个stream已经帮我们解决，只要配置了组，在生产者给消费者发生信息后，即使消费者挂机了，当其重启后，就会自动的去消费没有消费的信息









# 链路追踪:

## Spring Cloud Sleuth

**sleuth要解决的问题:**

![](.\图片\sleuth的1.png)

**而来sleuth就是用于追踪每个请求的整体链路**

![](.\图片\sleuth的2.png)



### 使用sleuth:

#### 1,安装zipkin:

![](.\图片\sleuth的3.png)

**运行jar包**

​			java -jar xxxx.jar

**然后就可以访问web界面,  默认zipkin监听的端口是9411**

​			localhost:9411/zipkin/

![](.\图片\sleuth的4.png)



**一条链路完整图片:**

![](.\图片\sleuth的5.png)

**精简版:**

![](.\图片\sleuth的6.png)

**可以看到,类似链表的形式**







#### 2,使用sleuth:

不需要额外创建项目,使用之前的8001和order的80即可



1,修改8001

**引入pom:**

![](.\图片\sleuth的7.png)

这个包虽然叫zipkin但是,里面包含了zpikin与sleuth

**修改配置文件:**

![](.\图片\sleuth的8.png)



2,修改80

**添加pom**

与上面是一样的



**添加配置**:

与上面也是一样的







3,测试:

启动7001.8001,80,9411

![](.\图片\sleuth的9.png)





