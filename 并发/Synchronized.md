# Synchronized



## 临界区

对公共资源进行访问的代码，称为临界区



## 竞态条件 Race Condition

多个线程在临界区内执行，由于代码的执行序列不同而导致结果无法预测，称之为发生了竞态条件  



## synchronized

为解决临界区的竞态条件

- 阻塞式的解决方案：synchronized，Lock 
- 非阻塞式的解决方案：原子变量  



**简称：对象锁**

- 采用互斥的方式，让共享资源最多被一个线程访问，其他线程获取这个资源就会被阻塞（独占锁）
- synchronized 实际是用**对象锁**保证了**临界区内代码的原子性**，临界区内的代码对外是不可分割的，不会被线程切换所打断
- 当拥有锁的线程因为某些原因cpu没有执行时，不会去将锁释放，其他访问共享资源的线程还是会被阻塞，当拥有锁的线程又获取权限可以执行时，就会进入队列，再次 执行，执行完后才会释放锁，下一个线程获取锁去访问（也就是可重入）

### 语法

```java
synchronized(对象)
{
	//临界区
}
```

注意

synchronized加在方法上，等价于对当前类对象加锁，无论方法正常执行完毕还是抛出异常，都会释放锁

```java
public synchronized void test() {} 
// 等价于
public void test() {
    synchronized(this) {}
}
//a.test() b.test() 不会互斥
```

synchronized加在静态方法上，相当于对这个类进行加锁，class类只会有一个

> 那么修饰静态方法，执行完毕后会释放锁吗？

```java
public synchronized static void test() {}
```



### synchronized原理

```java
static final Object lock=new Object();
static int counter = 0;
public static void main(String[] args) {
    synchronized (lock) {
    	counter++;
    }
}
```

以上源码进过反编译后得到

```java
 public static void main(java.lang.String[]);
    Code:
       0: getstatic     #2                  // 获取lock锁
       3: dup // 复制
       4: astore_1 //将lock锁引用复制给slot 1
       5: monitorenter // 将lock对象MarkWord设置为Monitor指针
       6: getstatic     #3                  // Field counter:I
       9: iconst_1
      10: iadd
      11: putstatic     #3                  // Field counter:I
      14: aload_1 // 获取astore_1存储的lock引用
      15: monitorexit// 将对象的MarkWord重置，因为你解开锁了，所以需要还原，唤醒EntryList中等待的线程
      16: goto          24 //代码结束
      19: astore_2//将异常信息存储给slot 2
      20: aload_1 // 获取astore_1存储的lock引用
      21: monitorexit
      22: aload_2
      23: athrow
      24: return
    Exception table: // 这里会监控指定行数的异常，如果出现异常，就会在19行开始处理
       from    to  target type
           6    16    19   any
          19    22    19   any
```

`Monitorenter`和`Monitorexit`指令，会让锁计数器加一或者减一，每一个对象在同一时间只与一个monitor(锁)相关联，而一个monitor在同一时间只能被一个线程获得

`monitorexit指令`：释放对于monitor的所有权，释放过程很简单，就是讲monitor的计数器减1，如果减完以后，计数器不是0，则代表刚才是重入进来的，当前线程还继续持有这把锁的所有权，如果计数器变成0，则代表当前线程不再拥有该monitor的所有权，即释放锁。



### 锁原理以及重入原理

Synchronazed修饰的每个对象都有一个监视器锁（monitor）。

当 monitor 被占用时就处于锁定状态，线程执行 monitorenter 时，会尝试获取 monitor 的所有权

1，如果monitor的进入数为0，那么线程就会进入monitor，设置进入数为1，该线程为该monitor的所有者

2，如果线程重复占用，monitor就会加一

3，monitor被占用时，其他线程获取会进入阻塞状态，进入 SynchronizedQueue同步队列，线程状态变为BLOCKED，直到monitor为 0，再重新获取monitor的所有权



同步方法

调用指令会检查方法的ACC_SYNCHRONIZED访问标志是否被设置，如果设置了就会先去获取monitor，获取成功后才会执行方法体，再释放monitor

Jvm 对象都有对象头，对象头是实现 synchronized 的基础

![](./img/15.png)

Mark Word 的结构

![](./img/16.png)

当多个线程同时请求某个对象监视器时，对象监视器会设置几种状态用来区分请求的线程：
Contention List：所有请求锁的线程将被首先放置到该竞争队列
Entry List：Contention List 中那些有资格成为候选人的线程被移到 Entry List
Wait Set：那些调用 wait 方法被阻塞的线程被放置到 Wait Set
OnDeck：任何时刻最多只能有一个线程正在竞争锁，该线程称为 OnDeck
Owner：获得锁的线程称为 Owner
!Owner：释放锁的线程

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/17.png)



### 可见性原理

Synchronized的happens-before规则，即监视器锁规则：对同一个监视器的解锁，happens-before于对该监视器的加锁

 JMM可以通过happens-before关系向程序员提供跨线程的内存可见性保证

> **如果A线程的写操作a与B线程的读操作b之间存在happens-before关系**
>
> **尽管a操作和b操作在不同的线程中执行，但JMM向程序员保证a操作将对b操作可见**

代码测试

> 还需要实际测试

```java
public class MonitorDemo {
    private int a = 0;

    public synchronized void writer() {    
        a++;// 2
    }                                      

    public synchronized void reader() {    
        int i = a;// 5              
    }                                      
}
```

通过 程序的执行顺序规则以及监视锁规则推测出一个 `happen-before` 规则

有A B 两个线程

如果A happens-before B，则A的执行结果对B可见，并且A的执行顺序先于B。

