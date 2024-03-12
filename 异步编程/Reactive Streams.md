# 反应式编程

反应式编程（Reactive Programming）是一种涉及数据流和变化传播的异步编程范式。这意味着可以通过所采用的编程语言轻松地表达静态（例如阵列）或动态（例如事件发射器）数据流。

根据反应式宣言所述，使用反应式方式构建的反应式系统会更加灵活、松耦合、可伸缩。这使得系统的开发更简单，能更轻易地应对系统功能的改动。反应式方式构建的系统对系统的失败情况也更有包容性，当失败确实发生时，它们的应对方案会是比较优雅得体而非混乱不可预知的。反应式系统具有很高的即时响应性，为用户提供了高效的交互反馈



根据反应式宣言所述，使用反应式编程构建的反应式系统具有如下特征。

- 即时响应性（Responsive）：只要有可能，系统就会及时地做出响应。即时响应是可用性和实用性的基石，并且即时响应意味着可以快速地检测到问题并且可以有效地对其进行处理。即时响应的系统专注于提供快速而一致的响应时间，确立可靠的反馈上限，以提供一致的服务质量。这种一致的行为反过来简化了错误处理，建立了用户使用的信心，并鼓励用户进一步与系统进行交互
- 即时响应性（Responsive）：只要有可能，系统就会及时地做出响应。即时响应是可用性和实用性的基石，并且即时响应意味着可以快速地检测到问题并且可以有效地对其进行处理。即时响应的系统专注于提供快速而一致的响应时间，确立可靠的反馈上限，以提供一致的服务质量。这种一致的行为反过来简化了错误处理，建立了用户使用的信心，并鼓励用户进一步与系统进行交互
- 弹性（Elastic）：系统在不断变化的工作负载下仍保持即时响应性。反应式系统可以通过增加或减少分配用于服务这些输入的资源来对输入速率的变化做出反应。这意味着设计上并没有并发争用点和中心瓶颈，从而能够分片或复制组件，并在它们之间分配输入。反应式系统通过提供相关的实时性能指标来支持预测和反应式伸缩算法，以便在商用硬件和软件平台上以经济有效的方式实现弹性。
- 消息驱动（Message Driven）：反应式系统依靠异步消息传递在组件之间建立边界，以确保松散耦合、隔离和位置透明性，该边界还提供将故障委派为消息投递出去的方法。使用显式的消息传递，可以通过在系统中构造并监视消息流队列，并在必要时应用回压来实现负载管理、弹性以及流量控制。使用位置透明的消息传递作为通信的手段，使得跨集群或者在单个主机中使用相同的结构和语义来管理失败成为可能。非阻塞通信允许接收者仅在有活动时才消耗资源，从而减少系统开销

反应式编程API也提供Java 8 Stream等运算符，但它们更适用于任何流序列（不仅仅是集合），并允许定义一个转换操作的管道，该管道将应用于通过它的数据，这要归功于方便的流畅API和使用Lambdas。它们旨在处理同步或异步操作，并允许缓冲（buffer）、合并（merge）、连接（join）或对数据应用各种转换(例如map等操作符)。



# Reactive Streams



Reactive Streams的主要目标是管理跨异步边界的流数据交换—考虑将元素从一个线程传递到另一个线程或线程池进行处理，同时确保接收方不会强制缓冲任意数量的数据。换句话说，回压是该模型的组成部分，以便允许在线程之间协调的队列有界。另外如果回压信号是同步的（参见Reactive Manifesto），异步处理的好处就将被否定，因此需要注意强制Reactive Streams实现的所有方面的完全非阻塞和异步行为。



总之，Reactive Streams是JVM上面向流的库的标准和规范。● 处理潜在无限数量的元素，并且按顺序进行处理。● 在组件之间异步传递元素。● 具有强制性的非阻塞回压。



API中包含了下面一些组员，这些组员需要Reactive Streams规范实现者来提供实现：● Publisher（发布者）● Subscriber（订阅者）● Subscription（订阅关系）● Processor（处理器）



通过代码可以发现

```xml
<dependency>
    <groupId>org.reactivestreams</groupId>
    <artifactId>reactive-streams</artifactId>
    <version>1.0.2</version>
</dependency>
<dependency>
    <groupId>org.reactivestreams</groupId>
    <artifactId>reactive-streams-tck</artifactId>
    <version>1.0.2</version>
    <scope>test</scope>
</dependency>
```



也就是定义了一些接口

```
public interface Processor<T, R> extends Subscriber<T>, Publisher<R> {}
```

-

```
public interface Publisher<T> {
    void subscribe(Subscriber<? super T> var1);
}
```

-

```java
public interface Subscriber<T> {
    void onSubscribe(Subscription var1);

    void onNext(T var1);

    void onError(Throwable var1);

    void onComplete();
}

```

-

```java
public interface Subscription {
    void request(long var1); 
    void cancel();
}
```





# RxJava

 

RxJava是Reactive Extensions的Java VM实现：RxJava是一个库，用于通过使用可观察序列来编写异步和基于事件的程序。它扩展了观察者模式以支持数据/事件序列，并添加了允许以声明方式组合数据序列的运算符，同时抽象出对低级线程、同步、线程安全和并发数据结构等问题的关注，RxJava试图做得非常轻量级，它仅仅作为单个JAR实现，仅关注Observable抽象和相关的高阶运算函数。RxJava版本1的API并不是基于Reactive Streams接口实现的，因此RxJava v1需要一个适配器，即使它在语义上的表现更像Reactive Streams。版本2将直接实现Reactive Streams接口并遵守规范，以便更好地支持与Java社区中的其他Reactive Streams实现库之间互通





# Reactor

Reactor反应式库与RxJava一样都是反应式编程规范的一个实现，其实Reactor中的流操作符与RxJava基本都是等同的，目前其主要在Spring5引入的WebFlux中作为反应式库使用，在Java项目中我们可以通过引入jar的方式，单独使用Reactor。

