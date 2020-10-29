# JVM--内存和垃圾回收

> 笔记来源于《尚硅谷的JVM视频》
>
> 《深入理解JAVA虚拟机》

## 字节码

字节码（Byte-code）是一种包含执行程序，由一序列 op 代码/数据对组成的二进制文件，是一种中间码

平时说的java字节码，指的是用java语言编译成的字节码

> 由于JVM跨语言的平台特性，JVM支持很多语言，所以现在通常讲字节码都是jvm字节码，不同的编译器编译出的字节码文件不同



## 虚拟机

所谓虚拟机（Virtual Machine），就是一台虚拟的计算机。它是一款软件，用来执行一系列虚拟计算机指令

大体上，虚拟机可以分为**系统虚拟机**和**程序虚拟机**



## Java虚拟机

Java虚拟机是一台执行Java字节码的虚拟计算机

JVM平台的各种语言可以共享Java虚拟机带来的跨平台性、优秀的垃圾回器，以及可靠的即时编译器

Java技术的核心就是Java虚拟机（JVM，Java Virtual Machine），因为所有的Java程序都运行在Java虚拟机内部

Java虚拟机就是二进制字节码的运行环境，负责装载字节码到其内部，解释/编译为对应平台上的机器指令执行

特点：

- 一次编译，到处运行
- 自动内存管理
- 自动垃圾回收功能



## JVM所在位置

JVM是运行在操作系统之上的，它与硬件没有直接的交互

> 用户使用高级语言编译产生字节码文件，传入到JVM中解析，再产生运行结果

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200713182357407.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTc1OTc5MQ==,size_16,color_FFFFFF,t_70)



## JVM架构模型

Java编译器输入的指令流基本上是一种基于栈的指令集架构，另外一种指令集架构则是基于寄存器的指令集架构。具体来说：这两种架构之间的区别：

基于栈式架构的特点

- 设计和实现更简单，适用于资源受限的系统；
- 避开了寄存器的分配难题：使用零地址指令方式分配。
- 指令流中的指令大部分是零地址指令，其执行过程依赖于操作栈。指令集更小，编译器容易实现，但是指令多。
- 不需要硬件支持，可移植性更好，更好实现跨平台



基于寄存器架构的特点

- 典型的应用是x86的二进制指令集：比如传统的PC以及Android的Davlik虚拟机。
- 指令集架构则完全依赖硬件，可移植性差
- 性能优秀和执行更高效
- 花费更少的指令去完成一项操作。
- 在大部分情况下，基于寄存器架构的指令集往往都以一地址指令、二地址指令和三地址指令为主，而基于栈式架构的指令集却是以零地址指令为主方水洋



总结：

- 跨平台性
- 指令集小
- 指令多
- 执行性能比寄存器差

## JVM生命周期

jvm的启动

Java虚拟机的启动是通过引导类加载器（bootstrap class loader）创建一个初始类（initial class）来完成的，这个类是由虚拟机的具体实现指定的



jvm的执行

- 程序开始执行时他才运行，程序结束时他就停止。
- 执行一个所谓的Java程序的时候，真真正正在执行的是一个叫做Java虚拟机的进程。



jvm的退出

有如下的几种情况：

- 程序正常执行结束
- 程序在执行过程中遇到了异常或错误而异常终止
- 由于操作系统用现错误而导致Java虚拟机进程终止
- 某线程调用Runtime类或system类的exit方法，或Runtime类的halt方法，并且Java安全管理器也允许这次exit或halt操作。
- 除此之外，JNI（Java Native Interface）规范描述了用JNI Invocation API来加载或卸载 Java虚拟机时，Java虚拟机的退出情况。

## JVM家族

### Sun Classic VM

1，早在1996年Java1.0版本的时候，Sun公司发布了一款名为sun classic VM的Java虚拟机，它同时也是世界上第一款商用Java虚拟机，在JDK1.4时完全被淘汰

2，这款虚拟机内部只提供解释器，因此效率比较低

3，如果使用JIT编译器，就需要进行外挂。但是一旦使用了JIT编译器，JIT就会接管虚拟机的执行系统。解释器就不再工作。解释器和编译器不能配合工作

4，现在hotspot内置了此虚拟机



### Exact VM：

Exact Memory Management：准确式内存管理

具备现代高性能虚拟机的维形

1，热点探测（寻找出热点代码进行缓存）

2，编译器与解释器混合工作模式



### HotSpot VM

