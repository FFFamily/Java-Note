# JAVA基础







## @序列化

### 一，定义

Java序列化就是指把Java对象转换为字节序列的过程

Java反序列化就是指把字节序列恢复为Java对象的过程



> 用一个字节序列可以表示一个对象，该字节序列包含该`对象的数据`、`对象的类型`和`对象中存储的属性`等信息
>
> 字节序列写出到文件之后，相当于文件中**持久保存**了一个对象的信息
>
> 反之，该字节序列还可以从文件中读取回来，重构对象，对它进行反序列化，对象的数据`、`对象的类型`和`对象中存储的数据`信息，都可以用来在内存中创建对象



一个对象要想序列化，必须满足两个**条件**:

一：该类必须实现`java.io.Serializable ` 接口，`Serializable` 是一个标记接口，不实现此接口的类将不会使任何状态序列化或反序列化，会抛出`NotSerializableException` 。

二：该类的所有属性必须是可序列化的。如果有一个属性不需要可序列化的，则该属性必须注明是瞬态的，使用`transient` 关键字修饰。



### 二，作用

序列化

1，在传递和保存对象时.保证对象的完整性和可传递性

2，对象转换为有序字节流,以便在网络上传输或者保存在本地文件中

反序列化

1，根据字节流中保存的对象状态及描述信息，通过反序列化重建对象



**总结：**序列化机制的核心作用就是对象状态的保存与重建



**例子：**

**1，**json/xml的数据传递

**2，**Serializable接口

Serializable是Java提供的序列化接口，是一个空接口，**为对象提供标准的序列化与反序列化操作**



**实现方式**

①若Student类仅仅实现了**Serializable接口**，则可以按照以下方式进行序列化和反序列化。

> `ObjectOutputStream`采用默认的序列化方式，对Student对象的非transient的实例变量进行序列化。     
>
> `ObjcetInputStream`采用默认的反序列化方式，对Student对象的非transient的实例变量进行反序列化。

 

②若Student类仅仅实现了Serializable接口，并且还定义了`readObject(ObjectInputStream in)`和`writeObject(ObjectOutputSteam out)`，则采用以下方式进行序列化与反序列化。

> `ObjectOutputStream`调用Student对象的`writeObject(ObjectOutputStream out)`的方法进行序列化。
>
> `ObjectInputStream`会调用Student对象的`readObject(ObjectInputStream in)`的方法进行反序列化。

 

③若Student类实现了`Externalnalizable`接口，且Student类必须实现`readExternal(ObjectInput in)`和`writeExternal(ObjectOutput out)`方法，则按照以下方式进行序列化与反序列化

> `ObjectOutputStream`调用Student对象的`writeExternal(ObjectOutput out))`的方法进行序列化。 
>
> `ObjectInputStream`会调用Student对象的`readExternal(ObjectInput in)`的方法进行反序列化。

## @内部类

即定义在一个类的内部

```JAVA
public class A {
     class B{}
}
```

1，可以定义非静态属性和方法，不可以定义static修饰的属性和方法，可以定义static final修饰的编译期变量，除非用static修饰这个内部类

> 为什么不可以定义static修饰的属性和方法？
>
> ​	首先内部类是外部类的一个成员，只有当外部类初始化的时候，内部类才能初始化，静态变量属于类级别，在类加载的时候就初始化
>
> ​	但是可以使用 static final 修饰的常量，即编译期常量



### 一，成员内部类

1，可以无条件的访问外部类的所有成员属性和成员方法（包括private和静态成员）

方式：

1-直接写属性名，其实本质还是外部类.this.属性

```java
private int aa = 1;
    class Inner{
        public void get(){
            System.out.println(aa);
        }
    }
//等同于
		public void get(){
            System.out.println(外部类.this.aa);
        }
//这种写法适用于当需要访问和外部类同名的成员时
```

反编译后的源码

```java
public class Outter
{
    private int a;
    
