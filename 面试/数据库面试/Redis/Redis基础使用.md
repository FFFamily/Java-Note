# Redis基础使用

## NoSql数据库

NoSQL(NoSQL = **Not Only SQL** )，意即“不仅仅是SQL”，泛指**非关系型的数据库**。 

NoSQL 不依赖业务逻辑方式存储，而以简单的key-value模式存储。

- 不遵循SQL标准
- 不支持ACID
- 远超于SQL的性能

### NoSql的适应场景

- 对数据高并发的读写
- 海量数据的读写
- 对数据的高可用拓展

### NoSql的不适应场景

- 需要事务支持
- 基于sql的结构化查询存储，处理复杂的关系,需要即席查询



### 常见的Nosql数据库

- Memcache
- Redis
- MongBd



## Redis简介

> 可以回答
>
> 你怎么看待Redis的？

使用【单线程+多路IO复用】

Redis是一种支持key-value等多种数据结构的存储系统。可用于缓存，事件发布或订阅，高速队列等场景。支持网络，提供字符串，哈希，列表，队列，集合结构直接存取，基于内存，可持久化。

**读写性能优异**

Redis能读的速度是110000次/s,写的速度是81000次/s （测试条件见下一节）

**数据类型丰富**

Redis支持二进制案例的 Strings, Lists, Hashes, Sets 及 Ordered Sets 数据类型操作。

**原子性**

Redis的所有操作都是原子性的，同时Redis还支持对几个操作全并后的原子性执行。
**持久化**

Redis支持RDB, AOF等持久化方式
**发布订阅**

Redis支持发布/订阅模式

**分布式**





## Redis解决的问题

随着互联网的发展，用户的访问大幅上升，给互联网平台带来了很大的性能挑战

1，配合关系型数据库做高速缓存

2，多样的数据结构存储持久化数据





## 为什么Redis 是单线程的为什么这么快？

1，首先最主要的就是Redis是基于内存的，内存操作时很快的
2，数据结构简单,对数据操作也简单
3，采用单线程模型, 避免了不必要的上下文切换和竞争条件, 也不存在多线程或者多线程切换而消耗CPU, 不用考虑各种锁的问题, 不存在加锁, 释放锁的操作, 没有因为可能出现死锁而导致性能消耗
4，虽然是单线程，但是采用的是多路IO复用模型,非阻塞IO
5，使用底层模型不同,它们之间底层实现方式及与客户端之间的 通信的应用协议不一样,Redis直接构建了自己的VM机制,因为一般的系统调用系统函数的话,会浪费一定的时间去移动和请求，它是直接调用自己的机制



## Redis 一般有哪些使用场景？

**热点数据的【缓存】**

缓存是Redis最常见的应用场景，之所有这么使用，主要是因为Redis读写性能优异。而且逐渐有取代memcached，成为首选服务端缓存的组件。而且，Redis内部是支持事务的，在使用时候能有效保证数据的一致性

**限时业务的运用**

redis中可以使用expire命令设置一个键的生存时间，到时间后redis会删除它。利用这一特性可以运用在限时的优惠活动信息、手机验证码等业务场景。

**计数器相关问题**

redis由于incrby命令可以实现原子性的递增，所以可以运用于高并发的秒杀活动、分布式序列号的生成、具体业务还体现在比如限制一个手机号发多少条短信、一个接口一分钟限制多少请求、一个接口一天限制调用多少次等等。

**分布式锁**

这个主要利用redis的setnx命令进行，setnx："set if not exists"就是如果不存在则成功设置缓存同时返回1，否则返回0 ，这个特性在俞你奔远方的后台中有所运用，因为我们服务器是集群的，定时任务可能在两台机器上都会运行，所以在定时任务中首先 通过setnx设置一个lock，如果成功设置则执行，如果没有成功设置，则表明该定时任务已执行。

 当然结合具体业务，我们可以给这个lock加一个过期时间，比如说30分钟执行一次的定时任务，那么这个过期时间设置为小于30分钟的一个时间就可以，这个与定时任务的周期以及定时任务执行消耗时间相关。




