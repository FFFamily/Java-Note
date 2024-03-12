# SPI

> 秦保科技
>
> 虽然在业务中基本上不会去使用SPI机制，但是对于编写框架有着如虎添翼的效果
>
> 应用了SPI 的知名框架有很多：Spring、Dubbo、JDBC、Common-Logging...
>
> 此处只涉及到基本的学习了解，更深入的可以自行了解：比如Dubbo中注解式的SPI...

## 概念

`SPI` 全名 `Service Provider interface`，翻译过来就是“服务提供接口”，再说简单就是提供某一个服务的接口， 提供给服务开发者或者服务生产商来进行实现。
Java SPI 是JDK内置的一种动态加载扩展点的实现。

在面向对象编程中，基于开闭原则和解耦的需要，一般建议用接口进行模块之间通信编程，通常情况下调用方模块是不会感知到被调用方模块的内部具体实现。

> 开闭原则：对扩展开放（针对提供方），对修改封闭（针对使用方）。也就是接口提供方法，子类继承并实现

为了实现在模块装配的时候不用在程序里面动态指明，这就需要一种服务发现机制。Java SPI 就是提供了这样一个机制：为某个接口寻找服务实现的机制。这有点类似 IoC 的思想，将装配的控制权移交到了程序之外。

`API` 全称`Application Programming Interface`， 翻译为“应用程序接口”，指的是应用程序为外部提供服务的接口，这个接口通常由服务提供者自行开发，定义好接口后很少改动

## 使用

编写接口，不同的接口实现，在 `META-INF` 中 的 `services` 文件夹 创建指定 接口的全路径  文本 ，里面就是 对应的实现类的全路径

加载就是使用 `ServerLoader ` 类 去执行

所以其中的原理就在 `ServerLoader` 中

SPI 接口

```java
public interface myspi {
    public void upload();
}
```

实现类

```java
public class muSpiImpl implements myspi{
    @Override
    public void upload() {
        System.out.println(1111);
    }
}
```

META-INF 文件配置：文件名 `com.tutu.xunfei.spi.myspi`

```xml
com.tutu.xunfei.spi.muSpiImpl
com.tutu.xunfei.spi.myspiImpl2
```

运行

```java
ServiceLoader<myspi> load = ServiceLoader.load(myspi.class);
Iterator<myspi> iterator = load.iterator();
while (iterator.hasNext()){
  myspi next = iterator.next();
  next.upload();
}
```

输出：1111



## 原理

> JavaSourceLearn 项目中
>

从 `load` 方法 开始

```java
public static <S> ServiceLoader<S> load(Class<S> service, ClassLoader loader)
{
    return new ServiceLoader<>(service, loader);
}
```

内部构建了一个 `ServiceLoader`

```java
/**
 * 构建
 */
private ServiceLoader(Class<S> svc, ClassLoader cl) {
    // 校验
    service = Objects.requireNonNull(svc, "Service interface cannot be null");
    // 选择类加载器
    loader = (cl == null) ? ClassLoader.getSystemClassLoader() : cl;
    // 访问JDK内部的信息需要权限
    acc = (System.getSecurityManager() != null) ? AccessController.getContext() : null;
    reload();
}
```

接着就是 `reload()` 方法

```java
/**
 * 清除此加载程序的提供程序缓存，以便所有提供程序重新加载
 * 调用此方法后，后续调用   iterator（）迭代器 方法将懒洋洋地查找和实例化 。正如新创建的加载器所做的那样。
 * 这里强调了懒加载，也就是意味着在正式调用方法的时候才会加载（这个时候是不会去加载文件夹下的文件内容）
 * 此方法适用于新提供者 可以安装到正在运行的Java虚拟机中。
 */
public void reload() {
    providers.clear();
  	// 这里封装了一个懒加载迭代器
    lookupIterator = new LazyIterator(service, loader);
}
```

从这里可以知道，`load()` 方法 只做了加载操作，为程序执行提供了环境

 既然是使用时懒加载，那么核心的方法在其懒加载的迭代器中

