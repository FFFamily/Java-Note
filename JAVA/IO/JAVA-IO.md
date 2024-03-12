# I/O：输入/输出流

## **什么是IO** 

Java中I/O操作：主要是指使用 java.io 包下的内容，进行输入、输出操作

可以把IO比作流水，数据在这样的一个传输流管道中流动。

IO流：就是数据传输的通道

流：一组有顺序的，有起点和终点的字节集合，是对数据传输的总称或抽象

输入：也叫做读取数据

输出：也叫做作写入数据 



## 阻塞IO/非阻塞IO

这两个概念是`程序级别`的。

主要描述的是程序请求操作系统IO操作后，如果IO资源没有准备好，那么程序该如何处理的问题: 前者等待；后者继续执行(并且使用线程一直轮询，直到有IO资源准备好了)

## 同步IO/非同步IO

这两个概念是`操作系统级别`的。

主要描述的是操作系统在收到程序请求IO操作后，如果IO资源没有准备好，该如何响应程序的问题: 前者不响应，直到IO资源准备好以后；后者返回一个标记(好让程序和自己知道以后的数据往哪里通知)，当IO资源准备好以后，再用事件机制返回给程序。





# IO模型

## BIO

**BIO 属于同步阻塞 IO 模型**

同步阻塞 IO 模型中，应用程序发起 read 调用后，会一直阻塞，直到在内核把数据拷贝到用户空间

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/7.png)





### 带来的问题

同一时间，服务器只能接受来自于客户端A的请求信息；虽然客户端A和客户端B的请求是同时进行的，但客户端B发送的请求信息只能等到服务器接受完A的请求数据后，才能被接受。

由于服务器一次只能处理一个客户端请求，当处理完成并返回后(或者异常时)，才能进行第二次请求的处理。很显然，这样的处理方式在高并发的情况下，是不能采用的。



这样的IO方式，虽然配合多线程能达到一定的异步效果。但是线程的开销也是很大的。哪怕是使用多线程实现异步效果，但是对于操作系统，还是使用的同步IO的方式，在操作系统层面还是会阻塞。



### JAVA中的使用

 java.net下面提供的部分网络API，比如 Socket、 Serversocket、 HttpURLConnection也归类到同步阻塞IO类库，因为网络通信IO行为。





## NIO

可以视为I/O多路复用模型，或者同步非阻塞模型

- Java 中的 NIO 于 Java 1.4 中引入，对应 `java.nio` 包，提供了 `Channel` , `Selector`，`Buffer` 等抽象
- NIO 中的 N 可以理解为 Non-blocking，不单纯是 New
- 它支持面向缓冲的，基于通道的 I/O 操作方法。 对于高负载、高并发的（网络）应用，应使用 NIO 



### **NIO 能解决什么问题**

通过一个典型场景，为什么需要多路复用，如果需要实现一个服务器应用，只简单要求能同时服务多个客户端请求即可。



### 优点

单线程、同端口多协议、操作系统优化、同步IO



### 流与块

I/O 与 NIO 最重要的区别是数据打包和传输的方式，I/O 以流的方式处理数据，而 NIO 以块的方式处理数据。

面向流的 I/O 一次处理一个字节数据: 一个输入流产生一个字节数据，一个输出流消费一个字节数据。为流式数据创建过滤器非常容易，链接几个过滤器，以便每个过滤器只负责复杂处理机制的一部分。不利的一面是，面向流的 I/O 通常相当慢。

面向块的 I/O 一次处理一个数据块，按块处理数据比按流处理数据要快得多。但是面向块的 I/O 缺少一些面向流的 I/O 所具有的优雅性和简单性。

I/O 包和 NIO 已经很好地集成了，java.io.* 已经以 NIO 为基础重新实现了，所以现在它可以利用 NIO 的一些特性。例如，java.io.* 包中的一些类包含以块的形式读写数据的方法，这使得即使在面向流的系统中，处理速度也会更快。



### 通道

通道 Channel 是对原 I/O 包中的流的模拟，可以通过它读取和写入数据。

通道与流的不同之处在于，流只能在一个方向上移动(一个流必须是 InputStream 或者 OutputStream 的子类)，而通道是双向的，可以用于读、写或者同时用于读写。

通道包括以下类型:

- FileChannel: 从文件中读写数据；
- DatagramChannel: 通过 UDP 读写网络中数据；
- SocketChannel: 通过 TCP 读写网络中数据；
- ServerSocketChannel: 可以监听新进来的 TCP 连接，对每一个新进来的连接都会创建一个 SocketChannel。