在分布式锁的场景中，主要用在比如秒杀系统等



## 数据类型

### 键（key）

#### keys *

 查询所有的键

#### exists key

判断某个key是否存在

#### type key 

查看你的key是什么类型

#### del key    

删除指定的key数据

#### unlink key  

根据value选择非阻塞删除

> 仅将keys从keyspace元数据中删除，真正的删除会在后续异步操作。

#### expire key 10  

10秒钟：为给定的key设置过期时间

#### ttl key 

查看还有多少秒过期，-1表示永不过期，-2表示已过期

####  select

切换数据库

> 默认16个数据库，类似数组下标从0开始，初始默认使用0号库

#### dbsize

查看当前数据库的key的数量

#### flushdb

清空当前库

#### flushall

通杀全部库



### 字符串（String）

String类型是二进制安全的，意味着Redis的string可以包含任何数据。

> 比如jpg图片或者序列化的对象。

String类型是Redis最基本的数据类型，一个Redis中字符串value最多可以是512M

数据结构

String的数据结构为简单动态字符串(Simple Dynamic String,缩写SDS)。

内部结构实现上类似于Java的ArrayList，采用预分配冗余空间的方式来减少内存的频繁分配.

> 也就是说
>
> 内部为当前字符串实际分配的空间capacity一般要高于实际字符串长度len。



#### set key value

添加键值对

#### get key

查询对应键值

#### append key value

将给定的<value> 追加到原值的末尾

#### strlen key

获得值的长度

#### setnx key value

只有在 key 不存在时  设置 key 的值

#### incr key

将 key 中储存的数字值增1

只能对数字值操作，如果为空，新增值为1

#### decr key

将 key 中储存的数字值减1

只能对数字值操作，如果为空，新增值为-1

#### incrby / decrby key <步长>

将 key 中储存的数字值增减。自定义步长。



#### mset <key1><value1><key2><value2>

同时设置一个或多个 key-value对 

#### mget <key1><key2><key3> 

同时获取一个或多个 value 

#### msetnx <key1><value1><key2><value2> 

同时设置一个或多个 key-value 对，当且仅当所有给定 key 都不存在。

注意：**原子性，有一个失败则都失败**

> Redis单命令的原子性主要得益于Redis的单线程。



#### getrange <key><起始位置><结束位置>

获得值的范围，类似java中的substring，**前包，后包**

#### setrange <key><起始位置><value>

用 <value> 覆写<key>所储存的字符串值，从<起始位置>开始(**索引从0****开始**)。

#### setex <key><过期时间><value>

设置键值的同时，设置过期时间，单位秒。

#### getset <key><value>

以新换旧，设置了新值同时获得旧值。



### 列表（list）

Redis 列表是简单的字符串列表，按照插入顺序排序。可以添加一个元素到列表的头部或者尾部

它的底层实际是个双向链表，对两端的操作性能很高，通过索引下标的操作中间的节点性能会较差。

数据结构

- List的数据结构为快速链表quickList
- 首先在列表元素较少的情况下会使用一块连续的内存存储，这个结构是ziplist，也即是压缩列表
- 当数据量比较多的时候才会改成quicklist
- Redis将链表和ziplist结合起来组成了quicklist。也就是将多个ziplist使用双向指针串起来使用。这样既满足了快速的插入删除性能，又不会出现太大的空间冗余。

![](./img/1.jpg)



#### lpush/rpush <key><value1><value2><value3> 

 从左边/右边插入一个或多个值。

#### lpop/rpop <key>

从左边/右边吐出一个值。值在键在，值光键亡。

#### rpoplpush <key1><key2>

从<key1>列表右边吐出一个值，插到<key2>列表左边。

#### lrange <key><start><stop>

按照索引下标获得元素(从左到右)

