# Springboot+vue个人博客

> 前后端分离项目
>
> 后台：jvm调优，代码性能调优，规范化代码
>
> 个人的：
>
> 1，可以添加Redis



## 一，数据库设计

> 数据库存放在服务器当中，若丢失可以在文档的`数据库` 中找回数据库表



1，乐观锁

每个字段上添加一个 `version` 字段

版本号机制，是最简单的乐观锁设置，在保证并发的情况下，每一条数据不会被意外修改





2，逻辑删除

给字段添加一个 `deleted` 字段 ， 用 0 和 1 控制



## 二，系统架构构建

1，创建出项目的基本骨架： controller，service 等等

> 同样也可以通过`MybatisPlus` 逆向生成

2，在`enums`创建 返回结果枚举 `ResultEnum`，状态码枚举 `StateEnums`

> 因为结果结果的种类很多，封装在一个枚举类中方便管理多种结果（状态）

3，在  `utils`  中 创建统一结果返回对象    `Result<T>`

```java
private Integer code;
private String msg;
private T data;
```

4，创建自定义全局异常 `BlogException`

> 既然设定了自定义的全局异常，那么在处理有些异常的时候就需要抛出自己的异常

5，在  `advice`  创建统一异常处理类 （专门处理自己创建的自定义异常）`BlogExceptionAdvice`，并且使用日志记录错误信息

> 那么这里就需要一个额外的过程。
>
> 在需要 记录日志的类上添加   `@Slf4j`  ,  这样就可以直接使用 log ，调用API
>
> 配置 logback-spring.xml 配置文件	（一般都是写好了的 ）



**这里我是直接粘贴的其配置文件，以后研究下**

--

```java
@ControllerAdvice // 需要添加此注解
@Slf4j
public class BlogExceptionAdvice {
/**
* 统一处理 BlogException
* @param exception
*/
@ExceptionHandler(BlogException.class) // 监听的异常
@ResponseBody
public Result<Object> exceptionHandler(BlogException exception) {
    log.error("统一异常处理：", exception);
    return new Result<>(exception.getErrorCode(), exception.getMessage());
}
```



**个人**

> 那么这里应该会有自定义的错误展示页面



7，这里有一步是创建 aop 的切面， 打印输出日志的

```java
RequestAspect // 因为springboot的单例的原因，不能直接使用，所以需要利用到线程的知识点
```

--

配置`aop` 的方式也很多，这里使用注解配置

--

```java
@Aspect
@Component
@Slf4j
public class RequestAspect {
	// 监听的方法
    @Pointcut("execution( * com.tutu.*.controller..*(..))")
    public void logPointCut() {}
    // 方法执行之前
    @Before("logPointCut()")
    public void doBefore(JoinPoint joinPoint) throws Exception {}
    // 环绕通知，在方法执行期间，一般统计耗时
    @Around("logPointCut()")
    public Object doAround(ProceedingJoinPoint pjp) throws Throwable {}
    // 后置通知
    @AfterReturning(returning = "ret", pointcut = "logPointCut()")
    public void doAfterReturning(Object ret) {}
    // 异常通知
    @AfterThrowing(pointcut = "logPointCut()", throwing = "e")
    public void saveExceptionLog(JoinPoint joinPoint, Throwable e) {}
    // 可以自定义方法，封装请求的日志信息，最后调用service，mapper方法，存入数据库
}
```



8，创建配置类 `BeanConfig`，这里主要是吧 `IdWorker` 这个类加入到Spring 容器中

> 雪花算法，生成ID
>
> 自增主键，性能最好，但是后面 有需要分库分表的时候会很麻烦，所以需要雪花算法

--

```java
@Bean
// 既然有了雪花算法，那么在每个mapper方法存入数据时，都是需要调用IdWorker生成ID
public IdWorker idWorker() {
	return new IdWorker();
}
```



9，创建实体类



10，创建  `Mapper` 接口 ， 并且 启动类上添加 扫描  `MAPPER`  的注解

```
@MapperScan("com.tutu.blog.mapper")
```



