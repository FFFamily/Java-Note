# AOP研究

谈及AOP，也就是面向切面编程

AOP的实现有两种

- 静态代理

- 动态代理

  - JDK动态代理
  - CGlib动态代理

  

想要了解AOP，得先了解这几种代理，谈及这几种代理，不得不谈代理模式

我自己的笔记谈代理模式的定义是：对一个对象提供替身，控制对这个对象的访问

## 代理模式的代码实现

### 静态代理

以老师授课为例

公共接口

```java
public interface Teacher {
    /**
     * 授课
     */
    void teach();
}
```

被代理对象

```java
public class Teachers  implements Teacher{
    @Override
    public void teach() {
        System.out.println("老师授课");
    }
}
```

代理对象

```java
public class TeacherProxy {
    /**
     * 目标对象，通过接口来聚合
     */
    private Teacher teacher;

    /**
     * 构造
     * @param teacher
     */
    public TeacherProxy(Teacher teacher) {
        this.teacher = teacher;
    }

    /**
     * 代理执行
     */
    public void teach(){
        System.out.println("我会代理你完成授课 ");
        teacher.teach();
    }
}
```

测试

```java
public class Test {
    public static void main(String[] args) {
        //创建目标对象(被代理对象)
        Teacher teacher = new Teachers();
        //创建代理对象
        TeacherProxy proxy = new TeacherProxy(teacher);
        //执行的是代理对象的方法，代理对象再去调用目标对象的方法
        proxy.teach();
    }
}
```



### 动态代理

#### JDK代理

和静态代理的差别，就在于代理类上

不再是直接调用，而是返回一个代理对象，代理对象去执行被代理对象的方法

```java
public class TeacherProxy {
    /**
     * 目标对象，通过接口来聚合
     */
    private Teacher teacher;

    /**
     * 构造
     * @param teacher
     */
    public TeacherProxy(Teacher teacher) {
        this.teacher = teacher;
    }

    /**
     * 给目标对象 生成一个代理对象
     */
    public Object getProxyInstance() {
        Object proxy = Proxy.newProxyInstance(teacher.getClass().getClassLoader(), teacher.getClass().getInterfaces(), new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                System.out.println("JDK代理");
                //反射机制调用目标对象的方法
                Object returnVal = method.invoke(teacher, args);
                return returnVal;
            }
        });
        return proxy;
    }
}
```

这里使用了`newProxyInstance` 方法

追进去，不走太深

`proxy.java`

```java
/**
     * 返回指定接口的代理类的实例,将方法调用分派到指定调用的处理程序。
     * @param   loader  类加载器
     * @param   interfaces 代理类接口
     * @param   h
     * @return
     * @throws  IllegalArgumentException
     * @throws  SecurityException
     * @throws  NullPointerException
     */
@CallerSensitive
public static Object newProxyInstance(ClassLoader loader,
                                      Class<?>[] interfaces,
                                      InvocationHandler h)
    throws IllegalArgumentException
{
    Objects.requireNonNull(h);

    final Class<?>[] intfs = interfaces.clone();
    final SecurityManager sm = System.getSecurityManager();
    if (sm != null) {
        checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
    }

    /*
	* 查找或生成指定的代理类。（重点：生成代理类的地方）
    */
    Class<?> cl = getProxyClass0(loader, intfs);

	// 使用指定的调用处理程序调用其构造函数。
	// 以下代码省略

}
```

追

```java
/**
    * 生成一个代理类。必须调用checkProxyAccess方法
    * 在调用此之前执行权限检查。
    */
private static Class<?> getProxyClass0(ClassLoader loader,
                                       Class<?>... interfaces) {
    if (interfaces.length > 65535) {
        throw new IllegalArgumentException("interface limit exceeded");
    }


    //如果给定加载程序定义的代理类
    //如果给定的接口存在，这将只返回缓存的副本；
    //否则，它将通过ProxyClassFactory创建代理类
    return proxyClassCache.get(loader, interfaces);
}
```

其中

```
proxyClassCache = new WeakCache<>(new KeyFactory(), new ProxyClassFactory());
```

缓存使用的是WeakCache实现的，此处主要关注使用ProxyClassFactory创建代理的情况。P

roxyClassFactory是Proxy类的静态内部类，实现了BiFunction接口，实现了BiFunction接口中的apply方法。

