# SpringBoot高级部分

> 来自《尚硅谷Boot高级部分》
>
> 笔记完全借鉴于这个大佬
>
> https://niceseason.github.io/2020/04/18/springboot/#%E4%B8%80-Spring-Boot%E4%B8%8E%E7%BC%93%E5%AD%98



# (一) Spring Boot与缓存

## 一、 JSR107

Java Caching定义了5个核心接口

- CachingProvider

  定义了创建、配置、获取、管理和控制多个CacheManager。一个应用可
  以在运行期访问多个CachingProvider。

- CacheManager

  定义了创建、配置、获取、管理和控制多个唯一命名的Cache，这些Cache
  存在于CacheManager的上下文中。一个CacheManager仅被一个CachingProvider所拥有。

- Cache

  一个类似**Map**的数据结构并**临时存储以Key为索引**的值。一个Cache仅被一个
  CacheManager所拥有。

- Entry

  一个存储在Cache中的key-value对。

- Expiry

  每一个存储在Cache中的条目有一个定义的有效期。一旦超过这个时间，条目为过期的状态。一旦过期，条目将不可访问、更新和删除。缓存有效期可以通过ExpiryPolicy设置。



## 二、 Spring缓存抽象

Spring从3.1开始定义了org.springframework.cache.Cache
和org.springframework.cache.CacheManager接口来**统一**不同的缓存技术；
**并支持使用JCache（JSR-107）**注解简化我们开发；

Cache接口有以下功能：

- 为缓存的组件规范定义，包含缓存的各种操作集合；

- Spring提供了各种xxxCache的实现；如RedisCache，EhCacheCache ,
  ConcurrentMapCache等；



## 三、 重要缓存注解及概念

| **Cache**          | **缓存接口，定义缓存操作。实现有：RedisCache、EhCacheCache、ConcurrentMapCache等** |
| ------------------ | :----------------------------------------------------------- |
| **CacheManager**   | **缓存管理器，管理各种缓存（Cache）组件**                    |
| **@Cacheable**     | **根据方法的请求参数对其结果进行缓存**                       |
| **@CacheEvict**    | **清空缓存**                                                 |
| **@CachePut**      | **更新缓存**                                                 |
| **@EnableCaching** | **开启基于注解的缓存**                                       |
| **keyGenerator**   | **缓存数据时key生成策略**                                    |
| **serialize**      | **缓存数据时value序列化策略**                                |

### 1，主要的参数

- **value**

  缓存名称，字符串/字符数组形式；

  ```
  如@Cacheable(value=”mycache”) 或者@Cacheable(value={”cache1”,”cache2”}
  ```

- **key**

  缓存的key,需要按照SpEL表达式编写，如果不指定则按照方法所有参数进行组合；

  ```
  如@Cacheable(value=”testcache”,key=”#userName”)
  ```

- **keyGenerator**

  key的生成器；可以自己指定key的生成器的组件id

  ```
  注意：key/keyGenerator：二选一使用;
  ```

- **condition**

  缓存条件，使用SpEL编写，在调用方法之前之后都能判断；

  ```
  如@Cacheable(value=”testcache”,condition=”#userName.length()>2”)
  ```

- **unless**（@CachePut、@Cacheable）

  用于否决缓存的条件，只在方法执行之后判断；

  ```
  如@Cacheable(value=”testcache”,unless=”#result ==null”)
  ```

- **beforeInvocation**（@CacheEvict）

  是否在执行前清空缓存，默认为false，false情况下方法执行异常则不会清空；

  ```
  如@CachEvict(value=”testcache”，beforeInvocation=true)
  ```

- **allEntries**（@CacheEvict）

  是否清空所有缓存内容，默认为false；

  ```
  如@CachEvict(value=”testcache”,allEntries=true)
  ```

### 2，缓存可用的SpEL表达式

**root**

表示根对象，不可省略

- 被调用方法名 **methodName**

  如 #root.methodName

- 被调用方法 **method**

  如 #root.method.name

- 目标对象 **target**

  如 #root.target

- 被调用的目标对象类 **targetClass**

  如 #root.targetClass

- 被调用的方法的参数列表 **args**

  如 #root.args[0]

- 方法调用使用的缓存列表 **caches**

  如 #root.caches[0].name

**参数名**

方法参数的名字. 可以直接 #参数名 ，也可以使用 #p0或#a0 的形式，0代表参数的索引；

如 #iban 、 #a0 、 #p0

**返回值**

方法执行后的返回值（仅当方法执行之后的判断有效，如‘unless’ ， @CachePut、@CacheEvict’的表达式beforeInvocation=false ）

