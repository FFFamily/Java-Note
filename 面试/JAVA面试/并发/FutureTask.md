研究 `FutureTaask` 中穿插的问题

- 和 `Future` 相比有什么不同

> 这个问题问的有问题，Future 只是一个顶层父类，定义了这种异步任务的一些通用行为，并不能用 FutureTask 和 Future 做比较，只能说 FutureTask 的实现方式有啥不同（和其他的 Future 相比）

## 概念

- FutureTask代表了一个可被取消的异步计算任务，该类实现了Future接口，比如提供了启动和取消任务、查询任务是否完成、获取计算结果的接口。
- FutureTask任务的结果只有当任务完成后才能获取，并且只能通过get系列方法获取，当结果还没出来时，线程调用get系列方法会被阻塞。
- 另外，一旦任务被执行完成，任务将不能重启，除非运行时使用了runAndReset方法。
- FutureTask中的任务可以是Callable类型，也可以是Runnable类型（因为FutureTask实现了Runnable接口）, FutureTask类型的任务可以被提交到线程池执行。



## 如何使用

- 直接 `new` 构造，调用相关的API

```java
public  static  void  main(String[]  args)  throws  InterruptedException,ExecutionException {
  long start = System.currentTimeMillis();
  // 1．创建future任务
  FutureTask<String> futureTask = new FutureTask<String>(() -> {
    return doSomethingA();;
  });
  // 2．开启异步单元执行任务A
  Thread thread = new Thread(futureTask, "threadA");
  thread.start();
  // 3．执行任务B
  String taskBResult = doSomethingB();
  // 4．同步等待线程A运行结束
  String taskAResult = futureTask.get();
  // 5．打印两个任务执行结果
  System.out.println(taskAResult + " " + taskBResult);
  System.out.println(System.currentTimeMillis() - start);
}
```

- 抛给线程池执行

```java
public static void main(String[] args) throws InterruptedException,ExecutionException {
  long start = System.currentTimeMillis();
  // 1．开启异步单元执行任务A
  Future<String> futureTask = POOL_EXECUTOR.submit(() -> {return  doSomethingA();});
  // 2．执行任务B
  String taskBResult = doSomethingB();
  // 3．同步等待线程A运行结束
  String taskAResult = futureTask.get();
  // 4．打印两个任务执行结果
  System.out.println(taskAResult + " " + taskBResult);
  System.out.println(System.currentTimeMillis() - start);
}
```



## 原理

### 继承关系

FutureTask实现了Future接口的所有方法，并且实现了Runnable接口，所以其是可执行任务，可以投递到线程池或者线程来执行。

### 类变量

● FutureTask中变量**state**是一个使用volatile关键字修饰的int类型，用来记录任务状态

> 用来解决多线程下内存不可见问题，具体可以参考《Java并发编程之美》

● 类图中outcome是任务运行的结果，可以通过get系列方法来获取该结果。另外，outcome这里没有被修饰为volatile，是因为变量state已经被volatile修饰了，这里是借用volatile的内存语义来保证写入outcome时会把值刷新到主内存，读取时会从主内存读取，从而避免多线程下内存不可见问题

**==没明白==**

> 可以参考《Java并发编程之美》

● 类图中runner变量，记录了运行该任务的线程，这个是在FutureTask的run方法内使用CAS函数设置的。

● 类图中waiters变量是一个WaitNode节点，是用Treiber stack实现的无锁栈，栈顶元素用waiters代表。栈用来记录所有等待任务结果的线程节点，



另外，FutureTask中使用了UNSAFE机制来操作内存变量

```java
private static final sun.misc.Unsafe UNSAFE;

private static final long stateOffset; //state变量的偏移地址
private static final long runnerOffset; //runner变量的偏移地址
private static final long waitersOffset; //waiters变量的偏移地址
static {
  try {
    //获取UNSAFE的实例
    UNSAFE = sun.misc.Unsafe.getUnsafe();
    Class<? > k = FutureTask.class;
    //获取变量state的偏移地址
    stateOffset = UNSAFE.objectFieldOffset
      (k.getDeclaredField("state"));
    //获取变量runner的偏移地址
    runnerOffset = UNSAFE.objectFieldOffset
      (k.getDeclaredField("runner"));
    //获取变量waiters变量的偏移地址
    waitersOffset = UNSAFE.objectFieldOffset
      (k.getDeclaredField("waiters"));
  } catch (Exception e) {
    throw new Error(e);
  }
}
```



