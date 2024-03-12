大前提：

- JDK 中的 `Future` 并不是完全的异步，获取异步结果的同时是需要阻塞当前线程的，所以更像是 “同步非阻塞”，而非异步
- 新增的 `CompletableFuture ` 扩展了 `Future`，添加了回调的机制



`Netty` 中的 `Future` 是对 JDK 中的 `Future` 进行了一层封装，名为 ：`ChannelFuture`

Netty 自己实现的 Future 继承了 JDK 的 Future，新增了 `sync()` 和`await()` 用于阻塞等待，还加了 Listeners，只要任务结束去回调 Listener 就可以了，那么我们就不一定要主动调用 `isDone()`来获取状态，或通过 `get()`阻塞方法来获取值。

```java
public interface Future<V> extends java.util.concurrent.Future<V> {
  
  // 只有IO操作完成时才返回true
  boolean isSuccess();
  // 只有当cancel(boolean)成功取消时才返回true
  boolean isCancellable();
  // IO操作发生异常时，返回导致IO操作以此的原因，如果没有异常，返回null
  Throwable cause();
  // 向Future添加事件，future完成时，会执行这些事件，如果add时future已经完成，会立即执行监听事件
  Future<V> addListener(GenericFutureListener<? extends Future<? super V>> listener);
  Future<V> addListeners(GenericFutureListener<? extends Future<? super V>>... listeners);
  // 移除监听事件，future完成时，不会触发
  Future<V> removeListener(GenericFutureListener<? extends Future<? super V>> listener);
  Future<V> removeListeners(GenericFutureListener<? extends Future<? super V>>... listeners);
  // 等待future done
  Future<V> sync() throws InterruptedException;
  // 等待future done，不可打断
  Future<V> syncUninterruptibly();
  // 等待future完成
  Future<V> await() throws InterruptedException;
  // 等待future 完成，不可打断
  Future<V> awaitUninterruptibly();
  boolean await(long timeout, TimeUnit unit) throws InterruptedException;
  boolean await(long timeoutMillis) throws InterruptedException;
  boolean awaitUninterruptibly(long timeout, TimeUnit unit);
  boolean awaitUninterruptibly(long timeoutMillis);
  // 立刻获得结果，如果没有完成，返回null
  V getNow();
  // 如果成功取消，future会失败，导致CancellationException
  @Override
  boolean cancel(boolean mayInterruptIfRunning);
  
}
```

Promise 接口继承自 Future 接口，重点添加了以下几个方法，可以人工设置 future 的执行成功与失败，并通知所有监听的 listener。

```java
public interface Promise<V> extends Future<V> {
  // 设置future执行结果为成功
  Promise<V> setSuccess(V result);
  // 尝试设置future执行结果为成功,返回是否设置成功
  boolean trySuccess(V result);
  // 设置失败
  Promise<V> setFailure(Throwable cause);
  // 尝试设置future执行结果为失败,返回是否设置成功 
  boolean tryFailure(Throwable cause);
  // 设置为不能取消
  boolean setUncancellable();
  // 源码中，以下为覆盖了Future的方法，例如；
  Future<V> addListener(GenericFutureListener<? extends Future<? super V>> listener);
  @Override
  Promise<V> addListener(GenericFutureListener<? extends Future<? super V>> listener);
}
```

 Future 和 Promise 的好处在于，获取到 Promise 对象后可以为其设置异步调用完成后的操作，然后立即继续去做其他任务。

**那就开始研究吧**

因为 `DefaultPromise` 是` Promise` 的基础实现，所以从 `DefaultPromise` 开始

