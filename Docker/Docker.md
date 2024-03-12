Docker基础篇之快速上手

# Docker简介

一款产 品从开发到上线，从操作系统，到运行环境，再到应用配置。作为开发+运维之间的协作我们需要关心很多东西，这也是很多互联网公司都不得不面对的问题，特别是各种版本的迭代之后，不同版本环境的兼容，对运维人员都是考验
**Docker**之所以发展如此迅速，也是因为它对此给出了一个标准化的解决方案。
环境配置如此麻烦，换一台机器，就要重来一次，费力费时。很多人想到，能不能从根本上解决问题，软件可以带环境安装?也就是说，安装的时候，把原始环境-模-样地复制过来。开发人员利用Docker可以消除协作编码时“在我的机器上可正常工作”的问题。



之前在服务器配置一个应用的运行环境，要安装各种软件，就拿尚硅谷电商项目的环境来说吧，**Java/TomcatMySQL/JDBC**驱动包等。安装和配置这些东西有多麻烦就不说了，它还不能跨平台。假如我们是在**Windows**上安装的这些环境，到了Linux 又得重新装。况且就算不跨操作系统，换另一台同样操作系统的服务器，要移植应用也是非常麻烦的。

传统上认为，软件编码开发/测试结束后，所产出的成果即是程序或是能够编译执行的二进制字节码等java为例)。而为了让这程序可以顺利执行，开发团队也得准备完整的部署文件，让维运团队得以部署应用程式，**开发需要清楚的告诉运维部署团队，用的全部配置文件+所有软件环境。不过，即便如此，仍然常常发生部署失败的状况。**Docker镜 像的设计**，使得Docker得以打过去「程序即应用」的观念。透过镜像(images)将作业系统核心除外，运作应用程式所需要的系统环境，由下而上打包，达到应用程式跨平台间的无缝接轨运.作。**



## docker理念

