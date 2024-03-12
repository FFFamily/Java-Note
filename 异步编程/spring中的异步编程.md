## 前言

Spring 2.0版本中提供了一种新的处理执行器（executors）的抽象，即TaskExecutor接口。

TaskExecutor接口与java.util.concurrent.Executor是等价的，其只有一个接口。

> 我对于此的理解就是 Spring 自己的一套线程池创建逻辑



该接口具有单个方法execute（Runnable task），该方法基于线程池的语义和配置接收要执行的任务。

最初创建TaskExecutor是为了给其他Spring组件提供所需的线程池抽象。

诸如ApplicationEventMulticaster、JMS的AbstractMessageListenerContainer和Quartz集成之类的组件都使用TaskExecutor抽象来池化线程。

> TaskExecutor 也就是类似于 JAVA 中的 Executor



Spring框架本身内置了很多类型的TaskExecutor实现。

- `SimpleAsyncTaskExecuto`这种TaskExecutor接口的实现不会复用线程，对应每个请求会新创建一个对应的线程来执行。它支持的并发限制将阻止任何超出限制的调用，这个可以通过调用`setConcurrencyLimit`方法来限制并发数，默认是不限制并发数的。

- `SyncTaskExecutor`这种`TaskExecutor`接口的实现不会异步地执行提交的任务，而是会同步使用调用线程来执行，这种实现主要用于没有必要多线程进行处理的情况，比如在进行简单的单元测试时

- `SimpleThreadPoolTaskExecutor`这个实现实际上是`Quartz的SimpleThreadPool`的子类，它监听Spring的生命周期回调。当你有一个可能需要Quartz和非Quartz组件共享的线程池时，通常会使用该实现。

- `ConcurrentTaskExecutor`这种TaskExecutor接口的实现是对JDK5中的java.util.concurrent.Executor的一个包装，通过setConcurrentExecutor(Executor concurrentExecutor)接口可以设置一个JUC中的线程池到其内部来做适配。还有一个替代方案ThreadPoolTaskExecutor，它通过bean属性的方式配置Executor线程池的属性。一般很少会用到Concurrent TaskExecutor，但如果ThreadPoolTaskExecutor不够健壮满足不了你的需求，那么ConcurrentTaskExecutor也是一种选择。
- `ThreadPoolTaskExecutor`该实现只能在Java 5环境中使用，其也是该环境中最常用的实现。它公开了bean属性，用于配置java.util.concurrent.ThreadPoolExecutor并将其包装在TaskExecutor中。如果你需要一些高级的接口，例如`ScheduledThreadPoolExecutor`，建议使用Concurrent TaskExecutor
- TimerTaskExecutor该实现使用单个java.util.Timer对象作为其内部异步线程来执行任务。它与SyncTaskExecutor的不同之处在于，该实现对所有提交的任务都在Timer内的单独线程中执行，尽管提交的多个任务的执行是顺序同步的。





## @Async

在Spring中可以在方法上添加@Async注释，以便异步执行该方法。

换句话说，调用线程将在调用含有@Async注释的方法时立即返回，并且该方法的实际执行将发生在Spring的TaskExecutor异步处理器线程中。

需要注意的是，该注解@Async默认是不会解析的，需要开启该注解的解析才能使用

> 这里之后也可以同步更新一下@Async 的相关知识
>
> 我记得是有关于其线程数量的问题



基于@Async注解的异步处理也是支持返回值的，但是返回值类型必须是Future或者其子类类型的，比如返回的Future类型可以是普通的java.util.concurrent.Future类型，也可以是Spring框架的org. springframework.util.concurrent.ListenableFuture类型，或者JDK8中的java.util.concurrent. CompletableFuture类型，又或者Spring中的AsyncResult类型等。这提供了异步执行的好处，以便调用者可以在调用Future上的get()之前处理其他任务。