如 #result



## 四、 缓存使用

1，引入spring-boot-starter-cache模块

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
```

2，在主配置类上标注，@EnableCaching开启缓存

3，使用缓存注解

```java
@Service
public class EmployeeService {
    @Autowired
    private EmployeeMapper employeeMapper;

    @Cacheable(value={"emp"},
            key = "#id+#root.methodName+#root.caches[0].name",
            condition = "#a0>1",
            unless = "#p0==2"
    )
    public Employee getEmpById(Integer id) {
        System.out.println("查询员工："+id);
        return employeeMapper.getEmpById(id);
    }

    @CachePut(value = {"emp"},key = "#employee.id" )
    public Employee updateEmp(Employee employee) {
        System.out.println("更新员工"+employee);
        employeeMapper.updateEmp(employee);
        return employee;
    }

    @CacheEvict(value = {"emp"},allEntries = true,beforeInvocation = true)
    public Integer delEmp(Integer id){
        int i=1/0;
        System.out.println("删除员工："+id);
        employeeMapper.delEmp(id);
        return id;
    }
}
```



**自定义KeyGenerator**

> 也就是自定义生成key的策略
>
> 使用时在注解属性内指定KeyGenerator=“myKeyGenerator”

--配置类

```java
@Configuration
public class MyCacheConfig {
    @Bean("myKeyGenerator")
    public KeyGenerator myKeyGenerator() {
        return new KeyGenerator(){
            @Override
            public Object generate(Object target, Method method, Object... params) {
                return method.getName()+"["+ Arrays.asList(params).toString()+target+"]";
            }
        };
    }
}
```



**@CacheConfig**

标注在类上，用于抽取@Cacheable的公共属性

由于一个类中可能会使用多次@Cacheable等注解，所以各项属性可以抽取到@CacheConfig



**@Caching**

组合使用@Cacheable、@CachePut、@CacheEvict

```java
@Caching(
       cacheable = {
           @Cacheable(/*value="emp",*/key = "#lastName")
       },
       put = {
           @CachePut(/*value="emp",*/key = "#result.id"),
           @CachePut(/*value="emp",*/key = "#result.email")
       }
  )
  public Employee getEmpByLastName(String lastName){
      return employeeMapper.getEmpByLastName(lastName);
  }
```



## 五，整合Redis

> 在笔记《SpringBoot整合Redis中》





# (二) Spring Boot与消息



## 一、消息简介

**消息代理规范**

- JMS（Java Message Service）JAVA消息服务
  - 基于JVM消息代理的规范。ActiveMQ、HornetMQ是JMS实现
- AMQP（Advanced Message Queuing Protocol）
  - 高级消息队列协议，也是一个消息代理的规范，兼容JMS
  - RabbitMQ是AMQP的实现

**作用**

通过消息服务中间件来提升系统异步通信、扩展解耦能力

当消息发送者发送消息以后，将由消息代理接管，消息代理保证消息传递到指定目的地



## 二、RabbitMQ

RabbitMQ是一个由erlang开发的AMQP(Advanved Message Queue Protocol)的开源实现。

### 1. 核心概念

- **Message**
  - 消息，消息是不具名的，它由消息头和消息体组成
  - 消息头，包括routing-key（路由键）、priority（相对于其他消息的优先权）、delivery-mode（指出该消息可能需要持久性存储）等
- **Publisher**
  - 消息的生产者，也是一个向交换器发布消息的客户端应用程序
- **Exchange**
  - 交换器，将生产者消息路由给服务器中的队列
  - 类型有direct(默认)，fanout, topic, 和headers，具有不同转发策略
- **Queue**
  - 消息队列，保存消息直到发送给消费者
- **Binding**
  - 绑定，用于消息队列和交换器之间的关联
- Connection
  - 网络连接，比如一个TCP连接
- Consumer
  - 消息的消费者，表示一个从消息队列中取得消息的客户端应用程序
- Virtual Host
  - 虚拟主机，表示一批交换器、消息队列和相关对象。
  - vhost 是 AMQP 概念的基础，必须在连接时指定
  - RabbitMQ 默认的 vhost 是 /
- Broker
  - 消息队列服务器实体

### 2. 运行机制

**消息路由**

AMQP 中增加了Exchange 和 Binding 的角色， Binding 决定交换器的消息应该发送到那个队列

**Exchange 类型**

1. direct

   点对点模式，消息中的路由键（routing key）如果和 Binding 中的 binding
   key 一致， 交换器就将消息发到对应的队列中。

2. fanout

   广播模式，每个发到 fanout 类型交换器的消息都会分到所有绑定的队列上去

3. topic

   将路由键和某个模式进行匹配，此时队列需要绑定到一个模式上。它将路由键和绑定键的字符串切分成单词，这些单词之间用点隔开。
   识别通配符： # 匹配 0 个或多个单词， *匹配一个单词



## 三、整合RabbitMQ

1，docker中安装运行

```
# 5672为服务端口，15672为web控制台端口
docker run -d -p 5672:5672 -p 15672:15672 38e57f28189,1
```

2，依赖

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
<!--自定义消息转化器Jackson2JsonMessageConverter所需依赖-->
<dependency>
	<groupId>com.fasterxml.jackson.core</groupId>
	<artifactId>jackson-databind</artifactId>
</dependency>
```

