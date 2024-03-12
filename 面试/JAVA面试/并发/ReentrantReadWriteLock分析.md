# ReadWriteLock

如果使用 ReentrantLock，可能本身是为了防止线程 A 在写数据、线程 B 在读数据造成的数据不一致，但这样，如果线程 C 在读数据、线程 D 也在读据，读数据是不会改变数据的，没有必要加锁，但是还是加锁了，降低了程序的性能。

因为这个，才诞生了读写锁ReadWriteLock。

ReadWriteLock 是一个读写锁接口，读写锁是用来提升并发程序性能的锁分离技术，

ReentrantReadWriteLock 是 ReadWriteLock 接口的一个具体实现，实现了读写的分离，读锁是共享的，写锁是独占的，读和读之间不会互斥，读写、写和读、写和写之间才会互斥，提升了读写的性能。

而读写锁有以下三个重要的特性：

（1）公平选择性：支持非公平（默认）和公平的锁获取方式，吞吐量还是非公平优于公平。

（2）重进入：读锁和写锁都支持线程重进入。

（3）锁降级：遵循获取写锁、获取读锁再释放写锁的次序，写锁能够降级成为读锁。



# ReentrantReadWriteLock分析



带着问题分析

1，**为什么有了`ReentrantLock`还需要`ReentrantReadWriteLock`?**

`ReentrantLock` 是独占锁，业务中有时候有写少读多的额场景，如果是独占锁，一个线程占据所有的资源，那就会很影响效率



2，**ReentrantReadWriteLock底层实现原理?**

先是分析底层数据结构

ReentrantReadWriteLock底层是基于ReentrantLock和AbstractQueuedSynchronizer来实现的，所以，ReentrantReadWriteLock的数据结构也依托于AQS的数据结构

看 `ReentrantReadWriteLock` 的源码

```java
public class ReentrantReadWriteLock
    implements ReadWriteLock, java.io.Serializable {
    /** 读锁 */
    private final ReentrantReadWriteLock.ReadLock readerLock;
    /** 写锁 */
    private final ReentrantReadWriteLock.WriteLock writerLock;
}
```

Sync 其实就是 AQS 的子类，readerLock和writerLock的功能实现依赖于Sync

```java
public static class WriteLock implements Lock, java.io.Serializable {
	private final Sync sync;
}
```

--

```java
public static class ReadLock implements Lock, java.io.Serializable {
    private final Sync sync;
}
```

在我们使用`ReentrantReadWriteLock`进行锁的操作的时候，实际上都是使用的Sync，Sync实现了AQS的部分方法

我们知道加锁的原理，实际上就是对AQS的state的值的操作，不同的锁操作方式不一样

ReentrantReadWriteLock 有两个状态，一个读，一个写，怎么表达呢？

ReentrantReadWriteLock 采取的是高16位代表读锁，低16位代表写锁



同时，`sync` 也有两个内部类

```java
// 缓存计数器
// HoldCounter主要有两个属性，count和tid，其中count表示某个读线程重入的次数，tid表示该线程的tid字段的值，该字段可以用来唯一标识一个线程。
static final class HoldCounter {
    int count = 0;
    final long tid = getThreadId(Thread.currentThread());
}
// ThreadLocalHoldCounter重写了ThreadLocal的initialValue方法，ThreadLocal类可以将线程与对象相关联
// 在没有进行set的情况下，get到的均是initialValue方法里面生成的那个HolderCounter对象。

static final class ThreadLocalHoldCounter extends ThreadLocal<HoldCounter> {
    // 初始化就是对 调用线程初始化这个HoldCounter类，这样每个线程调用的都是自己的HoldCounter
    public HoldCounter initialValue() {
        return new HoldCounter();
    }
}
```



3，**读锁和写锁的最大数量是多少?**

观看源码

```java
static final int SHARED_SHIFT   = 16;
// 65536
static final int SHARED_UNIT    = (1 << SHARED_SHIFT);
// 共享线程最大个数 65535 也就是 2 的 16 次方 - 1
static final int MAX_COUNT      = (1 << SHARED_SHIFT) - 1;
static final int EXCLUSIVE_MASK = (1 << SHARED_SHIFT) - 1;

/** 返回读锁（共享）线程数 */
static int sharedCount(int c)    { return c >>> SHARED_SHIFT; }
/** 返回写锁的可重入次数 */
static int exclusiveCount(int c) { return c & EXCLUSIVE_MASK; }
```



4，**写锁的获取与释放是怎么实现的?**

写锁使用的是`wirtelock`

写锁是可重入的独占锁

看看加锁的代码

```java
public void lock() {
    sync.acquire(1);
}
```

追踪，来到AQS

