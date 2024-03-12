# MybaitsPlus

> 该学习笔记出自视频学习中的文档，自己整理

## 一，入门

### 1、导入对应的依赖

```xml
<!--注意导plus和mybatis就只能导入一个，避免会发生冲突-->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.3.1</version>
</dependency>
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
</dependency>
<!--lombok用来简化实体类-->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

```

### 2，编写相关的代码

#### 	一，创建相关的数据库

#### 	二，实体类

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

#### 	三，配置数据源

```properties
# mysql 5 驱动不同 com.mysql.jdbc.Driver

# mysql 8 驱动不同com.mysql.cj.jdbc.Driver、需要增加时区的配置
serverTimezone=GMT%2B8
spring.datasource.username=
spring.datasource.password=
spring.datasource.url=jdbc:mysql://localhost:3306/mybatis_plus?
			useSSL=false&useUnicode=true&characterEncoding=utf-8&serverTimezone=GMT%2B8
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

#### 	四，创建通用mapper接口

**不要忘记了@Repository注解**

```java
/*
不需要像以前的配置一大堆文件
还可以自己定义一些自定义的crud
*/
@Repository
public interface UserMapper extends BaseMapper<User> {
}
```

### 3，使用

注意：不要忘记在主引导类上配置扫描mapper的注解

```java
@MapperScan("mypatisplus_test.demo.mapper")
```



```java
@Autowired
private UserMapper userMapper;

@Test
void Test() {
List<User> users = userMapper.selectList(null);
users.forEach(System.out::println);
}
```

### 4，产生的异常

​	一，没用在引导类上添加扫描mapper的注解

​	二，Unsatisfied dependency expressed through field 'mapper'

```java
@Repository
@Mapper
public interface userMapper extends BaseMapper<User> {
    //这个错误是idea报错说找不到这样的一个mapper，这个问题感觉也是版本所带来的问题
    /*
     1、@mapper后，不需要在spring配置中设置扫描地址，通过mapper.xml里面的namespace属性对应相关的mapper类，spring将动态的生成Bean后注入到IOC容器中

    2、@repository则需要在Spring中配置扫描包地址，然后生成dao层的bean，之后被注入到IOC容器
    */
}
```

按照上面的说法，再次检查了自己的DemoApplication中的注解

发现

```java
@MapperScan("mypatisplus_test.demo.mapper")
```

包名写错，应该是

```java
@MapperScan("mypatisplus_test.demo.domain")
```



## 二，配置日志

```properties
# 配置日志
mybatis-plus.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl
```



## 三，CRUD

### 1，插入

```java
int result = userMapper.insert(user); // 帮我们自动生成id----雪花算法
```

#### 我们设置主键自增的方法

##### 1，数据库字段设置自增

这种方法是不推荐的，因为平时开发中，是不允许修改数据库的，避免出现问题

##### 2，使用注解@TableId

```java
@TableId(type = IdType.AUTO)
private int id;


public enum IdType {
AUTO(0), // 数据库id自增
NONE(1), // 未设置主键
INPUT(2), // 手动输入
ID_WORKER(3), // 默认的全局唯一id
UUID(4), // 全局唯一id uuid
ID_WORKER_STR(5); //ID_WORKER 字符串表示法
}
```





#### 额外：分布式唯一ID生成方案

**1. 数据库自增长序列或字段**

**2. UUID**

**3. UUID的变种**

**4. Redis生成ID**

**5. Twitter的snowflake算法**（雪花算法）

其核心思想是：

​	使用41bit作为 毫秒数，10bit作为机器的ID（5个bit是数据中心，5个bit的机器ID），12bit作为毫秒内的流水号（意味 着每个节点在每毫秒可以产生 4096 个 ID），最后还有一个符号位，永远是0。可以保证几乎全球唯

**6. 利用zookeeper生成唯一ID**





### 2，更新

```java
int i = userMapper.updateById(user);
```

#### 自动填充方法

在涉及到更新操作中难免少不了更新的时间，这是阿里巴巴开发手册中提出的，每个字段需要添加两个列表

gmt_create：创建时间

gmt_modified：更新时间



##### 1，数据库设置

两个字段的类别是：datetime

设置一个默认值：	CURRENT_TIMESTAMP 

并且设置这个列值为 更新

> 同样的，不推荐这里修改列的属性



##### 2，mybatisplus中的设置

一，字段添加填充内容

```java
//在插入的时候自动填充
@TableField(fill = FieldFill.INSERT)
    private Date createTime;
