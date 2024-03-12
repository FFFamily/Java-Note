# LongAdder原理

LongAdder 类有几个关键域

```java
// 累加单元数组, 懒惰初始化
transient volatile Cell[] cells;
// 基础值, 如果没有竞争, 则用 cas 累加这个域
transient volatile long base;
// 在 cells 创建或扩容时, 置为 1, 表示加锁
transient volatile int cellsBusy;
```



## cas锁

```java
public class LockCas {
    // 相当于自定义了一个约束
    // 0 代表释放锁 1 代表加锁
    private AtomicInteger state = new AtomicInteger(0);
    public void lock() {
        while (true) {
            // 在资源没有加锁的情况，肯定是能修改成功的
            // 但是如果有其他的线程修改了（占有了锁），那就需要循环等待
            // 这样是不好的，使得cpu的压力很大
            if (state.compareAndSet(0, 1)) {
                break;
            }
        }
    }
    public void unlock() {
        log.debug("unlock...");
        state.set(0);
    }
}
```