```java
// 懒加载的具体实现
private class LazyIterator
    implements Iterator<S>
{

    // 传入的SPI接口Class
    Class<S> service;
    // 类加载器
   	ClassLoader loader;
  	// Enumeration 类似于数组，只不过是是支持某些特殊API的数组
  	Enumeration<URL> configs = null;
  	// 这个应该代表剩下的
  	Iterator<String> pending = null;
  	// SPI接口实现类全限定类名
  	String nextName = null;

    private LazyIterator(Class<S> service, ClassLoader loader) {
        this.service = service;
        this.loader = loader;
    }
    // 读取 META-INF/services 配置
    // 判断是否下一个是否能被加载
    private boolean hasNextService() {
        if (nextName != null) {
            return true;
        }
        if (configs == null) {
            try {
                // 拼接路径
                String fullName = PREFIX + service.getName();
                if (loader == null)
                    // 也就是用 classLoader 加载系统资源
                    configs = ClassLoader.getSystemResources(fullName);
                else
                    // loader 不为空也就意味着用指定加载器加载
                    configs = loader.getResources(fullName);
            } catch (IOException x) {
                fail(service, "Error locating configuration files", x);
            }
        }

        while ((pending == null) || !pending.hasNext()) {
            // 当 pending 为空或者没有下一个时
            // 这里的 hasMoreElements 方法就是来自于 Enumeration
            if (!configs.hasMoreElements()) {
                return false;
            }
            pending = parse(service, configs.nextElement());
        }
        nextName = pending.next();
        return true;
    }
		
    private S nextService() {
        if (!hasNextService())
            throw new NoSuchElementException();
        String cn = nextName;
        nextName = null; // GC 小技巧？
        Class<?> c = null;
        try {
            // initialize 参数为 false
            c = Class.forName(cn, false, loader);
        } catch (ClassNotFoundException x) {
            fail(service,
                 "Provider " + cn + " not found");
        }
        if (!service.isAssignableFrom(c)) {
            fail(service,
                 "Provider " + cn  + " not a subtype");
        }
        try {
            // 实例化，并返回
            S p = service.cast(c.newInstance());
            providers.put(cn, p);
            return p;
        } catch (Throwable x) {
            fail(service,
                 "Provider " + cn + " could not be instantiated",
                 x);
        }
        throw new Error();          // This cannot happen
    }

    public boolean hasNext() {
        if (acc == null) {
            return hasNextService();
        } else {
            PrivilegedAction<Boolean> action = new PrivilegedAction<Boolean>() {
                public Boolean run() { return hasNextService(); }
            };
            return AccessController.doPrivileged(action, acc);
        }
    }

    public S next() {
        if (acc == null) {
            return nextService();
        } else {
          	// 走需要权限的逻辑
            PrivilegedAction<S> action = () -> nextService();
            return AccessController.doPrivileged(action, acc);
        }
    }

    public void remove() {
        throw new UnsupportedOperationException();
    }

}
```





## 应用

> 以 JDBC 中的 DriverManager 为例
>

在JDBC4.0之前，我们开发有连接数据库的时候，通常会用Class.forName("com.mysql.jdbc.Driver")这句先加载数据库相关的驱动，然后再进行获取连接等的操作。

> 也就是JDK 1.6 版本前

**而JDBC4.0之后不需要用Class.forName("com.mysql.jdbc.Driver")来加载驱动，直接获取连接就可以了，现在这种方式就是使用了Java的SPI扩展机制来实现**。

> 也就是 JDK 1.8后

`mysql-connector-java-6.0.6.jar`中，可以找到`META-INF/services`目录，该目录下会有一个名字为`java.sql.Driver`的文件，文件内容是`com.mysql.cj.jdbc.Driver`，这里面的内容就是针对Java中定义的接口的实现。

```java
String url = "";
String userName= "";
String password = "";
// 我作为调用方，可以根据自己的需要去选择不同的实现，但是调用方式一致
Connection connection = DriverManager.getConnection(url, url, password);
Statement statement = connection.createStatement();
statement.execute("select * from user");
```

刚刚的例子是我们自己写的代码，选择了 `ServiceLoader` 加载，内部其实就是 利用了 双亲委派 通过一层层的类加载器加载找到我们的类，再通过 forName 的反射方式实例化

这里的 Driver 是属于 java.sql 中的，是属于JDK 内部代码，这部分是由 boot类加载器加载的

分析 DriverManager 类 ，研究时发现 8 和 17 部分代码 已经不一样了

先说 8的

核心代码都在 `DriverManager` 中的 `loadInitialDrivers` 方法中

而在 17 的代码中（暂时不清楚其他版本的优化）

取消了 存放在 `static` 的初始化代码块，转而变成了 每次 conect 时 调用一下方法，同时取代 static 的是 用到了锁

为什么要这么做呢？

我的猜测：

- 放在static中作为静态块不够灵活，初始化只会有一次，是不是后续的代码调整中加入了类似配置动态配置的代码，使得在 connect 时需要再次校验

> 如果已经初始化，那么就不需要再次初始化了

- JDBC 高版本的特性要求
- 集中问题
  - 为啥要用一个 boolean 变量去表示是否初始化呢？
  - 而且为啥 driversInitialized 的修改只在 `ensureDriversInitialized` 方法中，并没有其他的方法修改
  - static 和 driversInitialized 的方式都只会加载一次，为啥要更换呢？