//在插入后的更新的时候自动填充
@TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;
```

二，编写一个处理器

```java
@Component // 一定不要忘记把处理器加到IOC容器中！
public class MyMetaObjectHandler implements MetaObjectHandler {

    // 插入时的填充策略
    @Override
    public void insertFill(MetaObject metaObject) {
        /* 
            setFieldValByName(String fieldName, Object fieldVal, MetaObject)
            fieldName: 字段名
            fieldVal：需要填充的类型
        */
        this.setFieldValByName("createTime",new Date(),metaObject);
        this.setFieldValByName("updateTime",new Date(),metaObject);
    }

   // 更新时的填充策略
    @Override
    public void updateFill(MetaObject metaObject) {
        this.setFieldValByName("updateTime",new Date(),metaObject);
        }
}
```



#### 乐观锁

> 乐观锁 : 故名思意十分乐观，它总是认为不会出现问题，无论干什么不去上锁！如果出现了问题， 再次更新值测试
> 悲观锁：故名思意十分悲观，它总是认为总是出现问题，无论干什么都会上锁！再去操作！



##### 1，乐观锁实现方式

取出记录时，获取当前 version 更新时，带上这个version 执行更新时， set version = newVersion where version = oldVersion 如果version不对，就更新失败

1）数据库增加version字段

2）添加实体类字段

```java
@Version //乐观锁Version注解 
private Integer version;
```

3）注册乐观锁

```java
// 扫描我们的 mapper 文件夹 
@MapperScan("com.mapper") 
@EnableTransactionManagement 
@Configuration // 配置类 
public class MyBatisPlusConfig {
    // 注册乐观锁插件    
    @Bean    
    public OptimisticLockerInterceptor optimisticLockerInterceptor() {        
        return new OptimisticLockerInterceptor();    
    }
}

```

这样在使用更新操作的时候就会



### 3，查询

```
User user = userMapper.selectById(1L); 
```



批量查询

```java
List<User> users = userMapper.selectBatchIds(Arrays.asList(1, 2, 3)); 
```

map操作

```java
HashMap<String, Object> map = new HashMap<>();       
map.put("name","123");    
map.put("age",3);
List<User> users = userMapper.selectByMap(map); 
```

分页查询

方式：

1，原始的 limit 进行分页 

2，pageHelper 第三方插件

3，MP 其实也内置了分页插件



设置拦截器对象

```java
// 分页插件 
@Bean 
public PaginationInterceptor paginationInterceptor() {    
	return  new PaginationInterceptor(); 
}
```

然后就可以直接使用Page对象

```java
 //  参数一：当前页   
 //  参数二：页面大小    
 //  使用了分页插件之后，所有的分页操作也变得简单的！    
 Page<User> page = new Page<>(2,5);    
 userMapper.selectPage(page,null);
```



### 4，删除

```java
userMapper.deleteById(1240620674645544965L); 
 
userMapper.deleteBatchIds(Arrays.asList(1240620674645544961L,124062067464554496 2L)); 

