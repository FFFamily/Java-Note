# 整合mybatis

```
第一步：导入依赖
这个是mybatis整合spring-boot的jar包
引入了mybatis，mybatis-spring整合，jdbc
</dependency>
    <groupId>org.mybatis.spring.boot</groupId>             
    <artifactId>mybatis‐spring‐boot‐starter</artifactId>             
    <version>1.3.1</version>            
</dependency>


第二步：在主配置文件中配置数据源信息

使用注解的方式
第三步：编写mapper/dao接口、
@Mapper
public interface DepartmentMapper { 
//这里是对指定元素设置自增 
@Options(useGeneratedKeys = true,keyProperty = "id")     
@Insert("insert into department(departmentName) values(#{departmentName})")
public int insertDept(Department department); 
 }

、
自定义配置mybatis
@org.springframework.context.annotation.Configuration 
public class MyBatisConfig {       
    @Bean     
    public ConfigurationCustomizer configurationCustomizer(){         
    return new ConfigurationCustomizer(){               
        @Override             
        public void customize(Configuration configuration) {
        //当数据库是y_name时，而页面是yName，就可以设置这个           
        configuration.setMapUnderscoreToCamelCase(true);             
        }         
       }; 
} 
}



配置自动扫描包
可以在springboot的入口函数，也可以是mybatis的配置函数
@MapperScan(value = "com.atguigu.springboot.mapper") 
@SpringBootApplication public class SpringBoot06DataMybatisApplication {   


使用配置文件的方式
第一步：编写mapper接口
@Mapper
public interface DepartmentMapper { 
public int insertDept(Department department); 
 }


第二步：在resource中配置mapper-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
</configuration>


第三步：配置mapper映射文件
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.atguigu.springboot.mapper.EmployeeMapper">

</mapper>


第四步：在springboot主配置文件中配置mybatis
mybatis:  
//指定全局配置文件的位置    
    config‐location: classpath:mybatis/mybatis‐config.xml 
//指定sql映射文件的位置
    mapper‐locations: classpath:mybatis/mapper/*.xml  


```

