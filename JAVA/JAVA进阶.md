JAVA进阶

> 笔记来源于黑马视频，播客，书籍，以及个人理解

## I/O：输入/输出流

**什么是IO** 

Java中I/O操作：主要是指使用 java.io 包下的内容，进行输入、输出操作

IO流：就是数据传输的通道

流：一组有顺序的，有起点和终点的字节集合，是对数据传输的总称或抽象

输入：也叫做读取数据

输出：也叫做作写入数据 



**分类**

根据数据的流向分为：输入流和输出流

​	输入流 ：把数据从 其他设备 上读取到 内存 中的流。 

​	输出流 ：把数据从 内存 中写出到 其他设备 上的流。

格局数据的类型分为：字节流和字符流

​	字节流 ：以字节为单位，读写数据的流。 

​	字符流 ：以字符为单位，读写数据的流。



**字节流和字符流的区别（知识点）**

1，字节流没有缓冲区，直接输出，字符流有缓冲区。

> 也就是说字节流不需要调用close方法就已经把内容输出了，但是字符流会在调用close或者flush方法时，内容才会输出

 2，读写单位不同

> 字节流以字节（8bit）为单位，字符流以字符为单位，根据码表的不同而不同

3，处理对象不同

> 字节流能处理所有类型的数据，而字符流只能处理字符类型的数据



### 一，File类

Java文件类以抽象的方式代表文件名和目录路径名。该类主要用于文件和目录的创建、文件的查找和文件的删除等

> 其中有很多API方法就不做讨论

```java
File file=new File("test.txt");
//不会在当前目录下创建文件
//但是使用其他流初始化时，没有文件就会在根目录下创建这个文件
```



输出

#### **FileOutputStream** 

FileOutputStream 类是文件输出流，用于将数据写出到文件

> 写入数据的原理：
>
> (内存-->硬盘)
>
> java程序-->JVM(java虚拟机)-->OS(操作系统)-->OS调用写数据的方法-->把数据写入到文件中

构造方法 ：

```java
public FileOutputStream(File file) ：创建文件输出流以写入由指定的File对象表示的文件

public FileOutputStream(String name) ： 创建文件输出流以指定的名称写入文件 
```

**注意：**

当你创建一个流对象时，必须传入一个文件路径。该路径下，如果没有这个文件，会创建该文件。如果有这个文件，会清空这个文件的数据，需要标明追加数据



**笔记**：（需要验证正确与否）

写入一个字节，在实际的文件中，显示的却是ASCLL码

```java
FileOutputStream fos = new FileOutputStream(file); 
fos.write(33);//写入文件的是感叹号（！）
```

验证是正确的，写入的是对应ASCLL码的字符





#### **FileWriter** 

java.io.FileWriter 类是写出字符到文件的便利类

> 构造时使用系统默认的字符编码和默认字节缓冲区

构造方法 

```java
FileWriter(File file) ： 创建一个新的FileWriter，给定要读取的File对象 	

FileWriter(String fileName) ： 创建一个新的 FileWriter，给定要读取的文件的名称 
```





输入

#### **FileInputStream** 

java.io.FileInputStream 类是文件输入流，从文件中读取字节

构造方法 

```java
public FileInputStream(File file)
```

 通过打开与实际文件的连接来创建一个 FileInputStream ，该文件由文件系统中的File对象ﬁle命名

```
 FileInputStream(String name) 
```

通过打开与实际文件的连接来创建一个 FileInputStream ，该文件由文件系统中的路径名name命名 

**注意：**

当你创建一个流对象时，必须传入一个文件路径。该路径下，如果没有该文件,会抛出 FileNotFoundException ，不同于输出流

当文件读取到结尾时返回 -1,循环结束



#### **FileReader**

java.io.FileReader 类是读取字符文件的便利类,是一个抽象类

> 构造时使用系统默认的字符编码和默认字节缓冲区

**字符编码**：字节与字符的对应规则

> Windows系统的中文编码默认是GBK编码表。
>
> idea中UTF-8编码表

**字节缓冲区**：一个字节数组，用来临时存储字节数据。

