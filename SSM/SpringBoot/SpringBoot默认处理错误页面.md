# SpringBoot处理错误页面

默认会去找templates目录下的处理错误的页面

页面一般都是以错误代码为名字

```
404.html
406.html
```

也可以模糊

```
4xx.html
5xx.html
```



> 但是一般会优先精确的页面



## 两种方式

1.返回一个错误页面

2.返回一个错误信息的json



## 设置自己的错误处理页面

可以使用Thymeleaf去获取值

```
timestamp：时间戳
status：状态码
error：错误提示
exception：异常对象
message：异常消息
errors：JSR303数据校验的错误都在这里
```



1，编写一个错误处理控制器，针对哪个错误类去进行相关联的处理

```java
@ExceptionHandler(Exception.class)   
//这样就能处理所有的异常  
```

--

```java
@ControllerAdvice 
public class MyExceptionHandler {  
@ResponseBody     
@ExceptionHandler(UserNotExistException.class)     
    public Map<String,Object> handleException(Exception e){    
    Map<String,Object> map = new HashMap<>();         
    map.put("code","user.notexist");        
    map.put("message",e.getMessage());         
    return map;     
   } 
} 
```



但是上面的方法，不能自适应的处理不同设备的异常请求

需要去转发到错误页面，这样springboot就会自适应的去处理错误请求

并且需要传递错误状态码，不然就springboot就会按照默认的



```java
@ExceptionHandler(UserNotExistException.class)     
public String handleException(Exception e, HttpServletRequest request){}
    Map<String,Object> map = new HashMap<>();      
    //传入我们自己的错误状态码  4xx 5xx，否则就不会进入定制错误页面的解析流程    
    request.setAttribute("javax.servlet.error.status_code",500);         
    map.put("code","user.notexist");         
    map.put("message",e.getMessage());         
    //转发到/error        
     return "forward:/error";     
}
```

