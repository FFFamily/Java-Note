# Future

Future接口是java5的接口，提供了一种异步并行计算的功能

Future接口：异步任务接口

特点：多线程、异步、返回结果

优点：

* 结合多线程异步执行，提高效率

```java
private static void f2() throws InterruptedException, ExecutionException {
        ExecutorService executorService = Executors.newFixedThreadPool(3);
        FutureTask futureTask1 = new FutureTask(() ->{
            try {
                TimeUnit.MILLISECONDS.sleep(500);
            }catch (Exception e){
                e.printStackTrace();
            }
            return "任务一完成";
        });
        executorService.submit(futureTask1);
        FutureTask futureTask2 = new FutureTask(() ->{
            try {
                TimeUnit.MILLISECONDS.sleep(500);
            }catch (Exception e){
                e.printStackTrace();
            }
            return "任务一完成";
        });
        executorService.submit(futureTask2);
        System.out.println(futureTask1.get());
        System.out.println(futureTask2.get());
        executorService.shutdown();
    }
```

缺点：

* get方法会有阻塞主线程，一般放在方法的最后
* isDone方法轮询会耗费Cpu资源，一般结果的过去都是通过轮询的方式获取
* 总结：Future的结果获取不友好



# FutureTask

在研究线程的启动时，有三种方式

* Thread
* Runable
* Callable

实现方式不同，也各有不同的优缺点

同时，通常我们在使用的过程中，基本不会直接使用原生的方式去完成任务，通常会封装一定的功能，使得开发更为方便

以Callable方式为例

```java
class MyThread implements Callable<String>{
    @Override
    public String call() throws Exception {
        return null;
    }
}
```

Future 封装了相关的API可供使用，常用的就是FutureTask

```java
// 基本使用
FutureTask futureTask = new FutureTask<>(new MyThread());
Thread thread = new Thread(futureTask);
thread.start();
System.out.println(futureTask.get());
```







# completableFuture

## 概念

CompletableFuture是一个可以通过编程方式显式地设置计算结果和状态以便让任务结束的Future，并且其可以作为一个CompletionStage（计算阶段），当它的计算完成时可以触发一个函数或者行为；

当多个线程企图调用同一个CompletableFuture的complete、cancel方式时只有一个线程会成功

CompletableFuture除了含有可以直接操作任务状态和结果的方法外，还实现了CompletionStage接口的一些方法

当我们需要执行一些复杂的业务操作时，显然FutureTask不能达到预期的效果，那么就可以使用completableFuture

completableFuture 提供了一种观察者模式的机制，任务完成后通知

```java
public class CompletableFuture<T> implements Future<T>, CompletionStage<T> {}
```

在Java 8中， Complet able Future提供了非常强大的Future的扩展功能， 可以帮助我们简化异步编程的复杂性， 并且提供了函数式编程的能力， 可以通过回调的方式处理计算结果， 也提供了转换和组合Complet able Future的方法。

优点：

* 异步任务结束时，会**自动回调**某个对象的方法；
* 主线程设置好毁掉后，不再关心异步任务的执行，异步任务之间可以顺序执行
* 异步任务出错时，会自动回调某个对象的方法。



## 主要方法 

### ForkJoinPool

默认情况下支撑CompletableFuture异步运行的是ForkJoinPool

ForkJoinPool本身也是一种ExecutorService，与其他ExecutorService（比如ThreadPoolExecutor）相比，不同点是它使用了工作窃取算法来提高性能，其内部每个工作线程都关联自己的内存队列，正常情况下每个线程从自己队列里面获取任务并执行，当本身队列没有任务时，当前线程会去其他线程关联的队列里面获取任务来执行。这在很多任务会产生子任务或者有很多小的任务被提交到线程池来执行的情况下非常高效。

ForkJoinPool中有一个静态的线程池commonPool可用且适用大多数情况。commonPool会被任何未显式提交到指定线程池的ForkJoinTask执行使用。使用commonPool通常会减少资源使用（其线程数量会在不活跃时缓慢回收，并在任务数比较多的时候按需增加）。默认情况下，commonPool的参数可以通过system properties中的三个参数来控制：

● java.util.concurrent.ForkJoinPool.common.parallelism：并行度级别，非负整数。

●java.util.concurrent.ForkJoinPool.common.threadFactory:ForkJoinWorker ThreadFactory的类名。