### 缓冲区

发送给一个通道的所有数据都必须首先放到缓冲区中，同样地，从通道中读取的任何数据都要先读到缓冲区中。也就是说，不会直接对通道进行读写数据，而是要先经过缓冲区。

缓冲区实质上是一个数组，但它不仅仅是一个数组。缓冲区提供了对数据的结构化访问，而且还可以跟踪系统的读/写进程。

缓冲区包括以下类型:

- ByteBuffer
- CharBuffer
- ShortBuffer
- IntBuffer
- LongBuffer
- FloatBuffer
- DoubleBuffer



缓冲区状态变量

- capacity: 最大容量；
- position: 当前已经读写的字节数；
- limit: 还可以读写的字节数。



## 选择器

NIO 常常被叫做非阻塞 IO，主要是因为 NIO 在网络通信中的非阻塞特性被广泛使用。

NIO 实现了 IO 多路复用中的 Reactor 模型，一个线程 Thread 使用一个选择器 Selector 通过轮询的方式去监听多个通道 Channel 上的事件，从而让一个线程就可以处理多个事件。

通过配置监听的通道 Channel 为非阻塞，那么当 Channel 上的 IO 事件还未到达时，就不会进入阻塞状态一直等待，而是继续轮询其它 Channel，找到 IO 事件已经到达的 Channel 执行。

因为创建和切换线程的开销很大，因此使用一个线程来处理多个事件而不是一个线程处理一个事件具有更好的性能。

应该注意的是，只有套接字 Channel 才能配置为非阻塞，而 FileChannel 不能，为 FileChannel 配置非阻塞也没有意义。



### 同步非阻塞

同步非阻塞 IO 模型中，应用程序会一直发起 read 调用，等待数据从内核空间拷贝到用户空间的这段时间里，线程依然是阻塞的，直到在内核把数据拷贝到用户空间

> 换句话说，就是买了衣服后，又继续逛街，一边逛街一边问衣服好了没



但是，这种 IO 模型同样存在问题：

**应用程序不断进行 I/O 系统调用轮询数据是否已经准备好的过程是十分消耗 CPU 资源的。**

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/8.png)



### IO多路复用模型

IO 多路复用模型中，线程首先发起 select 调用，询问内核数据是否准备就绪，等内核把数据准备好了，用户线程再发起 read 调用。read 调用的过程（数据从内核空间->用户空间）还是阻塞的。

![java-io-model-2](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/java-io-model-2.png)



目前支持 IO 多路复用的系统调用，有 select，epoll、poll、kqueue 等等。select 系统调用，是目前几乎在所有的操作系统上都有支持

- **select 调用** ：内核提供的系统调用，它支持一次查询多个系统调用的可用状态。几乎所有的操作系统都支持。
- **epoll 调用** ：linux 2.6 内核，属于 select 调用的增强版本，优化了 IO 的执行效率。



**IO 多路复用模型，通过减少无效的系统调用，减少了对 CPU 资源的消耗。**

> Java 中的 NIO ，有一个非常重要的**选择器 ( Selector )** 的概念，也可以被称为 **多路复用器**。通过它，只需要一个线程便可以管理多个客户端连接。当客户端数据到了之后，才会为其服务。

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/9.png)



## AIO

AIO 也就是 NIO 2。Java 7 中引入了 NIO 的改进版 NIO 2,它是异步 IO 模型。

异步 IO 是基于事件和回调机制实现的，也就是应用操作之后会直接返回，不会堵塞在那里，当后台处理完成，操作系统会通知相应的线

程进行后续的操作。



采用“订阅-通知”模式:



进行 aio_read 系统调用会立即返回，应用进程继续执行，不会被阻塞，内核会在所有操作完成之后向应用进程发送信号。

异步 I/O 与信号驱动 I/O 的区别在于，异步 I/O 的信号是通知应用进程 I/O 完成，而信号驱动 I/O 的信号是通知应用进程可以开始 I/O。

![java-io-model-3](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/java-io-model-4.png)





![java-io-model-3](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/java-io-model-3.png)

### java对AIO的 支持





## **分类**

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

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/4.png)



### 一，File类

Java文件类以抽象的方式代表文件名和目录路径名。该类主要用于文件和目录的创建、文件的查找和文件的删除等

在 Java 语言的 java.io 包中，由 File 类提供了描述文件和目录的操作与管理方法,专门用来管理磁盘文件与目录

> 其中有很多API方法就不做讨论

```java
File file=new File("test.txt");
//不会在当前目录下创建文件
//但是使用其他流初始化时，没有文件就会在根目录下创建这个文件
```