### 构造函数

```java
public FutureTask(Callable<V> callable) {
  if (callable == null)
    throw new NullPointerException();
  this.callable = callable;
  this.state = NEW;
}
```

构造函数内保存了传递到callable任务的callable变量，并且将任务状态设置为NEW，这里由于state为volatile修饰，所以写入state的值可以保证callable的写入也会被刷入主内存，以避免多线程下内存不可见问题



### 执行流程

当我们创建一个FutureTask时，其任务状态初始化为NEW，当我们把任务提交到线程或者线程池后，会有一个线程来执行该FutureTask任务，具体是调用其run方法来执行任务。在任务执行过程中，我们可以在其他线程调用FutureTask的get()方法来等待获取结果，如果当前任务还在执行，则调用get的线程会被阻塞然后放入FutureTask内的阻塞链表队列；多个线程可以同时调用get方法，这些线程可能都会被阻塞并放到阻塞链表队列中。当任务执行完毕后会把结果或者异常信息设置到outcome变量，然后会移除和唤醒FutureTask内阻塞链表队列中的线程节点，进而这些由于调用FutureTask的get方法而被阻塞的线程就会被激活。



## 常用API

### run 方法

- 是如何运行？又是怎么存储结果？

该方法是任务的执行体，线程是调用该方法来具体运行任务的，如果任务没有被取消，则该方法会运行任务，并且将结果设置到outcome变量中

```java
public void run() {
  //1．如果任务不是初始化的NEW状态，或者使用CAS设置runner为当前线程失败，则直接返回
  if (state ! = NEW ||
      !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                   null, Thread.currentThread()))
    return;
  //2．如果任务不为null，并且任务状态为NEW，则执行任务
  try {
    Callable<V> c = callable;
    if (c ! = null && state == NEW) {
      V result;
      boolean ran;
      //2.1执行任务，如果OK则设置ran标记为true
      try {
        result = c.call();
        ran = true;
      } catch (Throwable ex) {
        //2.2执行任务出现异常，则标记false，并且设置异常
        result = null;
        ran = false;
        setException(ex);
      }
      //3．任务执行正常，则设置结果
      if (ran)
        set(result);
    }
  } finally {

    runner = null;
    int s = state;
    //4．为了保证调用cancel(true)的线程在该run方法返回前中断任务执行的线程
    if (s >= INTERRUPTING)
      handlePossibleCancellationInterrupt(s);
  }
}

private void handlePossibleCancellationInterrupt(int s) {
  //为了保证调用cancel在该run方法返回前中断任务执行的线程
  //这里使用Thread.yield()让run方法执行线程让出CPU执行权，以便让
  //cancel(true)的线程执行cancel(true)中的代码中断任务线程
  if (s == INTERRUPTING)
    while (state == INTERRUPTING)
      Thread.yield(); // wait out pending interrupt
}
```

代码1，如果任务不是初始化的NEW状态，或者使用CAS设置runner为当前线程失败，则直接返回；这个可以防止同一个FutureTask对象被提交给多个线程来执行，导致run方法被多个线程同时执行造成混乱。● 代码2，如果任务不为null，并且任务状态为NEW，则执行任务，其中代码2.1调用c.call()具体执行任务，如果任务执行OK，则调用set方法把结果记录到result，并设置ran为true；如果执行任务过程中抛出异常则设置result为null,ran为false，并且调用setException设置异常信息后，任务就处于终止状态，其中setException代码如下：

```java
        protected void setException(Throwable t) {
            //2.2.1
            if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
                outcome = t;
                UNSAFE.putOrderedInt(this, stateOffset, EXCEPTIONAL); // final state
                //2.2.1.1
                finishCompletion();
            }
        }
```

由上述代码可知，使用CAS尝试设置任务状态state为COMPLETING，如果CAS成功，则把异常信息设置到outcome变量，并且设置任务状态为EXCEPTIONAL终止状态，然后调用finishCompletion



