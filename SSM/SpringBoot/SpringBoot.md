# SpringBoot

> 来自视频
>
> boot的东西很多都忘记，都是需要自己在配置使用的时候才能深入巩固，文字笔记只能起到提醒的作用，所以还是需要在代码中逐渐巩固



简化spring应用开发的一个框架

J2EE的一站式解决方案

> 一站式解决方案（一体化解决方案）
>
> 什么是All-in-one Solution？
>
> All-in-one Solution
>
> 即一站式解决方案,一站式就是让用户享受到一次性完成或一步到位的便捷(俗称一条龙服务)，不再需要东奔西走，节省了时间，提高了效率，以适应现代人快节奏、高效率的要求



# 入门

导入依赖

```xml
<!--真正管理Spring Boot应用里面的所有依赖版本-->
<!--Spring-Boot的版本冲裁中心-->
<!--也是我们导入依赖后不需要写版本的原因-->
<parent>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-parent</artifactId>
      <version>1.5.9.RELEASE</version>
</parent>
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```



> **启动器：spring-boot-starter**
>
> `spring-boot-starter`：spring-boot场景启动器，帮我们导入了很多模块正常运行所依赖的组件；
>
> Spring Boot将所有的功能场景都抽取出来，做成一个个的starters（启动器），只需要在项目里面引入这些starter 相关场景的所有依赖都会导入进来。要用什么功能就导入什么场景的启动



简化部署，导入相关的打包工具

```xml
 <!-- 这个插件，可以将应用打包成一个可执行的jar包；-->
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
```

编写主程序

```java
@SpringBootApplication
public class HelloWorldMainApplication {
    public static void main(String[] args) {
        // Spring应用启动起来
        SpringApplication.run(HelloWorldMainApplication.class,args);
    }
}
```

编写相关联的controller或者service

```java
@Controller
public class HelloController {
    @ResponseBody
    @RequestMapping("/hello")
    public String hello(){
        return "Hello World!";
    }
}
```

resources文件夹



**static**：保存所有的静态资源； js css images；

**templates**：保存所有的模板页面；