3，配置文件

```properties
# 指定rebbitmq服务器主机
spring.rabbitmq.host=192.168.31.162
#spring.rabbitmq.username=guest  默认值为guest
#spring.rabbitmq.password=guest	 默认值为guest
```

4，使用

```java
@Autowired
private RabbitTemplate rabbitTemplate;

@Autowired
private AmqpAdmin amqpAdmin;//对交换机进行设置

//发送消息
rabbitTemplate.convertAndSend("amq.direct","ustc","aaaa");

Book book = new Book();
book.setName("西游记");
book.setPrice(23.2f);
//Book要实现Serializable接口
rabbitTemplate.convertAndSend("amq.direct","ustc",book);

//取出消息
Object o = rabbitTemplate.receiveAndConvert("ustc");
System.out.println(o.getClass());  //class cn.edu.ustc.springboot.bean.Book
System.out.println(o);			//Book{name='西游记', price=23.2}

//创建Direct类型的Exchange
amqpAdmin.declareExchange(new DirectExchange("admin.direct"));
//创建Queue
amqpAdmin.declareQueue(new Queue("admin.test"));
//将创建的队列与Exchange绑定
amqpAdmin.declareBinding(new Binding("admin.test", Binding.DestinationType.QUEUE,"admin.direct","admin.test",null));
```

默认的消息转化器是SimpleMessageConverter，对于对象以jdk序列化方式存储，若要以Json方式存储对象，就要自定义消息转换器

```java
@Configuration
public class AmqpConfig {
    @Bean
    public MessageConverter messageConverter() {
        //在容器中导入Json的消息转换器
        return new Jackson2JsonMessageConverter();
    }
}
```

消息的监听

在回调方法上标注@RabbitListener注解，并设置其属性queues，注册监听队列，当该队列收到消息时，标注方法遍会调用

可分别使用Message和保存消息所属对象进行消息接收，若使用Object对象进行消息接收，实际上接收到的也是Message

```java
@Service
public class BookService {
    @RabbitListener(queues = {"admin.test"})
    public void receive1(Book book){
        System.out.println("收到消息："+book);
    }

    @RabbitListener(queues = {"admin.test"})
    public void receive1(Object object){
        System.out.println("收到消息："+object.getClass());
        //收到消息：class org.springframework.amqp.core.Message
    }
    
    @RabbitListener(queues = {"admin.test"})
    public void receive2(Message message){
        System.out.println("收到消息"+message.getHeaders()+"---"+message.getPayload());
    }
}
```





# (三) Spring boot与检索

> 检索的学习需要通过文档对着api开发使用

## 一、 ElasticSearch入门

我们的应用经常需要添加检索功能，开源的 ElasticSearch 是目前全文搜索引擎的首选。他可以快速的存储、搜索和分析海量数据。

Elasticsearch是一个分布式搜索服务，提供Restful API，底层基于Lucene，采用多shard（分片）的方式保证数据安全，并且提供自动resharding的功能，github等大型的站点也是采用了ElasticSearch作为其搜索服务。

**概念**

-	索引---数据库
-	类型---表
-	文档---表中的记录
-	属性---列

## 二、 ES的安装与运行

- 9200端口

   RESTful API通过HTTP通信

- 9300端口

   Java客户端与ES的原生传输协议和集群交互

  

  

  安装

```
# 拉取ES镜像
docker pull elasticsearch:7.6.1
#运行ES
docker run -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m" -d -p 9200:9200 -p 9300:9300 --name ES03 41072cdeebc5

ES_JAVA_OPTS指定java虚拟机相关参数：

-Xms256m 初始堆内存大小为256m
-Xmx256m 最大堆内存大小为256m
discovery.type=single-node 设置为单点启动
```



创建一个员工目录，并支持各类型检索

