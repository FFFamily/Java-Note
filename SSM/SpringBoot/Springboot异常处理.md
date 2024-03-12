# Springboot异常处理

## 1，异常出路枚举类

```java
public enum ErrorCode{
    NOT_FOUND(404,"未找到")
    ;
    private int code;
    privaye String msg;

}
```



## 2，自定义异常类

```java
public class MyException extends RuntimeException{
	private String ErrorType;//通常这里也是前端的响应状态码
	private String Message;
	//省略构造，setter，getter方法
    public void MyException(){
        //就可以使用枚举中的常量
    }
}
```



## 2，异常处理类

```java
@ControllerAdvice//标明全局异常处理类，可以使用assingableTypes指定Controller，只处理特定类抛出的异常
@ResponseBody
public class ExceptionHandler{
    // 拦截所有异常,一般情况下一个方法特定处理一种异常
	@ExceptionHandler(value = Exception.class)
    public String exceptionHandler(Exception e) {
        //按道理这里是返回一个统一的处理类对象来响应结果
    	return "错误";
    }
}
```