**构造方法** :

```java
FileReader(File file) ： 创建一个新的 FileReader ，给定要读取的File对象  

FileReader(String fileName) ： 创建一个新的 FileReader 给定要读取的文件的名称 
```



#### **数据追加**

在测试的时候，每次程序运行，创建输出流对象，都会清空目标文件中的数据。

```java
public FileOutputStream(File file, boolean append) //文件输出流以写入由指定的 File对象表示的文件。 
public FileOutputStream(String name, boolean append) //创建文件输出流以指定的名称写入文件。
```

 这两个构造方法，参数中都需要传入一个boolean类型的值， true 表示追加数据， false 表示清空原有数据

 这样创建的输出流对象，就可以指定是否追加续写了





### 二，字节流

**一切皆为字节**

一切文件数据(文本、图片、视频等)在存储时，都是以二进制数字的形式保存，都一个一个的字节，那么传输时一 样如此。所以，字节流可以传输任意文件数据。在操作流的时候，无论使用什么样的流对象，底层传输的始终为二进制数据



#### **字节输出流（OutputStream ）**

java.io.OutputStream 抽象类是表示字节输出流的所有类的超类，将指定的字节信息写出到目的地

它定义了字节输出流的基本共性功能方法

```java
public void close() 关闭此输出流并释放与此流相关联的任何系统资源 		
public void flush() 刷新此输出流并强制任何缓冲的输出字节被写出
public void write(byte[] b) 将 b.length字节从指定的字节数组写入此输出流
public void write(byte[] b, int off, int len) ：
//从指定的字节数组写入 len字节，从偏移量oﬀ开始输出到此输出流
public abstract void write(int b) ：将指定的字节输出流
```

**写入字节数据** 

1. 写出字节： write(int b) 方法，每次可以写出一个字节数据

2. 写出字节数组： write(byte[] b) ，每次可以写出数组中的数据

3. 写出指定长度字节数组： write(byte[] b, int off, int len) ,每次写出从oﬀ索引开始,len个字节



#### **字节输入流（InputStream）**

InputStream 抽象类是表示字节输入流的所有类的超类，可以读取字节信息到内存中

它定义了字节输入 流的基本共性功能方法

```java
public void close() ：关闭此输入流并释放与此流相关联的任何系统资源。   
public abstract int read() ： 从输入流读取数据的下一个字节。
public int read(byte[] b) ： 从输入流中读取一些字节数，并将它们存储到字节数组b中
```

> 读取数据的原理(硬盘-->内存)
>
> ​        java程序-->JVM-->OS-->OS读取数据的方法-->读取文件



**笔记：**

读取多个字节时，需要一个循环的过程，因为不清楚文件中有多少字节，数组在不确定的情况下不知道能不能装的下文件中的字节，read（）方法读取到一个字节就会返回，一般需要一个循环条件，作为结束的标志

```java
//模板
byte[] bytes = new byte[2024];
int length = 0;
InputStream is = new InputStream(file);
while ((length = is.read(bytes))!=-1){
	System.out.println(new String(bytes, 0, length));
}
is.close();
```

**注意：**read方法在读取了一个字节后，会将指针移动到下一个字节后

​    并且在流的末端返回-1作为结束标志





### 三，字符流

当使用字节流读取文本文件时，可能会有一个小问题。就是遇到中文字符时，可能不会显示完整的字符，那是因为 一个中文字符可能占用多个字节存储。所以Java提供一些字符流类，以字符为单位读写数据，专门用于处理文本文件。

UTF-8：一个中文占用三字节

GBK:     一个中文占用2字节



#### **字符输入流（Reader）** 

java.io.Reader 抽象类是表示用于读取字符流的所有类的超类，可以读取字符信息到内存中

它定义了字符输入流的基本共性功能方法

```java
public void close() ：关闭此流并释放与此流相关联的任何系统资源
public int read() ： 从输入流读取一个字符
public int read(char[] a) ： 从输入流中读取一些字符，并将它们存储到字符数组a中
```



#### **字符输出流（Writer）** 

