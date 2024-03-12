# ThreadLocal的使用

基本测试使用代码

```java
public class ThreadLoaclDemo {
    static ThreadLocal<String> threadLocal = new ThreadLocal<>();
    static String test = "hello";
    public static void main(String[] args) {
        new Thread(() ->{
            threadLocal.set("hello threadLocal1");
            test += "1";
            System.out.println(threadLocal.get());
            System.out.println(test);
        }).start();

        new Thread(() ->{
            threadLocal.set("hello threadLocal2");
            test += "2";
            //threadLocal.remove(); 清除当前线程的本地内存中的 localVariable
            System.out.println(threadLocal.get());
            System.out.println(test);
        }).start();
    }
}

```



我们通常引出 `ThradLocal`，是考虑了这样的场景

> 在多线程处理共享变量时，都会存在着安全问题，，为了保证安全，通常会进行适当的同步操作
>
> 而同步的一般措施是：加锁
>
> 锁在保证着安全的同时，也会存在相关的效率和并发问题
>
> 那有没这样的变量，线程拿到后都是使用的自己的呢？



顺着这样的想法，很容易让人觉得，我们使用`ThreadLocal`，那么线程的本地变量就是存放在 `ThreadLocal `实例中，每个线程访问自己的变量，就是去 `ThreadLocal`通过当前线程实例拿到数据。

其实不是

线程的本地变量是存放在当前线程（调用线程）的 `threadlocals`中



通过源码，我们发现，Thread 类中有两个变量

```java
ThreadLocal.ThreadLocalMap threadLocals = null;

ThreadLocal.ThreadLocalMap inheritableThreadLocals = null;
```

默认情况下是为 `null`的，但是会在线程第一次调用 `ThradLocal`类的`set`或者`get`方法时，才会创建



先分析 `set`  、`get`、  `remove`方法

```java
public T get() {
    // 获取当前线程
    Thread t = Thread.currentThread();
    // 拿到当前用户线程的 threadLocalMap threadLocals
    ThreadLocalMap map = getMap(t);
    // 如果 threadLocals 不为空
    if (map != null) {
        // 从threadLocals中拿到当前线程本地变量中的值
        // key 是 当前 ThreadLocal 实例
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            T result = (T)e.value;
            return result;
        }
    }
    // threadLocals 为空，则初始化当前线程的threadLocals成员变量
    return setInitialValue();
}
```

--

```java
private T setInitialValue() {
    // 初始化为 null
    T value = initialValue();
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        map.set(this, value);
    } else {
        createMap(t, value);
    }
    return value;
}
```



通过源码发现，首先是获取当前线程，在用当前线程去调用`getMap`方法，去获取当前线程自己的变量（`threadlocal`）,其被绑定到了线程的成员变量上

```java
ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}
```

再看`set`，源码也类似

```java
public void set(T value) {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        // 424 行
        // 将值存入 threadlocals 中
        map.set(this, value);
    } else {
        createMap(t, value);
    }
}
```

`remove`方法就是将 当前线程的 `threadlocals` 中的 `ThreadLocal`实例移除

```java
public void remove() {
    ThreadLocalMap m = getMap(Thread.currentThread());
    if (m != null) {
        m.remove(this);
    }
}
```



通过这三个方法可以知道，其实 `ThreadLocal` 充当着的是一个工具类的作用

其并没有去过多的操控本类中的元素

而是变相的去使用当前线程中的 `threadlocals`

他调用 `set` 方法，将value 存入 调用线程的`threadlocals`中，调用 `get`方法取出来

如果调用线程一直不终止，那么存在`threadlocals`中的变量一直不会移除，这样就会有内存溢出的可能，所以适用后需要调用 `ThreadLocal`中的`remove`方法删除对应线程的 `threadlocals`中的本地变量



> 为何是map结构呢？
>
> 因为每个线程不止一个 ThreadLocal 变量

 

`ThreadLocal`也有一个短板，那就是 父子线程中无法使用 `ThreadLocal`共享

