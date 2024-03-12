# Mybatis

> 笔记来源于视频笔记
>
> 给自己的话：
>
> 这里还有很多知识没涉及到，所以需要自己在动手操作代码的时候，以及有道云的有些知识还没有整理，所以需要在整合的时候好好整理代码笔记

# 概念

## mybatis概念

1，mybatis是一个优秀的基于 java 的**持久层框架**，它内部封装了 jdbc，**使开发者只需要关注 sql语句本身**， 而不需要花费精力去处理其他与sql相关的繁杂过程

2，mybatis**通过xml 或注解的方式将要执行的各种statement配置起来**，并通过java对象和statement 中 sql 的动态参数进行映射生成最终执行的 sql 语句，最后由 mybatis 框架执行 sql 并将结果映射为 java 对象并 返回

3，采用 **ORM 思想**解决了实体和数据库映射的问题，对 jdbc进行了封装，屏蔽了 jdbc api 底层访问细节，使我 们不用与 jdbc api 打交道，就可以完成对数据库的持久化操作



## ORM思想

对象关系映射（Object Relational Mapping，简称ORM，或O/RM，或O/R mapping），是一种程序技术，用于实现面向对象编程语言里**不同类型系统的数据之间的转换**

ORM指的是**面向对象的对象模型**和**关系型数据库的数据结构**之间的相互转换

> "O(对象模型)：实体对象，即我们在程序中根据数据库表结构建立的实体类" 
>
> "R(关系型数据库的数据结构)：建立的数据库表" 
>
> "M(映射)：从R（数据库）到O（对象模型）的映射，可通过XML文件映射"



## 依赖

```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.4.5</version>
</dependency>
```





# 处理Dao的方式

## 两种开发方式

### 基于XML开发

1，导入pom.xml需要的jar包

2，创建domain包下的实体类

3，创建Dao包下的mapper接口，并声明方法

4，配置resourse包下对应mapper接口的映射xml文件

> 要求：目录要对应一致，且必须以持久层接口名称命名文件名，扩展名是.xml

文件格式

```xml
<?xml version="1.0" encoding="UTF-8"?> 
<!DOCTYPE mapper     PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"  
           "http://mybatis.org/dtd/mybatis-3-mapper.dtd"> 
<mapper namespace="com.itheima.dao.IUserDao">  

//id:方法名称
//resultType：映射的对象类型   
<select id="findAll" resultType="com.itheima.domain.User">sql语句</select> 

</mapper> 
```

5，配置主配置文件sqlMapConfig.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<!--1.配置properties-->
<properties resource="jdbcConfig.properties"></properties>

<!--使用typeAliases配置别名，它只能配置domain中类的别名 -->
<typeAliases>
   <package name="com.domain"></package>
</typeAliases>

<!--配置环境-->
    <environments default="mysql">
        <!-- 配置mysql的环境-->
        <environment id="mysql">
            <!-- 配置事务 -->
            <transactionManager type="JDBC"></transactionManager>
            <!--配置连接池-->
            <dataSource type="POOLED">
                <property name="driver" value="${jdbc.driver}"></property>
            </dataSource>
        </environment>
    </environments>

<!-- 配置映射文件的位置 -->
<mappers>
    <package name="com.tutu.dao"></package>
</mappers>
```

6，配置dom4j的xml解析器文件

​	1）DOM(JAXP Crimson解析器)

​	2）SAX(Simple API for XML)

​	3）JDOM

​	4）DOM4J

```
# Set root category priority to INFO and its only appender to CONSOLE.
#log4j.rootCategory=INFO, CONSOLE            debug   info   warn error fatal
log4j.rootCategory=debug, CONSOLE, LOGFILE

# Set the enterprise logger category to FATAL and its only appender to CONSOLE.
log4j.logger.org.apache.axis.enterprise=FATAL, CONSOLE

# CONSOLE is set to be a ConsoleAppender using a PatternLayout.
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} %-6r [%15.15t] %-5p %30.30c %x - %m\n