> lrange mylist 0 -1  0左边第一个，-1右边第一个，（0-1表示获取所有）

#### lindex <key><index>

按照索引下标获得元素(从左到右)

#### llen <key>

获得列表长度 

#### linsert <key> before <value><newvalue>

在<value>的后面插入<newvalue>插入值

#### lrem <key><n><value>

从左边删除n个value(从左到右)

#### lset<key><index><value>

将列表key下标为index的值替换成value



### 集合（set）

- Redis set对外提供的功能与list类似是一个列表的功能，特殊之处在于set是可以**自动排重**的
- Redis的Set是string类型的无序集合
- 它底层其实是一个value为null的hash表，所以添加，删除，查找的**复杂度都是**O(1)。
- Set数据结构是dict字典，字典是用哈希表实现的。

#### sadd <key><value1><value2> 

将一个或多个 member 元素加入到集合 key 中，已经存在的 member 元素将被忽略

#### smembers <key>

取出该集合的所有值

#### sismember <key><value>

判断集合<key>是否为含有该<value>值，有1，没有0

#### scard<key>

返回该集合的元素个数

#### srem <key><value1><value2> 

删除集合中的某个元素

#### spop <key>

随机从该集合中吐出一个值

#### srandmember <key><n>

随机从该集合中取出n个值。不会从集合中删除 

#### smove <source><destination>

把集合中一个值从一个集合移动到另一个集合

#### sinter <key1><key2>

返回两个集合的交集元素。

#### sunion <key1><key2>

返回两个集合的并集元素。

#### sdiff <key1><key2>

返回两个集合的**差集**元素(key1中的，不包含key2中的)



### 哈希(Hash)

Redis hash是一个string类型的field和value的映射表，hash特别适合用于存储对象。

> 类似Java里面的Map<String,Object>

Hash类型对应的数据结构是两种：ziplist（压缩列表），hashtable（哈希表）。当field-value长度较短且个数较少时，使用ziplist，否则使用hashtable。

#### hset <key><field><value>

给<key>集合中的 <field>键赋值<value>

#### hget <key1><field>

从<key1>集合<field>取出 value 

#### hmset <key1><field1><value1><field2><value2>

批量设置hash的值

#### hexists<key1><field>

查看哈希表 key 中，给定域 field 是否存在。 

#### hkeys <key>

列出该hash集合的所有field

#### hvals <key>

列出该hash集合的所有value

#### hincrby <key><field><increment>

为哈希表 key 中的域 field 的值加上增量 1  -1

#### hsetnx <key><field><value>

将哈希表 key 中的域 field 的值设置为 value ，当且仅当域 field 不存在 



### 有序集合 Zset(sorted set) 

Redis有序集合zset与普通集合set非常相似，是一个没有重复元素的字符串集合。

不同之处是有序集合的每个成员都关联了一个评分（score）,这个评分（score）被用来按照从最低分到最高分的方式排序集合中的成员。集合的成员是唯一的，但是评分可以是重复了 。

SortedSet(zset)是Redis提供的一个非常特别的数据结构，一方面它等价于Java的数据结构Map<String, Double>，可以给每一个元素value赋予一个权重score，另一方面它又类似于TreeSet，内部的元素会按照权重score进行排序，可以得到每个元素的名次，还可以通过score的范围来获取元素的列表。

zset底层使用了两个数据结构

（1）hash，hash的作用就是关联元素value和权重score，保障元素value的唯一性，可以通过元素value找到相应的score值。

（2）跳跃表，跳跃表的目的在于给元素value排序，根据score的范围获取元素列表。



#### zadd <key><score1><value1><score2><value2>

将一个或多个 member 元素及其 score 值加入到有序集 key 当中。

#### zrange <key><start><stop> [WITHSCORES] 

返回有序集 key 中，下标在<start><stop>之间的元素

> 带WITHSCORES，可以让分数一起和值返回到结果集。

#### zrangebyscore <key> minmax [withscores] [limit offset count]