```
PUT /megacorp/employee/1
{
    "first_name" : "John",
    "last_name" :  "Smith",
    "age" :        25,
    "about" :      "I love to go rock climbing",
    "interests": [ "sports", "music" ]
}

put请求
```

检索

```
GET /megacorp/employee/1
```

搜索所有雇员

```
GET /megacorp/employee/_search
```

搜索姓氏为 `Smith` 的雇员

```
GET /megacorp/employee/_search?q=last_name:Smith
```



> **使用查询表达式搜索**
>
> Query-string 搜索通过命令非常方便地进行临时性的即席搜索 ，但它有自身的局限性。
>
> Elasticsearch 提供一个丰富灵活的查询语言叫做 *查询表达式* ， 它支持构建更加复杂和健壮的查询。



年龄大于 30 的姓氏为 Smith 的员工

```json
GET /megacorp/employee/_search
{
    "query" : {
        "bool": {
            "must": {
                "match" : {
                    "last_name" : "smith" 
                }
            },
            "filter": {
                "range" : {
                    "age" : { "gt" : 30 } 
                }
            }
        }
    }
}
```

搜索下所有喜欢攀岩（rock climbing）的员工：

```
GET /megacorp/employee/_search
{
    "query" : {
        "match" : {
            "about" : "rock climbing"
        }
    }
}
```

高亮搜索

```
GET /megacorp/employee/_search
{
    "query" : {
        "match_phrase" : {
            "about" : "rock climbing"
        }
    },
    "highlight": {
        "fields" : {
            "about" : {}
        }
    }
}
```



## 二、 整合ElasticSearch

> SpringBoot默认支持两种技术来和ES交互；
>
> - Jest（默认不生效）
>   - 需要导入jest的工具包（io.searchbox.client.JestClient）
>   - 从springboot 2.2.0以后被弃用
> - SpringData ElasticSearch

版本

| Spring Data Elasticsearch | Elasticsearch |
| ------------------------- | ------------- |
| 3.2.x                     | 6.8.1         |
| 3.1.x                     | 6.2.2         |
| 3.0.x                     | 5.5.0         |
| 2.1.x                     | 2.4.0         |
| 2.0.x                     | 2.2.0         |
| 1.3.x                     | 1.5.2         |



2，配置文件

```
@Configuration
static class Config {
  @Bean
  RestHighLevelClient client() {

    ClientConfiguration clientConfiguration = ClientConfiguration.builder() 
      .connectedTo("localhost:9200")
      .build();

    return RestClients.create(clientConfiguration).rest();                  
  }
}
```

或者

```
spring.elasticsearch.rest.uris=http://192.168.31.162:9200
```



3，使用

创建

```java
@Autowired
RestHighLevelClient highLevelClient;


IndexRequest request = new IndexRequest("ustc", "book",
        UUID.randomUUID().toString())
        .source(Collections.singletonMap("feature", "high-level-rest-client"))
        .setRefreshPolicy(WriteRequest.RefreshPolicy.IMMEDIATE);
        
IndexResponse index = highLevelClient.index(request, RequestOptions.DEFAULT);

```

--

```
{
    "_index": "ustc",
    "_type": "book",
    "_id": "0dc9f47a-7913-481d-a36d-e8f034a6a3ac",
    "_score": 1,
    "_source": {
        "feature": "high-level-rest-client"
    }
}
```

获取

```java
//分别指定要获取的索引、类型、id
GetRequest getRequest = new GetRequest("ustc","book","0dc9f47a-7913-481d-a36d-e8f034a6a3ac");
GetResponse documentFields = highLevelClient.get(getRequest, RequestOptions.DEFAULT);
System.out.println(documentFields);
```



> ES有两个模板，分别为`ElasticsearchRestTemplate`和`ElasticsearchTemplate`
>
> 分别对应于**High Level REST Client**和**Transport Client**(弃用)，两个模板都实现了`ElasticsearchOperations`接口，因此使用时我们一般使用`ElasticsearchOperations`，具体实现方式由底层决定

```
@Autowired
ElasticsearchOperations elasticsearchOperations;
```

保存

```java
Book book = new Book();
book.setAuthor("路遥");
book.setBookName("平凡的世界");
book.setId(1);
IndexQuery indexQuery = new IndexQueryBuilder()
    .withId(book.getId().toString())
    .withObject(book)
    .build();
String index = elasticsearchOperations.index(indexQuery);
```

**查询索引**

```java
Book book = elasticsearchOperations.queryForObject(GetQuery.getById("1"), Book.class);
```