# LOGFILE is set to be a File appender using a PatternLayout.
log4j.appender.LOGFILE=org.apache.log4j.FileAppender
log4j.appender.LOGFILE.File=d:\axis.log
log4j.appender.LOGFILE.Append=true
log4j.appender.LOGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.LOGFILE.layout.ConversionPattern=%d{ISO8601} %-6r [%15.15t] %-5p %30.30c %x - %m\n
```

7，测试

```java
private InputStream is;
private SqlSession sqlSession;
private UserDao dao;
private AccountDao accountdao;
@Before
public void init() throws IOException {
    is = Resources.getResourceAsStream("sqlMapConfig.xml");
    SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(is);
    sqlSession = factory.openSession(true);
    dao = sqlSession.getMapper(UserDao.class);
}
@After
public void  destory() throws IOException {
    if (is!=null){
        is.close();
    }
    if (sqlSession!=null){
        sqlSession.close();
    }
}
public void test1(){
    User user = new User();
    List<User> users = dao.findAll();
}
```



### 基于注解开发

前六步基本相同，只是不用创建mapper的映射xml文件，而是直接在dao方法上添加注解

```sql
@Select("select * from user")
@Select("select count(*) from user ")
@Insert("insert into user(username)values(#{username})")
@Update("update user set username=#{username}")
@Delete("delete from user where id=#{id} ")

@Select("select * from user where username like #{username} ")

--这个需要在传递参数的时候加上%号
@Select("select * from user where username like '%${value}%' ")
```



# 执行流程（补充）





## 驼峰命名方式（补充）





# 自定义Mybatis

> 选择性学习

1.**Resources类**：*使用类加载器读取配置文件*

```java
public class Resources {
    /**
     * 根据传入的文件地址，返回一个字节输入流
     */
    public static InputStream getResourceAsStream(String filePath) {
        //获取字节码文件
        Class<Resources> resourcesClass = Resources.class;
        //
        ClassLoader loader = resourcesClass.getClassLoader();
        //
        InputStream is = loader.getResourceAsStream(filePath);
        return is;
    }
}
```

2.**SqlSessionFactoryBuilder类**

```java
public class SqlSessionFactoryBuilder {
    public SqlSessionFactory build(InputStream is) {
        return null;
    }
}
```

3.**SqlSessionFactory接口**

```java
public interface SqlSessionFactory {

    /**
     * 用于打开新的sqlSession对象
     * @return
     */
    SqlSession openSession();
}
```

4.**SqlSession接口**

```java
/**
 * 与数据库交互的核心类
 * 可以创建dao接口的代理对象
 */
public interface SqlSession {
    /**
     * @param daoInterfaceClass dao的接口字节码
     */
    //泛型要先声明，在使用
    <T> T getMapper(Class<T> daoInterfaceClass );
    //释放资源
    void close();
}
```

5.工具类



# CRUD的相关操作

## 配置对应关系

当实体类中的变量和数据库中的数据名称不统一时，配置对应关系

### xml方式

```xml
<!-- 配置 查询结果的列名和实体类的属性名的对应关系 -->
    <resultMap id="userMap" type="uSeR">
        <!-- 主键字段的对应 -->
        <id property="userId" column="id"></id>
        <!--非主键字段的对应-->
        <result property="userName" column="username"></result>
        <result property="实体类参数名" column="数据库元素名"></result>
    </resultMap>
```



### 注解方式

```java
@Results(value = {
        @Result(id = true , column="数据库参数" , property = "实体类名称"),
        })
```



> 或者使用AS

```sql
select id as userId,username as userName from user;
```



2，批注

> 不想去整理那些crud的方法，实际操作就好了，给自己一个偷懒的借口





# 动态SQL

## if语句

```xml
<select id="findUserByCondition" resultMap="userMap" parameterType="user">
        select * from user where 1 = 1 
            <if test="userName != null">
                and username = #{userName}
            </if>
            //test中的是实体类的参数名称
            //if标签是数据库中的元素名称
</select>
```



## where语句

```xml
<select id="findUserByCondition" resultMap="userMap" parameterType="user">
        select * from user
        //where标签就代替了where语句
        <where>
            <if test="userName != null">
                and username = #{userName}
            </if>
        </where>