11，创建对应的  Mappr 的映射xml文件，并提前配置好通用查询的映射结果，以及通用查询结果列

```xml
<!-- 通用查询结果列 -->
<sql id="Base_Column_List">
	log_id, log_url, log_params, log_status, log_message, log_method, log_time, log_result, log_ip, created_time
</sql>
```



12，在主配置文件中配置 mybatis ， 配置mysql的数据源

```yaml
mybatis:
  type-aliases-package: com.tutu.blog.pojo
  mapper-locations: classpath:mapper/*Mapper.xml
```



13，创建不同环境的配置文件 `DEV`,`PROP`，在主配置文件中引入

```yaml
spring:
  profiles:
    active: dev
```



14，创建对应的` service`

15，测试启动



## 三，日志记录

在我们自己编写的 `aop` 切面类的时候，由于`spring` 中都是单例的，所以不能直接使用` Log` 对象

> 这是为什么呢？使用会发生什么？



**为了解决不能使用的原因，这里使用其他的方法，对于这个方法我也不是太懂，这是一种固定的写法，里面的内容需要研究**

> 涉及到多线程  ` ThreadLocal`  的使用



使用 工具类  `ThreadLocalContext`

> 本地线程上下文，单例模式
>
> 用来存储在同一个线程中可能会用到的全局变量



1，创建aop日志记录类 `RequestAspect`

2，实现相关`aop`的相关方法 

3，实现`Logservice` 的`save`方法，来保存信息到数据库





----

以下便是后台部分业务编写内容

----





## 四，登录功能

> 这里介绍到，对于单点登录，一般直接推荐使用 `shiro`
>
> 额外注意
>
> 在登录验证里面只能验证admin的登录，其他普通用户无法登录

1，导入 `Shiro`

```xml
<!-- Shiro -->
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring</artifactId>
    <version>1.3.2</version>
</dependency>
```



2，编写 登录控制   `AdminController`

 验证账号密码是否正确，正确则创建一个 带有  `token`  的 `session` ，将其返回

```java
// 这个方法创建 token
AuthenticationToken authenticationToken = 
    	new UsernamePasswordToken(admin.getUsername(), admin.getPassword(), String.valueOf(StateEnums.ADMIN.getCode()));
// 创建后
subject.login(authenticationToken);
 
// 前提是验证通过
Serializable sessionId = subject.getSession().getId();
Map<String, Object> returnMap = new HashMap<>(2);
returnMap.put("token", sessionId);
return new Result<>(returnMap);
```



3，创建 处理管理员的登录和授权逻辑 `AdminRealm` ，其继承 `AuthorizingRealm`  , 要实现其方法



4，因为使用了 `Shiro` ，所以需要配置 ` Shiro` 的配置文件，装配 `AdminRealm`，配置哪些路径拦截，哪些放行



5，`adminController`编写一个控制器，获取管理员的信息，方便测试

```java
@RequestMapping(value = "/getAdmin", method = RequestMethod.GET)
    public Result<Admin> getAdmin() {
    Admin admin = adminService.getAdmin();
    return new Result<>(admin);
}
```



6，创建一个登录拦截器  `LoginInterceptor` ,没有携带`token`的请求就抛出异常，携带token的请求放行

针对登录的拦截方法，这里是拦截后实际执行的方法，拦截的规则，是在拦截器配置类 `InterceptorConfig`中配置

> 小技巧
>
> 创建一个Sting的数组，存放可以放行的请求url，拦截的时候看看是否在白名单中



7，使用了拦截器，那么就对拦截器需要有个配置文件  `InterceptorConfig`，对所有的请求进行拦截（除了登录的`url`等。。。）

8，这里基本上就已经完成了登录功能的验证



问题，报了一个这个错误

前端传的密码是明文，而后台存储的是hash值，导致先后台不匹配报错

如果数据库储存的密码是加密的 那么要 从前端获取密码后，在Java里将其转换成hash值

> 也就是说，测试的时候要用 密文

