# JSP

## 概念

Java Server Pages： java服务器端页面

可以理解为：一个特殊的页面，其中既可以指定定义html标签，又可以定义java代码

**注意**：JSP本质上就是一个Servlet



### 页面构成

静态内容：HTML元素

动态内容：脚本，指令，动作



### JSP运行原理

1，客户端发出请求访问JSP文件

2，jsp容器将JSP文件转换为java源文件，存在语法错误就终端并返回错误信息

3，jsp容器将java源文件编译成字节码文件（其实就是一个Servlet，Servlet容器会像处理其他Servlet文件一样处理这个字节码文件）

4，Servlet容器加载转换好的字节码文件，并执行响应信息给客户端



> 第一次访问时，会将jsp文件翻译为java文件，然后再编译成class文件
>
> 第二次访问时，就可以直接访问class文件

## JSP脚本元素

### JSP Scriptlets

```JSP
<% java语句，定义变量 %>
```

### JSP 声明

```
<%!
	全局变量，定义方法
%>
```

### JSP 表达式

```
<%=
	输出表达式（不需要分号）
%>
```

注意`JSP表达式`的变量或表达式不能有分号



## JSP指令

```
格式：<%@  %>
```

### page: 配置JSP页面的

常用属性

contentType：等同于response.setContentType()

1，设置响应体的mime类型以及字符集

2，设置当前jsp页面的编码

> （只能是高级的IDE才能生效，如果使用低级工具，则需要设置pageEncoding属性设置当前页面的字符集）

```
HTML格式：text/html
JPG格式：text/jpeg
纯文本：text/plain
GIF图片：image/gif
Word文档：application/msword
```

import：导包

errorPage：当前页面发生异常后，会自动跳转到指定的错误页面

isErrorPage：标识当前页面是否是错误页面
> true：是，可以使用内置对象exception
>
> false：否。默认值。不可以使用内置对象exception



### include: 导入资源文件

```html
<%@ include file="top.jsp" %>
```

额外注意：包含和被包含访问同一个request对象



###  taglib: 导入资源

> (一般为标签文件）

--

```html
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!--prefix：前缀，自定义的-->
```



## JSP注释

```jsp
jsp注释

<%-- --%>：可以注释所有
```



## JSP动作元素

### jsp:include和jsp:parma

动态的加入其他页面元素到当前的jsp文件

```jsp
<jsp:include page = "URL" flush = "true"></jsp:include>
<!--flush：表示是否将输出内容刷新到客户端-->

<jsp:include>
	<jsp:parma name = "" value=""></jsp:parma>
    <!--param是设置参数-->
</jsp:include>
```



**< jsp:include > 和 <%@ include>的区别**

1，< jsp:include >引入的和当前页面相互独立，互不影响，而include指令是需要将两个合并才能翻译成一个Servlet源文件

2，< jsp:include >是在运行时才包含，只包含运行结果，而include指令是在编译器包含，包含源文件

3，< jsp:include >被包含的页面不能改变响应状态码或者设置响应头，而include指令没有这个限制



### jsp:forword





## JSP的内置对象

JSP自带的不需要new也能使用的对象

### **四种范围对象**(由小到大)

尽量使用最小的范围对象，范围越大，性能损耗越大

> pageContext       			当前页面有效（切换页面就会无效）
>
> request 					同一次请求有效
>
> session					同一次会话有效（浏览器不关闭，都属于同一次会话）
>
> appliation					全局有效（整个项目有效）



这四种对象共用的方法（常用）：

```java
Object  getAttribute（String name） 

void setAttribute（String name，Object obj）设置属性值 

void removeAttribute（String name）根据属性名，删除对象
```



### 九大内置对象

#### out 

类型：JspWriter

输出对象	（在页面上输出）

#### request

类型：HttpServletRequest  

请求对象  存储客户端向服务端发送的请求（各种信息）只在同一次请求有效

**统一请求的编码方式**

get请求：

\1. new String（  原文件格式  ，修改的形式 ）--需要对每一个乱码的编码进行修改

​    new String （变量名.getBytes(  "iso-8859-1"  ,   "utf-8" )）

2.修改server.xml   在 Connector 中添加  URIEncoding=“需要更改的格式”

post请求：

  添加    request.setCharacterEncoding("utf-8");	

#### response  

类型：HttpServletResponse

响应对象   response对象用来给客户端传送输出信息

​      

#### session(存在于服务端）

类型：HttpSession  

一次会话的多个请求间

Cookie：存在于客户端，不是内置对象，由服务端产生，发送给客户端



#### applicaton   （全局对象）

类型：ServletContext  

当前页面有效

作用：所有用户间共享数据



#### config    （配置对象）

类型：ServletConfig

Servlet的配置对象



#### page

类型：Object	

当前jsp页面对象



#### exception

类型：Throwable

异常对象：只有声明了当前页面是错误页面时才可以调用



#### pageContext(页面容器)

类型：PageContext

当前页面共享数据，还可以获取其他八个内置对象