● java.util.concurrent.ForkJoinPool.common.exceptionHandler:Uncaught ExceptionHandler的类名。



### CompletionStage

Completion Stage代表异步计算过程中的某一个阶段， 一个阶段完成以后可能会触发另外一个阶段

一个阶段的计算执行可以是一个Function， Consumer或者Runnable。

一个阶段的执行可能是被单个阶段的完成触发，也可能是由多个阶段一起触发。



### runAsync

runAsync表示创建无返回值的异步任务，相当于ExecutorService submit(Runnable task)方法

基于runAsync系列方法实现无返回值的异步计算

当你想异步执行一个任务，并且不需要任务的执行结果时可以使用该方法，比如异步打日志，异步做消息通知等

```java
CompletableFuture<Void> voidCompletableFuture = CompletableFuture.runAsync(() -> {
  System.out.println(Thread.currentThread().getName());
});
```

结果

```java
ForkJoinPool.commonPool-worker-1 // 默认的线程池
```

**配合线程池使用**

使用runAsync (Runnable runnable, Executor executor)方法允许我们使用自己制定的线程池来执行异步任务

```java
ExecutorService executorService = Executors.newFixedThreadPool(3);
CompletableFuture<Void> voidCompletableFuture = CompletableFuture.runAsync(() -> {
	System.out.println(Thread.currentThread().getName());
},executorService);
```

结果

```java
pool-1-thread-1 // 指定线程池
```



### supplyAsync

创建带返回值的异步任务,相当于ExecutorService submit(Callable<T> task) 方法

基于supplyAsync系列方法实现有返回值的异步计算

当你想异步执行一个任务，并且需要任务的执行结果时可以使用该方法，比如异步对原始数据进行加工，并需要获取到被加工后的结果等

```java
CompletableFuture<String> objectCompletableFuture = CompletableFuture.supplyAsync(()->{
  System.out.println(Thread.currentThread().getName());
  return "supplyasync";
});
System.out.println(objectCompletableFuture.get());
```

结果

```java
ForkJoinPool.commonPool-worker-9//默认的线程池
supplyasync // supplyasync有返回值了
```

**配合线程池使用**

```java
public static <U> CompletableFuture<U> supplyAsync(Supplier<U> supplier,Executor executor)；
```



### getNow

调用的时候如果计算完了，就拿取这个计算完的值；否则就拿**备胎值**



### complete

立即打断`get方法`返回括号值



### whenComplete方法

在任务执行完之后自动回调方法

如果需要有 返回值，则 需要 `handle` 方法

```JAVA
ExecutorService threadPool = Executors.newFixedThreadPool(3);
CompletableFuture.supplyAsync(()->{
  System.out.println(Thread.currentThread().getName()+"--------副线程come in");
  int result = ThreadLocalRandom.current().nextInt(10);//产生随机数
  try {
    TimeUnit.SECONDS.sleep(1);
  } catch (InterruptedException e) {
    e.printStackTrace();
  }
  System.out.println("-----结果---异常判断值---"+result);
  //---------------------异常情况的演示--------------------------------------
  if(result > 2){
    int i  = 10 / 0 ;//我们主动的给一个异常情况
  }
  //------------------------------------------------------------------
  return result;
},threadPool).whenComplete((v,e) -> {//没有异常,v是值，e是异常
  if(e == null){
    System.out.println("------------------计算完成，更新系统updataValue"+v);
  }
}).exceptionally(e->{//有异常的情况
  e.printStackTrace();
  System.out.println("异常情况"+e.getCause()+"\t"+e.getMessage());
  return null;
});

//线程不要立刻结束，否则CompletableFuture默认使用的线程池会立刻关闭：暂停3秒钟线程
System.out.println(Thread.currentThread().getName()+"线程先去忙其他任务");
try {
  TimeUnit.SECONDS.sleep(3);
} catch (InterruptedException e) {
  e.printStackTrace();
}
```





### thenApply 方法

计算结果存在在依赖关系，使得线程串行化。因为依赖关系，所以一旦有异常，直接叫停。	

两个任务都是来自同一个线程实现

如果需要新起一个线程，则需要使用 ` thenApplyAsync` 方法

```java
CompletableFuture<Object> job1 = CompletableFuture.supplyAsync(() -> {
  try {
    System.out.println("任务一");
    Thread.sleep(1000);
  } catch (InterruptedException e) {
    throw new RuntimeException(e);
  }
  return "job1";
}).thenApply((res)->{
  System.out.println("任务一完成拉");
  return "job2";
});
System.out.println(job1.get());
```



