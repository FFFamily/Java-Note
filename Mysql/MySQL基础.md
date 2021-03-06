﻿# 数据库

## 一，概述

### 数据库相关概念

​	1、DB：数据库，保存一组有组织的数据的容器

> 数据库是管理数据的一种技术

​	2、DBMS：数据库管理系统，又称为数据库软件（产品），用于管理DB中的数据

​	3、SQL:结构化查询语言，用于和DBMS通信的语言

​	4、数据：是数据库中存储的基本对象，是描述事物的符号记录

> 数据库数据具有永久存储，有组织和可共享的基本特点

​	5、DBS：数据库系统

> 一般由数据库，数据库管理系统，应用程序，数据库管理人员组成



相关名称

- **数据库:** 数据库是一些关联表的集合。
- **数据表:** 表是数据的矩阵。在一个数据库中的表看起来像一个简单的电子表格。
- **列:** 一列(数据元素) 包含了相同类型的数据, 例如邮政编码的数据。
- **行：**一行（=元组，或记录）是一组相关的数据，例如一条用户订阅的数据
- **冗余**：存储两倍数据，冗余降低了性能，但提高了数据的安全性。
- **主键**：主键是唯一的。一个数据表中只能包含一个主键。你可以使用主键来查询数据。
- **外键：**外键用于关联两个表。
- **复合键**：复合键（组合键）将多个列作为一个索引键，一般用于复合索引。
- **索引：**使用索引可快速访问数据库表中的特定信息。索引是对数据库表中一列或多列的值进行排序的一种结构。类似于书籍的目录。
- **参照完整性:** 参照的完整性要求关系中不允许引用不存在的实体。与实体完整性是关系模型必须满足的完整性约束条件，目的是保证数据的一致性。

- **表头(header)**: 每一列的名称;
- **列(col)**: 具有相同数据类型的数据的集合;
- **行(row)**: 每一行用来描述某条记录的具体信息;
- **值(value)**: 行的具体信息, 每个值必须与该列的数据类型相同;
- **键(key)**: 键的值在当前列中具有唯一性。	

- **表（table）**：结构化的文件 ，可以用来储存特定类型的数据



### 数据库的好处

​	1.持久化数据到本地
​	2.可以实现结构化查询，方便管理
​	

### 数据库的结构

从数据库管理角度看，数据库通常采用三级模式结构

从数据库的最终用户来看，数据库结构分为集中式结构，文件服务器结构，客户/服务器结构等



#### 1，模式概念

数据模型：是描述数据的组织形式

模式：用给定的数据模型对具体数据的描述，是对全体数据的逻辑结构和特征的描述，值涉及“型”，不涉及具体的值

模式实例：指的是每一行数据就是模式的一个具体实例，一个模式可以有多个实例

> 模式是相对稳定（因为结构不会经常变动）
>
> 实例是相对变动（因为数据的值会经常变化）



尽管数据库管理系统产品很多，但是在体系上的机构通常都具有相同的特征，第一采用三级模式结构并提供二级映像功能



#### 2，三级模式

> 内部结构

指内模式，外模式，模式

作用：确保数	





**外模式：用户所看到的数据视图（用户模式或者子模式）**

1，外模式的内容来自模式

2，外模式是对数据库用户能够看见并且使用的局部数据的逻辑结构和特征的描述，是模式的子集或局部重构

3，用户只能看到想看的数据，外模式会屏蔽不需要的数据，确保误操作引起的数据损失，保证数据安全

4，外模式对应到关系数据库中的“视图”





**模式：整体数据的结构（逻辑模式或者概念模型）**

1，是对数据库中全体数据的逻辑结构和特征的描述，表示数据库中的全部信息

2，几部设计数据的物理存储细节和硬件环境，也不涉及具体的开发环境

3，一个数据库只有一种模式

4，定义数据库模式既要定义数据的逻辑结构，也要定义之间的联系，数据有关的安全性，完整性

5，数据库管理系统提供了模式定义语言来定义数据库中的模式



> 个人理解就是数据库中的库和表

> 个人理解“逻辑结构和特征”是讲的数据表中每一行的数据列以及和其他表的关系



**内模式：数据的物理存储方式（存储模式）**

1，是对数据库整个底层的表示，描述了数据的存储结构（数据的存储方式，是顺序还是B树还是散列）

2，捏模式不是关系的





#### 3，模式映像和数据独立性

为了能在内部实现三个抽层的联系和转换，数据库管理系统提供了2级映像：外模式/模式映像，模式/内模式映像



**外模式/模式映像**

当模式改变时，数据库管理人员用外模式定义语句，调整外模式到模式的映像，从而保持外模式不变