> 觉得这也不是 `ThreadLocal` 的短板，因为`ThreadLocal`，操作都是建立在当前线程



那么 `InheritableThreadLocal`因运而生

源码中就只有三个方法，也就是 重写的`ThreadLocal`的三个方法

```java
public class InheritableThreadLocal<T> extends ThreadLocal<T> {
    protected T childValue(T parentValue) {
        return parentValue;
    }
    /**
     * 获取也是 inheritableThreadLocals
     */
    ThreadLocalMap getMap(Thread t) {
       return t.inheritableThreadLocals;
    }
    /**
     * 重写 createMap 方法，创建的不再是 threadlocals 而是 inheritableThreadLocals
     */
    void createMap(Thread t, T firstValue) {
        t.inheritableThreadLocals = new ThreadLocalMap(this, firstValue);
    }
}
```

要想了解 `InheritableThreadLocal` 是如何让子线程访问父线程变量时，需要从`Thread` 的构造方法开始

```java
public Thread(Runnable target) {
    init(null, target, "Thread-" + nextThreadNum(), 0);
}
```

追踪

```java
/** 使用当前AccessControlContext初始化线程。*/
private void init(ThreadGroup g, Runnable target, String name,
                  long stackSize) {
    init(g, target, name, stackSize, null, true);
}
```

追踪

```java
private void init(ThreadGroup g, Runnable target, String name,
                  long stackSize, AccessControlContext acc,
                  boolean inheritThreadLocals) {
    if (name == null) {
        throw new NullPointerException("name cannot be null");
    }

    this.name = name;
    // 获取当前线程
    Thread parent = currentThread();
	/* 部分代码省略 */
    /*开始进入父子线程部分*/
    if (inheritThreadLocals && parent.inheritableThreadLocals != null) {
        // 如果父线程的 inheritableThreadLocals 不为空
        // 那就设置子线程中的 inheritableThreadLocals 变量
        // 使用父线程的 inheritableThreadLocals 作为构造函数，创建一个新的 ThreadLocalMap 变量，赋值给子线程的 inheritableThreadLocals
        this.inheritableThreadLocals =
            ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
    }
    this.stackSize = stackSize;
    tid = nextThreadID();
}
```

追踪 `createInheritedMap`

```java
static ThreadLocalMap createInheritedMap(ThreadLocalMap parentMap) {
    return new ThreadLocalMap(parentMap);
}
```

再进`ThreadLocalMap`看看是怎么通过父线程的`ThreadLocalMap`构造的

```java
/**
* 构造一个新映射，其中包含来自给定父映射的所有可继承ThreadLocals
* 仅由createInheritedMap调用
*/
private ThreadLocalMap(ThreadLocalMap parentMap) {
    // 获取实体
    Entry[] parentTable = parentMap.table;
    // 获取数量
    int len = parentTable.length;
    setThreshold(len);
    table = new Entry[len];
    // 复制，再封装
    for (int j = 0; j < len; j++) {
        Entry e = parentTable[j];
        if (e != null) {
            @SuppressWarnings("unchecked")
            ThreadLocal<Object> key = (ThreadLocal<Object>) e.get();
            if (key != null) {
                // 这里就是调用 InheritableThreadLocal 重写的childValue方法
                Object value = key.childValue(e.value);
                Entry c = new Entry(key, value);
                int h = key.threadLocalHashCode & (len - 1);
                while (table[h] != null) {
                    h = nextIndex(h, len);
                }
                table[h] = c;
                size++;
            }
        }
    }
}
```

这下就知道了

当父线程创建子线程时，构造函数会把父线程中的 `inheritableThreadLocals` 的本地变量复制一份，保存在子线程中的 `inheritableThreadLocals`中



> inheritableThreadLocals 的使用场景
>
> 子线程需要使用父线程中存放的用户登录信息
>
> 中间件需要把统一的id追踪的整个调用链路记录
>
> 《java并发编程之美》