</select>
```



## foreach语句

```xml
 <select id="findUserInIds" resultMap="userMap" parameterType="queryvo">
        
        <where>
            <if test="ids != null and ids.size()>0">
                <foreach collection="ids" open="and id in (" close=")" item="uid" separator=",">
                    #{uid}
                </foreach>
            </if>
        </where>
</select>
```

-

```xml
<!-- in查询所有，不分页 -->
<select id="selectIn" resultMap="BaseResultMap">
    select name from student where id in
    <foreach item="item" index="index" collection="list" open="(" separator="," close=")">
        #{item}
    </foreach>
</select>
collection：collection 属性的值有三个分别是 list、array、map
item ：表示在迭代过程中每一个元素的别名
index ：表示在迭代过程中每次迭代到的位置（下标）
open ：前缀
close ：后缀
separator ：分隔符，表示迭代时每个元素之间以什么分隔
```



额外的配置

mybatis中sql标签与include标签进行配合，灵活的查询需要的数据

```xml
<sql id="defaultUser">
        select * from user
</sql>
//这样就可以用defaultUser标签中的id代替sql语句了

<include refid="defaultUser"></include>


<select id="findUserInIds" resultMap="userMap" parameterType="queryvo">
        <include refid="defaultUser"></include>
    <where>
        <if test="ids != null and ids.size()>0">
           <foreach collection="" open="" close="" item="" separator="">
               #{uid}
           </foreach>
         </if>
     </where>
</select>
```



# 多表操作

## 多对一

第一种：继承

```
public class User extends Account
```

-

```xml
<!--查询所有账户同时包含用户名和地址信息-->
<select id="findAllAccount" resultType="User">
	select a.*,u.username,u.address from account a , user u where u.id = a.uid;
</select>
```



第二种：封装

xml

```xml
<!-- 定义封装account和user的resultMap -->
<resultMap id="accountUserMap" type="account">
    <!-- 一对一的关系映射：配置封装user的内容-->
	<association property="user" column="uid" javaType="user">
        <id property="userId" column="id"></id>
        <result column="userName"  property ="userName"></result>
	</association>
</resultMap>
```

注解

```java
@Results(id = "" ,value = {
        @Result(),
        @Result(property="对应的参数名",column="查询需要的参数"
            one=@One(select="全限定类名" , fetchById= FetchType.EAGER))
        })
//FetchType的几个常量
//1:EAGER——立即加载
//2:
```



## 一对多

一对多关系映射：主表实体应该包含从表实体的集合引用

```
private List<Account> accounts;
```

xml

```xml
//一个人是可以有多个账户，每个账户都有其自己的信息
<resultMap id="userAccountMap" type="uSeR">
    <!-- 主键字段的对应 -->
    <id property="userId" column="id"></id>
    <!--非主键字段的对应-->
    <result property="userName" column="username"></result>
    
//配置user对象中accounts集合的映射
    <collection property="accounts" ofType="account">
        <id column="aid" property="id"></id>
    </collection>
</resultMap>

<select id="findAll" resultMap="userAccountMap">
    select * from user u left outer join account a on u.id = a.uid
</select>
```

注解

```java
@Results(id = "" ,value = {
        @Result(),
        @Result(property="对应的参数名",column="查询需要的参数"
            many=@Many(select="全限定类名" , fetchById= FetchType.EAGER))
        })
```



## 多对多（补充）









# 连接池（补充）

配置文件

```
<properties url="file:///D:/文件/jdbcConfig.properties"></properties>
```

读取信息

```xml
<dataSource type="POOLED">
    <property name="driver" value=""></property>
    <property name="url" value="${jdbc.url}"></property>
    <property name="username" value="${jdbc.username}"></property>
    <property name="password" value="${jdbc.password}"></property>