```
org.apache.shiro.authc.IncorrectCredentialsException: Submitted credentials for token [org.apache.shiro.authc.UsernamePasswordToken - admin, rememberMe=false] did not match the expected credentials.
```



## 五，分页查询

1，封装一个Page对象

```java
/**
 * 分页对象
 */
@Data
public class Page<T> implements Serializable {
    private static final String SORT_ASC = "asc";
    private static final String SORT_DESC = "desc";
    /**
     * 当前页
     */
    private Integer currentPage = 1;
    /**
     * 每页显示条数
     */
    private Integer pageSize = 20;
    /**
     * 总页数
     */
    private Integer totalPage = 0;
    /**
     * 总条数
     */
    private Integer totalCount = 0;
    /**
     * 数据
     */
    private List<T> list;
    /**
     * 条件参数
     */
    private Map<String, Object> params = new HashMap<>(16);
    /**
     * 排序列
     */
    private String sortColumn;
    /**
     * 排序方式
     */
    private String sortMethod = "asc";
    /**
     * 获取当前页
     */
    public Integer getCurrentPage() {
        if (currentPage < 1) {
            return 1;
        }
        return this.currentPage;
    }
    /**
     * 设置排序列
     */
    public void setSortColumn(String sortColumn) {
        if (StringUtils.isBlank(sortColumn)) {
            this.sortColumn = null;
        } else {
            //upperCharToUnderLine 驼峰转下划线
            this.sortColumn = StringUtils.upperCharToUnderLine(sortColumn);
        }
    }
    /**
     * 获取index
     * @return
     */
    public Integer getIndex() {
        return (currentPage - 1) * pageSize;
    }
    /**
     * 设置总条数的时候计算总页数
     */
    public void setTotalCount(Integer totalCount) {
        this.totalCount = totalCount;
        this.totalPage = (int) Math.ceil(totalCount * 1.0 / pageSize);
    }

    /**
     * 设置排序方式
     */
    public void setSortMethod(String sortMethod) {
        if (StringUtils.isBlank(sortMethod)) {
            this.sortMethod = SORT_ASC;
        }
        if (sortMethod.toLowerCase().startsWith(SORT_ASC)) {
            this.sortMethod = SORT_ASC;
        } else if (sortMethod.toLowerCase().startsWith(SORT_DESC)) {
            this.sortMethod = SORT_DESC;
        } else {
            this.sortMethod = SORT_ASC;
        }
    }
}
```

2，用封装好了的结果集对象装载分页对象

```java
public Result<Page<User>> getByPage(@RequestBody Page<User> page) {
    page = userService.getByPage(page);
    return new Result<>(page);
}
```

3，数据层查询时使用`list`

```java
@Override
public Page<User> getByPage(Page<User> page) {
    // 查询数据
    List<User> userList = userMapper.getByPage(page);
    page.setList(userList);
    return page;
}
```



## 五，编写相关模块功能的接口

> 这里就是对那些功能写一些接口，CRUD
>
> 这里主要是涉及一些业务逻辑



**注意：因为拦截器的影响，导致我测试接口不方便，所以还是关了在测试**

> 如果没有验证，那么就跳转到 loginl.jsp 页面去



1，分类模块

2，友情链接

3，管理员

对于查看当前的管理员，没有实现

```
http://localhost:8080/admin/info
```

`ShiroUtils` 报了空指针异常

4，博客

（1）有一个方法是查看博客，查看博客的时候不需要知道其所有的信息，那么我展示回显给前端的对象就不一定得是博客对象，可以再封装一个视图对象

```
BlogVo
```

（2）分页查询

封装一个  `Page`  对象 ， 接口返回的是 装载了博客视图的  ` List` 集合

（3）对于排序列，不知道有什么用

```java
public Result<Page<BlogVo>> getByPage(@RequestBody Page<BlogVo> page) {}
```

理解：因为客户想要的排序方式有很多种，可以根据id，根据其他的字段，所以就需要用户选择指定的字段，但是不能所有的字段都可以排序，所以就需要一个字符串数组控制，包含的字段可以排序，不包含的就不能排序

