## Set

> 不保留重复元素
>
> Set和Collection具有同样的接口，实际上Set就是Collection，只是行为不同



## HashSet

> 实现了Set接口，由哈希表支持（实际上HashSet 是 HashMap 的一个实例）
>
> 底层采用 `HashMap` 来保存元素，专门为快速查找设计的Set

特点

- 无序，唯一值
- 值允许为null
- HashSet线程不安全，如果要修改，必须要外部加锁，或者使用`Collections.synchronizedSet()`
- 支持` fail-fast `机制

- 存入HashSet的元素必须定义hashcode方法



### HashSet 如何检查重复

1，HashSet用对象来计算HashCode

2，当你把对象加入`HashSet`时，HashSet 会先计算对象的`hashcode`值来判断对象加入的位置，同时也会与其他加入的对象的 hashcode 值作比较，如果没有相符的 hashcode，HashSet 会假设对象没有重复出现。但是如果发现有相同 hashcode 值的对象，这时会调用`equals()`方法来检查 hashcode 相等的对象是否真的相同。如果两者相同，HashSet 就不会让加入操作成功



> 首先判断两个元素的哈希值，如果哈希值一样，接着会比较
> equals 方法 如果 equls 结果为 true ，就视为同一个元素。如果 equals 为 false 就不是同一个元素，就会形成为链表



### HashMap 和 HashSet区别

- 接口
  - HashMap实现了Map接口，HashSet实现了Set接口
- 存储方式
  - HashMap按键值对存储数据，HashSet存储对象
- HashCode计算方式
  - HashMap用键来计算HashCode
  - HashSet用对象来计算HashCode，对于两个对象来说 hashcode 可能相同，所以 equals()方法用来判断对象的相等性

总结：二者在Java里有着相同的实现，前者仅仅是对后者做了一层包装，也就是说*HashSet*里面有一个*HashMap*(适配器模式)

```java
// 构造方法
// 那么其实HashSet的底层就是一个HashMap
public HashSet() {
		map = new HashMap<>();
}
```



## SortSet

此接口主要用于排序操作，即实现此接口的子类都属于排序的子类



## TreeSet

> TreeSet是基于TreeMao的NavigableSet实现
>
> 红黑树(自平衡的排序二叉树)
>
> 使用的不多，一般当需要存入的数据要排序时使用



- 有序，唯一值
- 不是线程安全的
- 支持`fail-fast`机制
- 当我们去使用这些排序的结合时，有时候自定义的类无法排序，这里就涉及到ConpareTo方法问题（详细在《排序问题》）



## LinkedHashSet

> 继承Set，是Set接口的哈希表和LinkedList的实现
>
> `LinkedHashSet` 是 `HashSet` 的子类，并且其内部是通过 `LinkedHashMap` 来实现的
>
> 内部使用链表来维护元素的循序，其插入的元素也需要实现hashcode方法



特点

- 定义了元素的插入顺序
- LinkedHashSet有两个影响其构成的参数：初始容量和加载因子
- 对于LinkedHashSet来说，过高的容量的开销比HashSet小，LinkedHashSet的迭代次数不受容量影响
- 线程不安全



### 三者的异同

- HashSet 是 Set 接口的主要实现类 ，HashSet 的底层是 HashMap，线程不安全的，可以存储 null 值；
- LinkedHashSet 是 HashSet 的子类，能够按照添加的顺序遍历；
- TreeSet 底层使用红黑树，能够按照添加元素的顺序进行遍历，排序的方式有自然排序和定制排序。





## EnumSet

EnumSet 是一个专门为枚举类设计的集合类，EnumSet 中所有元素都必须是指定枚举类型的枚举值，

该枚举类型在创建 EnumSet 时显式、或隐式地指定。

EnumSet 的集合元素也是有序的，它们以枚举值在 Enum 类内的定义顺序来决定集合元素的顺序