java.io.Writer 抽象类是表示用于写出字符流的所有类的超类，将指定的字符信息写出到目的地

它定义了字节 输出流的基本共性功能方法

```java
void write(int c) 写入单个字符。 
void write(char[] cbuf) 写入字符数组。 
abstract void write(char[]a, int off, int len)
 写入字符数组的某一部分,a数组的开始索引,len 写的字符个数
void write(String str)
写入字符串
void write(String str, int off, int len) 
写入字符串的某一部分,oﬀ字符串的开始索引,len写的字符个数
void flush() 刷新该流的缓冲
void close() 关闭此流，但要先刷新它
```



### 四，打印流

概述

平时我们在控制台打印输出，是调用`print`方法和`println`方法完成的，这两个方法都来自于`java.io.PrintStream`类，该类能够方便地打印各种数据类型的值，是一种便捷的输出方式。

> 包含   字节打印流：PrintStream    字符打印流：PrintWriter。

#### **PrintStream**

构造方法

```java
public PrintStream(String fileName) ： 使用指定的文件名创建一个新的打印流，即为改变打印流向，将输出的地方转移到fileName的地方
    
//例子
PrintStream ps = new PrintStream("文件地");
System.setOut(ps);//把输出语句的目的地改变为打印流的目的地    
```

其中还有很多printf和print方法，也就是说

```java
System.out.printf()//可以打印任何数据
```



### PrintWriter

专门打印字符

构造

```java
public PrintWriter(String fileName)
```



### 五，缓冲流

**概述**

缓冲流,也叫高效流，是对4个基本的`FileXxx` 流的增强，所以也是4个流，按照数据类型分类：

字节缓冲输入流：BufferedInputStream

字节缓冲输出流：BufferedOutputStream

字符缓冲输出流：BufferedReader

字符缓冲输入流：BufferedWriter

**基本原理**

是在创建流对象时，会创建一个内置的默认大小的缓冲区数组，通过缓冲区读写，减少系统IO请求次数，从而提高读写的效率。



**构造方法**

**字节缓冲流**

```java
public BufferedInputStream(InputStream in)：创建一个 新的缓冲输入流 
public BufferedOutputStream(OutputStream out)： 创建一个新的缓冲输出流
```

**字符缓冲流**

```java
public BufferedReader(Reader in)` ：创建一个 新的缓冲输入流
public BufferedWriter(Writer out)`： 创建一个新的缓冲输出流
```

特有的方法;

```java
BufferedReader：public String readLine(): 读一行文字
BufferedWriter：public void newLine(): 写一行行分隔符,由系统属性定义符号
```





### 六，转换流

#### **InputStreamReader**

`java.io.InputStreamReader`，是Reader的子类，是从字节流到字符流的桥梁。

它读取字节，并使用指定的字符集将其解码为字符。它的字符集可以由名称指定，也可以接受平台的默认字符集

> 转换流是字节与字符间的桥梁



何时使用转换流？

1. 当字节和字符之间有转换动作时
2. 操作的数据需要编码或解码时



构造方法

```java
InputStreamReader(InputStream in)`: 创建一个使用默认字符集的字符流。 
InputStreamReader(InputStream in, String charsetName)`: 创建一个指定字符集的字符流。
```

#### **OutputStreamWriter**

`java.io.OutputStreamWriter` ，是Writer的子类，是从字符流到字节流的桥梁。

使用指定的字符集将字符编码为字节。它的字符集可以由名称指定，也可以接受平台的默认字符集。 

构造方法

```java
OutputStreamWriter(OutputStream in)`: 创建一个使用默认字符集的字符流。 
OutputStreamWriter(OutputStream in, String charsetName)`: 创建一个指定字符集的字符流。
```



### 七，递归

递归打印多级目录 

分析：多级目录的打印，就是当目录的嵌套。遍历之前，无从知道到底有多少级目录，所以我们还是要使用递归实现。

 文件搜索 

```
搜索 D:\aaa 目录中的 .java 文件。

String中的endWith方法，返回值为boolean

file.getName().endsWith(".java")
```