```java
String[] sortColumns = {"blog_goods", "blog_read", "blog_collection",
                    "type_name", "blog_comment", "created_time", "update_time"};
```

（4）对于博客的保存，项目中没有对博客表的  `id` 设置为自增，所以 需要自己天添加的时候 附上 `ID`

> 是要通过 `IWorker` 创建唯一id（雪花算法）

（5）对于阅读的功能，都会在  `service` 中添加开启事务的功能

```java
@Transactional(rollbackFor = Exception.class)
```

5，日志

6，用户

（1）在处理登录上还有瑕疵







## 六，后台前端

使用了`vue-admin-template` 模板



1，在 `Vue.config.js` 中配置代理，设置端口

2，`assets`  中存放一些比较隐私的文件

> 因为打包后信息会改变

3，网上一些公共的资源，可以放在 `public `文件夹中

4，设置路由

> 小 TIPS
>
> 回调地狱
>
> 在回调中又需要执行其他的方法，这个方法又有回调



5，处理逻辑（登录）

> 在 api 中

6，设置请求头，在 `request.js` 中 设置



### 一，登录功能

1，views 下的 user 的 index.vue 里有登录的逻辑，只需要修改一些提示信息

2，这个代码会去找 'user/login'  ，而 这个会在 `model` 下找到 ，然后在去找 `user` 中的  login 方法

```
this.$store.dispatch('user/login', this.loginForm).then(() => {}
```

-

```
login({ username: username.trim(), password: md5(password) }).then(response => {}
```

3，由于会有 	`token`   的存在， 所以需要在 `request.js`  文件中配置 `token`

```javascript
// request interceptor
service.interceptors.request.use(
  config => {
    // do something before request is sent

    if (store.getters.token) {
      //这这里就是需要获取的token的值，从cookie中拿，而在那个‘/user/login’ 方法中已经存放进去了
      config.headers['Authorization'] = getToken()
    }
    return config
  },
  error => {
    // do something with request error
    console.log(error) // for debug
    return Promise.reject(error)
  }
)
```



### 二，前端数据的映射

1，vue 的使用

slot-scope 作用域插槽“

```html
<template slot-scope="scope">
    <el-tag v-if="scope.row.enable === 1">启用</el-tag>
    <el-tag v-else type="info">未启用</el-tag>
</template>
```



----

2，当删除用户时，有时需要弹出一些确定信息，一般有两种形式：提示框和确认框

1.message信息框：

2.confirm确认框：



----

3，一个页面需要使用其他页面时，需要注册那个页面组件

```typescript
import TypeAdd from './type-add'
```

--

```typescript
export default{
    components: {
        TypeAdd,
        TypeUpdate
    }
}
```

-- 然后就可以使用

```html
<type-add @getTypeList="getTypeList" @closeAddDrawer="closeAddDrawer" />
```



---

4，全局 store 基本用法

在每一个`vue`  实例的子组件中都可以通过	`$root`  访问，作用相同的还有  `$parent` 获取父级的组件