Docker是基于Go语言实现的云开源项目。
Docker的主要目标是“**Build, Ship[ and Run Any App,Anywhere**"，也就是通过对应用组件的封装、分发、部署、运行等生命期的管理，使用户的APP (可以是一个WEB应用或数据库应用等等)及其运行环境能够做到“**一次封装，到处运行**”。



 Linux容器技术的出现就解决了这样一 一个问题，而Docker就是在它的基础上发展过来的。将应用运行在Docker容器上面，而Docker容器在任何操作系统上都是一-致的，这就实现了跨平台、跨服务器。**只需要一次配置好环境，换到别的机子上就可以一键部署好，大大简化了操作**



## 总结

解决了运行环境和配置问题的软件容器，方便做持续集成并有助于整体发布的容器虚拟化技术



## 作用

### 之前的虚拟机技术

虚拟机**(virtual machine)**就是带环境安装的一种解决方案。

它可以在一种操作系统里面运行另一种作系统，比如在**Windows系统里面运行Linux系统**。应用程序对此毫无感知，因为虚拟机看上去跟真实系统- -模-样，而对于底层系统来说，虚拟机就是一个普通文件，不需要了就删掉，对其他部分毫无影响。这类虚拟机完美的运行了另一套系统，能够使应用程序，操作系统和硬件三者之间的逻辑不变。



虚拟机的缺点:

1、资源占用多

2、冗余步骤多

3、启动慢



### 容器虚拟化技术

由于前面虛拟机存在这些缺点，**Linux** 发展出了另一种虚拟化技术: **Linux 容器**(Linux Containers,缩为LXC)。

**Linux容器不是模拟一个完整的操作系统**，而是对进程进行隔离。有了容器，就可以将软件运行所的所有资源打包到一个隔离的容器中。容器与虚拟机不同，不需要捆绑一整套操作系统，只需要软件工作所需的库资源和设置。系统因此而变得高效轻量并保证部署在任何环境中的软件都能始终如一地运行。.



比较了**Docker**和传统虚拟化方式的不同之处:

1、传统虚拟机技术是虚拟出一套硬件后，在其上运行一个完整操作系统，在该系统上再运行所需应用进程;

2、而容器内的应用进程直接运行于宿主的内核，容器内没有自己的内核，**而且也没有进行硬件虚拟**。因此容器要比传统虚拟机为轻便。

3、每个容器之间互相隔离，每个容器有自己的文件系统，容器之间进程不会相互影响，能区分计算资源。



### 开发/运维(DevOps)

一次构建、随处运行，

#### 	更快速的应用交付和部署

		传统的应用开发完成后，需要提供一堆安装程序和配置说明文档，安装部署后需根据配置文档进行繁杂的配置才能正常运行。Docker化
之后只需要交付少量容器镜像文件，在正式生产环境加载镜像并运行即可，应用安装配置在镜像里已经内置好，大大节省部署配置和测
试验证时间。

#### 	更便捷的升级和扩缩容

		随着微服务架构和Docker的发展，大量的应用会通过微服务方式架构，应用的开发构建将变成搭乐高积木一样，每个Docker容器将变成-块“积木”，应用的升级将变得非常容易。当现有的容器不足以支撑业务处理时，可通过镜像运行新的容器进行快速扩容，使应用系统的扩容从原先的天级变成分钟级甚至秒级。

#### 	更简单的系统运维

		应用容器化运行后，生产环境运行的应用可与开发、测试环境的应用高度--致，容器会将应用程序相关的环境和状态完全封装起来，不会因为底层基础架构和操作系统的不一致性给应用带来影响，产生新的BUG。当出现程序异常时，也可以通过测试环境的相同容器进行快速定位和修复。

#### 	更高效的计算资源利用

	**Docker是内核级虚拟化**，其不像传统的虚拟化技术一样 需要额外的Hypervisor支持，所以在-台物理机上可以运行很多个容器实例，可大大提升物理服务器的CPU和内存的利用率。





# Docker安装

## 前提说明

**CentOS Docker安装**
Docker支持以下的CentOS版本:
CentOS 7 (64-bit)
CentOS 6.5 (64-bit)或更高的版本

**前提条件**
目前，CentOS 仅发行版本中的内核支持Docker。
Docker运行在CentOS 7.上，要求系统为64位、系统内核版本为3.10以上。
Docker运行在CentOS-6.5或更高的版本的CentOS上，要求系统为64位、系**统内核版本为2.6.32-431或者更高版本。**



## Docker 的基本组成



### 镜像( image )

Docker镜像(lmage)就是-一个只读的模板。镜像可以用来创建Docker容器，个镜像可以创建很多容器



### 容器( container)

Docker利用容器(Container) 独立运行的一个或一组应用。**容器是用镜像创建的运行实例。**
它可以被启动、开始、停止、删除。每个容器都是相互隔离的、保证安全的平台。
**可以把容器看做是一个简 易版的Linux环境**(包括root用户权限、进程空间、用户空间和网络空间等)和运行在其中的应用程序。
容器的定义和镜像几乎一模一样，也是一堆层的统一视角， 唯- -区别在于容器的最上面那-层是可读可写的。

### 仓库( repository)

仓库(**Repository**) 是**集中存放镜像**文件的场所。
仓库(**Repository**)和仓库注册服务器(**Registry**) 是有区别的。仓库注册服务器上往往存放着多个仓库，每个仓库中又包含了多镜像，
每个镜像有不同的标签(tag) 。

仓库分为公开仓库(**Public**) 和私有仓库(**Private**) 两种形式。
**最大的公开仓库是Docker Hub(ttps://hub. docker.com/)**
存放了数量庞大的镜像供用户下载。国内的公开仓库包括阿里云、网易云等





### 安装步骤

#### Centos6.8安装Docker

1、yum install -y epel-release

2、yum install -y docker-io

3、安装后的配置文件： etc/sysconfig/docker

4、启动 Docker后台服务: service docker start

5、docker version 验证







# 底层原理

## Docker是怎样工作的

Docker是一个Client-Server结构的系统，Docker守 护进程运行在主机上，然后通过Socket连 接从客户端访问，守护进程从客户端接受命令并管理运行在主机上的容器。**容器，是一个运行时环境，就是我们前面说到的集装箱。**



## 为什么Docker比较比vm快

1、**docker**有着比虚拟机更少的抽象层。由亍docker不需要**Hypervisor**实现硬件资源虚拟化,运行在docker容器上的程序直接使用的都是实际物理机的硬件资源。因此在CPU、内存利用率上docker将会在效率上有明显优势。

2、**docker**利用的是宿主机的内核,而不需要**Guest OS**。因此,当新建一个 容器时,docker不需要和虚拟机一样 重新加载- - 个操作系统内核仍而避免引寻、加载操作系统内核返个比较费时费资源的过程,当新建--个虚拟机时,虚拟机软件需要加载GuestOS,返个新建过程是分钟级别的。而docker由于直接利用宿主机的操作系统,则省略了返个过程,因此新建一-个docker容器只需要几秒钟。





# Docker常用命令

## 帮助命令

```shell
docker Version

docker info

docker --help
	自己查看官网解释，高手都是自己练出来的，百度上只不过是翻译了下，加了点例子
```

## 镜像命令

#### docker images

 列出本机上的镜像

```dockerfile
-a 列出本地所有的镜像(含中间映射层)
-q 只显示镜像ID
--digests 显示镜像的摘要信息
--no-trunc 显示完整的镜像信息
```



#### docker search

查找某个XXX镜像的名字

	docker search [OPTIONS] 镜像名字

OPTIONS 说明

```yaml
--no-trun #显示完整的镜像描述
-s #列出收藏数不小于指定值的镜像
--automated #只列出 automated build类型的镜像
```



#### docker pull 

#### 下载某个镜像

	docker pull 镜像名字[:TAG]



#### docker rmi 

删除某个XXX镜像

```yaml
docker rm -f 镜像ID
#删除单个
docker rm -f 镜像名1:TAG 镜像名2:TAG
#删除多个 
docker rmi -f ${docker images -qa}
#删除多个 
```



## 容器命令

有镜像才能创建容器

	docker pull centos

### 启动容器

	docker run [OPTIONS] IMAGE [COMMAND][ARG]

OPTIONS 说明 

```yaml
--name="容器新名字":为容器指定一个名称;
-d:后台运行容器，并返回容器ID， 也即启动守护式容器;
-i:以交互模式运行容器，通常与-t同时使用;
-t:为容器重新分配一个伪输入终端，通常与-i同时使用;
-P:随机端口映射;
-p:指定端口映射，有以下四种格式
ip:hostPort:containerPort
ip::containerPort
hostPort:containerPort
containerPort
```



### 正在运行的容器

	docker ps [OPTIONS]

OPTIONS说明 :

```JAVA
-a :列出当前所有正在运行的容器+历史上运行过的
-|:显示最近创建的容器。
-n:显示最近n个创建的容器。
-q :静默模式，只显示容器编号。
--no-trunc :不截断输出。
```



#### 退出容器

两种退出方式

	exit 容器停止退出
	
	ctrl+P+Q 容器不停止退出

#### 启动容器

```
docker start 容器ID或容器签名
```

#### 重启容器

```
docker restart 容器ID或容器签名
```

#### 停止容器

```
docker stop 容器ID或容器签名
```

#### 强制停止容器

```
docker kill 容器ID或容器签名
```

#### 删除已停止的容器

docker rm 容器ID  -f

```yaml
# 一次性删除多个容器
docker rm -f $(docker ps -a -q)

docker ps -a -q | xargs docker rm
```



#### 启动守护式容器

```yaml
# 使用镜像centos:latest以后台模式启动一个容器
docker run -d centos
```

这里会出现一个问题:

```yaml
docker ps -a  #进行查看,会发现容器已经退出
```

很重要的要说明的一点: 

- **Docker容器后台运行,就必须有一个前台进程.**
- 容器运行的命令如果不是那些**一直挂起的命令** (比如运行top，tail) ，就是会自动退出的。

> 这个是**docker**的机制问题

例如

```
service nginx start
```

但是,这样做,**nginx**为后台进程模式运行,就导致**docker**前台没有运行的应用,这样的容器后台启动后，会立即自杀

因为他觉得他没事可做了.所以，最佳的解决方案是将你要运行的程序以前台进程的形式运行



#### 查看容器日志

```
docker logs -f -t --tail 容器ID 
```

说明

	-t 是加入时间戳
	-f 跟随最新的日志打印
	--tail 数字显示最后多少条



#### 查看容器内的进程

```
docker top 容器ID
```



#### 查看容器内部细节

```
docker inspect 容器ID
```



#### 进入容器

有两种方式

```
docker exec -it 容器ID bashShell
```



```
重新进入docker attach 容器ID
```



上述两个区别

attach 直接进入容器启动命令的终端，不会启动新的进程

exec 实在容器中打开新的终端，并且可以穷的那个新的进程



#### 拷贝文件

```
docker cp 容器ID:容器内路径 目的主机路径
```





# Docker 镜像

镜像是一种轻量级、可执行的独立软件包，用来打包软件运行环境和基于运行环境开发的软件，它包含运行某个软件所需的有内容，包括代码、运行时、库、环境变量和配置文件。



## UnionFS(联合文件系统)

UnionFS (状节又件示统)
UnionFS (联合文件系统) : Union文件系统(UnionFS)是一一种分层、轻量级并且高性能的文件系统，它支持对文件系统的修作为一 次提交来一层层的叠加，同时可以将不同目录挂载到同一个虚拟文件系统下(unite several directories into a singlevirtualfilesystem)。

Union文件系统是Docker镜像的基础。镜像可以通过分层来进行继承，基于基础镜像(没有父镜像)可以制作各种具.体的应用镜像。



特性:

一次同时加载多个文件系统，但从外面看起来，只能看到一个文件系统，联合加载会把各层文件系统叠加起来，这样最终的文
件系统会包含所有底层的文件和目录



## Docker镜像加载原理

**Docker镜像加载原理:**

**docker**的镜像实际上由一层一层的文件系统组成，这种层级的文件系统**UnionFS。**



**botfs(boot file system)**主要包含**bootloader**和**kernel**, **bootloader**主 要是引导加载**kernel**, **Linux**刚启动时会加载bootfs文件系统，在**Docker**镜像的最底层是**bootfs**。这一-层与我们典型的**Linux/Unix**系统是- - -样的，包含boot加载器和内核。当boot加载完成之 后整个内核就都在内存中了，此时内存的使用权己由bootfs转交给内核，此时系统也会卸载bootfs。



**rootfs (root file system)，**在**bootfs**之 上。 包含的就是典型Linux系统中的**/dev, /proc, /bin, /etc**等标准目录和文件。**rootfs**就 是各种不同的操作系统发行版，比如**Ubuntu**，**Centos**等等。



平时我们安装的虚拟机的Centos都是好几个G ，为什么docker这里才要200m



对于一个精简的**OS, rootfs**可 以很小，只需要包括最基本的命令、工具和程序库就可以了，因为底层直接用**Host**的**kernel**,自只需要提供rootfs就行了。由此可见对于不同的**linux**发行版, **bootfs**基本是一致的, **rootfs**会有差别，因此不同的发行版可以公用**bootfs**。





## 分层结构

最大的一个好处就是-**共享资源**
比如:**有多个镜像都从相同的base镜像构建而来**，那么宿主机只需在磁盘上保存一份**base**镜像,
同时内存中也只需加载一份**base**镜像，就可以为所有容器服务了。而且镜像的每一层都可以被共享。



## 特点

Docker镜像都是只读的，当容器启动时，一个新的可写层被加载到**镜像的顶部**，这一层通常被称为**容器层**，容器层之下都叫**镜像层**



## Docker镜像Commit操作

docker commit 提交容器副本使之称为一个新的镜像

```
docker commit -m="提交的描述信息" -a="作者" 容器ID 要创建的目标镜像名:[标签名]
```



# Docker容器数据卷

**Docker**的理念:

- 将运用与运行的环境打包形成容器运行，运行可以伴随着容器，但是我们对数据的要求希望是持久化的

- 容器之间希望有可能共享数据

  

> Docker**容器产生的数据，**
>
> **如果不通过**docker**commit**生成新的镜像，使得数据做为镜像的一部分保存下来，
>
> 那么当容器删除后，数据自然也就没有了
>
> 为了能保存数据在docker中我们使用卷



## 作用

卷就是目录或文件，存在于一个或多个容器中，由**docker**挂载到容器，但不属于联合文件系统，因此能够绕过Union FileSystem提供一些用 于持续存储或共享数据的特性:
卷的设计目的就是数据的持久化，完全独立于容器的生存周期，因此Docker不 会在容器删除时删除其挂载的数据卷

特点:
1:数据卷可在容器之间共享或重用数据
2:卷中的更改可以直接生效
3:数据卷中的更改不会包含在镜像的更新中
4:数据卷的生命周期一直持续到没有容器使用它为止

**容器的持久化**

**容器间继承+共享数据**



## 数据卷

### 容器内添加

#### 	直接命令添加

```
docker run -it -v /宿主机绝对路径目录:/容器内目录 镜像名
```

命令(带权限：ro)

	docker run -it -v /宿主机绝对路径目录:/容器内目录**:ro** 镜像名





#### DockerFile添加

根目录下新建mydocker文件夹并进入

可在Dockerfile中使用VOLUME指令来给镜像添加一个或多个数据卷

1，创建dockerFile，并编写相关内容,

2，build后生成镜像

```
docker build
```

3，启动



## 数据卷容器

### 概念

命名的容器挂载数据卷，其它容器通过挂载这个(父容器)实现数据共享，挂载数据卷的容器，称之为数据卷容器.



### 容器间传递共享(--volumes -from)

1，先启动一个父容器doc1

启动后在 dataVolumeContainer1中新增内容

2，doc2/doc3 继承doc1 

	**--volumes -from**

doc2/doc3 分别在dataVolumeContainer2各自新增内容



**容器之间配置信息的传递，数据卷的生命周期一直持续到没有容器使用它为止**





# DockerFile解析

## 概念

Dockerfile是用来构建Docker镜像的构建文件，由一系列命令和参数构成的脚本

## 构建三步骤

	编写Dockerfile文件
	
	docker build
	
	docker run



## 构建过程解析

Dockerfile内容基础知识

1、每条保留字指令都必须为大写字母且后面要跟随至少一个参数
2、 指令按照从.上到下，顺序执行
3、#表示注释
4、每条指令都会创建一个新的镜像层，并对镜像进行提交

### Docker执行Dockerfile流程

1、 docker 从基础镜像运行一个容器
2、执行一-条指令并对容器作出修改
3、执行类似docker commit的操作提交- -个新的镜像层
4、docker再基 于刚提交的镜像运行一一个新容器
5、执行dockerfile中的 下一条指令直到所有指令都执行完成





## DockerFile体系结构(保留字指令)

### CMD

	Dockerfile中可以有多个CMD指令，但只有最后一个生效，CMD会被dockerrun之后的参数替换

##### ENTRYPOINT 

	docker run 之后的参数会被当做参数传递给 ENTRYPOINT 之后形成新的命令组合

##### curl的命令解释

**curl**命令可以用来执行下载、发送各种**HTTP**请求，指定**HTTP**头部等操作。

如果系统没有**curl**可以使用**yum install curl**安装，也可以下载安装。
**curl是将下载文件输出到stdout**
使用命令: curl http://www .baidu.com
执行后，www.baidu.com的html就会显示在屏幕上了

这是最简单的使用方法。用这个命令获得了htp://curl.haxx.se指向的页面，同样，如果这里的URL指向的是--个文件或者一幅图都可以直接下载到本地。如果下载的是HTML文档，那么缺省的将只显示文件头部，即HTML文档的header。要全部显示，请加参数-i

WHY

我们可以看到可执行文件找不到的报错，**executable file not found。**
之前我们说过，**跟在镜像名后面的是command,运行时会替换CMD的默认值。**
因此这里的-i替换了原来的CMD，而不是添加在原来的curl -s htp://ip.cn后面。而-i 根本不是命令，所以自然找不到。
那么如果我们希望加入-i这参数，我们就必须重新完整的输入这个命令:

```
docker run myip curl -s http://ip.cn -i
```

​	

### 自定义镜像Tomcat

1、mkdir -p /zzyy/mydockerfile/tomcat9

2、在上述目录下 touch c.txt

3、将jdk和tomcat安装的压缩包拷贝进上一步目录 

4、在zzyyuse/mydockerfile/tomcat9目录下新建Dockerfile文件

```dockerfile
FROM centos
MAINTAINER zzyy<zzyybs@ 126.com>
#把宿主机当前上下文的c .txt拷贝到容器/usr/local/路径下
COPY c.txt /usr/local/cincontainer.txt
#把java与tomcat添加到容器中
ADD jdk-8u171-linux x64.tar .gz /usr/local/
ADD apache-tomcat-9.0.8.tar.gz /usr/ocal/
#安装vim编辑器
RUN yum -y install vim
#设置工 作访问时候的WORKDIR路径， 登录落脚点
ENV MYPATH /usr/local
WORKDIR $MYPATH
#配:置java与tomcat环境变量
ENV JAVA_ HOME /usr/localjdk1 .8.0_ 171
ENV CLASSPATH $JAVA_ HOME/lib/dt.jar:$JAVA_ HOME/lib/tools.jar
ENV CATALINA_ HOME /usr/local/apache-tomcat-9.0.8
ENV CATALINA_ BASE /usr/ocal/apache-tomcat-9.0.8
ENV PATH $PATH:$JAVA_ HOME/bin:$CATALINA_ HOME/ib:$CATALINA_ HOME/bin
#容器运行时监听的端口
EXPOSE 8080
#启动时运行tomcat
# ENTRYPOINT ["/usrl/local/apache-tomcat-9.0.8/bin/startup.sh" ]
# CMD ["/usr/local/apache-tomcat-9.0.8/bin/catalina.sh","run"]
CMD /usr/local/apache-tomcat-9.0.8/bin/startup.sh && tail -F /usr/local/apache-tomcat-9.0.8/in/logs/catalina.out
```

##### 5、构建

##### 6、run

```dockerfile
docker run -d -p 9080:8080 -name myt9
 -v /zyuse/mydockerfiletomcat9/test:/usrlocal/apache-tomcat9.0.8/webapps/test
 -v /zzyyuse/mydockerfile/tomcat9/tomcat9logs/:/usrlocal/apache-tomcat-9.0.8/logs -privileged=true zzyytomcat9
```

##### 7、验证

##### 8、test发布

web.xml

```xml
<?xml version="1 .0" encoding="UTF-8"?>
<web-app xmIns:xsi="http://www.w3.org/2001/XML Schema-instance"
xmIns="http://java sun.com/xm/ns/javaee"
xsi:schemaL ocation="http://java. sun.com/xml/ns/javaee htp:/:/java. sun.com/xml/ns/javaee/web-app_ 2_ _5.xsd"
id="WebApp_ ID" version="2.5">
<display-name>test</display-name>

</web-app>
```

a.jsp

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC“//W3C//DTD HTML 4.01 Transitional//EN" http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here </title>
</head>
<body>
welcome-
<%="i am in docker tomcat self "%>
<br>
<br>
<% System.out,.printIn("==========docker tomcat self");%>
</body>
</htmI>
```

测试

```html
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC“//W3C//DTD HTML 4.01 Transitional//EN" http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here </title>
</head>
<body>
welcome-
<%="i am in docker tomcat self "%>
<br>
<br>
<% System.out,.printIn("==========docker tomcat self");%>
</body>
</htmI>
```





# 推送到阿里云

## 镜像生成方法

1、前面的Dockerfile

2、从容器中创建一个新的镜像 

```dockerfile
docker commit [OPTIONS] 容器ID [REPOSITORY[:TAG]]
```



## 推送

1、阿里云开发者平台创建仓库

2、将镜像推送到registry

```java
$ sudo docker login --username=white3e registry.cn-shenzhen.aliyuncs.com
$ sudo docker tag [ImageId] registry.cn-shenzhen.aliyuncs.com/ggccqq/mycentos:[镜像版本号]
$ sudo docker push registry.cn-shenzhen.aliyuncs.com/ggccqq/mycentos:[镜像版本号]
其中[ImageId][镜像版本]自己填写
```





