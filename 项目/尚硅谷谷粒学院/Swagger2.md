# Swagger2

> Swagger已经更新，SpringBoot的整合更加方便，详情看Github



1，导入依赖

```xml
		<!--整合Sweager-->
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.7.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger-ui</artifactId>
            <version>2.7.0</version>
            <scope>provided</scope>
        </dependency>
```

2，配置文件

```java
@Configuration
@EnableSwagger2
public class SweagerConf {
    @Bean
    public Docket webApiConfig(){

        return new Docket(DocumentationType.SWAGGER_2)
                .groupName("webApi")
                .apiInfo(webApiInfo())
                .select()
                .build();

    }

    private ApiInfo webApiInfo(){

        return new ApiInfoBuilder()
                .title("网站-课程中心API文档")
                .description("本文档描述了课程中心微服务接口定义")
                .version("1.0")
                .contact(new Contact("Helen", "http://atguigu.com", "55317332@qq.com"))
                .build();
    }
}

```

--

```java
@Configuration  
@EnableSwagger2
public class Swagger2Configuration {

   //api接口包扫描路径
   public static final String SWAGGER_SCAN_BASE_PACKAGE = "com.muyao.galaxy";

   public static final String VERSION = "1.0.0";

   @Bean
   public Docket createRestApi() {
       return new Docket(DocumentationType.SWAGGER_2)
                   .apiInfo(apiInfo())
                   .select()
.apis(RequestHandlerSelectors.basePackage(SWAGGER_SCAN_BASE_PACKAGE)) 
                   .paths(PathSelectors.any()) // 可以根据url路径设置哪些请求加入文档，忽略哪些请求
                   .build();
   }

   private ApiInfo apiInfo() {
       return new ApiInfoBuilder()
                   .title("单词计数服务") //设置文档的标题
                   .description("单词计数服务 API 接口文档") // 设置文档的描述
                   .version(VERSION) // 设置文档的版本信息-> 1.0.0 Version information
                   .termsOfServiceUrl("http://www.baidu.com") // 设置文档的License信息->1.3 License information
                   .build();
   }
}
```