> （官方文档）
>
> 对于 demo 或非常小型的有少量组件的应用来说这是很方便的。
>
> 不过这个模式扩展到中大型应用来说就不然了。因此在绝大多数情况下，我们强烈推荐使用 [Vuex](https://github.com/vuejs/vuex) 来管理应用的状态。

这里设置一个项目中全部可以使用的全局变量

（1）在 `store` 目录下有个`index.js`

```javascript
const store = new Vuex.Store({
  // 这些 modules都是在 store  目录下的 modules 文件夹 中封装了自定义的全局属性
  modules: {
    app,
    settings,
    user,
    global // 抛出来
  },
  getters // 抛出来
})
export default store
```

（2）我使用的是`getter` 

```javascript
const getters = {
  sidebar: state => state.app.sidebar,
  device: state => state.app.device,
  token: state => state.user.token,
  avatar: state => state.user.avatar,
  name: state => state.user.name,
  typeList: state => state.global.typeList // 这是我自己想要的全局变量
}
export default getters
```

（3）因为要使用 state 下的 global 的 typeList （如上），所以就需要自己创建一个自定义的全局属性

```javascript
const state = {
    // 分类列表
    typeList: []
}
// set方法
const mutations = {
    SET_TYPE: (state, typeList) => {
        state.typeList = typeList
    }
}

export default {
    namespaced: true,
    state,
    mutations
}
```

（4）然后就可以使用了

```
this.$store.getters.typeList
```

（5）当然这样是不完整的，因为之前也说了，是父类和子类之间，那么就是需要在所有`vue`组件的父级进行赋值，也就是 `mainapp.vue`



## 七，博客前端

1，this.$route.params.type

> 表示当前激活的路由的状态信息，包含了当前 URL 解析得到的信息，还有 URL 匹配到的 route records（路由记录）。
>

--

```
this.$route.params.type // 也就是表示当前路由下的参数中的type
```





2，方法前加@有什么用，方法前加：有什么用

> 加冒号的，说明后面的是一个变量或者表达式；没加冒号的后面就是对应的字符串字面量！

> @ 绑定事件





----

import persistedState from 'vuex-persistedstate'

import * as Cookies from 'js-cookie'

在stone 的 idnex中



## 八，路由守卫



## 九，个人问题

### 1，`springboot`是如何影响aop的配置，为什么要利用线程的上下文



### 2，配置这个有什么用，mybatis 又是如何利用的？

--  以下有什么用？

```xml
<!-- 通用查询结果列 -->
<sql id="Base_Column_List">
	log_id, log_url, log_params, log_status, log_message, log_method, log_time, log_result, log_ip, created_time
</sql>
```



### 3，在    `shiroUtils ` 工具类中为什么构造方法是私有的？



### 4，`adminRealm` 在 shiro 中有什么作用？



### 5，`shiro`  需要学习



### 6，`pagehelp` 的使用，在若依项目中，前台传来的分页对象是什么？



### 7，`spring` 事务的使用



### 8，`BUG`的解决

项目无法启动了

> 我就是sb，@Autowired 没有删掉

报错这里很说了xxx无法注入

就应该一个一个的找，那些没有注入，是不是注解没写，或者，注解没删！

```properties
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'shiroFilterFactoryBean' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: BeanPostProcessor before instantiation of bean failed; 

nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'authorizationAttributeSourceAdvisor' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: Unsatisfied dependency expressed through method 'authorizationAttributeSourceAdvisor' parameter 0; 

nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'securityManager' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: Unsatisfied dependency expressed through method 'securityManager' parameter 0; 

nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'adminRealm': Unsatisfied dependency expressed through method 'doGetAuthorizationInfo' parameter 0; 

nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'org.apache.shiro.subject.PrincipalCollection' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}

Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'authorizationAttributeSourceAdvisor' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: Unsatisfied dependency expressed through method 'authorizationAttributeSourceAdvisor' parameter 0; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'securityManager' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: Unsatisfied dependency expressed through method 'securityManager' parameter 0; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'adminRealm': Unsatisfied dependency expressed through method 'doGetAuthorizationInfo' parameter 0; nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'org.apache.shiro.subject.PrincipalCollection' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}

Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'securityManager' defined in class path resource [com/tutu/blog/config/ShiroConfig.class]: Unsatisfied dependency expressed through method 'securityManager' parameter 0; nested exception is org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'adminRealm': Unsatisfied dependency expressed through method 'doGetAuthorizationInfo' parameter 0; nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'org.apache.shiro.subject.PrincipalCollection' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}
	
	
	
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'adminRealm': Unsatisfied dependency expressed through method 'doGetAuthorizationInfo' parameter 0;

nested exception is org.springframework.beans.factory.NoSuchBeanDefinitionException: No qualifying bean of type 'org.apache.shiro.subject.PrincipalCollection' available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations: {}

```



### 9，上传文件的使用还不会

## 十，技巧

1，`controller` 层 不写参数校验，但是 要写参数校验，判断是否为空等等

2，非 `controller` 层 出错直接抛出异常