```java
  @Async
  public CompletableFuture<String> doSomething() {
      // 1．创建future
      CompletableFuture<String> result = new CompletableFuture<String>();
      // 2．模拟任务执行
      try {
          Thread.sleep(5000);
          System.out.println(Thread.currentThread().getName() +"doSomething");
      } catch (Exception e) {
          e.printStackTrace();
      }
      result.complete("done");

      // 3．返回结果
      return result;
  }
```

测试代码

```java
  public static void main(String arg[]) throws InterruptedException {
      // 1．创建容器上下文
      ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext( 
        new String[] { "beans-annotation.xml" });
      // 2. 获取AsyncExecutorExample实例并调用打印方法
      System.out.println(Thread.currentThread().getName() + " begin ");
      AsyncAnnotationExample asyncCommentExample = applicationContext.
getBean(AsyncAnnotationExample.class);

      // 3．获取异步future并设置回调
      CompletableFuture<String> resultFuture = asyncCommentExample.
doSomething();
      resultFuture.whenComplete(new BiConsumer<String, Throwable>() {
          @Override
          public void accept(String t, Throwable u) {
              if (null == u) {
                  System.out.println(Thread.currentThread().getName() + " "
+ t);
              } else {
                  System.out.println("error:" + u.getLocalizedMessage());
              }
          }
      });
      System.out.println(Thread.currentThread().getName() + " end ");
  }
```



最后看看使用@Async注解遇到异常时该如何处理。当@Async方法具有Future类型返回值时，很容易管理在方法执行期间抛出的异常，因为会在调用get方法等待结果时抛出该异常。但是对于void返回类型来说，异常未被捕获且无法传输。这时候可以提供AsyncUncaughtExceptionHandler来处理该类异常

```java
public class MyAsyncUncaughtExceptionHandler implements AsyncUncaughtExceptionHandler {
  @Override
   public  void  handleUncaughtException(Throwable  ex,  Method  method,Object... params) {
      // handle exception
  }
}
```





## 原理

在Spring中调用线程将在调用含有@Async注释的方法时立即返回，Spring是如何做到的呢？其实是其对标注@Async注解的类做了代理

```java
  public class AsyncAnnotationExample {
      @Async
      public CompletableFuture<String> doSomething() {

          // 1．创建future
          CompletableFuture<String> result = new CompletableFuture<String>();
          // 2．模拟任务执行
          try {
              Thread.sleep(1000);
              System.out.println(Thread.currentThread().getName() +
  "doSomething");
          } catch (Exception e) {
              e.printStackTrace();
          }
          result.complete("done");

          // 3．返回结果
          return result;
      }
  }
```

最后编译后 `spring` 处理后的代码为

```java
public class AsyncAnnotationExampleProxy {

    public AsyncAnnotationExample getAsyncTask() {
          return asyncTask;
      }

      public void setAsyncAnnotationExample(AsyncAnnotationExample asyncTask) {
          this.asyncTask = asyncTask;
      }

      private AsyncAnnotationExample asyncTask;
      private TaskExecutor executor = new SimpleAsyncTaskExecutor();
      public CompletableFuture<String> dosomthingAsyncFuture() {

          return CompletableFuture.supplyAsync(new Supplier<String>() {

              @Override
              public String get() {
                  try {
                      return asyncTask.dosomthing().get();
                  } catch (Throwable e) {
                      throw new CompletionException(e);
                  }
              }
          }, executor);
      }
  }
```

​	如上代码所示，Spring会对AsyncAnnotationExample类进行代理，并且会把AsyncAnnotationExample的实例注入AsyncAnnotationExampleProxy内部，当我们调用AsyncAnnotationExample的dosomthing方法时，实际调用的是AsyncAnnotation ExampleProxy的dosomthing方法，后者使用CompletableFuture.supplyAsync开启了一个异步任务（其马上返回一个CompletableFuture对象），并且使用默认的SimpleAsync TaskExecutor线程池作为异步处理线程，然后在异步任务内具体调用了AsyncAnnotationExample实例的dosomthing方法。默认情况下，Spring框架是使用Cglib对标注@Async注解的方法进行代理的，具体拦截器是AnnotationAsyncExecutionInterceptor，我们看看其invoke方法。