    public Outter() {
        this.a = 3;
    }
    
    class Inner
    {
        public void get() {
            System.out.println(Outter.this.a);
        }
    }
}
```



2，外部类访问内部类时需要创建成员内部类对象做引用

```
外部类.内部类 in = new 外部类().new 内部类();
```

3，内部类具有访问private，protected的权限



### 二，局部内部类

定义：定义在方法中的内部类



1、内部类不能被public、private、static修饰；

2、在外部类中不能创建内部类的实例；

3、内部类访问包含他的方法中的变量必须有final修饰；

4、外部类不能访问局部内部类，只能在方法体中访问局部内部类，且访问必须在内部类定义之后。



> 为什么必须有final修饰呢？



 首先需要知道的一点是:内部类和外部类是处于同一个级别的,内部类不会因为定义在方法中就会随着方法的执行完毕就被销毁.

这里就会产生问题：当外部类的方法结束时，局部变量就会被销毁了，但是内部类对象可能还存在(只有没有人再引用它时，才会死亡)。这里就出现了一个矛盾：内部类对象访问了一个不存在的变量。为了解决这个问题，就将局部变量复制了一份作为内部类的成员变量，这样当局部变量死亡后，内部类仍可以访问它，实际访问的是局部变量的”copy”。这样就好像延长了局部变量的生命周期

### 三，匿名内部类

1，唯一没有构造器的类

2，一般使用匿名内部类编写监听事件的代码

3，不能有访问修饰符和static修饰符

```java
public class O {
    class A{}
    public void a(A a){
        new Inner().get();
    } 
    public void b(){
        O o = new O();
        o.a(new A());
    }
}

```



### 四，静态内部类

```java
 static class ss{
        public void get(){
            System.out.println(aa);
        }
    }
```

1，不需要依赖于外部类

2，不能使用外部类非static的成员和方法	



## @包装类

Java中的基本数据类型没有方法和属性，而包装类就是为了让这些拥有方法和属性

### 一，分类

每个基本数据类型都对应着一个包装类

### 二，转换

装箱：基本数据类型转换为包装类

```java
int i = 1;
//自动装箱
Intager ii = i;
//手动装箱
Intager ii = new Intager(i);
```



拆箱：包装类转换为基本数据类型

```java
Intager i = 1;
//自动拆箱
int ii = i;
//手动拆箱
int ii=i.intValue();
```



### 三，常用的方法

```java
Integer.toString()//将整型转换为字符串
Integer.parseInt()//将字符串转换为int类型
valueOf()//方法把字符串转换为包装类然后通过自动拆箱
```





## @事件处理

### 一，概念

**事件**：用户对组件的一个操作，称之为一个事件

**事件源：**发生事件的组件就是事件源

**事件监听器（处理器）**：监听并负责处理事件的方法



### 二，执行顺序

1、给事件源注册监听器

2、事件被触发

3、组件产生一个相应的事件对象，并把此对象传递给与之关联的事件监听器

4、事件处理器执行相关的代码来处理该事件



### 三，使用

匿名监听器

```java
button.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {

            }
        });
```



监听器

```java
public class mylistener implements ActionListener {
    @Override
    public void actionPerformed(ActionEvent actionEvent) {
        System.out.println("我是监听器");
    }
}