> 注意：
>
> ​	1.Spring Boot默认jar包使用嵌入式的Tomcat，(**默认不支持JSP页面**）；
>
> ​	2. 可以使用模板引擎（freemarker、thymeleaf）；
>

**application.properties**：Spring Boot应用的配置文件；可以修改一些默认设置；



# 常用注解

## @SpringBootApplication

Spring Boot应用标注在某个类上说明这个类是SpringBoot的主配置类，SpringBoot 就应该运行这个类的main方法来启动SpringBoot应用



## @Configuration

表名这个类是springboot的配类



## @EnableAutoConfiguration

告诉SpringBoot开启配置功能，会自动去配置以前ssm中需要的一些配置

**EnableAutoConﬁguration**指定的值，将这些值作为自动配置类导入到容器中，自动配置类就生效，帮我们进行自动配置工作；

换句话说，在类中有**EnableAutoConﬁguration**，springboot就会扫描



## @ConfigurationProperties

告诉SpringBoot将本类中的所有属性和配置文件中相关的配置进行绑定



## @PropertySource

在springBoot中，不可能把所有的配置都防在主配置文件中去，会有一些单独抽取出来的配置文件来独立的配置一些数据

```java
@PropertySource(value = {"classpath:person.properties"})
public class Person { 
```



## @ImportResource

**导入Spring的配置文件，让配置文件里面的内容生效**

Spring Boot里面没有Spring的配置文件，我们自己编写的配置文件，也不能自动识别，所以需要这个注解

**标注在一个配置类上，或者在主函数上面，这样就可以不用去写配置类了，当然，springboot中推荐不去适用配置文件（xml）**

```java
@ImportResource(locations = {"classpath:beans.xml"})
//导入Spring的配置文件让其生效
```



## @EnableWebMvc

这样spring-boot对于mvc的自动配置就失效了

```java
@EnableWebMvc
@Configuration 
public class MyMvcConfig extends WebMvcConfigurerAdapter { 
```



# 两种配置文件

1，`application.properties`

2，`application.yml`



> YAML（YAML Ain't Markup Language）
>
> 标记语言，是一种将文本以及文本相关的其他信息结合起来，展现出关于文档结构和数据处理细节的电脑文字编码



 在使用配置文件需要注意**乱码的问题**

> **原因:**是idea使用的是utf-8的编码，但是properties使用的是ASCII码

![img](./img/clipboard.png)





## 获取值

```java
@ConfigurationProperties(prefix = "people")
public class Person {
```

需要导入文件

```xml
<!--导入配置文件处理器，配置文件进行绑定就会有提示-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
```



## Proﬁle 

应用在实际的开发中可能需要不同的开发环境，也就需要不同的配饰文件，spring就导入了Profile来切换不同的开发环境



文件的书写方式

--profile对应不同的开发环境

```
application-{proﬁle}.properties
或者
application-{proﬁle}.yml
```



切换

第一种：主配置文件中指定需要的profile

```
spring.profile.active = profile名字
```

第二种：命令行

```
java -jar spring-boot.jar --spring.proﬁles.active=dev;
```

第三种：虚拟机参数：` -Dspring.proﬁles.active=profile名字 `

![img](./img/2.png)



第四种：yml的多文档块方式

> 在yml中
>
> \- - -
>
> 表示将yml分割为不同的文档模块
>
> \- - -

```yaml
server:   
    port: 8081 
spring:   
    profiles:     
    active: prod   //这里就是指定启动那个模板
-‐‐
server:  
    port: 8083 
spring:  
   profiles: dev     -
-‐‐  server:   
    port: 8084 
spring:   
    profiles: prod
```



## 配置文件的加载顺序

内部加载没有顺序，全部加载

```
–ﬁle:./conﬁg/
–ﬁle:./ 
–classpath:/conﬁg/ 
–classpath:/
```



外部加载

1.命令行参数 所有的配置都可以在命令行上进行指定 

```
java -jar spring-boot.jar --server.port=8087 --server.context-path=/abc  
//多个配置用空格分开； "--配置项=值"
```

2.来自java:comp/env的JNDI属性

3.Java系统属性（System.getProperties()）

4.操作系统环境变量 

5.RandomValuePropertySource配置的random.*属性值  

6.jar包外部的application-{proﬁle}.properties或application.yml(带spring.proﬁle)配置文件

7.jar包内部的application-{proﬁle}.properties或application.yml(带spring.proﬁle)配置文件  

**再来加载不带proﬁle** 

8.jar包外部的application.properties或application.yml(不带spring.proﬁle)配置文件

9.jar包内部的application.properties或application.yml(不带spring.proﬁle)配置文件

10.@Conﬁguration注解类上的@PropertySource

11.通过SpringApplication.setDefaultProperties指定的默认属性



# 自动配置原理

> 这方面的知识已经有所遗忘，没有可信度，只是搬运笔记



文档：自动配置原理
链接：http://note.youdao.com/noteshare?id=4505c4a29944ebe34e2df06d7f90fb0d&sub=6182F2F611B042A8B352D209860F7DB5





## 使用外置servlet容器

```java
1，必须创建一个war项目
2，将嵌入式的Tomcat指定为provided；
<dependency>    
    <groupId>org.springframework.boot</groupId>    
    <artifactId>spring‐boot‐starter‐tomcat</artifactId>    
    <scope>provided</scope> 
</dependency>


3，编写一个SpringBootServletInitializer的子类，并调用conﬁgure方法
public class ServletInitializer extends SpringBootServletInitializer {  
    @Override    
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {        
    //传入SpringBoot应用的主程序       
    return application.sources(SpringBoot04WebJspApplication.class);    
    }   
    }
```

