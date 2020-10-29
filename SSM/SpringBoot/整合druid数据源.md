# 整合druid数据源

```
第一步：导入druid依赖
第二步：配置druid相关配置
spring:
  datasource:
#   数据源基本配置
    username: root
    password: 123456
    driver-class-name: com.mysql.jdbc.Driver
    url: jdbc:mysql://localhost:3306/ssm_crud
    //这里需要注意的是修改了数据源方式
    type: com.alibaba.druid.pool.DruidDataSource
#   数据源其他配置
    initialSize: 5
    minIdle: 5
    maxActive: 20
    maxWait: 60000
    timeBetweenEvictionRunsMillis: 60000
    minEvictableIdleTimeMillis: 300000
    validationQuery: SELECT 1 FROM DUAL
    testWhileIdle: true
    testOnBorrow: false
    testOnReturn: false
    poolPreparedStatements: true
#   配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙  
    filters: stat,wall,log4j
    maxPoolPreparedStatementPerConnectionSize: 20
    useGlobalDataSourceStat: true  
    connectionProperties: druid.stat.mergeSql=true;
    druid.stat.slowSqlMillis=500
    


第三步：编写针对druid的配置类
  @ConfigurationProperties(prefix = "spring.datasource")     
  @Bean     
  public DataSource druid(){        
      return  new DruidDataSource();     
  } 


第三步：在这个配置类中编写Druid的监控
 @Bean     
 public ServletRegistrationBean statViewServlet(){         
     ServletRegistrationBean bean = new ServletRegistrationBean(new StatViewServlet(),  "/druid/*");         
     Map<String,String> initParams = new HashMap<>();           
     initParams.put("loginUsername","admin");         
     initParams.put("loginPassword","123456");         
     initParams.put("allow","");//默认就是允许所有访问         
     initParams.put("deny","192.168.15.21");           
     bean.setInitParameters(initParams);
 return bean;    
 } 
 
  //2、配置一个web监控的filter     
  @Bean     
  public FilterRegistrationBean webStatFilter(){         
      FilterRegistrationBean bean = new FilterRegistrationBean();         
      bean.setFilter(new WebStatFilter());           
      Map<String,String> initParams = new HashMap<>();         
      initParams.put("exclusions","*.js,*.css,/druid/*");           
      bean.setInitParameters(initParams);           
      bean.setUrlPatterns(Arrays.asList("/*"));           
      return  bean;     
  } 


```