线程A先对共享变量A进行加一，由2 happens-before 5关系可知线程A的执行结果对线程B可见即线程B所读取到的a的值为1



## 缺陷

在JVM中，使用`Monitorenter`和`Monitorexit`指令实际是去使用操作系统底层的Mutex Lock来实现的，但是， Mutex Lock的使用是需要将当前的线程挂起，并且从用户态切换到内核态中，这样的切换代价是昂贵的。

然而在现实中的大部分情况下，同步方法是运行在单线程环境(无锁竞争环境)，如果每次都调用Mutex Lock那么将严重的影响程序的性能。





## 优化

dk1.6中对锁的实现引入了大量的优化，以此减少锁操作的开销

锁粗化(Lock Coarsening)：

也就是减少不必要的紧连在一起的unlock，lock操作，将多个连续的锁扩展成一个范围更大的锁

锁消除(Lock Elimination)：

通过运行时JIT编译器的逃逸分析来消除一些没有在当前同步块以外被其他线程共享的数据的锁保护，通过逃逸分析也可以在线程本地Stack上进行对象空间的分配(同时还可以减少Heap上的垃圾收集开销)

轻量级锁(Lightweight Locking)：

这种锁实现的背后基于这样一种假设，即在真实的情况下我们程序中的大部分同步代码一般都处于无锁竞争状态(即单线程执行环境)，在无锁竞争的情况下完全可以避免调用操作系统层面的重量级互斥锁，取而代之的是在monitorenter和monitorexit中只需要依靠一条CAS原子指令就可以完成锁的获取及释放。当存在锁竞争的情况下，执行CAS指令失败的线程将调用操作系统互斥锁进入到阻塞状态，当锁被释放的时候被唤醒

偏向锁(Biased Locking)：

是为了在无锁竞争的情况下避免在锁获取过程中执行不必要的CAS原子指令，因为CAS原子指令虽然相对于重量级锁来说开销比较小但还是存在非常可观的本地延迟。	

适应性自旋(Adaptive Spinning)

当线程在获取轻量级锁的过程中执行CAS操作失败时，在进入与monitor相关联的操作系统重量级锁(mutex semaphore)前会进入忙等待(Spinning)然后再次尝试，当尝试一定的次数后如果仍然没有成功则调用与该monitor关联的semaphore(即互斥锁)进入到阻塞状态。



### 同步锁

Java SE 1.6里Synchronied同步锁，一共有四种状态：`无锁`、`偏向锁`、`轻量级锁`、`重量级锁`，它会随着竞争情况逐渐升级。

锁可以升级但是不可以降级，目的是为了提供获取锁和释放锁的效率。

锁膨胀方向： 无锁 → 偏向锁 → 轻量级锁 → 重量级锁 (此过程是不可逆的)



### 自旋锁

自旋锁的出现，是考虑到了Synchronized的重量级性质，其加锁和释放锁都会涉及到用户态和内核态的切换，频繁的切换势必会带来很大的开销。

如果，每次锁占用的时间很短，为了这么一点时间去阻塞和恢复线程，有点得不偿失

如何让线程每次不必要去进行阻塞操作呢？那便是自旋锁

让另一个没有获取到锁的线程在门外等待一会(自旋)，但不放弃CPU的执行时间。等待持有锁的线程是否很快就会释放锁。为了让线程等待，我们只需要让线程执行一个忙循环(自旋)，这便是自旋锁由来的原因。



自旋锁早在JDK1.4 中就引入了，只是当时默认时关闭的。在JDK 1.6后默认为开启状态

自旋锁本质上与阻塞并不相同，先不考虑其对多处理器的要求，如果锁占用的时间非常的短，那么自旋锁的新能会非常的好，相反，其会带来更多的性能开销

> 因为在线程自旋时，始终会占用CPU的时间片，如果锁占用的时间太长，那么自旋的线程会白白消耗掉CPU资源

在JDK定义中，自旋锁默认的自旋次数为10次，用户可以使用参数`-XX:PreBlockSpin`来更改



### 自 适应自旋锁

> 自旋锁也有一个弊端，如果自旋的结束的同时，线程释放了锁，那岂不是循环等待的时间都浪费了？

这个时候就需要更加聪明的锁来实现更加灵活的自旋。来提高并发的性能

在JDK 1.6中引入了自适应自旋锁。这就意味着自旋的时间不再固定了，而是由前一次在同一个锁上的自旋 时间及锁的拥有者的状态来决定的。如果在同一个锁对象上，自旋等待刚刚成功获取过锁，并且持有锁的线程正在运行中，那么JVM会认为该锁自旋获取到锁的可能性很大，会自动增加等待时间。相反，如果对于某个锁，自旋很少成功获取锁。那再以后要获取这个锁时将可能省略掉自旋过程，以避免浪费处理器资源。有了自适应自旋，JVM对程序的锁的状态预测会越来越准备。



### 锁消除





## Volatile 与 synchronized区 别

- Volatile 不加锁，不会阻塞线程
- volatile 无法保证原子性：count++，只能保证可见性和原子性
- synchronized更安全



## synchronizated 和 lock 差别

![](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/18.png)



## synchronized 可以替代读写锁吗









### 加锁和释放锁的原理

### 可重入原理

### 可见性原理

### 锁升级和锁降级

### Synchronized使得同时只有一个线程可以执行，性能比较差，有什么提升的方法?

### Synchronized有哪些缺陷？可以怎么解决

### 如何灵活地控制锁的释放和获取

### 多个线程等待同一个snchronized锁的时候，JVM如何选择下一个获取锁的线程?

非公平锁，即抢占式

