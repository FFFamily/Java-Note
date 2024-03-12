# Thymeleaf模板引擎

spring-boot的打包方式是jar，不支持对jsp的使用，但是为了获取的方便，引入了模板引擎

**spring-boot支持Thymeleaf**



1，导入依赖

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```



2，配置

```yaml
#thymelea模板配置
spring:
  thymeleaf:
    #thymeleaf 所在路径
    prefix: classpath:/templates/
    #thymeleaf 后缀
    suffix: .html
    #thymeleaf 采用的标准
    mode: HTML5
    #thymeleaf 编码格式
    encoding: UTF-8
```

--

Thymeleaf的缓存解，在配置文件中禁用缓存

```properties
spring.thymeleaf.cache=false 
```





3，在templates目录下创建html文件

导入这个是为了使用时候会有提示

```html
<html lang="en" xmlns:th="http://www.thymeleaf.org">
```







4，语法

th:改变标签中原有的属性的值

表达式

```
${...}：获取变量值；OGNL，对象属性，方法，内置对象
*{...}：选择表达式：和${}在功能上是一样；
//配合 th:object="${session.user}
#{...}：获取国际化内容 
@{...}：定义URL
~{...}：片段引用表达式
```



--抽取公共页面

```html
<div th:fragment="copy"> 这是我需要引用的模板</div>   


//第一种方式
<div th:insert="~{footer :: copy}"></div> 
~{templatename::selector}：模板名::选择器 
~{templatename::fragmentname}:模板名::片段名 

//将内容（不包括自己的标签）放到引入中
<div th:insert="footer :: copy"></div>
//将内容替换引入
<div th:replace="footer :: copy"></div> 
//将内容全部放在引入中
<div th:include="footer :: copy"></div>
```

--日期格式化

```
${#dates.format(emp.birth, 'yyyy-MM-dd HH:mm')}
```