```java
        private void finishCompletion() {
            //a遍历链表节点
            for (WaitNode q; (q = waiters) ! = null; ) {
                //a.1 CAS设置当前waiters节点为null
                if (UNSAFE.compareAndSwapObject(this, waitersOffset, q, null)) {
                    //a.1.1
                    for (; ; ) {
                        //唤醒当前q节点对应的线程
                            Thread t = q.thread;
                            if (t ! = null) {
                                q.thread = null;
                                LockSupport.unpark(t);
                            }
                            //获取q的下一个节点
                            WaitNode next = q.next;
                            if (next == null)
                                break;
                            q.next = null; //help gc
                            q = next;
                        }
                        break;
                    }
                }
                // b所有阻塞的线程都被唤醒后，调用done方法
                done();

                callable = null;         // callable设置为null
            }
```

上述代码比较简单，即当任务已经处于终态后，激活waiters链表中所有由于等待获取结果而被阻塞的线程，并从waiters链表中移除它们，等所有由于等待该任务结果的线程被唤醒后，调用done()方法，done默认实现为空实现。上面我们讲了当任务执行过程中出现异常后的处理方法，下面我们看下代码3，了解当任务是正常执行完毕后set(result)的实现

```java
        protected void set(V v) {
            //3.1
            if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
                outcome = v;
                UNSAFE.putOrderedInt(this, stateOffset, NORMAL); // final state
                finishCompletion();
            }
        }
```

如代码3.1所示，使用CAS尝试设置任务状态state为COMPLETING，如果CAS成功，则把任务结果设置到outcome变量，并且将任务状态设置为NORMAL终止状态，然后调用finishCompletion唤醒所有因为等待结果而被阻塞的线程



### get 方法

等待异步计算任务完成，并返回结果；如果当前任务计算还没完成则会阻塞调用线程直到任务完成；如果在等待结果的过程中有其他线程取消了该任务，则调用线程会抛出CancellationException异常；如果在等待结果的过程中有线程中断了该线程，则抛出InterruptedException异常；如果任务计算过程中抛出了异常，则会抛出Execution-Exception异常

```
        public V get() throws InterruptedException, ExecutionException {
            //1．获取状态，如有需要则等待
            int s = state;
            if (s <= COMPLETING)
                //等待任务终止
                s = awaitDone(false, 0L);
            //2．返回结果
            return report(s);
        }
```

如代码1所示，获取任务的状态，如果任务状态的值小于等于COMPLETING，则说明任务还没有完成，所以调用awaitDone挂起调用线程。● 代码2表示如果任务已经完成，则返回结果。下面我们来看awaitDone方法实现：

```
        private int awaitDone(boolean timed, long nanos)
            throws InterruptedException {
            //1.1超时时间
            final long deadline = timed ? System.nanoTime() + nanos : 0L;
            WaitNode q = null;
            boolean queued = false;
            //1.2 循环，等待任务完成
            for (; ; ) {
                //1.2.1任务被中断，则移除等待线程节点，抛出异常
                if (Thread.interrupted()) {
                    removeWaiter(q);
                    throw new InterruptedException();
                }
                //1.2.2 任务状态>COMPLETING说明任务已经终止
    int s = state;
    if (s > COMPLETING) {
        if (q ! = null)
            q.thread = null;
        return s;
    }
    //1.2.3任务状态为COMPLETING
    else if (s == COMPLETING) // cannot time out yet
        Thread.yield();
    //1.2.4为当前线程创建节点
    else if (q == null)
        q = new WaitNode();
    //1.2.5 添加当前线程节点到链表
    else if (! queued)
        queued = UNSAFE.compareAndSwapObject(this, waitersOffset,
                                            q.next = waiters, q);
    //1.2.6 设置了超时时间
    else if (timed) {
        nanos = deadline - System.nanoTime();
        if (nanos <= 0L) {
            removeWaiter(q);
            return state;
        }
        LockSupport.parkNanos(this, nanos);
    }
    //1.2.7没有设置超时时间
    else
        LockSupport.park(this);
}
}
```

 代码1.1获取设置的超时时间，如果传递的timed为false说明没有设置超时时间，则deadline设置为0。● 代码1.2无限循环等待任务完成，其中代码1.2.1表示如果发现当前线程被中断，则从等待链表中移除当前线程对应的节点（如果队列里面有该节点的话），然后抛出InterruptedException异常；代码1.2.2表示如果发现当前任务状态大于COMPLETING，说明任务已经进入了终态（可能是NORMAL、EXCEPTIONAL、CANCELLED、INTERRUPTED中的一种），则把执行任务的线程的引用设置为null，并且返回结果。● 代码1.2.3表示如果当前任务状态为COMPLETING，说明任务已经接近完成了，只有结果还未设置到outCome中，则这时让当前线程放弃CPU执行，意在让任务执行线程获取到CPU从而将任务状态从COMPLETING转换到终态NORMAL，这样可以避免当前调用get系列方法的线程被挂起，然后再被唤醒的开销。● 代码1.2.4表示如果当前q为null，则创建一个与当前线程相关的节点，代码1.2.5表示如果当前线程对应节点还没放入waiters管理的等待列表，则使用CAS操作放入。● 代码1.2.6表示如果设置了超时时间则使用LockSupport.parkNanos(this,nanos)让当前线程挂起deadline时间，否则会调用“LockSupport.park(this); ”让线程一直挂起直到其他线程调用了unpark方法，并且以当前线程为参数（比如finishCompletion()方法）。



