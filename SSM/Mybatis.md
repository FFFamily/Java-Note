# Mybatis

> 笔记来源于视频笔记

# 一，概念

## 1，mybatis概念

1，mybatis是一个优秀的基于 java 的**持久层框架**，它内部封装了 jdbc，**使开发者只需要关注 sql语句本身**， 而不需要花费精力去处理其他与sql相关的繁杂过程

2，mybatis**通过xml 或注解的方式将要执行的各种statement配置起来**，并通过java对象和statement 中 sql 的动态参数进行映射生成最终执行的 sql 语句，最后由 mybatis 框架执行 sql 并将结果映射为 java 对象并 返回

3，采用 **ORM 思想**解决了实体和数据库映射的问题，对 jdbc进行了封装，屏蔽了 jdbc api 底层访问细节，使我 们不用与 jdbc api 打交道，就可以完成对数据库的持久化操作



## 2，ORM思想

对象关系映射（Object Relational Mapping，简称ORM，或O/RM，或O/R mapping），是一种程序技术，用于实现面向对象编程语言里**不同类型系统的数据之间的转换**

ORM指的是**面向对象的对象模型**和**关系型数据库的数据结构**之间的相互转换

> "O(对象模型)：实体对象，即我们在程序中根据数据库表结构建立的实体类" 
>
> "R(关系型数据库的数据结构)：建立的数据库表" 
>
> "M(映射)：从R（数据库）到O（对象模型）的映射，可通过XML文件映射"



## 3，依赖

```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.4.5</version>
</dependency>
```





# 二，处理Dao的方式

# 三，两种开发方式

## 1，基于XML开发

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



## 2，基于注解开发

前六步基本相同，只是不用创建mapper的映射xml文件，而是直接在dao方法上添加注解

```sql
@Select("select * from user")
@Select("select count(*) from user ")
@Insert("insert into user(username)values(#{username})")
@Update("update user set username=#{username}")
@Delete("delete from user where id=#{id} ")

@Select("select * from user where username like #{username} ")
//这个需要在传递参数的时候加上%号
@Select("select * from user where username like '%${value}%' ")
//这个不需要加%号
```



# 四，执行流程

# 五，自定义Mybatis

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



# 六，CRUD的相关操作

## 1，配置对应关系

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

