# Linux

网易镜像地址：http://mirrors.163.com/



## 一，目录结构

几个重要的目录

```
/bin 存放经常使用的命令
/home 存放普通用户的主目录
/root 系统管理员
/media 识别的设备
/mnt 临时挂载的文件系统
/usr/local 安装目录
/var 存放不断变化的文件
```

## 二，命令

### 1，vi和vim

![image-20200624093142942](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200624093142942.png)

快捷键

拷贝当前行   yy , 拷贝当前行向下的 5 行 5yy，并粘贴（p）。

删除当前行  dd  , 删除当前行向下的 5 行 5dd

设置文件的行号，取消文件的行号.命令行下  : set nu 和  :set nonu

快速移动：20 shift+g 



### 2，开机关机

```
shutdown -h now : 表示立即关机

shutdown -h 1 : 表示 1 分钟后关机

shutdown -r now: 立即重启

syn：把内存的数据同步到磁盘

reboot：就是重启系统。
```

 

###  3，用户管理

#### 用户相关

 添加用户

```yml
useradd  [选项]  用户名
# 将tutu划分到renlei这个目录
useradd -d /home/renlei tutu
```

 添加密码

```
passwd	用户名
```

 删除用户

```yml
userdel 用户名
# 删除用户 xh 以及用户主目录
userdel -r 用户名
```

 查询用户

```
id 用户名
```

 切换用户

```
su	–	切换用户名
```

#### 组相关

Linux中，每个文件都对应着所有者，所在组，其他组

查看文件所有者

```
ls -ahl
```

修改文件所有者

```
chown 用户名 文件名
```

修改文件的所在组

```
chgrp 组名 文件名
```

改变用户所在组

```
usermod	–g	组名	用户名
```

修改文件所有者

```
chown  newowner  file  改变文件的所有者

chown newowner:newgroup  file  改变用户的所有者和所有组

-R   如果是目录 则使其下所有子文件或目录递归生效
```

修改文件所在组

```
chgrp newgroup file	改变文件的所有组
```

添加组

那几添加组

```yml
groupadd 组名
# 添加用户到组
useradd	-g 用户组 用户名
```

删除组

```
groupdel 组名
```

修改组

```
# 将用户的组修改
usermod	-g 用户组 用户名
```

#### 相关文件

/etc/passwd 文件：记录用户的各种信息

/etc/shadow 文件：口令的配置文件

/etc/group 文件：记录linux的组的信息



### 4，帮助指令

```
man 指令

help 指令
```



### 5，文件目录

#### pwd指令

显示当前目录的绝对目录

```yml
pwd
```

#### ls指令

```yml
ls [选项]	[目录或是文件]

ls -l #显示所有目录
ks -al # 显示所有文件和目录以及隐藏文件
```

#### cd指令

 切换到指定目录

```yml
cd	[参数]
```

#### mkdir指令

创建一个目录

```
mkdir [选项]
```

#### rmdir指令

删除空目录

```yml
rmdir	[选项]	要删除的空目录、

rmdir -rf 目录1  #删除不是空的目录1
```



#### touch指令

创建空文件

```
touch 文件名称
```



#### cp指令

拷贝文件到指定的目录

```yml
cp [选项] source dest

-r ：递归复制整个文件夹
# 将a拷贝到A
cp a.txt /A
# 将A下的文件拷贝到B目录
cp /A /B
```



#### rm指令

删除文件或者目录

```
rm	[选项]	要删除的文件或目录
-r ：递归删除整个文件夹
-f ： 强制删除不提示
```



#### mv指令

移动文件或者目录，以及重命名

```yml
# 重命名 
mv	oldNameFile newNameFile

# 移动文件
mv /temp/movefile /targetFolder 
```



#### cat指令

查看文件内容，以只读的方式

```
cat	[选项] 要查看的文件
-n ：显示行号
```



#### more指令

按页显示文本内容

![image-20200625151618089](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625151618089.png)

#### less指令

less 指令用来分屏查看文件内容，它的功能与 more 指令类似，但是比 more 指令更加强大，支持各种显示终端。less 指令在显示文件内容时，并不是一次将整个文件加载之后才显示，而是根据显示需要加载内容，对于显示大型文件具有较高的效率



#### 追加

覆盖原来的内容

```
> 
```

追加到原来的内容后面

```
>>
```



#### echo指令

输出内容到控制台



#### head指令

显示文件开头部分

```yml
head -n 5 文件	#功能描述：查看文件头 5 行内容，5 可以是任意行数
```