```java
		File file = new File(pathname);//创建File
        File[] files = file.listFiles();//把当前File对象下所有的文件夹或目录
        for (File file1: files){
            if (file1.isFile()){//递归的终止条件是：当前File为文件
                System.out.println(file1.getAbsolutePath());
            }
            else{//当前File为目录，则，打印当前File的子文件的递归目录
                //String s = file1.getPath();
                //printAllFiles(s);
                //printAllFiles(file1.getPath());
                System.out.println(file1.getAbsolutePath());
                printAllFiles(file1.getAbsolutePath());
            }

        }
```



### 八，序列化和反序列化

> 待补充

代码操作

```java
public class Book implements Serializable {
    private String name;
    private int price;
    public Book(String name , int price){
        this.name = name;
        this.price= price;
    }

    @Override
    public String toString() {
        return "Book{" +
                "name='" + name + '\'' +
                ", price=" + price +
                '}';
    }
}

public static void main(String[] args) {
        File file = new File("test.txt");
        try {
            ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
            oos.writeObject(new Book("sb",22));
            oos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
```



反序列化

```java
ObjectInputStream ois=new ObjectInputStream(new FileInputStream(new File("e:"+File.separator+"demoA.txt")));
 
Object obj=ois.readObject()
```



### 九，关闭和刷新

因为内置缓冲区的原因，如果不关闭输出流，无法写出字符到文件中。但是关闭的流对象，是无法继续写出数据 的。如果我们既想写出数据，又想继续使用流，就需要 flush 方法了。

flush ：刷新缓冲区，流对象可以继续使用。 

close :先刷新缓冲区，然后通知系统释放资源。流对象不可以再被使用了



### 十，Scanner



### 十，新特性

JDK9

```java
FileInputStream fis = new FileInputStream("c:\\1.jpg");
FileOutputStream fos = new FileOutputStream("d:\\1.jpg");
        try(fis;fos){
            int len = 0;
            while((len = fis.read())!=-1){
                //使用字节输出流中的方法write,把读取到的字节写入到目的地的文件中
                fos.write(len);
            }
        }catch (IOException e){
            System.out.println(e);
        }
```

JDK7

```java
try(
 FileInputStream fis = new FileInputStream("c:\\1.jpg");
 FileOutputStream fos = new FileOutputStream("d:\\1.jpg");)
 {
            int len = 0;
            while((len = fis.read())!=-1){
                //使用字节输出流中的方法write,把读取到的字节写入到目的地的文件中
                fos.write(len);
            }
        }catch (IOException e){
            System.out.println(e);
        }

```



## JDBC： Java DataBase Connectivity

### 一，使用

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



### 二，具体对象

#### DriverManager：驱动管理对象

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



#### Connection：数据库连接对象

1，获取执行sql对象

```
Statement createStatement()
PreparedStatement prepareStatement(String sql)
```

2，管理实务



#### Statement：执行sql的对象

```
1. boolean execute(String sql) ：可以执行任意的sql 
2. int executeUpdate(String sql) ：执行DML语句、DDL语句
3. ResultSet executeQuery(String sql)  ：执行DQL（select)语句
```



executeUpdate()方法的返回值：**影响的行数**，**可以通过这个影响的行数判断DML语句是否执行成功** 返回值>0的则执行成功，反之，则失败



#### ResultSet：结果集对象,封装查询结果

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



####  PreparedStatement：执行sql的对象

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



### 三，JDBC工具类

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



### 四，JDBC控制事务

> 这些东西个人认为在mysql知识点中详细归纳比较好，毕竟那些框架都对事物有良好的支持

#### 1，开启事务

```java
Connection.setAutoCommit(boolean autoCommit);
//调用该方法设置参数为false，即开启事务
```

#### 2，提交事务

```
Connection.commit();
```

#### 3，回滚事务

```
Connection.rollback(); 
```



### 五，数据库连接池

其实就是一个容器(集合)，存放数据库连接的容器。

当系统初始化好后，容器被创建，容器中会申请一些连接对象，当用户来访问数据库时，从容器中获取连接对象，**用户访问完之后，会将连接对象归还给容器**

实现方式



### 六，SpringJDBC

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