由于应用程序一般是依据数据的外模式编写，所以不用修改应用程序，保证了程序和数据的逻辑独立性



**模式/内模式映像**

当数据库的物理存储改变（更换存储位置），只需要对模式/内模式映像做调整，就可以保持模式不变，从而不用改变应用程序，保证了数据和程序的物理独立性



#### 4，外部结构

1.集中式系统：数据库系统全部集中在一台计算机

​	1）单用户系统

​	2）多用户系统



2.分布式系统：数据库被划分逻辑关联、而物理分布在计算机网络不同常德的计算机中，且整体操作和分布控制数据能力的数据库系统

特点：

​	a.分布性：数据分布存储在不同的地方

​	b.自治性：每个地方都是一个独立的数据库系统

​	c.全局性：逻辑上是一个整体

3.客户机/服务机系统

4.浏览器/服务器系统



C/S与D/S的比较

​	a.面对广域网使用bs，消息迅速，维护简单，操作方便

​	b.CS安全性高，交互性强，处理数据量大，查询灵活



### 数据模型

数据的静态特征：数据的基本结构，数据的联系，数据取值范围约束

数据的动态特征：数据可以进行操作以及操作规则

数据模型：是对现实世界数据特征的抽象，用于表达现实世界中的对象，将现实世界中的信息用一种规范的，易于处理的方式表达出来

> 实际上就是模型化数据和信息的工具

#### 1，组成要素

1. 数据结构：研究对象的集合，描述系统的静态特征
2. 数据操作：对对象集合的操作，描述系统的动态特征
3. 数据完整性：对数据模型提出的一系列约束或规则



#### 2，分类

##### 1，概念层数据模型

概念层数据模型是指抽象现实系统中有应有价值的元素以及其关联关系、反应现实系统中有应用价值的信息结构，并且不依赖于数据的组织层数据模型

> 来自《数据库原理与应用》
>
> 我没搞懂书中的定义

概念数据模型（Conceptual Data Model），简称概念模型，是面向数据库用户的现实世界的模型，主要用来描述世界的概念化结构，它使数据库的设计人员在设计的初始阶段，摆脱计算机系统及DBMS的具体技术问题，集中精力分析数据以及数据之间的联系等，与具体的数据库管理系统（Database Management System，简称DBMS）无关

> 来自《百度百科》



##### 2，组织层数据模型

组织层数据模型是从数据的组织形式的角度来描述信息

主要的组织层数据模型：层次模型，网状模型，关系模型，面向对象模型，对象关系模型



**2.1，层次数据模型**

采用层次模型作为数据的组织方式，用树型结构表示实体和实体之间的联系

优点：查询快，结构简单

缺点：

插入和删除操作限制多

查询子女结点必须通过双亲结点

只能表示实体之间的1:n的关系，不能表示m:n的复杂关系																				

![1](.\img\1.png)



**2.2，网状数据模型**

采用图形结构表示实体和实体之间的联系

优点：存储效率高，可以表示复杂的关系

缺点：

结构复杂，必须了解表的结构才能很好使用

插入和删除更复杂

![2](.\img\2.png)

**2.3，关系数据模型**

采用关系模型作为组织方式，用关系表示实体间的联系

关系型数据库是目前最流行的数据库，同时也是被普遍使用的数据库



1，关系数据模型中，无论是是实体、还是实体之间的联系都是被映射成统一的关系---一张二维表，在关系模型中，操作的对象和结果都是一张二维表

2，关系型数据库可用于表示实体之间的多对多的关系

**组成**
数据结构：用二维表来组织数据

数据操作：关系运算，交并差等等

数据完整性约束：与现实世界中应用需求的数据的相容性和正确性，数据库内数据之间的相容性和正确性



**基本术语**

关系：二维表，表名就是关系名

属性：表中每一列为一个属性

值域：属性的取值范围

元组：表的一行数据

分量：元组中的每一个属性称为分量

关系模式：二维表的结构，可以理解为数据类型

关系数据库：对应于一个关系模型的所有关系集合

候选键：属性的值能够唯一表示一个关系的元组但又不包含多余的属性

主键：确定唯一的元组

主属性和非主属性：包含任意候选键的属性为主属性，不包含就是非



**集合运算**

| ID   | name | gender | age  |
| ---- | ---- | ------ | ---- |
| 1    | 张三 | 男     | 12   |
| 2    | 李四 | 男     | 13   |
| 3    | 王五 | 女     | 14   |

--

| ID   | name | gender | age  |
| ---- | ---- | ------ | ---- |
| 4    | 二蛋 | 女     | 23   |
| 2    | 李四 | 男     | 13   |
| 6    | 七七 | 女     | 77   |



并运算