#### tail指令

输出文件尾部内容

```
tail a.txt : 默认显示尾部10行
tail -n 5 a.txt : 显示5行
tail -f a.txt : 实时追踪文件的更新
```



#### In指令

给一个文件创建一个软连接

```yml
ln -s [原文件或目录] [软链接名]
# 这样使用软连接名就会连接到指定目录或者文件
```



#### history指令

查看已经执行过的命令



### 6，时间日期类

#### date指令

显示当前日期



### 7，搜索查询类

#### find指令

从指定目录向下递归地遍历其各个子目录，将满足条件的文件或者目录显示在终端

```
find	[搜索范围]	[选项]
```

![image-20200625165801196](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625165801196.png)

```
find /home -name a.txt
```

#### locate指令

快速定位文件位置，Locate 指令无需遍历整个文件系统，查询速度较快。为了保证查询结果的准确度，管理员必须定期更新 locate 时刻

```
locate a.txt
```

#### grep指令

过滤查找

```
grep -n 显示匹配行和行号
grep -i 忽略字母大小写
```



### 8，压缩解压

#### gzip/gunzip指令

gzip 用于压缩文件， gunzip 用于解压的

注意：压缩后不会保留原来的文件



#### zip/unzip指令

```
zip -r 压缩目录
unzip -d 目录  解压后放置在哪个目录
```



#### tar指令

tar 指令 是打包指令，最后打包后的文件是 .tar.gz 的文件

![image-20200625171041605](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625171041605.png)





```yml
#将a和b打包成A.tar.gz
tar -zcvf A.tar.gz a.txt b.txt

#将A解压到dog目录，前提是dog目录存在
tar -zcvf A.tar.gz -C /dog/
```



























## 三，运行级别

配置文件：/etc/inittab

```
0：关机
1：单用户【找回丢失密码】
2：多用户状态没有网络服务
3：多用户状态有网络服务
4：系统未使用保留给用户
5：图形界面
6：系统重启
```

### 1，切换级别

```
init [0,1,2,3,4,5,6]
```

### 2，找回root密码

```
开机->在引导时输入 回车键-> 看到一个界面输入 e ->  看到一个新的界面，选中第二行（编辑内核）在输入  e->  在这行最后输入	1 ,再输入 回车键->再次输入 b ,这时就会进入到单用户模式。
这时，我们就进入到单用户模式，使用 passwd  指令来修改 root  密码。
```



## 四，权限

ls  -l 中显示的内容如下：

```
**-rwxrw-r--** 1 root root 1213 Feb 2 09:39 abc
```

1)第 0 位确定文件类型(d, - , l , c , b)

2)第 1-3 位确定所有者（该文件的所有者）拥有该文件的权限。---User

3)第 4-6 位确定所属组（同用户组的）拥有该文件的权限，---Group

4)第 7-9 位确定其他用户拥有该文件的权限 ---Other



### rwx 作用到文件

1) [ r ]代表可读(read): 可以读取,查看

2)  [ w ]代表可写(write): 可以修改,但是不代表可以删除该文件,删除一个文件的前提条件是对该文件所在的目录有写权限，才能删除该文件.

3) [ x ]代表可执行(execute):可以被执行



### rwx 作用到文件

1) [ r ]代表可读(read): 可以读取,查看

2)  [ w ]代表可写(write): 可以修改,但是不代表可以删除该文件,删除一个文件的前提条件是对该文件所在的目录有写权限，才能删除该文件.

3) [ x ]代表可执行(execute):可以被执行



### 修改权限

#### 第一种方式：+ 、-、= 变更权限

```yml
#u:所有者	g:所有组	o:其他人	a:所有人(u、g、o 的总和)

1)	chmod	u=rwx,g=rx,o=x	文件目录名
2)	chmod	o+w	文件目录名
3)	chmod	a-x	文件目录名
```

#### 第二种方式：通过数字变更权限

规则：r=4 w=2 x=1     ,   rwx=4+2+1=7 

> chmod u=rwx,g=rx,o=x       文件目录名
>
> 相当于 
>
>  chmod  751                    文件目录名



```
要求：将  /home/abc.txt 文件的权限修改成 rwxr-xr-x, 使用给数字的方式实现：

rwx = 4+2+1 = 7

r-x = 4+1=5

r-x = 4+1 =5

指令：chmod 755 /home/abc.txt
```



## 五，任务调度

任务调度：是指系统在某个时间执行的特定的命令或程序。

```
crontab [选项]
```

