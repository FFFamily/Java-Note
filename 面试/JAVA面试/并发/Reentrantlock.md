# Reentrantlock分析

> 可重入、可打断
>
> 公平锁和非公平锁的原理



带着问题分析源码



## **什么是可重入，什么是可重入锁? 它用来解决什么问题?**

个人理解为：可重入是可以同一个事物可以重复访问

可重入锁：同一线程可以重复对同一个对象加锁，而不会出现死锁，可重入锁主要用在线程需要多次进入临界区代码时，需要使用可重入锁。

加锁时，需要判断锁是否已经被获取。如果已经被获取，则判断获取锁的线程是否是当前线程。如果是当前线程，则给获取次数加1。如果不是当前线程，则需要等待。



## **ReentrantLock的核心是AQS， 说说其类内部结构关系。**

ReentrantLock 有个内部类 Sync，其继承了AQS，并实现了对应的加锁和释放锁的方法`tryAcquire`  和   `tryRelease`

ReentrantLock  可重入锁的实现就是基于这个内部类

我们知道，AQS 是不提供加锁和释放锁的方法的，都是由子类提供实现。

同时，AQS的state状态信息，在ReentrantLock 中代表的是可重入次数，而Sync实现的方法就是去通过CAS操控state状态值，实现可重入锁。





## **ReentrantLock是如何实现公平锁的?**

`FairSync` 是 ReentrantLock 执行公平锁的类

由源码可知，加锁时实际执行 `acquire`

```java
final void lock() {
    acquire(1);
}
```

追进去，发现是执行的AQS中的  `acquire` 方法

