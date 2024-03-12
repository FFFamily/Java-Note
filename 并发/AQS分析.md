# AQS分析

AQS是一个用来构建锁和同步器的框架，使用AQS能简单且高效地构造出应用广泛的大量的同步器

比如我们提到的ReentrantLock，Semaphore，其他的诸如ReentrantReadWriteLock，SynchronousQueue，FutureTask等等皆是基于AQS的。

当然，我们自己也能利用AQS非常轻松容易地构造出符合我们自己需求的同步器。



> 问题待补充

什么是AQS? 为什么它是核心?

AQS的核心思想是什么? 它是怎么实现的? 底层数据结构等

AQS有哪些核心的方法?

AQS定义什么样的资源获取方式? 

AQS定义了两种资源获取方式：

`独占`(只有一个线程能访问执行，又根据是否按队列的顺序分为`公平锁`和`非公平锁`，如`ReentrantLock`) 和`共享`(多个线程可同时访问执行，如`Semaphore	`CountDownLatch`、 `CyclicBarrier` )。`ReentrantReadWriteLock`可以看成是组合式，允许多个线程同时对某一资源进行读。

AQS底层使用了什么样的设计模式? 模板

AQS的应用示例?







整体介绍AQS

AQS是一个用来构建锁和同步器的框架，使用AQS能简单且高效地构造出应用广泛的大量的同步器。比如 ReentrantLock、读写锁（ReentrantReadWriteLock）等等。其核心思想是 对于共享资源，将当前线程设置为有效线程，并锁定资源，其他线程访问则会阻塞。

这是对于AQS对于锁的介绍。在AQS构建同步器方面，其有自己的一个阻塞和唤醒机制，该机制依靠于内部的一个双向队列。其内部还维护了一个state同步状态量，在不同的锁其表示的意义不同，自定义同步器在实现时只需要实现共享资源 state 的获取与释放方式即可。AQS对于资源的共享方式有两种：独占和共享，而不同的共享方式由不同的内部类实现。独占就是只有一个线程能访问资源，其中独占又分为公平和非公平，公平与非公平的实现方式就是主要还是看Sync这个类的子类，



## 核心思想

AQS核心思想是，如果被请求的共享资源空闲，则将当前请求资源的线程设置为有效的工作线程，并且将共享资源设置为锁定状态。如果被请求的共享资源被占用，那么就需要一套线程阻塞等待以及被唤醒时锁分配的机制，这个机制AQS是用CLH队列锁实现的，即将暂时获取不到锁的线程加入到队列中。

这个AQS的思想也就是其他锁的思想

简单来说：是用一个int类型的变量表示同步状态，并提供了一系列的CAS操作来管理这个同步状态对象 

一个是 state（用于计数器，类似gc的回收计数器） 

一个是线程标记（当前线程是谁加锁的）， 

一个是阻塞队列（用于存放其他未拿到锁的线程) 

## 结构

AbstractQueuedSynchronizer 继承于 AbstractOwnableSynchronizer

```java
public abstract class AbstractQueuedSynchronizer extends AbstractOwnableSynchronizer implements java.io.Serializable
```

AbstractOwnableSynchronizer 定义了独占锁的设置以及获取

```java
protected final void setExclusiveOwnerThread(Thread thread) {
    exclusiveOwnerThread = thread;
}
protected final Thread getExclusiveOwnerThread() {
    return exclusiveOwnerThread;
}
```

等待队列节点类  `Node`

内部类（条件变量）：`ConditionObject`



整体结构如上

对个体单独分析

### AbstractQueuedSynchronizer 

AbstractQueuedSynchronizer 是一个FIFO的双向队列，内部通过`head`和`tail`记录

```java
//等待队列的头，延迟初始化。除初始化外，它仅通过方法setHead进行修改 
private transient volatile Node head;

//等待队列的尾部，延迟初始化。仅通过方法enq修改以添加新的等待节点
private transient volatile Node tail;
```

AQS使用一个int成员变量来表示同步状态，通过内置的FIFO队列来完成获取资源线程的排队工作。

AQS使用CAS对该同步状态进行原子操作实现对其值的修改。

```java
//同步状态
private volatile int state;
```

状态信息通过`getState`，`setState`，`compareAndSetState`进行操作

```java
/**
 * 返回同步状态的当前值
 */
protected final int getState() {
    return state;
}

/**
 * 设置同步状态的值
 */
protected final void setState(int newState) {
    state = newState;
}

/**
 * 原子地(CAS操作)将同步状态值设置为给定值update如果当前同步状态的值等于expect(期望值)
 */
protected final boolean compareAndSetState(int expect, int update) {
    return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
}
```

注意

> 不同的锁实现对于static的定义不一样
>
> ReentrantLock 是可重入次数
>
> ReentrantReadWriteLock 是 state 高16代表读状态（读次数），以及低16位写锁的可重入次数



对于AQS，==其线程同步的关键就是对状态值 `state`的操作==

操作state的方式有 独占方式 和 共享方式，后续会讲到



### Node

Node 类在AQS中主要充当的角色就是存储在等待队列中的线程结点的封装，其定义了一系列线程的状态值，用来表示当前线程在竞争锁时的状态，

其之所以能表示当前线程值是因为内部维护了一个Thraed变量，用来代表队列中的线程

同时AQS的双向队列也是有Node保证的，其定义了前驱结点和后继结点，用来组成双向链表的形式

大部分的参数都是由voliate修饰的，目的就是在并发环境下Node结点的可见性

> volatile 的作用很明显：保证可见性和防止代码重排

```java
/**
 * 等待队列节点类.
 */
static final class Node {
    /** 用来标记该线程时获取共享资源时被阻塞后放入AQS队列中 即共享模式 */
    static final Node SHARED = new Node();
    /** 用来标记该线程时获取独占资源时被阻塞后放入AQS队列中 即独占模式 */
    static final Node EXCLUSIVE = null;

    /** 表示当前的线程被取消*/
    static final int CANCELLED =  1;
    /** 表示当前节点的后继节点包含的线程需要运行，也就是unpark(线程需要被唤醒) */
    static final int SIGNAL    = -1;
    /** 表示当前节点在等待condition，也就是在condition队列（条件队列）中 */
    static final int CONDITION = -2;
    /**
     * 表示当前场景下后续的acquireShared能够得以执行，也就是释放共享资源后需要通知其他节点
     */
    static final int PROPAGATE = -3;

    /**
     * 记录线程的等待状态:SIGNAL、CANCELLED、CONDITION、PROPAGATE、0
     */
    volatile int waitStatus;

    /**
     * 前驱结点
     */
    volatile Node prev;

    /**
     * 后继结点
     */
    volatile Node next;

    /**
     * 结点所对应的AQS队列里面的线程
     */
    volatile Thread thread;

    /**
     * 下一个等待结点
     */
    Node nextWaiter;

    /**
     * 结点是否在共享模式下等待
     */
    final boolean isShared() {
        return nextWaiter == SHARED;
    }

    /**
     *  获取前驱结点，若前驱结点为空，抛出异常
     */
    final Node predecessor() throws NullPointerException {
        Node p = prev;
        if (p == null) {
            throw new NullPointerException();
        } else {
            return p;
        }
    }
	// 省略构造方法
}
```



### ConditionObject 条件变量

理解条件变量这个概念

可以从 wait和 notify说起，wait/notify锁的实现是需要配合synchronized的，在AQS中，signal/await同样也要配合锁（AQS实现的锁），以此实现同步

> signal/await 是 AQS中的方法

但是，synchronized 只能针对一个共享变量，但是AQS的锁，可以对应多个条件变量

> 因为可以从锁中获取 lock.newCondition()

这里的Lock对象相当于 synchronized 加上共享变量，lock方法就是进入了 synchronized 块内，await方法就相当于执行wait方法



理解了 条件变量后

再来看 ConditionObject  这个类

ConditionObject的作用就是提供了条件锁的同步实现，通过链表来维护等待队列（条件队列），其内部定义了一些线程同步通信的一些方法：signal、signalAll、await等，相当于AQS内部的一个工具类的角色

即：当我们使用了AQS相关的锁，想在同步快中做一些多条件的同步操作，就可以使用ConditionObject

我们开发中要想使用condition，必须得在锁的同步块中，然后进行一系列同步方法操作

```java
ReentrantLock lock = new ReentrantLock();
// newCondition 在AQS内部声明一个ConditionObject 对象，可以访问AQS的内部变量
Condition condition = lock.newCondition();
// 加锁
lock.lock();
// 等待
condition.await();
// 唤醒
condition.signal();
// 释放锁
lock.unlock();
```

源码

```java
 public class ConditionObject implements Condition, java.io.Serializable {
     // 和AQS一样，维护着一个条件队列，不是AQS的双向队列
     // 用来存放调用await阻塞的线程
     private transient Node firstWaiter;
     private transient Node lastWaiter;
     
     @Override
     public final void await() throws InterruptedException {
         if (Thread.interrupted()) {
             throw new InterruptedException();
         }
         // 创建一个类型为 CONDITION 类型的Node 节点,将其放入条件队列末尾
         Node node = addConditionWaiter();
         // 释放锁
         int savedState = fullyRelease(node);
         int interruptMode = 0;
         // 调用 park 阻塞 当前线程
         while (!isOnSyncQueue(node)) {
             LockSupport.park(this);
             if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                 break;
         }
         // ...
     }
     private Node addConditionWaiter() {
         // 拿到最后一个结点
         Node t = lastWaiter;
         // 如果最后一个节点被取消了，请清理.
         if (t != null && t.waitStatus != Node.CONDITION) {
             unlinkCancelledWaiters();
             t = lastWaiter;
         }
         // 先创建结点
         Node node = new Node(Thread.currentThread(), Node.CONDITION);
         if (t == null)
             // 最后一个结点为空，则让其成为第一个
             firstWaiter = node;
         else
             // 最后一个结点不为空，则让其下一个成为最后一个
             t.nextWaiter = node;
         lastWaiter = node;
         return node;
     }
     
     public final void signal() {
         if (!isHeldExclusively())
             throw new IllegalMonitorStateException();
         Node first = firstWaiter;
         if (first != null)
             // 将条件对列头元素移动到AQS队列
             doSignal(first);
     }
 }
```



大概认识了AQS的结构分析后

了解到

1，当多个线程调用lock.lock()方法时，只会有一个线程拿的到锁，其他的线程会转换为Node进入AQS阻塞队列中，并做CAS自旋尝试获取锁

2，当拿到锁的线程调用condition.await方法时，会释放锁，并转换成 Node 节点进入对应的条件变量的 条件队列中

3，这个时候因为调用lock.lock方法而进入阻塞队列的线程中会有一个拿到锁，然后去获取资源

4，当了另一个线程调用条件变量的signal方法时，就会把该条件变量中的条件队列里的一个或者全部Node结点移动到AQS阻塞队列中

> 了解其结构，也就是理解其核心思想，了解其运作原理





## 资源的获取与释放

前面有提到AQS同步的关键在于，state值的操作

影响同步的关键就是获取和释放以及修改，AQS获取资源的方式分两种方式：独占/共享



### 两模式的区别

1， 独占模式即当锁被某个线程成功获取时，其他线程无法获取到该锁，共享模式即当锁被某个线程成功获取时，其他线程仍然可能获取到该锁。

独占：同一时间只有一个线程能拿到锁执行，锁的状态只有0和1两种情况。

> - 公平锁：按照线程在队列中的排队顺序，先到者先拿到锁
> - 非公平锁：当线程要获取锁时，无视队列顺序直接去抢锁，谁抢到就是谁的

共享： 同一时间有多个线程可以拿到锁协同工作，锁的状态大于或等于0。

> 如Semaphore/CountDownLatch。Semaphore、CountDownLatCh、 CyclicBarrier、ReadWriteLock 



> 要想研究具体怎么执行，需要找到具体的子类实现，因为AQS没有提供对应的方法

不同的自定义同步器争用共享资源的方式也不同。

自定义同步器在实现时只需要实现共享资源 state 的获取与释放方式即可，至于具体线程等待队列的维护(如获取资源失败入队/唤醒出队等)，AQS已经在上层已经帮我们实现好了。



### 独占方式流程

#### 获取独占资源

```java
/**
     * 以独占模式获取(资源)，忽略中断
     */
public final void acquire(int arg) {
  // 尝试获取资源，具体就是设置状态 state
  if (!tryAcquire(arg) &&
      // 如果失败了就会去创建一个EXCLUSIVE的Node结点，插入AQS阻塞队列
      acquireQueued(addWaiter(Node.EXCLUSIVE), arg)) {
    // 自我中断
    selfInterrupt();
  }
}
```



1，首先调用tryAcquire方法，调用此方法的线程会试图在独占模式下获取对象状态。此方法应该查询是否允许它在独占模式下获取对象状态，如果允许，则获取它。如果不允许， 在AbstractQueuedSynchronizer源码中默认会抛出一个异常，即需要子类去重写此方法完成自己的逻辑

> tryAcquire默认实现是抛出异常

2，若tryAcquire失败，则调用addWaiter方法，addWaiter方法完成的功能是将调用此方法的线程封装成为一个结点并放入Sync queue。

```java
private Node addWaiter(Node mode) {
    // 以当前线程构建Node结点
    Node node = new Node(Thread.currentThread(), mode);
    // 拿到链表尾部结点
    Node pred = tail;
    // 直接CAS天添加到尾部
    if (pred != null) {
        node.prev = pred;
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    // 上一步直接添加失败则走enq 的流程，会在后续AQSQ入队操作中解释该方法
    enq(node);
    return node;
}
```

3，调用acquireQueued方法，此方法完成的功能是Sync queue中的结点不断尝试获取资源，若成功，则返回true，否则，返回false。

```java
final boolean acquireQueued(final Node node, int arg) {
    //标记是否成功拿到资源 TRUE：失败 / FALSE: 成功
    boolean failed = true;
    try {
        //标记等待过程中是否被中断过
        boolean interrupted = false;
        // 一直自旋获取资源
        for (;;) {
            // 拿到上一个线程节点
            final Node p = node.predecessor();
            //如果前驱是head，即该结点已成老二，那么便有资格去尝试获取资源（可能是老大释放完资源唤醒自己的，当然也可能被interrupt了）
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // GC回收 setHead 方法中已经将前驱置为null了
                failed = false; // 标记成功拿到资源
                return interrupted;
            }
            //如果自己可以休息了，就通过park()进入waiting状态，直到被unpark()。如果不可中断的情况下被中断了，那么会从park()中醒过来，发现拿不到资源，从而继续进入park()等待。
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                //如果等待过程中被中断过，哪怕只有那么一次，就将interrupted标记为true
                interrupted = true;
        }
    } finally {
        // 如果等待过程中没有成功获取资源（如timeout，或者可中断的情况下被中断了），那么取消结点在队列中的等待。
        if (failed)
            cancelAcquire(node);
    }
}
```



#### 释放独占资源

```java
public final boolean release(int arg) {
    // 尝试释放资源，也就是设置state值
    if (tryRelease(arg)) {
        Node h = head;
        // 释放成功就调用 unpark 方法，唤醒 AQS 阻塞队列中的一个线程
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}
```



注意

我们都知道，同步是建立在对state的值操作上，修改的操作都在 `tryRelease`和`tryAcquire`方法中进行，但是AQS没有提供，其实需要具体的子类来实现

state 的修改都是使用 CAS 算法尝试修改的



### 共享方式流程

获取共享资源

```java
public final void acquireShared(int arg) {
    if (tryAcquireShared(arg) < 0)
        doAcquireShared(arg);
}
```

释放共享资源

```java
public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        // 成功则唤醒AQS阻塞队列中的一个线程，被唤醒的会查看当前状态变量 state 是否满足要去，满足继续执行，不满足则挂起
        doReleaseShared();
        return true;
    }
    return false;
}
```

注意

`tryAcquireShared` `tryReleaseShared` AQS也没有提供



### Interruptibly关键字

独占模式下，对应额方法中还有些方法带Interruptibly的，带这个关键字说明会对打断进行响应









## AQS入队操作

讲解了两个模式中的资源的获取与实现，都涉及到AQS阻塞队列的入队操作，拿不到资源的时候，都是被纳入阻塞队列中

那么入队是怎么执行的呢？

走读源码发现，最终发现入队操作在 `enq` 方法中执行

```java
private Node enq(final Node node) {
    for (;;) {
        // 指向 尾部结点
        Node t = tail;
        if (t == null) { // Must initialize
            // 如果为null，则使用CAS 设置 一个哨兵结点 为 头结点
            if (compareAndSetHead(new Node()))
                // 然后将尾结点也指向头结点，设置完后进入下一个循环
                tail = head;
        } else {
            // 前驱结点 设置为 尾结点
            node.prev = t;
            // CAS  设置 尾结点为 node
            if (compareAndSetTail(t, node)) {
                // 这个时候t就在node 的前一个
                t.next = node;
                return t;
            }
        }
    }
}
```







## AQS有哪些锁的实现

常见的有 ReentrantReadWriteLock、ReentrantLock

打开源码，展开AbstractQueuedSynchronizer 的 子类，都是 Sync内部类 来继承实现的，并不是由ReentrantLock等这些类直接实现



总结

分析下来，感觉AQS围绕着其阻塞队列而运行着的，什么时候进阻塞队列，什么时候进条件队列，激活条件，什么时候激活，什么时候阻塞

也就是AQS对于同步的控制



## AQS 中设计模式

模板方法模式：简单概括是某些操作可以统一，但是某些操作却因子类的不同而具备不同的实现，比如AQS中锁的实现。

> 以ReentrantLock为例，state初始化为0，表示未锁定状态。A线程lock()时，会调用tryAcquire()独占该锁并将state+1。此后，其他线程再tryAcquire()时就会失败，直到A线程unlock()到state=0(即释放锁)为止，其它线程才有机会获取该锁。当然，释放锁之前，A线程自己是可以重复获取此锁的(state会累加)，这就是可重入的概念。

在实现了AQS的类中，需要实现某些方法

```JAVA
isHeldExclusively()//该线程是否正在独占资源。只有用到condition才需要去实现它。
tryAcquire(int)//独占方式。尝试获取资源，成功则返回true，失败则返回false。
tryRelease(int)//独占方式。尝试释放资源，成功则返回true，失败则返回false。
tryAcquireShared(int)//共享方式。尝试获取资源。负数表示失败；0表示成功，但没有剩余可用资源；正数表示成功，且有剩余资源。
tryReleaseShared(int)//共享方式。尝试释放资源，成功则返回true，失败则返回false。
```

这些方法的实现必须是内部线程安全的，并且通常应该简短而不是阻塞。AQS类中的其他方法都是final ，所以无法被其他类使用，只有这几个方法可以被其他类使用。