![image-20200625174336176](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625174336176.png)



```
设置任务调度文件：/etc/crontab
设置个人任务调度。执行 crontab –e 命令。接着输入任务到调度文件
如：*/1 * * * * ls –l	/etc/ > /tmp/to.txt
意思说每小时的每分钟执行 ls –l /etc/ > /tmp/to.txt 命令
```

![image-20200625174528063](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625174528063.png)





```
1)	conrtab –r：终止任务调度。
2)	crontab –l：列出当前有那些任务调度
3)	service crond restart	[重启任务调度]
```

## 六，分区挂载

需求是给我们的 Linux 系统增加一个新的硬盘，并且挂载到/home/newdisk

1，添加一个硬盘

2，分区命令

```
fdisk	/dev/sdb

开始分区后输入 n，新增分区，然后选择 p ，分区类型为主分区。两次回车默认剩余全 部空间。最后输入 w 写入分区并退出，若不保存退出输入 q
```

相关指令

```
•	m	显示命令列表
•	p	显示磁盘分区 同 fdisk	–l
•	n	新增分区
•	d	删除分区
•	w	写入并退出
```



3，格式化磁盘

```
mkfs -t	ext4 /dev/sdb1
```

4，挂载

mount       /dev/sdb1   /newdisk

```
mount     设备名称  挂载目录
```

5，永久挂载

 永久挂载: 通过修改/etc/fstab 实现挂载添加完成后  执行 mount   –a 即刻生效



6，查询操作

查询系统整体磁盘使用情况

```
df -h
```

查询指定目录的磁盘占用情况

```
du -h	/目录
-s 指定目录占用大小汇总
-h 带计量单位
-a 含文件
```



## 七，网络配置

### 1，修改网关

### 2，网络配置

自动获取

静态获取（自己百度）



第一步：修改文件

```
vi/ etc/sysconfig/network-scripts/ifcfg-eth0
```



## 八，进程管理

```
ps -aux
```

![image-20200625175909514](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625175909514.png)



以全格式显示当前所有的进程，查看进程的父进程。

```
ps -ef
展示的其中PPID就是父进程
```



终止进程

```
kill	[选项] 进程号（功能描述：通过进程号杀死进程）
killall 进程名称（功能描述：通过进程名称杀死进程，也支持通配符，这在系统因负载过大而变得很慢时很有用）


-9 :表示强迫进程立即停止
```



查看进程树

```
pstree [选项] ,可以更加直观的来看进程信息

-p :显示进程的 PID
-u :显示进程的所属用户
```



动态监控进程：top

```
-d：每隔几秒更新
-i：不显示任何闲置和僵死进程
-p：指定监控ID
```

互交指令

```
P：cpu使用率排序
M：内存排序
N：PID排序
q：退出
u：指定用户
k：杀死
```



查看网络情况

```
netstat [选项]
netstat -anp
```

-an  按一定顺序排列输出

-p  显示哪个进程在调用



## 九，服务管理

在 CentOS7.0 后 不再使用 service ,而是 systemctl

查看服务

```
ls -l /etc/init.d/

或者

chkconfig --list
chkconfig	服务名	--list
chkconfig	--level	5	服务名	on/off
```

运行级别



• 运行级别 0：系统停机状态，系统默认运行级别不能设为 0，否则不能正常启动

• 运行级别 1：单用户工作状态，root 权限，用于系统维护，禁止远程登陆

• 运行级别 2：多用户状态(没有 NFS)，不支持网络

• 运行级别 3：完全的多用户状态(有 NFS)，登陆后进入控制台命令行模式

• 运行级别 4：系统未使用，保留

• 运行级别 5：X11 控制台，登陆后进入图形 GUI 模式

• 运行级别 6：系统正常关闭并重启，默认运行级别不能设为 6，否则不能正常启动

![image-20200625180907913](C:\Users\涂涂\AppData\Roaming\Typora\typora-user-images\image-20200625180907913.png)



## 十，下载

### rmp

```
查询已安装的 rpm 列表 rpm  –qa|grep xx

rpm -qa :查询所安装的所有 rpm 软件包

rpm -qi  软件包名 ：查询软件包信息

rpm -ql  软件包名 :查询软件包中的文件

rpm -qf 文件全路径名 查询文件所属的软件包

rpm -e RPM 包的名称：卸载

rpm -ivh RPM 包全路径名称：安装
i=install 安 装
v=verbose 提 示
h=hash	进度条
```



yum

```
yum list|grep xx 软件列表

yum install xxx
```