1，JDK1.3时，HotSpot VM成为默认虚拟机

2，不管是现在仍在广泛使用的JDK6，还是使用比例较多的JDK8中，默认的虚拟机都是HotSpot

3，HotSpot指的就是它的热点代码探测技术。

- 通过计数器找到最具编译价值代码，触发即时编译或栈上替换
- 通过编译器与解释器协同工作，在最优化的程序响应时间与最佳执行性能中取得平衡



### JRockit

1，专注于服务器端应用，JRockit内部不包含解析器实现，全部代码都靠即时编译器编译后执行

2，JRockit JVM是世界上最快的JVM



### IBM的J9

1，全称：IBM Technology for Java Virtual Machine，简称IT4J，内部代号：J9

2，市场定位与HotSpot接近，服务器端、桌面应用、嵌入式等多用途VM广泛用于IBM的各种Java产品

3，目前，有影响力的三大商用虚拟机之一，也号称是世界上最快的Java虚拟机



### KVM和CDC / CLDC Hotspot

- 智能控制器、传感器
- 老人手机、经济欠发达地区的功能手机



### Azul VM

1，Azul VM是Azu1Systems公司在HotSpot基础上进行大量改进，运行于Azul Systems公司的专有硬件Vega系统上的ava虚拟机



### Liquid VM

1，高性能Java虚拟机中的战斗机



### Apache Marmony

### Micorsoft JVM

1，微软为了在IE3浏览器中支持Java Applets，开发了Microsoft JVM

### Taobao JVM

1，基于openJDK开发了自己的定制版本AlibabaJDK，简称AJDK。是整个阿里Java体系的基石。

2，基于openJDK Hotspot VM发布的国内第一个优化、深度定制且开源的高性能服务器版Java虚拟机。

3，taobao vm应用在阿里产品上性能高，硬件严重依赖inte1的cpu，损失了兼容性，但提高了性能

4，目前已经在淘宝、天猫上线，把oracle官方JvM版本全部替换了



### Dalvik VM

1，谷歌开发的，应用于Android系统，并在Android2.2中提供了JIT，发展迅猛。

2，Dalvik y只能称作虚拟机，而不能称作“Java虚拟机”，它没有遵循 Java虚拟机规范



### Graal VM



# 类加载子系统

负责加载Class文件

## 流程

> 在.class文件->JVM->最终成为元数据模板，此过程就要一个运输工具（类装载器Class Loader），扮演一个快递员的角色。

