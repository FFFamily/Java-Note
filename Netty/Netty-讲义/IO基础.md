# IO

## NIO vs BIO

如果仔细分析，一定会发现阻塞I/O存在一些缺点。根据阻塞I/O通信模型，总结了它的两个缺点。

（1）当客户端多时，会创建大量的处理线程。且每个线程都要占用栈空间和一些CPU时间。

（2）阻塞可能带来频繁的上下文切换，且大部分上下文切换可能是无意义的。在这种情况下非阻塞I/O就有了它的应用前景。

Java NIO是从JDK 1.4开始使用的，它既可以说成是“新I/O”，也可以说成是“非阻塞I/O”。下面是Java NIO的工作原理。

（1）由一个专门的线程来处理所有的I/O事件，并负责分发。

（2）事件驱动机制：事件到的时候触发，而不是同步地去监视事件。

（3）线程通信：线程之间通过wait、notify等方式通信。保证每次上下文切换都是有意义的，减少无谓的线程切换。



### IO 模型

同步阻塞、同步非阻塞、同步多路复用、异步阻塞（没有此情况）、异步非阻塞

* 同步：线程自己去获取结果（一个线程）
* 异步：线程自己不去获取结果，而是由其它线程送结果（至少两个线程）



当调用一次 channel.read 或 stream.read 后，会切换至操作系统内核态来完成真正数据读取，而读取又分为两个阶段，分别为：

* 等待数据阶段
* 复制数据阶段

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/0033.png)

* 阻塞 IO

  ![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/0039.png)

* 非阻塞  IO

  ![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/0035.png)

* 多路复用

  ![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/0038.png)

* 信号驱动

* 异步 IO

  ![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/0037.png)

* 阻塞 IO vs 多路复用

  ![](/Users/tujunjie/Library/Mobile Documents/com~apple~CloudDocs/Java-Note/Netty/Netty-讲义/img/0034.png)

  ![](/Users/tujunjie/Library/Mobile Documents/com~apple~CloudDocs/Java-Note/Netty/Netty-讲义/img/0036.png)