```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        // tryAcquire 返回 false 会将线程放入阻塞队列中
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

加锁的具体逻辑体现在 `tryAcquire`  中，但是AQS不提供，而是由子类实现，使用`FairSync`调用的，那么也就是 `FairSync` 实现

```java
@Override
protected final boolean tryAcquire(int acquires) {
    // 当前线程
    final Thread current = Thread.currentThread();
    // 获取state值
    int c = getState();
    // 状态为0，可以加锁
    if (c == 0) {
        // hasQueuedPredecessors 保证公平，得先去阻塞队列中看是否有线程阻塞
        if (!hasQueuedPredecessors() &&
            compareAndSetState(0, acquires)) {
            // 设置当前线程为锁的持有者
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    // 加锁的是否为当前线程
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) {
            throw new Error("Maximum lock count exceeded");
        }
        setState(nextc);
        return true;
    }

    return false;
}
```

  了解过公平锁和非公平锁的实现，就会发现，公平锁的实现的核心代码就是 `hasQueuedPredecessors`，追进去

```java
public final boolean hasQueuedPredecessors() {
    Node t = tail; // Read fields in reverse initialization order
    Node h = head;
    Node s;
    // 第一个条件：若h==t，说明队列为空，返回false
    // 第二个条件：s=null 代表有一个元素要做为AQS的第一个结点入对列，这里需要了解AQS的enq方法，如果是第一个元素入队，是要先创建一个哨兵结点，然后是该元素
    // 第三个条件：s不为空，那就看s代表的线程是不是当前线程，则返回true
    return h != t &&
        ((s = h.next) == null || s.thread != Thread.currentThread());
}
```

分析理解就是

1，阻塞队列为空时，可以加锁

2，队列不为空，且是第一个结点入队列时，不可以加锁

3，阻塞队列中第一个元素不是当前线程，不可以加锁

> 这样就保证了公平性





## **ReentrantLock是如何实现非公平锁的?**

同样的，ReentrantLock 的锁操作是基于内部类`Sync`，其又有两个子类`FairSync` 和 `NonfairSync`，前者公平锁，后者非公平锁

研究ReentrantLock的锁，也就是研究这两个类的代码逻辑

刚刚讲完了公平的，非公平的其实区别仅仅体现在，`tryAcquire` 的方法实现

```java
final boolean nonfairTryAcquire(int acquires) {
    final Thread current = Thread.currentThread();
    int c = getState();
    if (c == 0) {
        // 对比公平锁，这里少了 hasQueuedPredecessors 方法
        // 这里就是谁先到这里，判断了为0，就可以通过CAS修改
        if (compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0) // overflow
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}
```



问题来了，非公平和公平到底怎么体现的呢？

非公平锁

A B两个线程，A 拿到锁，B去访问时阻塞，A使用玩了资源，释放了锁，并唤醒阻塞队列中阻塞线程B，但是这个时候又来了个C也去访问，比B先拿到了锁，B又得阻塞，这就是非公平锁，明明B等了那么久，但是C一来就拿到了

公平锁

A B两个线程，A 拿到锁，B去访问时阻塞，A使用玩了资源，释放了锁，并唤醒阻塞队列中阻塞线程B，但是这个时候又来了个C也去访问，C去拿锁时，得去先看阻塞队列里有没有阻塞线程，有就阻塞自己，这个时候B就能顺理成章的拿到锁了





## **ReentrantLock默认实现的是公平还是非公平锁?**

```java
/**
 * 构造方法，默认是非公平锁
 */
public ReentrantLock() {
    sync = new NonfairSync();
}

/**
 *
 */
public ReentrantLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
}
```



## **ReentrantLock和Synchronized的对比?**

> 来自[ReentrantLock和synchronized的区别 - 码年 - 博客园 (cnblogs.com)](https://www.cnblogs.com/yufengzhang/p/9443492.html)

**Java 5为了加强内置锁的功能，引入了可重入锁（ReentrantLock）。在此之前“synchronized”和“volatile”是实现并发的方式。**

Synchronized关键字使用内置锁（intrinsic lock）或者称作监视锁（monitor lock）。每一个Java对象都有一个内置锁与之相关联。无论什么时候，当一个线程尝试去访问一个synchronized代码块或者synchronized方法的时候，线程都需要首先获取到对象关联的内置锁。对于static方法，线程获取的是类对象的内置锁。

内置锁机制使得代码的书写非常整洁，并且大部分场合下功能也够用。所以为什么我们需要额外的去显式的创建锁？

内置锁机制在功能上有一些限制：

1. 不能中断（interrupt）一个正在等待获取锁的线程
2. 不能测试锁是否空闲从而不用一直等待锁
3. 锁获取和释放得在同一个代码块释中进行

ReentrantLock还支持对锁的测试，支持既可以被中断又可以设置超时。ReentrantLock还可以设置公平原则，允许更灵活的线程调度





## **ReentrantLock是如何实现重入的?**

可重入的关键也在 `tryAcquire` 代码中

```java
@Override
protected final boolean tryAcquire(int acquires) {
    // 省略部分代码
    // 加锁的是否为当前线程
    else if (current == getExclusiveOwnerThread()) {
        
        int nextc = c + acquires;
        // 小于0，说明可重入次数溢出了
        if (nextc < 0) {
            throw new Error("Maximum lock count exceeded");
        }
        // 状态值+1
        setState(nextc);
        return true;
    }

    return false;
}
```







## **ReentrantLock的打断逻辑?**

读源码的时候发现，有些方法，后面会有一些`Interruptibly`关键字，这代表着什么意思？

`lock`  和 `lockInterruptibly`

有这样的关键字，也就代表着会对打断做出响应，也就是说会有`InterruptedException` 异常

```java
@Override
public void lockInterruptibly() throws InterruptedException {
    sync.acquireInterruptibly(1);
}
```

走进去

```java
public final void acquireInterruptibly(int arg)
    throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    if (!tryAcquire(arg))
        doAcquireInterruptibly(arg);
}
```



额外

释放锁的流程

```java
public void unlock() {
    sync.release(1);
}
```

追

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

再追

```java
protected final boolean tryRelease(int releases) {
    int c = getState() - releases;
    // 修改的不是锁的持有者就报错
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    // c 为0就释放锁
    if (c == 0) {
        free = true;
        setExclusiveOwnerThread(null);
    }
    // 更新 state 的值
    setState(c);
    return free;
}
```





使用ReentrantLock实现安全的List

```java
public class ReentrantLockListDemo {
    private List<Integer> list = new ArrayList<>();
    private volatile ReentrantLock lock = new ReentrantLock();
    public void add(int num){
        lock.lock();
        try {
            list.add(num);
        }finally {
            lock.unlock();
        }
    }
}
```



总结

文章只是涉及ReentrantLock的加锁源码导读，其实，ReentrantLock的加锁，同样还需要访问AQS，因为在加锁时会有阻塞的问题，需要控制同步问题，这些都需要AQS阻塞队列的参与