![img](https://img-blog.csdnimg.cn/20200713183403217.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80NTc1OTc5MQ==,size_16,color_FFFFFF,t_70)



字节码文件通过ClasserLoader加载，产生一个Class文件，然后再通过链接（验证，解析），最后就是初始化，调用类`

![20200713183333649](..\img\jvmimg\20200713183333649.png)



### 加载阶段

1，通过一个类的全限定名获取定义此类的二进制字节流

2，将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构

3，**在内存中生成一个代表这个类的java.lang.Class对象**，作为方法区这个类的各种数据的访问入口

（class实例实在加载阶段产生的）



### 链接阶段

验证：确保Class文件的字节流中包含信息符合当前虚拟机的要求

主要包括四种验证，文件格式验证，元数据验证，字节码验证，符号引用验证



准备：为类变量分配内存并且设置该类**变量**的默认初始值，零值

（这里强调是将变量赋值）

```java
private int n = 1;
//在这个阶段 n = 0
//在下一个初始化阶段才是将 n = 1；
```



> final修饰的static在编译的时候就已经分配了，因为它已经是常量了
>
> 
>
> 实例变量不会分配，会随着对象一起分配到java堆中



解析：将常量池捏符号引用转换为直接引用

> 在加载类的时候实际上会去加载很多其他的类，不可能每个加载的类都存放在一个堆中，所以实际上是去使用引用



### 初始化阶段

1，初始化阶段就是执行类构造器方法<clinit>()方法的过程，其不同于类的构造器

> **构造器是虚拟机视角下的`<init>()`**
>
> **构造器方法中指令按语句在源文件中出现的顺序执行**



```java
public class ClassInitTest {
    //任何一个类声明以后，内部至少存在一个类的构造器
    private static int num = 1;
    
    static {
        num = 2;
        number = 20;
        System.out.println(num);
        System.out.println(number);  //报错，非法的前向引用
    }

    private static int number = 10;

    public static void main(String[] args) {
        
        System.out.println(ClassInitTest.num); // 2
        System.out.println(ClassInitTest.number); // 10
    }
}
```



> iconst_0  就是加载的变量

![1](..\img\jvmimg\1.jpg)



值得注意的是：

> 这个方法不需要定义，是编译器自动收集类中的所有类变量的赋值动作和静态代码快中的语句合并
>
> 当不存在赋值动作或者静态代码时，就不会有<clinit>()方法产生



2，该类有父类，在执行子类<clinit>()方法前父类已经执行完成

```java
public class ClinitTest1 {
    static class Father{
        public static int A = 1;
        static{
            A = 2;
        }
    }

    static class Son extends Father{
        public static int B = A;
    }

    public static void main(String[] args) {
        //加载Father类，其次加载Son类。
        System.out.println(Son.B);//2
    }
}
```



3，虚拟机保证一个类的<clinit>()方法在多线程下同步枷锁，也就是说，调用重复创建这个类时只是调用缓存中存在的类对象



这里会导致程序卡死：

有一个线程抢到同步锁，开始加载类，但是static代码块中是个死循环，另一个线程一直等待锁的释放

```java
public class DeadThreadTest {
    public static void main(String[] args) {
        Runnable r = () -> {
            System.out.println(Thread.currentThread().getName() + "开始");
            DeadThread dead = new DeadThread();
            System.out.println(Thread.currentThread().getName() + "结束");
        };

        Thread t1 = new Thread(r, "线程1");
        Thread t2 = new Thread(r, "线程2");

        t1.start();
        t2.start();
    }
}

class DeadThread {
    static {
        if (true) {
            System.out.println(Thread.currentThread().getName() + "初始化当前类");
            while (true) {

            }
        }
    }
}
```





## 类加载器分类

1，JVM支持两种类型的类加载器 。分别为引导类加载器（Bootstrap ClassLoader）和自定义类加载器（User-Defined ClassLoader）

2，Java虚拟机规范将所有派生于抽象类ClassLoader的类加载器都划分为自定义类加载器

> 也就是说，所有直接或者间接继承ClassLoader的加载器都划分为自定义加载器，即**ExtClassLoader 和 AppClassLoader 都属于自定义加载器**
>
> ClassLoader类，它是一个抽象类，其后所有的类加载器都继承自ClassLoader（不包括启动类加载器）
>
> 获取 ClassLoader 途径
>
> ```java
> clazz.getClassloader();//获取当前类的
> 
> Thread.currentThread().getContextClassLoader();//获取当前线程上下文的
> 
> ClassLoader.getSystemClassLoader();//获取系统的
> 
> DriverManager.getCallerClassLoader();//获取调用者的
> ```
>
> 





3，程序中常用的有3个：引导类加载器，扩展类加载器，系统类加载器，额外的还有用户自定义加载器，是包含关系

即

```java
ClassLoader systemClassLoader = ClassLoader.getSystemClassLoader();

// 获取其上层的：扩展类加载器
ClassLoader extClassLoader = systemClassLoader.getParent();

// 试图获取 根加载器（引导类加载器）
ClassLoader bootstrapClassLoader = extClassLoader.getParent();

// 获取自定义加载器
ClassLoader classLoader = ClassLoaderTest.class.getClassLoader();

// 获取String类型的加载器
ClassLoader classLoader1 = String.class.getClassLoader();

```

得到的结果，从结果可以看出 根加载器无法直接通过代码获取，同时目前用户代码所使用的加载器为系统类加载器。

同时我们通过获取String类型的加载器，发现是null，那么说明String类型是通过根加载器进行加载的，也就是说**Java的核心类库都是使用引导类加载器进行加载的**

```
sun.misc.Launcher$AppClassLoader@18b4aac2
sun.misc.Launcher$ExtClassLoader@1540e19d
null
sun.misc.Launcher$AppClassLoader@18b4aac2
null 
```



### 启动加载器

> 引导类加载器，Bootstrap ClassLoader					

1，使用C/C++语言实现的，嵌套在JVM内部

2，它用来加载Java的核心库，用于提供JVM自身需要的类

3，没有父加载器

4，加载扩展类和应用程序类加载器，并作为他们的父类加载器

5，出于安全考虑，Bootstrap启动类加载器只加载包名为java、javax、sun等开头的类

```java
URL[] urLs = sun.misc.Launcher.getBootstrapClassPath().getURLs();
for (URL element : urLs) {
	System.out.println(element.toExternalForm());
}

file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/resources.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/rt.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/sunrsasign.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/jsse.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/jce.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/charsets.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/lib/jfr.jar
file:/C:/Program%20Files/Java/jdk1.8.0_144/jre/classes
```



### 扩展类加载器

> 扩展类加载器，Extension ClassLoader

1，Java语言编写，是Launcher的内部类

2，派生于ClassLoader类

> 从java.ext.dirs系统属性所指定的目录中加载类库，或从JDK的安装目录的jre/lib/ext子目录（扩展目录）下加载类库。如果用户创建的JAR放在此目录下，也会自动由扩展类加载器加载

```java
String extDirs = System.getProperty("java.ext.dirs");
for (String path : extDirs.split(";")) {
	System.out.println(path);
}

C:\Program Files\Java\jdk1.8.0_144\jre\lib\ext
C:\WINDOWS\Sun\Java\lib\ext
```





### 系统类加载器

> 应用程序类加载器，系统类加载器，AppClassLoader
>
> 虚拟机自带
>
> 通过classLoader.getSystemclassLoader()方法可以获取到该类加载器

1，Java语言编写,

2，派生于ClassLoader类

3，父类加载器为扩展类加载器

4，它负责加载环境变量classpath（也就是自定义类的路径）或系统属性java.class.path指定路径下的类库

5，一般来说，Java应用的类都是由它来完成加载



### 用户自定义类加载器

1，隔离加载类

2，修改类加载的方式

3，扩展加载源

4，防止源码泄漏



如何自定义类加载器？

1，继承抽象类java.lang.ClassLoader类

2，在JDK1.2之前，在自定义类加载器时，总会去继承ClassLoader类并重写loadClass()方法，从而实现自定义的类加载类，但是在JDK1.2之后已不再建议用户去覆盖loadClass()方法，而是建议把自定义的类加载逻辑写在findclass()方法中

3，在编写自定义类加载器时，如果没有太过于复杂的需求，可以直接继承URIClassLoader类，这样就可以避免自己去编写findclass()方法及其获取字节码流的方式，使自定义类加载器编写更加简洁

```java
public class CustomClassLoader extends ClassLoader {
    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {

        try {
            byte[] result = getClassFromCustomPath(name);
            if (result == null) {
                throw new FileNotFoundException();
            } else {
                return defineClass(name, result, 0, result.length);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        throw new ClassNotFoundException(name);
    }

    private byte[] getClassFromCustomPath(String name) {
        //从自定义路径中加载指定类:细节略
        //如果指定路径的字节码文件进行了加密，则需要在此方法中进行解密操作。
        return null;
    }

    public static void main(String[] args) {
        CustomClassLoader customClassLoader = new CustomClassLoader();
        try {
            Class<?> clazz = Class.forName("One", true, customClassLoader);
            Object obj = clazz.newInstance();
            System.out.println(obj.getClass().getClassLoader());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```



### 双亲委派机制

原理

**Java虚拟机对class文件采用的是按需加载的方式**，也就是说当需要使用该类时才会将它的class文件加载到内存生成class对象。

而且**加载某个类的class文件时，Java虚拟机采用的是双亲委派模式，即把请求交由父类处理，它是一种任务委派模式**

![1](..\JVM\img\1.png)

1. 如果一个类加载器收到了类加载请求，它并不会自己先去加载，而是把这个请求委托给父类的加载器去执行；
2. 如果父类加载器还存在其父类加载器，则进一步向上委托，依次递归，请求最终将到达顶层的启动类加载器；
3. 如果父类加载器可以完成类加载任务，就成功返回，倘若父类加载器无法完成此加载任务，子加载器才会尝试自己去加载，这就是双亲委派模式。
4. 父类加载器一层一层往下分配任务，如果子类加载器能加载，则加载此类，如果将加载任务分配至系统类加载器也无法加载此类，则抛出异常

> 当自己去创建一个javaapi中的类时，jvm不回去加载自己的类，而是去加载核心库中的java文件



优势

1，避免重复加载类

2，保护程序安全，防止核心API被篡改



### 沙箱安全机制

自定义String类时：在加载自定义String类的时候会率先使用引导类加载器加载，而引导类加载器在加载的过程中会先加载jdk自带的文件（rt.jar包中java.lang.String.class），报错信息说没有main方法，就是因为加载的是rt.jar包中的String类。



这样可以保证对java核心源代码的保护，这就是沙箱安全机制