输出

FileOutputStream 

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



FileWriter 

java.io.FileWriter 类是写出字符到文件的便利类

> 构造时使用系统默认的字符编码和默认字节缓冲区

构造方法 

```java
FileWriter(File file) ： 创建一个新的FileWriter，给定要读取的File对象 	

FileWriter(String fileName) ： 创建一个新的 FileWriter，给定要读取的文件的名称 
```





输入

FileInputStream 

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



FileReader

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



**数据追加**

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





### 面试题

#### 说一说常见的输入输出流

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/22.png)



#### 字节流和字符流的区别

读写单位不同：字节流以字节（8bit）为单位，字符流以字符为单位，根据码表映射字符，一次可能读多个字节。

处理对象不同：字节流能处理所有类型的数据（如图片、avi 等），而字符流只能处理字符类型的数据。

字节流：一次读入或读出是 8 位二进制。
字符流：一次读入或读出是 16 位二进制。

设备上的数据无论是图片或者视频，文字，它们都以二进制存储的。二进制的最终都是以一个 8 位为数据单元进行体现，所以计算机中的最小数据单元就是字节。意味着，字节流可以处理设备上的所有数据，所以字节流一样可以处理字符数据。

> 结论：只要是处理纯文本数据，就优先考虑使用字符流。 除此之外都使用字节流



#### 说一说 java 类 中的文件类 File

在 Java 语言的 java.io 包中，由 File 类提供了描述文件和目录的操作与管理方法。File 类不同于输入输出流，它不负责数据的输入输出，而专门用来管理磁盘文件与目录。

> 就说File类是java.io下专门用来管理文件和目录的

File 类共提供了三个不同的构造函数，以不同的参数形式灵活地接收文件和目录名信息

```java
File (String pathname)
File f1=new File("FileTest1.txt"); //创建文件对象 f1，f1 所指的文件是在当前目录下创建的 FileTest1.txt
```



```java
File (String parent , String child)
例:File f2 = new File(“D:\\dir1","FileTest2.txt") ; // 注意：D:\\dir1 目录事先必须存在，否则异常
```



```java
File (File parent , String child)
File f4=new File("\\dir3");
File f5=new File(f4,"FileTest5.txt"); // 在如果 dir3 目录不存在使用f4.mkdir()先创建
```

> 这个感觉可以不回答，就说有3种构造方法



一个对应于某磁盘文件或目录的 File 对象一经创建， 就可以通过调用它的方法来获得文件或目录的属性。

```java
public boolean exists( ) 判断文件或目录是否存在
public boolean isFile( ) 判断是文件还是目录
public boolean isDirectory( ) 判断是文件还是目录
public String getName( ) 返回文件名或目录名
public String getPath( ) 返回文件或目录的路径。
public long length( ) 获取文件的长度
public String[ ] list ( ) 将目录中所有文件名保存在字符串数组中返回。
```

> 就说File类还有一些访问文件和目录属性的API，具体是什么就忘记了



File 类中还定义了一些对文件或目录进行管理、操作的方法，常用的方法有：

```java
public boolean renameTo( File newFile ); 重命名文件
public void delete( ); 删除文件
public boolean mkdir( ); 创建目录
```

> 以及一些文件管理的API



#### 如何选择 IO 流

1，确定是 输入还是输出

2，明确操作的数据对象是否是纯文本

3，明确具体的设备

> 硬盘文件：
> 读取：`FileInputStream`,,` FileReade`r,
> 写入：`FileOutputStream`，`FileWriter`
>
> 内存用数组：
> byte[]：`ByteArrayInputStream`, `ByteArrayOutputStream`
> char[]：`CharArrayReader`, `CharArrayWriter`
>
> 键盘：
> 用 System.in（是一个 `InputStream` 对象）读取，用 `System.out`（是一个`OutoutStream` 对象）打印

4，是否需要缓冲提高效率

> 加上 Buffered：BufferedInputStream, BufferedOuputStream, BuffereaReader,BufferedWriter



#### BIO 、NIO 、AIO 有什么区别？

BIO：Block IO 同步阻塞式 IO，就是我们平常使用的传统 IO，它的特点是模式简单使用方便，并发处理能力低。

NIO：New IO 同步非阻塞 IO，是传统 IO 的升级，客户端和服务器端通过 Channel（通道）通讯，实现了多路复用。

AIO：Asynchronous IO 是 NIO 的升级，也叫 NIO2，实现了异步非堵塞 IO ，异步 IO的操作基于事件和回调机制。

​	
