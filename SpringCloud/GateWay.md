# GateWay



![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%841.png)

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%842.png)

**gateway之所以性能号,因为底层使用WebFlux,而webFlux底层使用netty通信(NIO)**



## 作用

鉴权校验：验证是否认证和授权
统一入口：提供所有微服务的入口点，起到隔离作用，保障服务的安全性
限流熔断
路由转发
负载均衡



## 架构图

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%843.png)



## 特性

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%844.png)



## GateWay与zuul的区别

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%845.png)



zuul1.x的模型:

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%846.png)

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%847.png)



## webflux

**是一个非阻塞的web框架,类似springmvc这样的**

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%848.png)





## 路由

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%849.png)

就是根据某些规则,将请求发送到指定服务上



## 断言

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%8410.png)

就是判断,如果符合条件就是xxxx,反之yyyy



## 过滤

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%8411.png)

​	**路由前后,过滤请求**





## GateWay的工作原理

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%8412.png)

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%8413.png)





## 使用GateWay

### pom

在有父项目后可以不用写具体的版本号

导入Getway后就不需要web相关（比如MVC）的依赖

同时也要注意，尽量不要去引入父项目中的依赖，而是自己简单导入

防止依赖过多无法管理，导致项目启动报错

```xml
<!--gateway 网关 -->
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
```

### 配置文件

使用的是nacos+springcloud+gateway

所以配置文件有所不同

```yml
# 笔记之前的版本
server:
  port: 9527
spring:
  application:
    name: cloud-gateway
eureka:
  instance:
    hostname: cloud-gateway-service
  client:
    service-url:
      register-with-eureka: true
      fetch-registry: true
      defaultZone: http://eureka7001.com:7001/eureka
```

版本二

```yml
server:
  port: 8080
spring:
  application:
    name: gateway
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true # 启用自动根据服务ID生成路由 开启注册中心自动路由功能
          lower-case-service-id: true # 设置路由的路径为小写的服务ID
      routes: # 这个是路由规则
        - id: news	# 路由id（尽量和微服务名保持一）
          uri: http://localhost:8082	# 真实调用地址 / 也可以用微服务名
          predicates:
            - Path=/locations/**
    nacos:
      discovery:
        server-addr: 127.0.0.1:8848
```

主启动类

```java
@SpringBootApplication
@EnableEurekaClient
public class GateWayMain9527 {
    public static void main(String[] args) {
        SpringApplication.run(GateWayMain9527.class,args);
    }
}
```

两种方式的配置文件信息

```yml
spring:
  application:
    name: cloud-gateway
  cloud:
    gateway:
    # 开启从注册中心动态创建路由的功能，利用服务名进行路由
      scovery:
    	ocator:
    	  able: true
      routes:
        - id: payment-routh
        # 方式一:直接通过端口
          uri: http://localhost:8001 #代表从注册中心获取服务，且以lb(load-balance)负载均衡方式转发
          predicates:
            - Path=/payment/get/** # 注意：P要大写，这是配置断言
            
				# 方式二：通过服务名，从注册中心获取服务组件,前提是需要开启注册功能
        - id: payment-routh2
          uri: lb:cloud-provider-service
          predicates:
            - Path=/payment/lb/**
            
# ​	当访问localhost:9527/payment/get/1时 
# ​ 路由到localhost:8001/payment/get/1            
```

​		

### 出现的问题

通过方式一能访问对应的服务，但是切换到方式二后一直报错500超时异常，不明白原因





## 编码方式配置信息

**GateWay的网关配置,除了支持配置文件,还支持硬编码方式**



![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/gateway%E7%9A%8420.png)







## Pridicate断言

Spring Cloud Gateway包括很多内置的Route Predicate工厂

分别对应着HTTP请求的各种属性，请求头，cookie等等

Spring Cloud Gateway 创建Route对象时，RoutePredicateFactory创建Predicate对象，再赋值给Route



即

```yml
predicates:
  - Path=/payment/get/** # 注意：P要大写
  # 这个断言表示,如果外部访问路径是指定路径,就路由到指定微服务上
```



断言的类型



```java
After: 可以指定,只有在指定时间后,才可以路由到指定微服务，在此之前的访问,都会报404
before:与after类似,他说在指定时间之前的才可以访问
between:需要指定两个时间,在他们之间的时间才可以访问

    //那么如何获取时区    
ZonedDateTime time = ZonedDateTime.now();//获取默认时区
```

​				

```java
cookie:只有包含某些指定cookie(key,value),的请求才可以路由
 //value可以是正则表达式
```



```java
Header:只有包含指定请求头的请求,才可以路由
    //value可以是正则表达式
```



```java
host:只有指定主机的才可以访问,
		比如我们当前的网站的域名是www.aa.com
    那么这里就可以设置,只有用户是www.aa.com的请求,才进行路由
            http://localhost:8888/paym -H "Host: www.baidu.com"
```



```java
method:只有指定请求才可以路由,比如get请求...
```



```java
path:只有访问指定路径,才进行路由
```



```java
Query:必须带有请求参数才可以访问
```





## Filter过滤器

由GatewayFilter工厂类产生，和断言的配置类似，只有满足相关的条件，才放行，反之过滤



生命周期：**在请求进入路由之前,和处理请求完成,再次到达路由之前**

分类:

1，GatewayFilter(单一过滤器)

2，GlobalFilter(全局过滤器)



```yml
# 会在匹配的请求头上加一对请求，名为X-Request-Id
filters:
	- AddRequestParameter=X-Request-Id ,1024
```





### **自定义全局过滤器**

```java
@Component
public class MyGatewayFiltter implements GlobalFilter, Ordered {
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String username = exchange.getRequest().getQueryParams().getFirst("username");
        //如果username为空，直接过滤
        if (username==null){
            exchange.getResponse().setStatusCode(HttpStatus.NOT_ACCEPTABLE);
            return exchange.getResponse().setComplete();
        }
        //反之，直接下一个过滤器，即，放行
        return chain.filter(exchange);
    }
	//返回的是执行的过滤器级别，数字越大，越先执行
    @Override
    public int getOrder() {
        return 0;
    }
}
```







