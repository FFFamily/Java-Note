### JDBC： Java DataBase Connectivity

## 一，使用

导入jar包，根据不同版本导入

```
mysql-connector-java-5.0.8-bin-jar
```

注册驱动

```
Class.forName("com.mysql.jdbc.Driver");
```

取数据库连接对象 Connection

```
Connection 	= DriverManager.getConnection("jdbc:mysql://localhost:3306/db3", "root", "root");
```

定义sql

```
String sql = "update account set balance = 500 where id = 1";
```

获取执行sql语句的对象 Statement

```
Statement stmt = conn.createStatement();
```

行sql，接受返回结果

```
int count = stmt.executeUpdate(sql);
```

处理结果，释放资源

```
stmt.close();
conn.close();
```



## 二，具体对象

### DriverManager：驱动管理对象

1，告诉程序该使用哪一个数据库驱动

```java
//通过查看源码发现：在com.mysql.jdbc.Driver类中存在静态代码块
static {
     try {
        java.sql.DriverManager.registerDriver(new Driver());
	 } catch (SQLException E) {
		throw new RuntimeException("Can't register driver!");
	 }
}
```

写代码就只用

```
Class.forName("com.mysql.jdbc.Driver");//sql5.7版本前
Class.forName("com.mysql.cj.jdbc.Driver");//sql5.7版本后
```

2，获取数据库连接

```
static Connection getConnection(String url, String user, String password)
```



### Connection：数据库连接对象

1，获取执行sql对象

```
Statement createStatement()
PreparedStatement prepareStatement(String sql)
```

2，管理实务



### Statement：执行sql的对象

```
1. boolean execute(String sql) ：可以执行任意的sql 
2. int executeUpdate(String sql) ：执行DML语句、DDL语句
3. ResultSet executeQuery(String sql)  ：执行DQL（select)语句
```



executeUpdate()方法的返回值：**影响的行数**，**可以通过这个影响的行数判断DML语句是否执行成功** 返回值>0的则执行成功，反之，则失败



### ResultSet：结果集对象,封装查询结果

```java
boolean next():
//游标向下移动一行，判断当前行是否是最后一行末尾(是否有数据)，如果是，则返回false，如果不是则返回true
```

  

```
getXxx(参数):获取数据 
```

Xxx：代表数据类型 

1. int：代表列的编号,从1开始  如： getString(1) 
2. String：代表列名称。 如： getDouble("balance")

注意：resultSet的索引是从1开始的



###  PreparedStatement：执行sql的对象

SQL注入问题：在拼接sql时，有一些sql的特殊关键字参与字符串的拼接。会造成安全性问题

> 输入密码：a' or 'a' = 'a
>
> ```
> 而执行的sql：select * from user where username = 'fhdsjkf' and password = 'a' or 'a' = 'a' 
> ```

解决：参数使用?作为占位符

那么定义的sql

```sql
select * from user where username = ? and age = ?;
```

而执行sql的对象就换为

```java
PreparedStatement preparedStatement  = Connection.prepareStatement(String sql);
```

接着就是赋值

```
方法： setXxx(参数1,参数2)
	* 参数1：？的位置编号 从1 开始
	* 参数2：？的值

preparedStatement.setString(1,"图图");
preparedStatement.setInt(1,18);
```



## 三，JDBC工具类

1，需要使用jdbc.properties配置文件保存数据源信息

```
driver=数据库驱动路径
url=url连接字符串
user=用户名
password=密码
```

2，实现配置类

```java
public class JDBCUtil{
    private static String url;
    private static String user;
    private static String password;
    private static String driver;
    // 使用静态代码注册驱动并给静态变量赋值
    static{
        try {
            // 创建Properties集合类
            Properties pro = new Properties();
            // 获取src路径下文件，使用ClassLoader类加载器
            ClassLoader classLoader = JDBCUtils.class.getClassLoader();
            // URL定位了文件的绝对路径
            URL res = classLoader.getResource("jdbc.properties");
            // 获取字符串路径
            String path = res.getPath();
            // 读取文件
            pro.load(new FileReader(path));
            // 给静态变量赋值
            url = pro.getProperty("url");
            user = pro.getProperty("user");
            password = pro.getProperty("password");
            driver = pro.getProperty("driver");
            // 注册驱动
            Class.forName(driver);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    //获取连接
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
	}
    //释放资源
    public static void close(Statement stmt, Connection conn){
        if(stmt != null){
            try {
                stmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if(conn != null){
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

}
```



## 四，JDBC控制事务

> 这些东西个人认为在mysql知识点中详细归纳比较好，毕竟那些框架都对事物有良好的支持

### 1，开启事务

```java
Connection.setAutoCommit(boolean autoCommit);
//调用该方法设置参数为false，即开启事务
```

### 2，提交事务

```
Connection.commit();
```

### 3，回滚事务

```
Connection.rollback(); 
```



## 五，数据库连接池

其实就是一个容器(集合)，存放数据库连接的容器。

当系统初始化好后，容器被创建，容器中会申请一些连接对象，当用户来访问数据库时，从容器中获取连接对象，**用户访问完之后，会将连接对象归还给容器**

实现方式



## 六，SpringJDBC

1，导入jar包

2，创建JdbcTemplate对象

```JAVA
//依赖于数据源DataSource
JdbcTemplate template = new JdbcTemplate(dataSource);
```

3，调用JdbcTemplate的方法来完成CRUD的操作

```JAVA
update(): 执行DML语句。增、删、改语句

queryForMap():查询结果将结果集封装为map集合
//将列名作为key，将值作为value 将这条记录封装为一个map集合
//注意：这个方法查询的结果集长度只能是1

queryForList():查询结果将结果集封装为list集合
//注意：将每一条记录封装为一个Map集合，再将Map集合装载到List集合中

query():查询结果，将结果封装为JavaBean对象
//query的参数：RowMapper
//一般我们使用BeanPropertyRowMapper实现类。可以完成数据到JavaBean的自动封装
//new BeanPropertyRowMapper<类型>(类型.class)

queryForObject()：查询结果，将结果封装为对象
//一般用于聚合函数的查询
```