button.addActionListener(actionEvent -> new mylistener());
button.addActionListener(new mylistener());
```



### 四，分类

动作事件（`ActionEvent`）

接口：`ActionListener`



焦点事件（`FocousEvent`）

接口：`FocusListener`



键盘事件（`KeyEvent`）

接口：`KeyListener`



鼠标事件

接口：`MouseListener`



窗口事件



选项事件

表格模型事件



## @异常

**异常** ：指的是程序在执行过程中，出现的非正常的情况，最终**会导致JVM的非正常停止**

**注意**：	

1.在Java等面向对象的编程语言中，**异常本身是一个类**，产生异常就是创建异常对象并抛出了一个异常对象

2.java处理异常的方式是中断处理

3.异常指的并不是语法错误,语法错了,编译不通过,不会产生字节码文件,根本不能运行.



异常产生过程

1. 方法处发生异常
2. JVM会产生一个异常对象：包括异常的名称，内容，产生位置
3. JVM将异常发送给方法的调用者（调用者无法处理，又会向上一级发送异常对象，即JVM）
4. JVM接受到异常对象，打印对象信息，并终止程序

![img](E:\有道云笔记\新建文件夹\qqA18D73086F0D435363C26D86B8CAD5E6\a06541cd094646bb8347118bde642426\异常产生过程.png)



### 一，分类

**`Throwable`体系：**

异常的根类是**`Throwable`**，其下有两个子类：**Error**与**Exception**

**Error**:严重错误Error，无法通过处理的错误，只能事先避免。

**Exception**:表示异常，异常产生后程序员可以通过代码的方式纠正，使程序继续运行，是必须要处理的



### 二，异常(Exception)的分类

**编译时期异常**:checked异常	

在编译时期,就会检查,如果没有处理异常,则编译失败。(如日期格式化异常)



**运行时期异常**:runtime异常(非检查异常)

在运行时期,检查异常.在编译时期,运行异常不会编译器检测(不报错)。(如数学异常3/0)



### 三，异常处理

Java异常处理的五个关键字：**try、catch、finally、throw、throws**



**抛出异常throw**

**用在方法内**，用来抛出一个异常对象，将这个异常对象传递到调用者处，**并结束当前方法的执行**

```
使用格式：
throw new 异常类名(参数)
```

**注意**：

如果产生了问题，我们就会throw将问题描述类即异常进行抛出，**也就是将问题返回给该方法的调用者。**



那么对于调用者来说，有两种处理方法：

1，一种是进行捕获处理

2，另一种就是继续将问题声明出去，使用throws声明处理



**声明异常throws**

运用于方法声明之上,用于表示当前方法不处理异常,而是提醒该方法的**调用者**来处理异常(抛出异常

```
声明异常格式：
修饰符 返回值类型 方法名(参数) throws 异常类名1,异常类名2…{   }	
```



**捕获异常try…catch**

1. 该方法不处理,而是声明抛出,由该方法的调用者来处理(throws)。

2. 在方法中使用try-catch的语句块来处理异常。
3. catch和finally不能同时省略

```
捕获异常语法如下：
try{
     编写可能会出现异常的代码
}catch(异常类型  e){
     处理异常的代码
     //记录日志/打印异常信息/继续抛出异常
}
```

**注意**:

* 这种异常处理方式，要求**多个catch中的异常不能相同**，并且若catch中的多个异常之间有子父类异常的关系，那么**子类异常要求在上面的catch处理**，**父类异常在下面的catch处理**

* **运行时异常**被抛出可以不处理。即不捕获也不声明抛出

* **如果finally有return语句,永远返回finally中的结果,避免该情况**

**（如果try语句中有return，返回的是try语句中的返回值，并且不受catch其他语句影响返回值）**

* 如果父类抛出了多个异常,子类重写父类方法时,抛出和父类相同的异常或者是父类异常的子类或者不抛出异常

* **父类方法没有抛出异常，子类重写父类该方法时也不可抛出异常**。此时子类产生该异常，只能捕获处理，不能声明抛出



### 四，自定义异常

- 所有异常都必须是 Throwable 的子类。
- 如果希望写一个检查性异常类，则需要继承 Exception 类。
- 如果你想写一个运行时异常类，那么需要继承 RuntimeException 类。

```
格式：
class MyException extends Exception{
//定义有参构造方法
    public RegistException(String message) {
        super(message);
    } }
//只继承Exception 类来创建的异常类是检查性异常类。


if(exprl){
    throw new MuException()
}
```





## @Swing

> 不做讨论