## 多线程

> 多线程往往是java的一个性能重点，所以需要单独一个笔记讲述多线程
>
> 需要我查阅更多的书籍后才能对其统计知识点





## 反射

### 一，概念

**对于任何一个对象，我们都能够对它的方法和属性进行调用**。我们把这种**动态获取对象信息和调用对象方法**的功能称之为**反射机制**。

反射就像一个掌控全局的角色，不论程序在那里，谁执行的，它都知道



> 我们使用的一些主流框架中反射技术应用是非常广泛的.
>
> 所谓反射其实是获取类的字节码文件，也就是.class文件，那么我们就可以通过Class这个对象进行获取



### 二，实现反射的方式

> java.lang.reflect 包实现了反射机制





第一种：通过Object类的getClass方法 

```
Class cla = foo.getClass();
```

第二种：通过对象实例方法获取对象 

```
Class cla = foo.class;
```

第三种：通过Class.forName方式 

```java
Class cla = Class.forName("全类名");
cla.newInstance()//初始化对象，接着就是使用对象了
```







### 三，相关的逻辑方法

#### 操作类

> 详细查看API

#### 操作方法

> 详细查看API



### 四，使用

```java
package tutu.demo;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class Testreflect {
    public static void main(String[] args) {
        Class Student = null;
        try {
            //初始化
            Student = Class.forName("tutu.demo.Student");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        System.out.println("获取对象的所有公有属性");
        //获取对象的所有公有属性
        Field[] fields = Student.getFields();
        for (Field f: fields) {
            System.out.println(f);
            //也就是把和这个类相关的所有的公有属性获取了
            //public java.lang.String tutu.demo.Student.className
            //public java.lang.String tutu.demo.Person.name
            //public int tutu.demo.Person.age
        }

        System.out.println("获取对象的所有属性，不包含继承的");
        //Declared Fields 声明字段
        Field[] declaredFields = Student.getDeclaredFields();
        for (Field f : declaredFields) {
            System.out.println(f);
        }

        System.out.println("获取对象的所有公共方法");
        Method[] methods = Student.getMethods();
        for (Method m : methods) {
            System.out.println(m);
        }

        System.out.println("获取对象的对象的所有方法，不包含继承的");
        Method[] declaredMethods = Student.getDeclaredMethods();
        for (Method dm : declaredMethods) {
            System.out.println(dm);
        }

        System.out.println("获取对象公共构造器");
        Constructor[] constructors = Student.getConstructors();
        for (Constructor c : constructors) {
            System.out.println(c);
        }

        System.out.println("获取对象所有构造器");
        Constructor[] declaredConstructors = Student.getDeclaredConstructors();
        for (Constructor dc : declaredConstructors) {
            System.out.println(dc);
        }

        System.out.println("实例化对象");
        try {
            //第一种方式，通过newInstance()方法创建对象，然后在使用set方法赋值
            //类似于new() , 把对象实例化，操作对象
            //Object s = Student.newInstance();
            Class c = Class.forName("tutu.demo.Student");
            Student stu1 = (Student) c.newInstance();
            stu1.setAddress("湖南");
            System.out.println(stu1);


            //第二种方式，获取构造器
            //c.getConstructor(Class<E>...classes)
            //反射需要的是Class类型去构造方法
            Constructor<Student> constructor = c.getConstructor(String.class, int.class, String.class, String.class);
            Student stu2 = constructor.newInstance("涂", 20, "软件2班", "湖南");
            System.out.println(stu2);

            System.out.println("获取方法并且执行");
            Method show = c.getMethod("showInfo");
            Object object = show.invoke(stu2);
            System.out.println(object);

        } catch (InstantiationException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        }
    }
}
```



### 五，哪里运用到了反射

1，使用JDBC连接数据库时使用Class.forName()通过反射加载数据库的驱动程序；

2，pring框架也用到很多反射机制，最经典的就是xml的配置模式，Spring 通过 XML 配置模式装载 Bean 的过程

​	1) 将程序内所有 XML 或 Properties 配置文件加载入内存中; 