</dataSource>
type=”POOLED”：MyBatis 会创建 PooledDataSource 实例 ，使用链接池
type=”UNPOOLED” ： MyBatis 会创建 UnpooledDataSource 实例 ，不使用链接池
type=”JNDI”：MyBatis 会从 JNDI 服务上查找 DataSource 实例，然后返回使用 
```

使用





# 事务（补充）



# 延迟加载（补充）

延迟加载：在真正使用数据时才发起查询，不用的时候不查询。按需加载（懒加载）

立即加载：不管用不用，只要一调用方法，马上发起查询



> 一对多，多对多：通常情况下我们都是采用延迟加载，例子：查询用户的时候暂时不需要每个账户的信息
>
> 
>
> 多对一，一对一：通常情况下我们都是采用立即加载。



## 1，基于XML

```xml
//在sqlMapConfig.xml文件中配置settings标签
<settings>
    <setting name="lazyLoadingEnabled" value="true"/>
    <setting name="aggressiveLazyLoading" value="false"/>
</settings>
cacheEnabled：全局地开启或关闭配置文件中的所有映射器已经配置的任何缓存
aggressiveLazyLoading：当开启时，任何方法的调用都会加载该对象的所有属性
                                否则，每个属性会按需加载
lazyLoadingEnabled：延迟加载的全局开关。当开启时，所有关联对象都会延迟加载。
```

```xml
//取而代之的是调用账户dao的查询方法，这样基本上就完成了延迟查找
//配置user对象中accounts集合的映射
<collection select="com.tutu.dao.AccountDao.findAll"></collection>
```

## 2，基于注解

```xml
//在sqlMapConfig.xml文件中配置settings标签
<settings>
    <setting name="cacheEnabled" value="true"/>
</settings>
```



```java
@Results(id = "" ,value = {
        @Result(),
        @Result(property="对应的参数名",column="查询需要的参数"
            one=@One(select="全限定类名" , fetchById= FetchType.EAGER))
        })
//FetchType的几个常量
//1:EAGER——立即加载
//2:
```



# 缓存

## 一级缓存

1. 它指的是Mybatis中**SqlSession对象的缓存**
2. 当我们执行查询之后，查询的结果会同时**存入到SqlSession为我们提供一块区域中**
3. **该区域的结构是一个Map**。当我们再次查询同样的数据，mybatis会先去sqlsession中
4. 查询是否有，有的话直接拿出来用
5. **当SqlSession对象消失时，mybatis的一级缓存也就消失了**



## 二级缓存

1. 它指的是Mybatis中SqlSessionFactory对象的缓存
2. 由同一个SqlSessionFactory对象创建的SqlSession共享其缓存

### 二级缓存基于xml的使用

第一步：让Mybatis框架支持二级缓存（在SqlMapConfig.xml中配置）

```xml
<settings>
    <setting name="cacheEnabled" value="true"/>
</settings>    
```

第二步：让当前的映射文件支持二级缓存（在IUserDao.xml中配置）

```xml
<mapper namespace="com.tutu.dao.UserDao">
    <cache/>
</mapper> 
```

第三步：让当前的操作支持二级缓存（在select标签中配置）

```xml
<select useCache="true"></select>
```

### 二级缓存基于注解的使用

```xml
//在sqlMapConfig.xml文件中配置settings标签
<settings>
    <setting name="cacheEnabled" value="true"/>
</settings>
```



在dao类上配置

```java
@CacheNamespace(blocking = true) //这样就是开启了二级缓存
```



# OGNL表达式

Object Graphic Navigation Language：对象图导航 语言

它是通过对象的取值方法来获取数据。

在写法上把get给省略了。

> 比如：我们获取用户的名称
>
> 类中的写法：user.getUsername(); 
>
> OGNL表达式写法：user.username



**注意**：mybatis中为什么能直接写username,而不用user.呢？

​		因为在**parameterType**中已经提供了属性所属的类，所以此时不需要写对象名



# 额外

## log4j.properties文件

```
log4j.rootLogger=debug, stdout, R

log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout

# Pattern to output the caller's file name and line number.
log4j.appender.stdout.layout.ConversionPattern=%5p [%t] (%F:%L) - %m%n

log4j.appender.R=org.apache.log4j.RollingFileAppender
log4j.appender.R.File=example.log

log4j.appender.R.MaxFileSize=100KB
# Keep one backup file
log4j.appender.R.MaxBackupIndex=5

log4j.appender.R.layout=org.apache.log4j.PatternLayout
log4j.appender.R.layout.ConversionPattern=%p %t %c - %m%n
```



# 缺失的内容

- 分页的使用
- 相关部分的原理内容