| ID   | name | gender | age  |
| ---- | ---- | ------ | ---- |
| 2    | 李四 | 男     | 13   |

交运算

| ID   | name | gender | age  |
| ---- | ---- | ------ | ---- |
| 1    | 张三 | 男     | 12   |
| 2    | 李四 | 男     | 13   |
| 3    | 王五 | 女     | 14   |
| 4    | 二蛋 | 女     | 23   |
| 6    | 七七 | 女     | 77   |

差运算

| ID   | name | gender | age  |
| ---- | ---- | ------ | ---- |
| 1    | 张三 | 男     | 12   |
| 3    | 王五 | 女     | 14   |

笛卡尔积

> 不演示

选择

> 不演示

投影

> 不演示

连接

> 不演示

除

> 不演示





## 二，范式

#### 概念

设计数据库时，**需要遵循的一些规范**。

要遵循后边的范式要求，必须先遵循前边的所有范式要求 

设计关系数据库时，遵从不同的规范要求，设计出合理的关系型数据库，这些不同的规范要求被称为不同的范式，各种范式呈递次规范，越高的范式数据库冗余越小。

#### 六种范式

第一范式（1NF）、第二范式（2NF）、第三范式（3NF）、巴斯-科德范式（BCNF）、第四范式(4NF）和第五范式（5NF，又称完美范式）



#### 相关概念

> 1. 函数依赖：A-->B,如果通过A属性(属性组)的值，可以确定唯一B属性的值。则称B依赖于A                
> 2. 完全函数依赖：A-->B， 如果A是一个属性组，则B属性值得确定需要依赖于A属性组中所有的属性值 
> 3. 部分函数依赖：A-->B， 如果A是一个属性组，则B属性值得确定只需要依赖于A属性组中某一些值即可
> 4. 传递函数依赖：A-->B, B -- >C . 如果通过A属性(属性组)的值，可以确定唯一B属性的值，在通过B属性（属性组）的值可以确定唯一C属性的值，则称 C 传递函数依赖于A
> 5. 码：如果在一张表中，一个属性或属性组，被其他所有属性所完全依赖，则称这个属性(属性组)为该表的码
> 6. 主属性：码属性组中的所有属性
> 7. 非主属性：除过码属性组的属性



**一般来说，一个数据库设计符合3NF或BCNF就可以了。**



**第一范式（1NF）**：每一列都是不可分割的原子数据项

> 指数据库表的每一列都是不可分割的基本数据项，同一列中不能有多个值

**第二范式（2NF）**：在1NF的基础上，非码属性必须完全依赖于码（在1NF基础上消除非主属性对主码的部分函数依赖）

即，表属性依赖于主键

> 要求数 据库表中的每个实例或行必须可以被惟一地区分。为实现区分通常需要为表加上一个列，以存储各个实例的惟一标识

**第三范式（3NF）**：在2NF基础上，任何非主属性不依赖于其它非主属性（在2NF基础上消除传递依赖）

即，不能出现重复的非主键

> 要求一个数据库表中不包含已在其它表中已包含的非主关键字信息，就是属性不依赖于其它非主属性。

**巴斯-科德范式（BCNF）**：在满足第三范式（3NF）基础上，任何非主属性不能对主键子集依赖（即在3NF基础上，消除主属性对候选码的部分函数依赖和传递函数依赖）

**第四范式（4NF）**：第四范式即在满足巴斯-科德范式（BCNF）的基础上，消除非平凡且非函数依赖的多值依赖（即把同一表内的多对多关系删除）

**第五范式（5NF）**：在满足第四范式（4NF）的基础上，消除不是由候选码所蕴含的连接依赖







## 三，语法规范

​	1.不区分大小写,但建议关键字大写，表名、列名小写
​	2.每条命令最好用分号结尾
​	3.**可使用空格和缩进**来增强语句的可读性
​	4.注释
​		单行注释：#注释文字
​		单行注释：-- 注释文字
​		多行注释：/* 注释文字  */
​	
​	
​	

## 四，SQL的语言分类

1，DQL（Data Query Language）：数据查询语言
2，DML(Data Manipulate Language)：用来对数据库中**表的数据**进行增删改
3，DDL（Data Define Language）：**用来定义数据库对象**：数据库，表，列等
4，DCL(Data Control Language)：数据控制语言，用来定义数据库的**访问权限和安全级别**，及**创建用户**





### DQL

```mysql
	# 语法	
	select
		字段列表
	from
		表名列表
	where
		条件列表
	group by
		分组字段
	having
		分组之后的条件
	order by
		排序
	limit
		分页限定
```



#### 基础查询
 	语法：

```sql
SELECT 
	要查询的东西
FROM 
	表名;
```



特点：
①通过select查询完的结果 ，是一个虚拟的表格，不是真实存在
② 要查询的东西 可以是常量值、可以是表达式、可以是字段、可以是函数



#### 条件查询

​	条件查询：根据条件过滤原始表的数据，查询到想要的数据
​	语法：

```sql
select 
	要查询的字段|表达式|常量值|函数
from 
	表
where 
	条件;
```



分类：
一、条件表达式
	示例：salary>10000
	条件运算符：> < >= <= = != <>

二、逻辑表达式
	示例：salary>10000 && salary<20000
	逻辑运算符：and（&&），or（||），not（!）



#### 模糊查询

​	语法

```sql
select 
	要查询的字段|表达式|常量值|函数
from 
	表
where 
	条件
like
	'%条件%';
```

示例：last_name like 'a%'



#### 排序查询	

```mysql
语法：
select
	要查询的东西
from
	表
where 
	条件
order by 
	排序的字段|表达式|函数|别名 
asc|desc
	升序|降序
```

#### 常见函数

一、单行函数

	1、字符函数
		concat拼接
		substr截取子串
		upper转换成大写
		lower转换成小写
		trim去前后指定的空格和字符
	    ltrim去左边空格
		rtrim去右边空格
	    replace替换
		lpad左填充
	    rpad右填充
		instr返回子串第一次出现的索引
	    length 获取字节个数	
	2、数学函数
		round 四舍五入
		rand 随机数
		floor向下取整
		ceil向上取整
		mod取余
		truncate截断
	3、日期函数
		now当前系统日期+时间
		curdate当前系统日期
		curtime当前系统时间
		str_to_date 将字符转换成日期
		date_format将日期转换成字符
	4、流程控制函数
		if 处理双分支
		case语句 处理多分支
			情况1：处理等值判断
			情况2：处理条件判断
		
	5、其他函数
		version版本
		database当前库
		user当前连接用户





二、分组函数


		sum 求和
		max 最大值
		min 最小值
		avg 平均值
		count 计数
	
		特点：
		1、以上五个分组函数都忽略null值，除了count(*)
		2、sum和avg一般用于处理数值型
			max、min、count可以处理任何数据类型
	    3、都可以搭配distinct使用，用于统计去重后的结果
		4、count的参数可以支持：
			字段、*、常量值，一般放1

#### 分组查询
​	语法：

```sql
select 
	查询的字段，分组函数
from 
	表
group by 
	分组的字段
```



特点：
1、可以按单个字段分组
2、和分组函数一同查询的字段最好是分组后的字段
3、分组筛选

```
		针对的表	位置			关键字
分组前筛选：	原始表		group by的前面		where
分组后筛选：	分组后的结果集	group by的后面		having
```

4、可以按多个字段分组，字段之间用逗号隔开
5、可以支持排序
6、having后可以支持别名





#### 多表连接查询

一、传统模式下的连接 ：等值连接——非等值连接

1，等值连接的结果 = 多个表的交集
2，n表连接，至少需要n-1个连接条件
3，多个表不分主次，没有顺序要求
4，一般为表起别名，提高阅读性和性能



二、sql99语法：通过join关键字实现连接

含义：1999年推出的sql语法

支持：等值连接、非等值连接 （内连接），外连接，交叉连接

语法

	select 字段
	from 表
	inner|left outer|right outer|cross join 表2 on  连接条件
	inner|left outer|right outer|cross join 表3 on  连接条件

隐式内连接：使用where条件消除无用数据

```mysql
select + 列名1，列名2...+ from 表名 +where 条件
```

显示内连接

```mysql
select 字段列表 from 表名1 [inner] join 表名2 on 条件
```

左外连接：

```mysql
select 字段列表 from 表1 left [outer] join 表2 on 条件
```

右外连接：

```mysql
select 字段列表 from 表1 right [outer] join 表2 on 条件
```



三、自连接

sql99

	SELECT e.last_name,m.last_name
	FROM employees e
	JOIN employees m ON e.`manager_id`=m.`employee_id`;

sql92


	SELECT e.last_name,m.last_name
	FROM employees e,employees m 
	WHERE e.`manager_id`=m.`employee_id`;



#### 子查询

含义：

一条查询语句中又嵌套了另一条完整的select语句，其中被嵌套的select语句，称为子查询或内查询
在外面的查询语句，称为主查询或外查询

特点：

1、子查询都放在小括号内
2、子查询可以放在from后面、select后面、where后面、having后面，但一般放在条件的右侧
3、子查询优先于主查询执行，主查询使用了子查询的执行结果
4、子查询根据查询结果的行数不同分为以下两类：



单行子查询

结果集只有一行
一般搭配单行操作符使用：> < = <> >= <= 
非法使用子查询的情况：
	a、子查询的结果为一组值
	b、子查询的结果为空



多行子查询
结果集有多行
一般搭配多行操作符使用：any、all、in、not in
	in： 属于子查询结果中的任意一个就行
	any和all往往可以用其他查询代替



#### 分页查询

语法：

```sql
select 字段|表达式,...
from 表
where 条件
group by 分组字段
having 条件
order by 排序的字段
limit 起始的条目索引，条目数;
```

特点：

1.起始条目索引从0开始

2.limit子句放在查询语句的最后

```sql
3.公式：select * from  表 limit （page-1）* sizePerPage,sizePerPage
```



#### 联合查询

引入：
	union 联合、合并

语法：

	select 字段|常量|表达式|函数 【from 表】 【where 条件】 union 【all】
	select 字段|常量|表达式|函数 【from 表】 【where 条件】 union 【all】
	select 字段|常量|表达式|函数 【from 表】 【where 条件】 union  【all】
	.....
	select 字段|常量|表达式|函数 【from 表】 【where 条件】

特点：

1、多条查询语句的查询的列数必须是一致的
2、多条查询语句的查询的列的类型几乎相同
3、union代表去重，union all代表不去重

### DML

#### 插入

语法：

```sql
insert into 表名(字段名，...) values (值1，...);
```

特点：

	1、字段类型和值类型一致或兼容，而且一一对应
	2、可以为空的字段，可以不用插入值，或用null填充
	3、不可以为空的字段，必须插入值
	4、字段个数和值的个数必须一致
	5、字段可以省略，但默认所有字段，并且顺序和表中的存储顺序一致



#### 修改

修改单表语法：

```sql
update 表名 set 字段=新值,字段=新值 where 条件
```
修改多表语法：

```sql
update 表1 别名1,表2 别名2
set 字段=新值，字段=新值
where 连接条件
and 筛选条件
```

#### 删除

方式1：delete语句 

单表的删除：

```sql
delete from 表名 where 筛选条件
```

多表的删除：

```sql
delete 别名1，别名2
from 表1 别名1，表2 别名2
where 连接条件
and 筛选条件;
```


方式2：truncate语句

	truncate table 表名



两种方式的区别【面试题】
	

	#1.truncate不能加where条件，而delete可以加where条件
	
	#2.truncate的效率高一点
	
	#3.truncate 删除带自增长的列的表后，如果再插入数据，数据从1开始
	#delete 删除带自增长列的表后，如果再插入数据，数据从上一次的断点处开始
	
	#4.truncate删除不能回滚，delete删除可以回滚



### DDL

#### 库的管理
库的管理：

一、创建库

```mysql
CREATE DATABASE IF NOT EXISTS "库名" CHARACTER SET "字符集名"
```

二、删除库

```mysql
drop database 库名
```
三、查询库

```mysql
show databases; # 查询当前所有库

show create database 数据库名称; # 查询数据库的创建时间
```

四、修改库

```mysql
alter database 数据库名称 character set 字符集名称; # 修改数据库的字符集 

RENAME database oldName TO newName # 修改数据库名
```

五、使用

```MYSQL
USE 数据库名  
```





#### 表的管理

1.创建表

```mysql
CREATE TABLE IF NOT EXISTS info(
	stuId INT,
	stuName VARCHAR(20),
	gender VARCHAR,
	bornDate Date
);	
```

2.修改表

```mysql
ALTER TABLE 表名 ADD|MODIFY|DROP|CHANGE COLUMN 字段名 【字段类型】;	
```

3.修改字段名

```mysql
ALTER TABLE studentinfo CHANGE COLUMN sex gender CHAR;	
```

4.修改表名

```mysql
ALTER TABLE stuinfo RENAME [TO]  studentinfo;
```

5.修改字段类型和列级约束

```mysql
ALTER TABLE studentinfo MODIFY COLUMN borndate DATE ;
```

6.添加字段

```mysql
ALTER TABLE studentinfo ADD COLUMN email VARCHAR(20) first;
```

7.删除字段

```mysql
ALTER TABLE studentinfo DROP COLUMN email;
```

8.删除表

```mysql
DROP TABLE [IF EXISTS] studentinfo;
```

9.查询某个数据库中所有的表名称

```mysql
show tables;
```

10.查询表结构

```MYSQL
desc 表名
```



### DCL

#### 管理用户

添加用户

```mysql
CREATE USER '用户名' @ '主机名' IDENTIFIED BY '密码';
```

删除用户

```mysql
DROP USER '用户名' @ '主机名';
```

修改用户密码

```mysql
UPDATE USER SET PASSWORD = PASSWORD('新密码') WHERE USER = '用户名';
# UPDATE USER SET PASSWORD = PASSWORD('abc') WHERE USER = 'lisi';

SET PASSWORD FOR '用户名' @ '主机名' = PASSWORD('新密码');
# SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123');
```



>  mysql中忘记了root用户的密码？
>
> 1. cmd -- > net stop mysql 停止mysql服务
> 2.  使用无验证方式启动mysql服务： mysqld --skip-grant-tables               
> 3. 打开新的cmd窗口,直接输入mysql命令，敲回车。就可以登录成功 
> 4. use mysql; 
> 5. update user set password = password('你的新密码') where user = 'root'; 
> 6. 关闭两个窗口  
> 7.  打开任务管理器，手动结束mysqld.exe 的进程      
> 8. 启动mysql服务       
> 9. 使用新密码登录

 查询用户

```mysql
# 1. 切换到mysql数据库
USE myql;
# 2. 查询user表
SELECT * FROM USER;

```



通配符： % 表示可以在任意主机使用用户登录数据库



#### 权限管理

查询权限

```mysql
SHOW GRANTS FOR '用户名' @ '主机名';
# SHOW GRANTS FOR 'lisi'@'%';
```

授予权限

```mysql
grant 权限列表 on 数据库名.表名 to '用户名' @ '主机名';
```

撤销权限

```mysql
revoke 权限列表 on 数据库名.表名 from '用户名' @ '主机名';
# REVOKE UPDATE ON db3.`account` FROM 'lisi'@'%';
```



## 五，常见约束

```properties
NOT NULL: 非空约束
DEFAULT:
UNIQUE: 唯一约束
CHECK:
PRIMARY KEY: 主键约束
FOREIGN KEY: 外键约束
```

对主键/外键的修改

```mysql
# 在创建表时，添加主键约束
        create table stu(
            id int primary key,-- 给id添加主键约束
            name varchar(20)
        );
# 删除主键
        -- 错误 alter table stu modify id int ;
        ALTER TABLE stu DROP PRIMARY KEY;
# 创建完表后，添加主键
        ALTER TABLE stu MODIFY id INT PRIMARY KEY; 
            ALTER TABLE category ADD constraint pk_category_id primary key (id);
# alter table category 表示修改表category
# add constraint 增加约束
# pk_category_id 约束名称
    //pk是primary key的缩写,category是表名,id表示约束加在id字段上
    //可以自己定义约束名称
# primary key 约束类型是主键约束
# (id) 表示约束加在id字段上
```

其他约束的修改（非空为例子）

```mysql
# 创建表时添加约束
CREATE TABLE stu(
    id INT,
    NAME VARCHAR(20) NOT NULL 
);
# 创建表完后，添加非空约束
ALTER TABLE 表名 MODIFY 属性 NOT NULL;
# 删除name的非空约束
ALTER TABLE 表名 MODIFY 属性 VARCHAR(20);
```



**级联操作**

创建表之后

```mysql
ALTER TABLE 表名 ADD CONSTRAINT 外键名称 
	+ FOREIGN KEY (外键字段名称) REFERENCES 主表名称(主表列名称)
		+ ON UPDATE CASCADE ON DELETE CASCADE;
		
级联更新：ON UPDATE CASCADE 
级联删除：ON DELETE CASCADE
```

创建表时

```mysql
CREATE TABLE tab_route(
    FOREIGN KEY (cid) REFERENCES tab_category(cid)
);
```





## 六，数据库设计--多表操作

#### 分类

**（1）一对一**

实现方式：一对一关系实现，可以在任意一方添加唯一外键指向另一方的主键。

**（2）一对多**

实现方式：在多的一方建立外键，指向一的一方的主键

**（3）多对多**

实现方式：多对多关系实现需要借助第三张中间表。中间表至少包含两个字段，这两个字段作为第三张表的外键，分别指向两张表的主键



## 七，数据库事务

> 

### 含义

通过一组逻辑操作单元（一组`sql`语句），将数据从一种状态切换到另外一种状态

事务中，要么都执行，要么都不执行

### 特征（ACID）

- 原子性：事务是最小的执行单位，不允许分割，要么都执行，要么都回滚。
- 一致性：保证数据的状态操作前和操作后保持一致
- 隔离性：多个事务同时操作相同数据库的同一个数据时，一个事务的执行不受另外一个事务的干扰
- 持久性：一个事务一旦提交，则数据将持久化到本地，除非其他事务对其进行修改



### 步骤

	1、开启事务
	2、编写事务的一组逻辑操作单元（多条sql语句）
	3、提交事务或回滚事务



### 分类

隐式事务，没有明显的开启和结束事务的标志

	insert、update、delete语句本身就是一个事务

显式事务，具有明显的开启和结束事务的标志

​	1、开启事务：取消自动提交事务的功能

```
start transaction;
set autocommit=0;
```

​	2、编写事务的一组逻辑操作单元（多条sql语句）

```
insert
update
delete
```

​	3、提交事务或回滚事务

```
commit;
rollback

savepoint  断点
commit to 断点
rollback to 断点
```





### 隔离级别

事务并发问题如何发生？

> 当多个事务同时操作同一个数据库的相同数据时



事务的并发问题有哪些？

> 脏读：一个事务读取到了另外一个事务未提交的数据
> 不可重复读：同一个事务中，多次读取到的数据不一致
> 幻读：一个事务读取数据时，另外一个事务进行更新，导致第一个事务读取到了没有更新的数据



如何避免事务的并发问题？

--

| 隔离级别                     | 脏读 | 不可重复读 | 幻读 |
| ---------------------------- | ---- | ---------- | ---- |
| 不提交读（READ-UNCOMMITTED） | √    | √          | √    |
| 提交读（READ-COMMITTED）     | ×    | √          | √    |
| 可重复度（REPEATABLE-READ）  | ×    | ×          | √    |
| 可串行化（SERIALIZABLE）     | ×    | ×          | ×    |

**不可重复读和幻读区别**

不可重复读的重点是修改比如多次读取一条记录发现其中某些列的值被修改，幻读的重点在于新增或者删除比如多次读取一条记录发现记录增多或减少了



设置隔离级别：

```mysql
set session|global  transaction isolation level 隔离级别名;
```
查看隔离级别：

```mysql
SELECT @@tx_isolation;
# MySQL 8.0 为  SELECT @@transaction_isolation;

+-----------------+
| @@tx_isolation  |
+-----------------+
| REPEATABLE-READ |
+-----------------+
```







## 八，视图

含义：理解成一张虚拟的表



视图和表的区别：

视图：不占用物理空间，仅仅保存的是sql逻辑

表：完全相同	占用物理空间



视图的好处：

1、sql语句提高重用性，效率高
2、和表实现了分离，提高了安全性



### 创建

​	语法：

```mysql
CREATE VIEW  视图名
AS
查询语句;
```


### 增删改查
1、查看视图的数据

```mysql
SELECT * FROM my_v4;
SELECT * FROM my_v1 WHERE last_name='Partners';
```

2、插入视图的数据

```mysql
INSERT INTO my_v4(last_name,department_id) VALUES('虚竹',90);
```

3、修改视图的数据

```mysql
UPDATE my_v4 SET last_name ='梦姑' WHERE last_name='虚竹';	
```

4、删除视图的数据

```mysql
DELETE FROM my_v4;
```



### 某些视图不能更新
1，包含以下关键字的sql语句：分组函数、distinct、group  by、having、union或者union all
​2，常量视图
​3，Select中包含子查询
​4，join
​5，from一个不能更新的视图
​6，where子句的子查询引用了from子句中的表

### 视图逻辑的更新
方式一：

```mysql
CREATE OR REPLACE VIEW test_v7
AS
SELECT last_name FROM employees WHERE employee_id>100;
```

方式二:

```mysql
ALTER VIEW test_v7
AS
SELECT employee_id FROM employees;

SELECT * FROM test_v7;
```
### 视图的删除
```mysql
DROP VIEW test_v1,test_v2,test_v3;
```

### 结构查看	
```mysql
DESC test_v7;
HOW CREATE VIEW test_v7;
```



## 九，存储过程

含义：一组经过预先编译的sql语句的集合
好处：

	1、提高了sql语句的重用性，减少了开发程序员的压力
	2、提高了效率
	3、减少了传输次数

分类：

	1、无返回无参
	2、仅仅带in类型，无返回有参
	3、仅仅带out类型，有返回无参
	4、既带in又带out，有返回有参
	5、带inout，有返回有参
	注意：in、out、inout都可以在一个存储过程中带多个
### 创建存储过程
语法：

```mysql
create procedure 存储过程名(in|out|inout 参数名  参数类型,...)
begin
	存储过程体
end
```

注意

	1、需要设置新的结束标记
	delimiter 新的结束标记
	示例：
	delimiter $
	
	CREATE PROCEDURE 存储过程名(IN|OUT|INOUT 参数名  参数类型,...)
	BEGIN
		sql语句1;
		sql语句2;
	
	END $
	
	2、存储过程体中可以有多条sql语句，如果仅仅一条sql语句，则可以省略begin end
	
	3、参数前面的符号的意思
	in:该参数只能作为输入 （该参数不能做返回值）
	out：该参数只能作为输出（该参数只能做返回值）
	inout：既能做输入又能做输出



### 调用存储过程

```
call 存储过程名(实参列表)
```



## 十，函数

### 创建函数

学过的函数：LENGTH、SUBSTR、CONCAT等
语法：

```mysql
CREATE FUNCTION 函数名(参数名 参数类型,...) RETURNS 返回类型
BEGIN
	函数体
END
```

### 调用函数
```mysql
SELECT 函数名（实参列表）
```

### 函数和存储过程的区别

|          | 关键字    | 调用语法        | 返回值          | 应用场景                                                 |
| -------- | --------- | --------------- | --------------- | -------------------------------------------------------- |
| 函数     | FUNCTION  | SELECT 函数()   | 只能是一个      | 一般用于查询结果为一个值并返回时，当有返回值而且仅仅一个 |
| 存储过程 | PROCEDURE | CALL 存储过程() | 可以有0个或多个 | 一般用于更新                                             |

​		

## 流程控制

### 系统变量
一、全局变量

作用域：针对于所有会话（连接）有效，但不能跨重启

```mysql
# 查看所有全局变量
SHOW GLOBAL VARIABLES;
# 查看满足条件的部分系统变量
SHOW GLOBAL VARIABLES LIKE '%char%';
# 查看指定的系统变量的值
SELECT @@global.autocommit;
# 为某个系统变量赋值
SET @@global.autocommit=0;
SET GLOBAL autocommit=0;
```

二、会话变量

作用域：针对于当前会话（连接）有效

```mysql
# 查看所有会话变量
SHOW SESSION VARIABLES;
# 查看满足条件的部分会话变量
SHOW SESSION VARIABLES LIKE '%char%';
# 查看指定的会话变量的值
SELECT @@autocommit;
SELECT @@session.tx_isolation;
# 为某个会话变量赋值
SET @@session.tx_isolation='read-uncommitted';
SET SESSION tx_isolation='read-committed';
```

### 自定义变量
#### 1、用户变量

声明并初始化：

```mysql
SET @变量名=值;
SET @变量名:=值;
SELECT @变量名:=值;
```
赋值：

方式一：一般用于赋简单的值

```mysql
SET 变量名=值;
SET 变量名:=值;
SELECT 变量名:=值;
```

方式二：一般用于赋表 中的字段值


```mysql
SELECT 
	字段名或表达式 
INTO 
	变量
FROM 
	表;
```

使用：

	select @变量名;



#### 2、局部变量

声明：

```mysql
declare 变量名 类型 [default 值];
```
赋值：

方式一：一般用于赋简单的值

```mysql
SET 变量名=值;
SET 变量名:=值;
SELECT 变量名:=值;
```

方式二：一般用于赋表 中的字段值


```mysql
SELECT 
	字段名或表达式 
INTO 
	变量
FROM 
	表;
```

使用：

```mysql
select 变量名
```



#### 3，二者的区别

|          | 作用域              | 定义位置            | 语法                     |
| -------- | ------------------- | ------------------- | ------------------------ |
| 用户变量 | 当前会话            | 会话的任何地方      | 加@符号，不用指定类型    |
| 局部变量 | 定义它的BEGIN END中 | BEGIN END的第一句话 | 一般不用加@,需要指定类型 |



### 分支

#### 1、if函数

​	语法：if(条件，值1，值2)
​	特点：可以用在任何位置

#### 2、case语句

语法：

	情况一：类似于switch
	case 表达式
	when 值1 then 结果1或语句1(如果是语句，需要加分号) 
	when 值2 then 结果2或语句2(如果是语句，需要加分号)
	...
	else 结果n或语句n(如果是语句，需要加分号)
	end 【case】（如果是放在begin end中需要加上case，如果放在select后面不需要）
	
	情况二：类似于多重if
	case 
	when 条件1 then 结果1或语句1(如果是语句，需要加分号) 
	when 条件2 then 结果2或语句2(如果是语句，需要加分号)
	...
	else 结果n或语句n(如果是语句，需要加分号)
	end 【case】（如果是放在begin end中需要加上case，如果放在select后面不需要）


特点：
	可以用在任何位置

#### 3、if elseif语句

语法：

	if 情况1 then 语句1;
	elseif 情况2 then 语句2;
	...
	else 语句n;
	end if;

特点：
	只能用在begin end中

三者比较：
	if函数		简单双分支
	case结构	等值判断 的多分支
	if结构		区间判断 的多分支

### 循环

语法：


```mysql
WHILE 循环条件  DO
	循环体
END WHILE;
```

特点：

	只能放在BEGIN END里面
	
	如果要搭配leave跳转语句，需要使用标签，否则可以不用标签
	
	leave类似于java中的break语句，跳出所在循环



