​	2) Java类里面解析xml或properties里面的内容，得到对应实体类的字节码字符串以及相关的属性信息; 

​	3) 使用反射机制，根据这个字符串获得某个类的Class实例; 

​	4) 动态配置实例的属性。

3，解析泛型





## 泛型

> JDK1.5 出现了泛型的概念

### 一，概念

泛型在java中有很重要的地位，在面向对象编程及各种设计模式中有非常广泛的应用

泛型，即“参数化类型”

泛型的本质是为了参数化类型（在不创建新的类型的情况下，通过泛型指定的不同类型来控制形参具体限制的类型）

> 那么参数化类型怎么理解呢？
>
> 顾名思义，就是将类型由原来的具体的类型参数化，类似于方法中的变量参数，此时类型也定义成参数形式（可以称之为类型形参），然后在使用/调用时传入具体的类型（类型实参）。



### 二，一个经典泛型例子

```java
List arrayList = new ArrayList();
arrayList.add("aaaa");
arrayList.add(100);

for(int i = 0; i< arrayList.size();i++){
    String item = (String)arrayList.get(i);
  	System.out.printf(item)
}
//程序就会报错

java.lang.ClassCastException: java.lang.Integer cannot be cast to java.lang.String
//ArrayList可以存放任意类型，例子中添加了一个String类型，添加了一个Integer类型，再使用时都以String的方式使用，因此程序崩溃了

//所以就有了泛型

List<String> arrayList = new ArrayList<String>();
```



### 三，特性

```java
List<String> stringArrayList = new ArrayList<String>();
List<Integer> integerArrayList = new ArrayList<Integer>();

Class classStringArrayList = stringArrayList.getClass();
Class classIntegerArrayList = integerArrayList.getClass();

if(classStringArrayList.equals(classIntegerArrayList)){
    Log.d("泛型测试","类型相同");
}
```

> 泛型类型在逻辑上看以看成是多个不同的类型，实际上都是相同的基本类型

注意

- 泛型的类型参数只能是类类型，不能是简单类型。
- 不能对确切的泛型类型使用instanceof操作，编译时会出错
- 泛型只在编译阶段有效



### 四，分类

#### 1，泛型类

泛型类型用于类的定义中，被称为泛型类

> 最典型的就是各种容器类，如：List、Set、Map

```java
//此处T可以随便写为任意标识，常见的如T、E、K、V等形式的参数常用于表示泛型
//在实例化泛型类时，必须指定T的具体类型
public class Generic<T>{ 
    //key这个成员变量的类型为T,T的类型由外部指定  
    private T key;

    public Generic(T key) { //泛型构造方法形参key的类型也为T，T的类型由外部指定
        this.key = key;
    }

    public T getKey(){ //泛型方法getKey的返回值类型为T，T的类型由外部指定
        return key;
    }
}
```

#### 2，泛型接口

泛型接口常被用在各种类的生产器中

```java
//定义一个泛型接口
public interface Generator<T> {
    public T next();
}
```

> 实现接口需要声明泛型类型，不然会报错



#### 3，泛型方法

声明此方法为泛型方法：public  <T>  T 

只有声明了<T>的方法才是泛型方法

```java
public <T> T genericMethod(){
        T instance = tClass.newInstance();
        return instance;
}
```



### 五，泛型通配符

```java
public void show(Generic<Number> obj){ }

Generic<Integer> gInteger = new Generic<Integer>(123);
Generic<Number> gNumber = new Generic<Number>(456);

show(gNumber);//程序报错

//	同一种泛型可以对应多个版本（因为参数类型是不确定的），不同版本的泛型类实例是不兼容的
//	因此我们需要一个在逻辑上可以表示同时是Generic<Integer>和Generic<Number>父类的引用类型。由此类型通配符应运而生

public void show(Generic<?> obj){ }
```



### 六，泛型上下边界

上界通配符

```
<? extends ClassType> 该通配符表示ClassType的所有子类型
```

下界通配符

```
<? super ClassTyep>  该通配符表示ClassType 的所有父类型
```





## 网络编程

> 网络编程需要我去尝试一个聊天项目后再去整理