当WeakCache中没有缓存相应接口的代理类，则会调用ProxyClassFactory类的apply方法来创建代理类。

> proxyClassCache.get(loader, interfaces);方法就不跟了

`ProxyClassFactory.java`

就追到这里了，可以看出 最终生成代理类的地方在` ProxyGenerator.generateProxyClass`

```java
/**
         * 生成代理类字节码 = 》 ProxyGenerator.generateProxyClass
         * @param loader
         * @param interfaces
         * @return
         */
@Override
public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {

    Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
    for (Class<?> intf : interfaces) {
        /*
                 * 校验类加载器是否能通过接口名称加载该类
                 * 这个加载器是被代理目标类的加载器
                 */
        Class<?> interfaceClass = null;
        try {
            interfaceClass = Class.forName(intf.getName(), false, loader);
        } catch (ClassNotFoundException e) {
        }
        if (interfaceClass != intf) {
            throw new IllegalArgumentException(
                intf + " is not visible from class loader");
        }
        /*
                 * 校验该类是否是接口
                 */
        if (!interfaceClass.isInterface()) {
            throw new IllegalArgumentException(
                interfaceClass.getName() + " is not an interface");
        }
        /*
                 * 校验接口是否重复
                 */
        if (interfaceSet.put(interfaceClass, Boolean.TRUE) != null) {
            throw new IllegalArgumentException(
                "repeated interface: " + interfaceClass.getName());
        }
    }

    String proxyPkg = null;     // 代理类包名
    int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

    /*
             * 非public接口，代理类的包名与接口的包名相同
             */
    for (Class<?> intf : interfaces) {
        int flags = intf.getModifiers();
        if (!Modifier.isPublic(flags)) {
            accessFlags = Modifier.FINAL;
            String name = intf.getName();
            int n = name.lastIndexOf('.');
            String pkg = ((n == -1) ? "" : name.substring(0, n + 1));
            if (proxyPkg == null) {
                proxyPkg = pkg;
            } else if (!pkg.equals(proxyPkg)) {
                throw new IllegalArgumentException(
                    "non-public interfaces from different packages");
            }
        }
    }

    if (proxyPkg == null) {
        // 如果没有非公共代理接口，请使用com.sun.proxy包
        proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
    }

    /*
             * 为代理类生成名字：com.sun.proxy.$Proxy0
             */
    long num = nextUniqueNumber.getAndIncrement();
    String proxyName = proxyPkg + proxyClassNamePrefix + num;

    /*
               重要
             * 真正生成代理类的字节码文件的地方
             */
    byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
        proxyName, interfaces, accessFlags);
    try {
        // 使用类加载器将代理类的字节码文件加载到JVM中，native方法
        return defineClass0(loader, proxyName,
                            proxyClassFile, 0, proxyClassFile.length);
    } catch (ClassFormatError e) {
        /*
                 * A ClassFormatError here means that (barring bugs in the
                 * proxy class generation code) there was some other
                 * invalid aspect of the arguments supplied to the proxy
                 * class creation (such as virtual machine limitations
                 * exceeded).
                 */
        throw new IllegalArgumentException(e.toString());
    }
}
}
```



#### CGlib代理

其实现需要第三方包

```java
public class TeacherProxy implements MethodInterceptor {
    /**
     * 目标对象，通过接口来聚合
     */
    private Teacher1 teacher;

    /**
     * 构造
     * @param teacher
     */
    public TeacherProxy(Teacher1 teacher) {
        this.teacher = teacher;
    }

    /**
     *
     * @return
     */
    public Object getProxyInstance() {
        //1. 创建一个工具类
        Enhancer enhancer = new Enhancer();
        //2. 设置父类
        enhancer.setSuperclass(teacher.getClass());
        //3. 设置回调函数
        enhancer.setCallback(this);
        //4. 创建子类对象，即代理对象
        return enhancer.create();
    }

    /**
     * 重写  intercept 方法，会调用目标对象的方法
     * @param arg0
     * @param method
     * @param args
     * @param arg3
     * @return
     * @throws Throwable
     */
    @Override
    public Object intercept(Object arg0, Method method, Object[] args, MethodProxy arg3) throws Throwable {
        System.out.println("Cglib代理模式");
        Object returnVal = method.invoke(teacher, args);
        return returnVal;
    }
}
```



## AOP中的代码实现