自身分析不出来，那就分析调用方

分析

```
 DriverManager.getConnection(url, url, password);
```

我发现了两者版本的不同

JDK 17

```java
private static Connection getConnection(
    String url, java.util.Properties info, Class<?> caller) throws SQLException {
    ClassLoader callerCL = caller != null ? caller.getClassLoader() : null;
  	// 可以看到这里的 getPlatformClassLoader 有点不一样
  	// 其返回的是 PlatformClassLoader（源于Java 9）取代了 扩展类加载器 extensionClassLoader
    if (callerCL == null || callerCL == ClassLoader.getPlatformClassLoader()) {
        callerCL = Thread.currentThread().getContextClassLoader();
    }
		
  	//... 省略
  
    println("DriverManager.getConnection(\"" + url + "\")");
		// 这里使用到了锁
    ensureDriversInitialized();
		//... 省略
}
```

JDK 8

```JAVA
private static Connection getConnection(
    String url, java.util.Properties info, Class<?> caller) throws SQLException {
    ClassLoader callerCL = caller != null ? caller.getClassLoader() : null;
  	// 这里使用到了锁
    synchronized(DriverManager.class) {
        // 同步加载正确的类加载器
        if (callerCL == null) {
            callerCL = Thread.currentThread().getContextClassLoader();
        }
    }
}
```

> 这里的锁让我引发了另一个思考
>
> 以上思路出发点被打断，后续也被我推翻
>
> 应该是对 getContextClassLoader 的优化导致不需要 锁



我开始猜想 static 代码块的并发问题

多个类的静态代码块是可以并行执行的，因此不能在多个类的静态代码块中共享数据，有则需要考虑线程安全

很多时候，有这样的设计思想：在静态代码块中初始化变量，在真正使用的时候都是固定的值。

这里的流程也是一样的，使用驱动的时候，在 static 中利用 Servcerloader 加载，然后在 getConnect() 的时候获取

同时 Skip 的一句话点醒了我：这是在写框架，无法预料用户的行为。同时写下测试用例

```java
class A {
    static {
        System.out.println("A =>" + new Date());
        try {
            Thread.sleep(1000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("A =>" + new Date());
    }
}

class B extends A {
    static {
        System.out.println("B =>" + new Date());
        try {
            Thread.sleep(10000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("B =>" + new Date());
    }
}

class C extends A {
    static {
        System.out.println("C =>" + new Date());
        try {
            Thread.sleep(10000L);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println("C =>" + new Date());
    }
}

public class Test {
    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                new B();
            }
        }).start();
        new Thread(new Runnable() {
            @Override
            public void run() {
                new C();
            }
        }).start();
    }
}
```

结果

```java
A =>Sun Feb 26 23:24:14 CST 2023 
A =>Sun Feb 26 23:24:15 CST 2023
B =>Sun Feb 26 23:24:15 CST 2023 // 并行
C =>Sun Feb 26 23:24:15 CST 2023 // 并行
B =>Sun Feb 26 23:24:25 CST 2023
C =>Sun Feb 26 23:24:25 CST 2023
```

这里也就说明 B C 会在 A 之后并行执行 static 方法，那么在设计这套框架的时候是不是也需要考虑这样的情况：自定义 DriverManager

想到这里，我就认为取消 static 是有必要的

如果有多个继承于 DriverManager ，static 都进行了某些初始化的操作，其中不乏有访问 DriverManager 的公共变量，这里就会有一定的并发问题，那么既然 JDK 是在写框架，就应该去避免这样的逻辑。少了 static 后，初始化就放入了方法中，同时控制并发使用了锁。

取消这样的操作，也就更加验证了 开闭原则

额外

isDriverAllowed() 方法用于确保，注册的驱动类对调用类是可见的，因为 注册驱动的类 和 当前调用驱动的类 的 类加载器可以能并非同一个，导致不能互相调用

因为你可以传类加载器。还是那句话，这是写框架，需要考虑到方方面面



总结：

SPI 就是一个利用反射和类加载器的实现

- 不需要改动源码就可以实现扩展，解耦。
- 实现扩展对原来的代码几乎没有侵入性。
- 只需要添加配置就可以实现扩展，符合开闭原则
- `Java SPI`虽然使用了懒加载机制，但是其获取一个实现时，需要使用迭代器循环加载所有的实现类
- 当需要某一个实现类时，需要通过循环一遍来获取

等等这些是否可以融入到我们的框架中呢？比如说我们框架中不是有很多配置以及流程都是放在业务框架那边的，是否可以利用这样的特性去进行完善？

> 以此，我也意识到，现在的代码比较，应该是8和11或17的比较   1.7和1.8的比较已成过去式