### thenAccept

接收任务的处理结果，并**消费处理，无返回结果**|**消费型函数式接口**，之前的是Function

基于thenAccept实现异步任务A，执行完毕后，激活异步任务B执行

需要注意的是，这种方式激活的异步任务B是可以拿到任务A的执行结果的

```java
public static void main(String[] args) throws ExecutionException, InterruptedException
{
    CompletableFuture.supplyAsync(() -> {
        return 1;
    }).thenApply(f -> {
        return f + 2;
    }).thenApply(f -> {
        return f + 3;
    }).thenApply(f -> {
        return f + 4;
    }).thenAccept(r -> System.out.println(r));
}
```



### thenRun 

thenRun 的方法没有入参，也买有返回值



### exceptionally

在某个任务执行出现异常时的回调方法，会将抛出异常作为参数传递到回调方法中，如果该任务正常执行则会exceptionally方法返回的CompletionStage的result就是该任务正常执行的结果

后面的任务不会执行



### CompleteFuture和线程池说明

- 上面的几个方法都有普通版本和**后面加Async**的版本
- 以`thenRun`和`thenRunAsync`为例，有什么区别？



结论

* 没有传入自定义线程池，都用默认线程池ForkJoinPool
* 传入了一个自定义线程池如果你执行第一个任务的时候，传入了一个自定义线程池
* 调用thenRun方法执行第二个任务的时候，则第二个任务和第一个任务是用同一个线程池
* 调用thenRunAsync执行第二个任务的时候，则第一个任务使用的是你自己传入的线程池，第二个任务使用的是ForkJoin线程池



## 组合处理

CompletableFuture功能强大的原因之一是其可以让两个或者多个Completable-Future进行运算来产生结果

### thenCombine / thenAcceptBoth / runAfterBoth

 

## 比价网2站案例

#### 需求说明

* 同一款产品，同时搜索出同款产品在各大电商平台的售价；
* 同一款产品，同时搜索出本产品在同一个电商平台下，各个入驻卖家售价是多少

#### 输出返回

出来结果希望是同款产品的在不同地方的价格清单列表， 返回一个List<String>

#### 解决方案

比对同一个商品在各个平台上的价格，要求获得一个清单列表

* 按部就班， 查完京东查淘宝， 查完淘宝查天猫
* 万箭齐发，一口气多线程异步任务同时查询
  

代码

```java
public class Case {
    static List<NetMall> list = Arrays.asList(
      new NetMall("jd"),
      new NetMall("dangdang"),
        new NetMall("taobao")
    );

    public static List<String> getPrice(List<NetMall> list,String productName){
        return list
                .stream() //----流式计算做了映射（利用map），希望出来的是有格式的字符串（利用String.format）,%是占位符
                .map(netMall -> String.format(productName + " in %s price is %.2f",
                                netMall.getNetMallName(),//第一个%
                                netMall.calcPrice(productName))).collect(Collectors.toList());//第二个%
    }

    public static void main(String[] args) {
        long startTime = System.currentTimeMillis();
        List<String> list1 = getPrice(list, "mysql");
        for(String element:list1){
            System.out.println(element);
        }
        long endTime = System.currentTimeMillis();
        System.out.println("---当前操作花费时间----costTime:"+(endTime-startTime)+"毫秒");
    }
}

class NetMall{
    @Getter
    private String netMallName;

    public NetMall(String netMallName){
        this.netMallName = netMallName;
    }

    public double calcPrice(String productName){
        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return ThreadLocalRandom.current().nextDouble() * 2 + productName.charAt(0);//用这句话来模拟价格
    }
}

//mysql in jd price is 110.48
//mysql in dangdang price is 109.06
//mysql in taobao price is 110.96
//---当前操作花费时间----costTime:3098毫秒
```

优化

