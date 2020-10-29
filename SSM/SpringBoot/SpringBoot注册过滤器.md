# SpringBoot注册过滤器

```
第一种：在主配置文件中进行相关联的配置、
第二种：
在mvc的配置文件中添加EmbeddedServletContainerCustomizer 组件
@Bean  
//一定要将这个定制器加入到容器中 
public EmbeddedServletContainerCustomizer embeddedServletContainerCustomizer(){     
return new EmbeddedServletContainerCustomizer() {           
//定制嵌入式的Servlet容器相关的规则         
@Override         
public void customize(ConfigurableEmbeddedServletContainer container) {             
container.setPort(8083);         
}     
}; }



由于SpringBoot默认是以jar包的方式启动嵌入式的Servlet容器来启动SpringBoot的web应用，没有web.xml文件，所以在使用其相关的组件时，就需要自己创建类、

注册servlet
@Bean 
public ServletRegistrationBean myServlet(){
//这个MyServlet就是自己创建了的继承了Httpservlet的servlet
    ServletRegistrationBean registrationBean = 
            new ServletRegistrationBean(new  MyServlet(),"/myServlet"); 
    return registrationBean; 
} 


注册Filtter
@Bean 
public FilterRegistrationBean myFilter(){     
    FilterRegistrationBean registrationBean = new FilterRegistrationBean();
    //自己创建的拦截器
    registrationBean.setFilter(new MyFilter());   
    //设置拦截请求  
    registrationBean.setUrlPatterns(Arrays.asList("/hello","/myServlet"));
    return registrationBean; 
}



注册listener
@Bean 
public ServletListenerRegistrationBean myListener(){     
ServletListenerRegistrationBean<MyListener> registrationBean = 
             new  ServletListenerRegistrationBean<>(new MyListener());     
return registrationBean; }



注意：在DispatcherServletAutoConﬁguration这个springboot帮我们自动配置的springmvc时已经配置了默认的相关要求

默认拦截： /  所有请求；包静态资源，但是不拦截jsp请求；   /*会拦截jsp     

可以通过server.servletPath来修改SpringMVC前端控制器默认拦截的请求路径 
```