HashMap<String, Object> map = new HashMap<>();    
map.put("name","t");    
userMapper.deleteByMap(map);
```



逻辑删除

> 物理删除 ：从数据库中直接移除  
>
> 
>
> 逻辑删除 ：再数据库中没有被移除，而是通过一个变量来让他失效！ deleted = 0 => deleted = 1

1，数据库添加deleted字段

2，实体类

```java
@TableLogic //逻辑删除 
private Integer deleted;
```

3，配置类

```java
// 逻辑删除组件 
@Bean 
public ISqlInjector sqlInjector() {   
	return new LogicSqlInjector(); 
}
```

4，配置文件

```properties
# 配置逻辑删除 
mybatis-plus.global-config.db-config.logic-delete-value=1 
mybatis-plus.global-config.db-config.logic-not-delete-value=0
```



注意，当以这样的方式进行删除时，实际上进行的是更新操作，修改deleted字段

并且当查询的时候会自动过滤已经逻辑删除的字段



## 四，性能分析插件

```java
@Bean 
@Profile({"dev","test"})// 设置 dev test 环境开启，保证我们的效率 
public PerformanceInterceptor performanceInterceptor() {    
    PerformanceInterceptor performanceInterceptor = new PerformanceInterceptor();   
    performanceInterceptor.setMaxTime(100); // ms设置sql执行的最大时间，如果超过了则不 执行    
    performanceInterceptor.setFormat(true); // 是否格式化代码    
    return performanceInterceptor; 
}
```





记住，要在SpringBoot中配置环境为dev或者 test 环境



## 五，条件构造器

用于一些复杂的sql

利用：QueryWrapper 完成一些条件

```
QueryWrapper<User> wrapper = new QueryWrapper<>(); 
wrapper        
    .isNotNull("name")        
    .isNotNull("email")        
    .ge("age",12); 
```

同样的还有很多，可以去官网文档查看





## 六，代码生成器

```java
// 代码自动生成器 public class KuangCode {
    public static void main(String[] args) {        
    // 需要构建一个 代码自动生成器 对象        
        AutoGenerator mpg = new AutoGenerator();       
        // 配置策略
        // 1、全局配置        
        GlobalConfig gc = new GlobalConfig();        
        String projectPath = System.getProperty("user.dir");        
        gc.setOutputDir(projectPath+"/src/main/java");        
        gc.setAuthor("狂神说");        
        gc.setOpen(false);        
        gc.setFileOverride(false); // 是否覆盖        
        gc.setServiceName("%sService"); // 去Service的I前缀        
        gc.setIdType(IdType.ID_WORKER);        
        gc.setDateType(DateType.ONLY_DATE);        
        gc.setSwagger2(true);        
        mpg.setGlobalConfig(gc);
        //2、设置数据源        
        DataSourceConfig dsc = new DataSourceConfig();        
        dsc.setUrl("jdbc:mysql://localhost:3306/kuang_community? useSSL=false&useUnicode=true&characterEncoding=utf-8&serverTimezone=GMT%2B8");        
        dsc.setDriverName("com.mysql.cj.jdbc.Driver");        
        dsc.setUsername("root");        
        dsc.setPassword("123456");        
        dsc.setDbType(DbType.MYSQL);        
        mpg.setDataSource(dsc);
        //3、包的配置        
        PackageConfig pc = new PackageConfig();        
        pc.setModuleName("blog");        
        pc.setParent("com.kuang");        
        pc.setEntity("entity");        
        pc.setMapper("mapper");        
        pc.setService("service");        
        pc.setController("controller");        
        mpg.setPackageInfo(pc);
        //4、策略配置        
        StrategyConfig strategy = new StrategyConfig();  
        strategy.setInclude("blog_tags","course","links","sys_settings","user_record"," user_say"); // 设置要映射的表名        
        strategy.setNaming(NamingStrategy.underline_to_camel);        
        strategy.setColumnNaming(NamingStrategy.underline_to_camel);        
        strategy.setEntityLombokModel(true); // 自动lombok；
        strategy.setLogicDeleteFieldName("deleted");        // 自动填充配置        
        TableFill gmtCreate = new TableFill("gmt_create", FieldFill.INSERT);        
        TableFill gmtModified = new TableFill("gmt_modified", FieldFill.INSERT_UPDATE);        
        ArrayList<TableFill> tableFills = new ArrayList<>();        
        tableFills.add(gmtCreate);        
        tableFills.add(gmtModified);        
        strategy.setTableFillList(tableFills);        // 乐观锁        
        strategy.setVersionFieldName("version");
        strategy.setRestControllerStyle(true);        
        strategy.setControllerMappingHyphenStyle(true); // localhost:8080/hello_id_2        
        mpg.se tStrategy(strategy);
        mpg.execute(); //执行    
    } 
}
```