返回有序集 key 中，所有 score 值介于 min 和 max 之间(包括等于 min 或 max )的成员。有序集成员按 score 值递增(从小到大)次序排列。 

#### zrevrangebyscore <key> maxmin [withscores] [limit offset count] 

#### zincrby <key><increment><value>   

为元素的score加上增量

#### zrem <key><value>

删除该集合下，指定值的元素

#### zcount <key><min><max>

统计该集合，分数区间内的元素个数 

#### zrank <key><value>

返回该值在集合中的排名，从0开始。



### Bitmaps

现代计算机用二进制（位） 作为信息的基础单位， 1个字节等于8位

> “abc”分别对应的ASCII码分别是97、 98、 99， 对应的二进制分别是01100001、 01100010和01100011



Redis提供了Bitmaps这个“数据类型”可以实现对位的操作：

（1）  Bitmaps本身不是一种数据类型， 实际上它就是字符串（key-value） ， 但是它可以对字符串的位进行操作。

（2）  Bitmaps单独提供了一套命令， 所以在Redis中使用Bitmaps和使用字符串的方法不太相同。 可以把Bitmaps想象成一个以位为单位的数组， 数组的每个单元只能存储0和1， 数组的下标在Bitmaps中叫做偏移量。



#### setbit<key><offset><value>

设置Bitmaps中某个偏移量的值（0或1）

例如，线程有几个用户，其id为1,15,16

那么就可以操作BitMaps，使其第1,15,16位写成1，以此来记录用户是否访问

> 注意
>
> 很多应用的用户id以一个指定数字（例如10000） 开头， 直接将用户id和Bitmaps的偏移量对应势必会造成一定的浪费， 通常的做法是每次做setbit操作时将用户id减去这个指定数字。
>
> 在第一次初始化Bitmaps时， 假如偏移量非常大， 那么整个初始化过程执行会比较慢， 可能会造成Redis的阻塞。



#### getbit<key><offset>

获取Bitmaps中某个偏移量的值



#### bitcount<key>[start end] 

统计字符串从start字节到end字节比特值为1的数量



#### bitop and(or/not/xor) <destkey> [key…]

bitop是一个复合操作， 它可以做多个Bitmaps的and（交集） 、 or（并集） 、 not（非） 、 xor（异或） 操作并将结果保存在destkey中。

> 例如
>
> 计算两天都访问过网站的用户



#### Bitmaps与set对比

| set和Bitmaps存储一天活跃用户对比 |                    |                  |                        |
| -------------------------------- | ------------------ | ---------------- | ---------------------- |
| 数据  类型                       | 每个用户id占用空间 | 需要存储的用户量 | 全部内存量             |
| 集合  类型                       | 64位               | 50000000         | 64位*50000000 = 400MB  |
| Bitmaps                          | 1位                | 100000000        | 1位*100000000 = 12.5MB |

> 注意：假如该网站每天的独立访问用户很少， 例如只有10万（大量的僵尸用户） ， 那么两者的对比如下表所示， 很显然， 这时候使用Bitmaps就不太合适了， 因为基本上大部分位都是0。



### HyperLogLog

在工作当中，我们经常会遇到与统计相关的功能需求，比如统计网站PV（PageView页面访问量）,可以使用Redis的incr、incrby轻松实现。

但像UV（UniqueVisitor，独立访客）、独立IP数、搜索记录数等需要去重和计数的问题如何解决？这种求集合中不重复元素个数的问题称为基数问题。

Redis HyperLogLog 是用来做基数统计的算法，HyperLogLog 的优点是，在输入元素的数量或者体积非常非常大时，计算基数所需的空间总是固定的、并且是很小的。







### Geospatial

Redis 3.2 中增加了对GEO类型的支持。GEO，Geographic，地理信息的缩写。该类型，就是元素的2维坐标，在地图上就是经纬度。redis基于该类型，提供了经纬度设置，查询，范围查询，距离查询，经纬度Hash等常见操作。