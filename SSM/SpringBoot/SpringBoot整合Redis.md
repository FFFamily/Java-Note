# SpringBoot整合Redis

## 导入依赖

```xml
<!-- redis -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- spring2.X集成redis所需common-pool2-->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
    <version>2.6.0</version>
</dependency>
```



## 启动Redis

```
先运行 redis-service.exe
再运行 redis-cli.exe
```

若是在Linux中配置的Redis，需要再配置主机地址

```properties
#redis服务器主机地址
spring.redis.host=192.168.31.162
```



## 配置文件

在导入redis依赖后RedisCacheConfiguration类就会自动生效，创建RedisCacheManager，并使用RedisCache进行缓存数据，要缓存的对象的类要实现Serializable接口，默认情况下是以**jdk序列化数据**存在redis中

如下形式

```
k:"emp::1"
v:
\xAC\xED\x00\x05sr\x00$cn.edu.ustc.springboot.bean.Employeeuqf\x03p\x9A\xCF\xE0\x02\x00\x05L\x00\x03dIdt\x00\x13Ljava/lang/Integer;L\x00\x05emailt\x00\x12Ljava/lang/String;L\x00\x06genderq\x00~\x00\x01L\x00\x02idq\x00~\x00\x01L\x00\x08lastNameq\x00~\x00\x02xpsr\x00\x11java.lang.Integer\x12\xE2\xA0\xA4\xF7\x81\x878\x02\x00\x01I\x00\x05valuexr\x00\x10java.lang.Number\x86\xAC\x95\x1D\x0B\x94\xE0\x8B\x02\x00\x00xp\x00\x00\x00\x03t\x00\x07cch@aaasq\x00~\x00\x04\x00\x00\x00\x01q\x00~\x00\x08t\x00\x03cch
```

要想让对象以**json形式**存储在redis中，需要自定义RedisCacheManager，使用GenericJackson2JsonRedisSerializer类对value进行序列化



```java
@EnableCaching//开启缓存
@Configuration//声明为配置文件
public class RedisConfig extends CachingConfigurerSupport {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        //Redis模板
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        //Redis序列化器
        RedisSerializer<String> redisSerializer = new StringRedisSerializer();
        //创建GenericJackson2JsonRedisSerializer的json序列化器
        Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer(Object.class);
       
        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);
       
        jackson2JsonRedisSerializer.setObjectMapper(om);
        
        template.setConnectionFactory(factory);
        //key序列化方式
        template.setKeySerializer(redisSerializer);
        //value序列化
        template.setValueSerializer(jackson2JsonRedisSerializer);
        //value hashmap序列化
        template.setHashValueSerializer(jackson2JsonRedisSerializer);
        return template;
    }

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory factory) {
        RedisSerializer<String> redisSerializer = new StringRedisSerializer();
        Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer(Object.class);
        //解决查询缓存转换异常的问题
        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);
        jackson2JsonRedisSerializer.setObjectMapper(om);
        // 配置序列化（解决乱码的问题）,过期时间600秒
        RedisCacheConfiguration config = RedisCacheConfiguration.defaultCacheConfig()
                .entryTtl(Duration.ofSeconds(600))
              .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(redisSerializer))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(jackson2JsonRedisSerializer))
                .disableCachingNullValues();
        RedisCacheManager cacheManager = RedisCacheManager.builder(factory)
                .cacheDefaults(config)
                .build();
        return cacheManager;
    }
}
```



在查询数据库的方法前使用注解

```java
@Cacheable(value = "banner", key = "'selectIndexList'")//注意双引号里面有个单引号
@Override
public List<CrmBanner> selectIndexList() {
	List<CrmBanner> list = baseMapper.selectList(new QueryWrapper<CrmBanner>().orderByDesc("sort"));
	return list;
}
```



或者使用RedisTemplate

```java
@RestController
public class ResdiTestController {

    @Autowired
    private RedisTemplate redisTemplate;

    @RequestMapping("/redisTest")
    @ApiOperation("测试Redis")
    public String TestRedis(){
        Usermin u = new Usermin();
        u.setId("1");
        u.setName("tutu");
        redisTemplate.opsForValue().set("usermin",u);
        return "存入成功";
    }
}
```





启动Redis服务

```properties
找到Redis目录

[root@online root]# ./redis-server /etc/redis.config
# 配置文件的目录不唯一

[root@online root]# ./redis-cli
# 这个时候就会出现
127.0.0.1：6379>
```



在配置文件中配置Redis

```properties
spring.redis.host=localhost
spring.redis.port=6379
spring.redis.database=0
spring.redis.timeout=1800000

spring.redis.lettuce.pool.max-active=20
spring.redis.lettuce.pool.max-wait=-1
#最大阻塞等待时间(负数表示没限制)
spring.redis.lettuce.pool.max-idle=5
spring.redis.lettuce.pool.min-idle=0
```





可能遇到的问题

（1）需要关闭Linux的防火墙，这样window的代码才能访问Linux

（2）找到redis配置文件， 注释一行配置

```
bind 127.0.0.1
# 这个是默认只有本地才能使用
```

（3）关闭自我保护机制

```
protected-mode yes  === >   protected-mode no
```