### cancel 方法

尝试取消任务的执行，如果当前任务已经完成或者任务已经被取消了，则尝试取消任务会失败；如果任务还没被执行时调用了取消任务，则任务将永远不会被执行；如果任务已经开始运行了，这时取消任务，则由参数mayInterruptIfRunning决定是否要将正在执行任务的线程中断，如果为true则标识要中断，否则标识不中断。当调用取消任务后，再调用isDone()方法，后者会返回true，随后调用isCancelled()方法也会一直返回true；如果任务不能被取消，比如任务已经完成了，任务已经被取消了，则该方法会返回false

```
        public boolean cancel(boolean mayInterruptIfRunning) {
            //1．如果任务状态为New则使用CAS设置任务状态为INTERRUPTING或者CANCELLED
            if (! (state == NEW &&
                  UNSAFE.compareAndSwapInt(this, stateOffset, NEW,
                          mayInterruptIfRunning ? INTERRUPTING : CANCELLED)))
                    return false;
                //2．如果设置了中断正常执行任务线程，则中断
                try {
                    if (mayInterruptIfRunning) {
                        try {
                            Thread t = runner;
                            if (t ! = null)
                                t.interrupt();
                        } finally { // final state
                            UNSAFE.putOrderedInt(this, stateOffset, INTERRUPTED);
                        }
                    }
                } finally {
                    //3．移除并激活所有因为等待结果而被阻塞的线程
                    finishCompletion();
                }
                return true;
            }
```

● 如代码1所示，如果任务状态为New则使用CAS设置任务状态为INTERRUPTING或者CANCELLED，如果mayInterruptIfRunning设置为true，说明要中断正在执行任务的线程，则使用CAS设置任务状态为INTERRUPTING，否则设置为CANCELLED；如果CAS失败则直接返回false。● 如果CAS成功，则说明当前任务状态已经为INTERRUPTING或者CANCELLED，如果mayInterruptIfRunning为true则中断执行任务的线程，然后设置任务状态为INTERRUPTED。● 最后代码3移除并激活所有因为等待结果而被阻塞的线程。





之后  complateFuture 对于 FutureTask 的区别

FutureTask虽然提供了用来检查任务是否执行完成、等待任务执行结果、获取任务执行结果的方法，但是这些特色并不足以让我们写出简洁的并发代码，比如它并不能清楚地表达多个FutureTask之间的关系。另外，为了从Future获取结果，我们必须调用get()方法，而该方法还是会在任务执行完毕前阻塞调用线程，这明显不是我们想要的。我们真正想要的是：● 可以将两个或者多个异步计算结合在一起变成一个，这包含两个或者多个异步计算是相互独立的情况，也包含第二个异步计算依赖第一个异步计算结果的情况。● 对反应式编程的支持，也就是当任务计算完成后能进行通知，并且可以以计算结果作为一个行为动作的参数进行下一步计算，而不是仅仅提供调用线程以阻塞的方式获取计算结果。● 可以通过编程的方式手动设置（代码的方式）Future的结果；FutureTask不能实现让用户通过函数来设置其计算结果，而是在其任务内部来进行设置。● 可以等多个Future对应的计算结果都出来后做一些事情。为了克服FutureTask的局限性，以及满足我们对异步编程的需要，JDK8中提供了CompletableFuture。