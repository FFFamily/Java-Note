# Git

## Git基本操作

查看状态

```properties
git status
# 查看工作区、暂存区状态
```

初始化

```properties
git add [file name]
# 将工作区的“新建/修改”添加到暂存区
```

提交

```properties
git commit -m "commit message" [file name]
# 将暂存区的内容提交到本地库
```

查看历史记录

```properties
git log
```



## GitHub的使用

### 1，创建远程仓库

### 2，创建本地版仓库

```properties
git init
```

### 3，添加文件到暂存区

```properties
git add [file name]
```

### 4，提交文件到本地仓库

```properties
git commit -m"提交信息---必须写"
```

### 5，修改文件后需要重复第三步第四步

### 6，查询提交记录

```properties
git log
# 执行的操作，作者，以及日期和提交的信息
commit 84fa5e0a66678d6e77af59e851ffd34ab470febc 
Author: FFFamily <tjj747487547@sina.com> 
Date:   Wed Aug 5 14:15:47 2020 +0800

    第二次提交文件，并修改了gello文件
```

### 7，删除文件

```properties
# 删除本地的指定文件
rm fileName

# 删除仓库中的指定文件
git rm fileName
```

删除了文件，但是本地仓库中没有删除

```properties
#通过 git status 发现222.txt文件已经被删除了，如果需要把仓库中的也删除，那么就需要重新删除仓库中的再提交

Changes not staged for commit:
(use "git add/rm <file>..." to update what will be committed)
(use "git restore <file>..." to discard changes in working directory)
        deleted:    222.txt
```

### 8，忽略文件

手动创建一个.gitignore文件，前提是没有上传，不然需要清理缓存

```properties
#清除本地缓存
git rm -r --cached 
```



```properties
# .gitignore文件内容
aa/: 忽略aa目录下的所有文件

bb: 忽略bb文件

*.a: 忽略以.a结尾的文件

!cc.txt: 除了cc.txt文件
```

### 9，删除仓库

```properties
find . -name ".git" | xargs rm -Rf
```



### 10，上传文件

```properties
git remote add "名称" "SSH密匙"

git push -u "名称" master
```



### 11，克隆文件

```
git clone
```



### 12，拉取文件

```properties
git pull [远程库地址别名] [远程分支名]

# 例子

git pull note master
```

当同时修改一个文件时，会产生冲突，会导致上传失败，这时会提示需要先拉取后处理冲突，再去上传

当拉取文件后，会有产生冲突的文件提示要修改

也可以使用工具去解决冲突

```java
"<<<<<<< HEAD " ----------直接删除

是指你本地的分支的
"============" ----------直接删除
本地待提交的commit代码

">>>>>>>> 39645e0443a07957dae" --------直接删除
```



### 13，忽略目录下的某个文件上传

```
$ git update-index --assume-unchanged SpringCloud/图片/*.png
```



## 分支

创建新分支

```properties
git branch (分支名)
```

切换分支

```properties
git checkout (分支名)
```

合并分支

```properties
git merge 分支名
```

列出分支

```properties
git branch
```

删除分支

```properties
git branch -d (branchname)
```