```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        // 加锁失败则进入阻塞队列
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

加锁的逻辑在 `tryAcquire`

> 这里同样也要注意，看ReentrantReadWriteLock的源码，Sync也有两个子类，分别代表着公平锁和非公平锁
>
> 以公平的为例，非公平的只是少了一些判断，和ReentrantLock一致

```java
protected final boolean tryAcquire(int acquires) {
    // 获取当前线程
    Thread current = Thread.currentThread();
    // 获取状态
    int c = getState();
    // 写线程可重入数量
    int w = exclusiveCount(c);
    if (c != 0) {
        // 不为0，说明被其他线程使用
        if (w == 0 || current != getExclusiveOwnerThread()) {
            // w=0,说明有线程获取了读锁,并占用了所有的数量，返回false
            // w!=0 说明有线程获取了该锁，就去看看这个线程是不是自己，当前线程不是写锁的拥有者，那就返回false
            return false;
        }
        if (w + exclusiveCount(acquires) > MAX_COUNT) {
            throw new Error("Maximum lock count exceeded");
        }
        // 加锁
        setState(c + acquires);
        return true;
    }
    // writerShouldBlock 是实现公平和非公平的方法
    if (writerShouldBlock() ||
        !compareAndSetState(c, c + acquires)) {
        return false;
    }
    setExclusiveOwnerThread(current);
    return true;
}
```

释放

```java
public void unlock() {
    sync.release(1);
}
```

--

```java
protected final boolean tryRelease(int releases) {
    //  isHeldExclusively 看看读锁的持有者是不是该线程
    if (!isHeldExclusively()) {
        throw new IllegalMonitorStateException();
    }
    // 获取读锁的可重入值，没有考虑高16位，因为获取写的同时写锁的状态肯定为0
    int nextc = getState() - releases;
    boolean free = exclusiveCount(nextc) == 0;
    // 写锁的可重入值为0，则释放锁
    if (free) {
        setExclusiveOwnerThread(null);
    }
    setState(nextc);
    return free;
}
```





4，**读锁的获取与释放是怎么实现的?**

```java
public void lock() {
    sync.acquireShared(1);
}
```

进去

```java
protected final int tryAcquireShared(int unused) {
    //当前线程
    Thread current = Thread.currentThread();
    // 状态值
    int c = getState();
    // 如果写锁的可重入值不为0并且写锁的持有者不是当前线程
    // 也就是说，写锁被占有时不能加读锁
    if (exclusiveCount(c) != 0 &&
        getExclusiveOwnerThread() != current) {
        return -1;
    }
    // 获取读锁的重入数量
    int r = sharedCount(c);
    // readerShouldBlock 是公平和非公平的关键
    if (!readerShouldBlock() &&
        // 读锁的重入数小于最大值
        r < MAX_COUNT &&
        // CAS 修改状态
        compareAndSetState(c, c + SHARED_UNIT)) {
        if (r == 0) {
            // 如果读锁的重入数为0，说明之前没有使用读锁，那么将当前线程设置为第一个读锁持有者
            firstReader = current;
            firstReaderHoldCount = 1;
        } else if (firstReader == current) {
            // 如果又是当前线程拿到读锁
            firstReaderHoldCount++;
        } else {
            // 说明在当前线程前就有线程拿到读锁了
            HoldCounter rh = cachedHoldCounter;
            if (rh == null || rh.tid != getThreadId(current))
                cachedHoldCounter = rh = readHolds.get();
            else if (rh.count == 0)
                readHolds.set(rh);
            rh.count++;
        }
        return 1;
    }
    // 执行到这里还没有拿到读锁，只能自旋获取了，逻辑和tryAcquireShared方法差不多
    return fullTryAcquireShared(current);
}
```



锁降级

> 笔记来源于 [JUC锁: ReentrantReadWriteLock详解 | Java 全栈知识体系 (pdai.tech)](https://pdai.tech/md/java/thread/java-thread-x-lock-ReentrantReadWriteLock.html#什么是锁升降级)

锁降级指的是写锁降级成为读锁。

如果当前线程拥有写锁，然后将其释放，最后再获取读锁，这种分段完成的过程不能称之为锁降级。锁降级是指把持住(当前拥有的)写锁，再获取到读锁，随后释放(先前拥有的)写锁的过程。

接下来看一个锁降级的示例。因为数据不常变化，所以多个线程可以并发地进行数据处理，当数据变更后，如果当前线程感知到数据变化，则进行数据的准备工作，同时其他处理线程被阻塞，直到当前线程完成数据的准备工作，如代码如下所示：

```java
public void processData() {
    readLock.lock();
    if (!update) {
        // 必须先释放读锁
        readLock.unlock();
        // 锁降级从写锁获取到开始
        writeLock.lock();
        try {
            if (!update) {
                // 准备数据的流程(略)
                update = true;
            }
            readLock.lock();
        } finally {
            writeLock.unlock();
        }
        // 锁降级完成，写锁降级为读锁
    }
    try {
        // 使用数据的流程(略)
    } finally {
        readLock.unlock();
    }
}
```

上述示例中，当数据发生变更后，update变量(布尔类型且volatile修饰)被设置为false，此时所有访问processData()方法的线程都能够感知到变化，但只有一个线程能够获取到写锁，其他线程会被阻塞在读锁和写锁的lock()方法上。当前线程获取写锁完成数据准备之后，再获取读锁，随后释放写锁，完成锁降级。

锁降级中读锁的获取是否必要呢? 答案是必要的。主要是为了保证数据的可见性，如果当前线程不获取读锁而是直接释放写锁，假设此刻另一个线程(记作线程T)获取了写锁并修改了数据，那么当前线程无法感知线程T的数据更新。如果当前线程获取读锁，即遵循锁降级的步骤，则线程T将会被阻塞，直到当前线程使用数据并释放读锁之后，线程T才能获取写锁进行数据更新。

RentrantReadWriteLock不支持锁升级(把持读锁、获取写锁，最后释放读锁的过程)。目的也是保证数据可见性，如果读锁已被多个线程获取，其中任意线程成功获取了写锁并更新了数据，则其更新对其他获取到读锁的线程是不可见的

