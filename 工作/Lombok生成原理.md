> 为什么要研究Lombok生成原理呢？
>
> 来自《简单的异步相应式的实现》中我想学习框架中的思想，让异步的代码看起来像同步执行一样，这就需要涉及到AST
>
> 那么我就从Lombok开始

Lombok原理
Java的编译分为以下⼏个阶段：

解析与填充符号表->注解处理->分析与字节码⽣成->⽣成⼆进制class⽂件。

Lombok 使⽤的是 JDK 6 实现的 JSR 269: Pluggable Annotation Processing API (编译期的注解处理器 APT)，它是在编译期时把 Lombok 的注解代码，转换为常规的 Java ⽅法⽽实现注⼊。

在编译期阶段，当 Java 源码被抽象成语法树 (AST) 之后，Lombok 会根据⾃⼰的注解处理器动态的修改AST，增加新的代码 (节点)，在这⼀切执⾏之后，再通过分析⽣成了最终的字节码 (.class) ⽂件，这就是Lombok 的执⾏原理。


注解处理器 APT 的作用



DSL 



JavacTree是Java编译器（Javac）中的一个类，它是AST（抽象语法树）节点的基类。AST是编译器的一种数据结构，它把源代码解析成树形结构，并将代码的语义和结构以语法形式呈现出来。JavacTree中的方法被用于获取和修改AST节点的信息，如获取节点的类型、位置和属性等。从AST中可以提取出程序的结构信息，如类、方法、变量等，进而进行分析、检查和优化等操作。因此，JavacTree在Javac编译器的内部起着非常重要的作用。



在我想要使用 `com.sun.tools` 下的 一些类时 无法引用，比如



软件包 'com.sun.tools.javac.tree' 在模块 'jdk.compiler' 中声明，但后者没有将它导出到未命名模块



![image-20230308190619025](https://tutu-learn.oss-cn-hangzhou.aliyuncs.com/image-20230308190619025.png)





利用插入式注解处理器在编译阶段修改语法树，需要用到 Javac 中的注解处理工具 APT(Annotation Processing Tool)，这是 Sun 为了帮助注解的处理过程而提供的工具，APT 被设计为操作 Java 源文件，而不是编译后的类。

本文使用的是 JDK 8，Javac 相关的源码存放在 tools.jar 中，要在程序中使用的话就必须把这个库放到类路径上。注意，到了 JDK 9 时，整个 JDK 所有的 Java 类库都采用模块化进行重构划分，Javac 编译器就被挪到了 jdk.compiler 模块，并且对该模块的访问进行了严格的限制。




![img](https://img-blog.csdnimg.cn/ec515b677a3e4305be6c658b3869db17.png)

但是还可以依然没有直接的展示出 实现原理，但是我发现在弄播客中有涉及到加网s P I在 在奇远码中也找到了针对S P I的实现





暂时放下对他原理的追踪

开始研究语法树



我可以自己做到自己的注解然后让idea 识别，少写某些代码