```java
public class Case {
    static List<NetMall> list = Arrays.asList(
      new NetMall("jd"),
      new NetMall("dangdang"),
        new NetMall("taobao")
    );

    public static List<String> getPrice(List<NetMall> list,String productName){
        return list
                .stream() //----流式计算做了映射（利用map），希望出来的是有格式的字符串（利用String.format）,%是占位符
                .map(netMall -> String.format(productName + " in %s price is %.2f",
                                netMall.getNetMallName(),//第一个%
                                netMall.calcPrice(productName))).collect(Collectors.toList());//第二个%
    }

    //从功能到性能
    public static List<String> getPricesByCompletableFuture(List<NetMall> list,String productName){
        return list.stream().map(netMall ->
                        CompletableFuture.supplyAsync(() -> String.format(productName + " in %s price is %.2f",
                                netMall.getNetMallName(),
                                netMall.calcPrice(productName))))//Stream<CompletableFuture<String>>
                                .collect(Collectors.toList())//List<CompletablFuture<String>>
                                .stream()//Stream<CompletableFuture<String>
                                .map(s->s.join())//Stream<String>
                                .collect(Collectors.toList());
    }

    public static void main(String[] args) {
        long startTime = System.currentTimeMillis();
        List<String> list1 = getPrice(list, "mysql");
        for(String element:list1){
            System.out.println(element);
        }
        long endTime = System.currentTimeMillis();
        System.out.println("--普通版----当前操作花费时间----costTime:"+(endTime-startTime)+"毫秒");
        System.out.println("------------------------------分割----------------------");
        startTime = System.currentTimeMillis();
        List<String> list2 = getPricesByCompletableFuture(list, "mysql");
        for(String element:list2){
            System.out.println(element);
        }
        endTime = System.currentTimeMillis();
        System.out.println("--性能版-当前操作花费时间----costTime:"+(endTime-startTime)+"毫秒");
    }
}

class NetMall{
    @Getter
    private String netMallName;

    public NetMall(String netMallName){
        this.netMallName = netMallName;
    }

    public double calcPrice(String productName){
        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        return ThreadLocalRandom.current().nextDouble() * 2 + productName.charAt(0);//用这句话来模拟价格
    }
}
//mysql in jd price is 109.49
//mysql in dangdang price is 110.85
//mysql in taobao price is 110.32
//--普通版----当前操作花费时间----costTime:3124毫秒
//------------------------------分割----------------------
//mysql in jd price is 109.34
//mysql in dangdang price is 109.02
//mysql in taobao price is 110.37
//--性能版-当前操作花费时间----costTime:1000毫秒
```



### 对计算速度进行选用

- `applyToEither`方法，快的那个掌权

```java
public class CompletableFutureDemo2 {
    public static void main(String[] args) throws ExecutionException, InterruptedException
    {
        CompletableFuture<String> play1 = CompletableFuture.supplyAsync(() -> {
            System.out.println(Thread.currentThread().getName() + "\t" + "---come in ");
            //暂停几秒钟线程
            try { TimeUnit.SECONDS.sleep(2); } catch (InterruptedException e) { e.printStackTrace(); }
            return "play1 ";
        });

        CompletableFuture<String> play2 = CompletableFuture.supplyAsync(() -> {
            System.out.println(Thread.currentThread().getName() + "\t" + "---come in ");
            try { TimeUnit.SECONDS.sleep(1); } catch (InterruptedException e) { e.printStackTrace(); }
            return "play2";
        });

        CompletableFuture<String> thenCombineResult = play1.applyToEither(play2, f -> {//对计算速度进行选用
            return f + " is winner";
        });

        System.out.println(Thread.currentThread().getName() + "\t" + thenCombineResult.get());
    }
}
//ForkJoinPool.commonPool-worker-9  ---come in 
//ForkJoinPool.commonPool-worker-2  ---come in 
//main  play2 is winner
```

### 对计算结果进行合并

`thenCombine` 合并

- 两个CompletionStage任务都完成后，最终能把两个任务的结果一起交给thenCOmbine来处理
- 先完成的先等着，等待其它分支任务

```java
public class CompletableFutureDemo2
{
    public static void main(String[] args) throws ExecutionException, InterruptedException
    {
        CompletableFuture<Integer> completableFuture1 = CompletableFuture.supplyAsync(() -> {
            System.out.println(Thread.currentThread().getName() + "\t" + "---come in ");
            return 10;
        });

        CompletableFuture<Integer> completableFuture2 = CompletableFuture.supplyAsync(() -> {
            System.out.println(Thread.currentThread().getName() + "\t" + "---come in ");
            return 20;
        });

        CompletableFuture<Integer> thenCombineResult = completableFuture1.thenCombine(completableFuture2, (x, y) -> {
            System.out.println(Thread.currentThread().getName() + "\t" + "---come in ");
            return x + y;
        });
        
        System.out.println(thenCombineResult.get());
    }
}
//30
```

