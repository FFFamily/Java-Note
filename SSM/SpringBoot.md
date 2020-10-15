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



## **快速创建springBoot项目**

resources文件夹中目录结构



**static**：保存所有的静态资源； js css images；

**templates**：保存所有的模板页面；

注意：

​	1.（Spring Boot默认jar包使用嵌入式的Tomcat，**默认不支持JSP页面**）；

​	2.  可以使用模板引擎（freemarker、thymeleaf）；

**application.properties**：Spring Boot应用的配置文件；可以修改一些默认设置；