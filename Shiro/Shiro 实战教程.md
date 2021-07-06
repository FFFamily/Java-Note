> Shiro 实战教程
>
> 缓存功能没有实现，没有报错

## 一，权限管理

权限管理属于系统安全的范畴，权限管理实现`对用户访问系统的控制`，按照安全规则或者[安全策略](http://baike.baidu.com/view/160028.htm)控制用户可以访问而且只能访问自己被授权的资源。

权限管理包括用户`身份认证`和`授权`两部分，简称`认证授权`。

> 对于需要访问控制的资源用户首先经过身份认证
>
> 认证通过后用户具有该资源的访问权限方可访问

###  认证

`身份认证`，就是判断一个用户是否为合法用户的处理过程

### 授权

`授权，即访问控制`，控制谁能访问哪些资源。主体进行身份认证后需要分配权限方可访问系统的资源，对于某些资源没有权限是无法访问的

----

## 二，shiro

Shiro 是一个功能强大且易于使用的Java安全框架，它执行身份验证、授权、加密和会话管理。使用Shiro易于理解的API，您可以快速轻松地保护任何应用程序—从最小的移动应用程序到最大的web和企业应用程序

Shiro是apache旗下一个开源框架，它将软件系统的安全认证相关的功能抽取出来，实现用户身份认证，权限授权、加密、会话管理等功能，组成了一个通用的安全认证框架

1，简单易用

2，API容易搞懂

----

## 三，核心架构

![image-20200520220413190](./img/2.png)



### Subject（主体）

`Subject即主体`，外部应用与subject进行交互，subject记录了当前操作用户，将用户的概念理解为当前操作的主体，可能是一个通过浏览器请求的用户，也可能是一个运行的程序。	

Subject在shiro中是一个接口，接口中定义了很多认证授相关的方法，外部程序通过subject进行认证授，而subject是通过SecurityManager安全管理器进行认证授权

### SecurityManager(核心)

`SecurityManager即安全管理器`，对全部的subject进行安全管理，它是shiro的核心，负责对所有的subject进行安全管理。通过SecurityManager可以完成subject的认证、授权等，实质上SecurityManager是通过Authenticator进行认证，通过Authorizer进行授权，通过SessionManager进行会话管理等。

`SecurityManager是一个接口，继承了Authenticator, Authorizer, SessionManager这三个接口。`

### Authenticator（认证器）

`Authenticator即认证器`，对用户身份进行认证

Authenticator是一个接口，`shiro`提供`ModularRealmAuthenticator`实现类，通过`ModularRealmAuthenticator`基本上可以满足大多数需求，也可以自定义认证器。

### Authorizer(授权器)

`Authorizer即授权器`，用户通过认证器认证通过，在访问功能时需要通过授权器判断用户是否有此功能的操作权限。

###  Realm（执行的实体）

`Realm即领域`，相当于`datasource`数据源，`securityManager` 进行安全认证需要通过Realm获取用户权限数据，比如：如果用户身份数据在数据库那么realm就需要从数据库获取用户身份信息。

- ​	注意：不要把realm理解成只是从数据源取数据，在realm中还有认证授权校验的相关的代码。

### SessionManager

`sessionManager即会话管理`

`shiro `框架定义 了一套会话管理，它不依赖 `web容器 ` 的 `session `，所以`shiro `可以使用在`非web应用`上，也可以将分布式应用的会话集中在一点管理，此特性可使它实现单点登录。

### SessionDAO

`SessionDAO即会话dao`，是对session会话操作的一套接口

比如要将`session`存储到数据库，可以通过`jdbc`将会话存储到数据库。

### CacheManager

`CacheManager即缓存管理`，将用户权限数据存储在缓存，这样可以提高性能。

### Cryptography

​	`Cryptography即密码管理`，shiro提供了一套加密/解密的组件，方便开发。比如提供常用的散列、加/解密等功能。

----

## 四，认证

### 1，认证概述

最常用的简单身份认证方式是系统通过核对用户输入的用户名和口令，看其是否与系统中存储的该用户的用户名和口令一致，来判断用户身份是否正确

### 2，关键对象

- **Subject：主体**

访问系统的用户，主体可以是用户、程序等，进行认证的都称为主体； 

- **Principal：身份信息**

是主体（subject）进行身份认证的标识，标识必须具有`唯一性`

如用户名、手机号、邮箱地址等，一个主体可以有多个身份，但是必须有一个主身份（Primary Principal）,也就是作为登录系统时的身份

- **credential：凭证信息**

是只有主体自己知道的安全信息，如密码、证书等。

### 3，认证流程

1，主体（`subject`）携带自己的身份信息（凭证信息）登录，也就是`token`

2，安全管理器会去请求认证器，认证器又会去请求`Realm` 获取去数据

3，如果信息和数据库中的一致，那么就通过

4，否则就认证失败



### 4，入门

#### （1）导入依赖

```xml
<dependency>
  <groupId>org.apache.shiro</groupId>
  <artifactId>shiro-core</artifactId>
  <version>1.5.3</version>
</dependency>
```

#### （2）shiro配置文件

> .ini  结尾文件（类似于 .txt）
>
> .ini 复杂数据格式，一般是写配置
>
> 整合 spingboot 后是使用不到的，只是为了学习时的简单，这样就不用去访问数据库，直接写死在这个文件

```ini
[users]
xiaochen=123
zhangsan=456
```

####  （3）代码

```java
public class TestAuthenticator {
    public static void main(String[] args) {
        //创建securityMana  ger
        DefaultSecurityManager defaultSecurityManager = new DefaultSecurityManager();
        defaultSecurityManager.setRealm(new IniRealm("classpath:shiro.ini"));
        //将安装工具类中设置默认安全管理器
        SecurityUtils.setSecurityManager(defaultSecurityManager);
        //获取主体对象
        Subject subject = SecurityUtils.getSubject();
        //创建token令牌
        UsernamePasswordToken token = new UsernamePasswordToken("xiaochen1", "123");
        //用户登录，没有报错则认为认真成功
        subject.login(token);
    }
}
```



认证失败的常见异常

- `UnknownAccountException` 账号不存在  // 认证器返回null
- `DisabledAccountException` 帐号被禁用
- `LockedAccountException` 帐号被锁定
- `ExcessiveAttemptsException` 登录失败次数过多
- `ExpiredCredentialsException`（凭证过期）等
- `IncorrectCredentialsException` 密码错误  //认证器认证密码时不匹配返回异常

-----



#### （4）解析认证源码过程(❤)

1，给 `login` 打断点进入，查看执行流程

```java
// 就直接来到了 DelegatingSubject 中
public void login(AuthenticationToken token) throws AuthenticationException {
    // 虽然调用的是subject的login，但是底层还是使用的securityManager
    // this 代表当前 DelegatingSubject
    // token 就是口令信息
    Subject subject = this.securityManager.login(this, token);
}
```

2，再次进入 `login` 方法

```java
// 来到了 DefaultSecurityManager 中的login方法
public Subject login(Subject subject, AuthenticationToken token) {
    AuthenticationInfo info;
        try {
            info = this.authenticate(token);
        } catch (AuthenticationException var7) {
            
        }
}
```

3，进入 authenticate 方法

```java
// 来到了认证管理器 AuthenticatingSecurityManager 中的 authenticate 方法
private Authenticator authenticator = new ModularRealmAuthenticator();

public AuthenticationInfo authenticate(AuthenticationToken token)  {
    //再次调用这个类中的 authenticator 的 authenticate 方法
	return this.authenticator.authenticate(token);
}
```

4，再次进入 authenticate 方法

```java
// AbstractAuthenticator
public final AuthenticationInfo authenticate(AuthenticationToken token)  {
    AuthenticationInfo info;
    try {
    	info = this.doAuthenticate(token);
    }
}
```

5，再次进入 `doAuthenticate` 方法

```java
protected AuthenticationInfo doAuthenticate(AuthenticationToken authenticationToken)  {
    // 这里是检测是否配置Realm
	this.assertRealmsConfigured();
	Collection<Realm> realms = this.getRealms();
    // 判断如果realm的数量为一则执行doSingleRealmAuthentication反之 doMultiRealmAuthentication
	return realms.size() == 1 ? 	this.doSingleRealmAuthentication((Realm)realms.iterator().next(), authenticationToken) : this.doMultiRealmAuthentication(realms, authenticationToken);
    }
```

6，这里只配置了一个realm，所以会进入 `doSingleRealmAuthentication` 方法

```java
protected AuthenticationInfo doSingleRealmAuthentication(Realm realm, AuthenticationToken token) {
    // 判断是否支持 token
	if (!realm.supports(token)) {
            String msg = "";
            throw new UnsupportedTokenException(msg);
        } else {
        	// 这里会有认证信息
            AuthenticationInfo info = realm.getAuthenticationInfo(token);
            if (info == null) {
                String msg = "";
                throw new UnknownAccountException(msg);
            } else {
                return info;
            }
        }
}
```

7，继续追踪 `getAuthenticationInfo` 方法

```java
public final AuthenticationInfo getAuthenticationInfo(AuthenticationToken token)  {
    // 从缓存中拿token
    AuthenticationInfo info = this.getCachedAuthenticationInfo(token);
    if (info == null) {
    	info = this.doGetAuthenticationInfo(token);
    }  
}
```

8，继续追踪 `doGetAuthenticationInfo` 方法

```java
protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token)  {
    // 获取token
    UsernamePasswordToken upToken = (UsernamePasswordToken)token;
    // 获取用户名，这里才进行到了用户名的校验
    SimpleAccount account = this.getUser(upToken.getUsername());
    if (account != null) {
        // 判断是否加锁
        if (account.isLocked()) {
        	throw new LockedAccountException("");
        }
		// 判断是否过期
        if (account.isCredentialsExpired()) {
            String msg = "";
            throw new ExpiredCredentialsException(msg);
        }
    }
    return account;
}
```

9，跳出这个方法，回到  `AuthenticatingRealm`  的  `getAuthenticationInfo`  方法，接下来就是对密码的判断

```java
if (info != null) {
	this.assertCredentialsMatch(token, info);
} else {
	log.debug("", token);
}
```

10，追踪到 `assertCredentialsMatch`类中

```java
protected void assertCredentialsMatch(AuthenticationToken token, AuthenticationInfo info) {
    CredentialsMatcher cm = this.getCredentialsMatcher();
    if (cm != null) {
        // 这里就判断密码
        if (!cm.doCredentialsMatch(token, info)) {
            String msg = "";
            throw new IncorrectCredentialsException(msg);
        }
    } else {
        throw new AuthenticationException("");
    }
}
```



从第八，九步可以知道，当需要我们自己去判断自己的Realm时，就需要继承`AuthorizingRealm`，实现指定的方法来进行判断，密码的校验是交给`shiro`自动完成

`SimpleAccountRealm` 继承了 `AuthorizingRealm` 实现了用户的认证和授权

意思是，自己的认证规则也是需要继承 `AuthorizingRealm`



### 5，自定义Realm(❤)

上边的程序使用的是`Shiro`自带的`IniRealm`，`IniRealm`从`ini`配置文件中读取用户的信息，大部分情况下需要从系统的数据库中读取用户信息，所以需要自定义realm。



**根据认证源码认证使用的是`SimpleAccountRealm`**



`SimpleAccountRealm的部分源码中有两个方法一个是 认证 一个是 授权`,

```java
public class SimpleAccountRealm extends AuthorizingRealm {
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token)  {}
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {}
}
```



##### （1）自定义realm

```java
public class CustomerRealm extends AuthorizingRealm {
    //授权方法
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        return null;
    }

    //认证方法
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token)  {
        String principal = (String) token.getPrincipal();
        if("tjj".equals(principal)){
            return new SimpleAuthenticationInfo(principal,"123",this.getName());
        }
        return null;
    }
}
```

##### （2）测试

```java
public class TestAuthenticatorCusttomerRealm {
    public static void main(String[] args) {
        //创建securityManager
        DefaultSecurityManager defaultSecurityManager = new DefaultSecurityManager();
        //IniRealm realm = new IniRealm("classpath:shiro.ini");
        //设置为自定义realm获取认证数据
        defaultSecurityManager.setRealm(new CustomerRealm());
        //将安装工具类中设置默认安全管理器
        SecurityUtils.setSecurityManager(defaultSecurityManager);
        //获取主体对象
        Subject subject = SecurityUtils.getSubject();
        //创建token令牌
        UsernamePasswordToken token = new UsernamePasswordToken("xiaochen", "123");
        subject.login(token);//用户登录
    }
}
```





### 6，使用MD5和Salt

> 实际应用是将盐和散列后的值存在数据库中，自动realm从数据库取出盐和加密后的值由shiro完成密码校验。

##### （1）自定义md5+salt

```java
/**
 * 自定义md5+salt realm
 */
public class CustomerRealm extends AuthorizingRealm {
    //授权方法
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        return null;
    }

    //认证方法
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token)  {
        String principal = (String) token.getPrincipal();
        if("xiaochen".equals(principal)){
            String password = "3c88b338102c1a343bcb88cd3878758e";
            String salt = "Q4F%";
            return new SimpleAuthenticationInfo(principal,password, 
                            ByteSource.Util.bytes(salt),this.getName());
        }
        return null;
}
```

##### （2）使用

```java
public class TestAuthenticatorCusttomerRealm {
    public static void main(String[] args) {
        //创建securityManager
        DefaultSecurityManager defaultSecurityManager = new DefaultSecurityManager();
        //IniRealm realm = new IniRealm("classpath:shiro.ini");
        //设置为自定义realm获取认证数据
        CustomerRealm customerRealm = new CustomerRealm();
        //设置md5加密
        HashedCredentialsMatcher credentialsMatcher = new HashedCredentialsMatcher();
        credentialsMatcher.setHashAlgorithmName("MD5");
        credentialsMatcher.setHashIterations(1024);//设置散列次数
        customerRealm.setCredentialsMatcher(credentialsMatcher);
        defaultSecurityManager.setRealm(customerRealm);
        //将安装工具类中设置默认安全管理器
        SecurityUtils.setSecurityManager(defaultSecurityManager);
        //获取主体对象
        Subject subject = SecurityUtils.getSubject();
        //创建token令牌
        UsernamePasswordToken token = new UsernamePasswordToken("xiaochen", "123");
        subject.login(token);//用户登录
    }
}
```

-----



## 五，授权

### 1，授权

授权，即访问控制，控制谁能访问哪些资源。

主体进行身份认证后需要分配权限方可访问系统的资源，对于某些资源没有权限是无法访问的。

### 2，关键对象

**授权可简单理解为who对what(which)进行How操作：**

`Who，即主体（Subject）`，主体需要访问系统中的资源。

`What，即资源（Resource)`，如系统菜单、页面、按钮、类方法、系统商品信息等。资源包括`资源类型`和`资源实例`

`How，权限/许可（Permission)`，规定了主体对资源的操作许可，权限离开资源没有意义，如用户查询权限、用户添加权限、某个类方法的调用权限、编号为001用户的修改权限等，通过权限可知主体对哪些资源都有哪些操作许可。

### 3，授权流程（▲）

1，用户携带`token`请求，如果有`token`就放行

2，判断`token`是否合法

3，不合法就认证失败，合法就放行

4，判断是否具有权限，没有就报错，有就访问资源

### 4，授权方式

- **基于角色的访问控制**
  
  - RBAC基于角色的访问控制（Role-Based Access Control）是以角色为中心进行访问控制
  
    ```java
    if(subject.hasRole("admin")){
       //操作什么资源
    }
    ```
  
- **基于资源的访问控制**
  
  - RBAC基于资源的访问控制（Resource-Based Access Control）是以资源为中心进行访问控制
  
    ```java
    if(subject.isPermission("user:update:01")){ //资源实例
      //对01用户进行修改
    }
    if(subject.isPermission("user:update:*")){  //资源类型
      //对01用户进行修改
    }
    ```
  
    

### 5，权限字符串 

权限字符串的规则是：

```
资源标识符：操作：资源实例标识符
```

****

意思是对哪个资源的哪个实例具有什么操作，“:”是资源/操作/实例的分割符，权限字符串也可以使用*通配符。

例子：

- 用户创建权限：user:create，或user:create:*
- 用户修改实例001的权限：user:update:001
- 用户实例001的所有权限：user:*：001



### 6，shiro中授权编程实现方式

- **编程式**

  ```java
  Subject subject = SecurityUtils.getSubject();
  if(subject.hasRole(“admin”)) {
  	//有权限
  } else {
  	//无权限
  }
  ```

- **注解式**

  ```java
  @RequiresRoles("admin")
  public void hello() {
  	//有权限
  }
  ```

- **标签式**

  ```jsp
  JSP/GSP 标签：在JSP/GSP 页面通过相应的标签完成：
  <shiro:hasRole name="admin">
  	<!— 有权限—>
  </shiro:hasRole>
  注意: Thymeleaf 中使用shiro需要额外集成!
  ```


### 7，入门

##### （1）realm的实现

```java
public class CustomerRealm extends AuthorizingRealm {
    //授权方法
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        // 获取主用户名
        String primaryPrincipal = (String) principals.getPrimaryPrincipal();
        SimpleAuthorizationInfo simpleAuthorizationInfo = new SimpleAuthorizationInfo();
        simpleAuthorizationInfo.addRole("admin");
        simpleAuthorizationInfo.addStringPermission("user:update:*");
        simpleAuthorizationInfo.addStringPermission("product:*:*");
        return simpleAuthorizationInfo;
    }

    //认证方法
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token)  {
        String principal = (String) token.getPrincipal();
        if("xiaochen".equals(principal)){
            String password = "3c88b338102c1a343bcb88cd3878758e";
            String salt = "Q4F%";
            return new SimpleAuthenticationInfo(principal,password, 
                  ByteSource.Util.bytes(salt),this.getName());
        }
        return null;
    }

}
```

##### （2）授权

```java
public class TestAuthenticatorCusttomerRealm {
    public static void main(String[] args) {
        //创建securityManager
        DefaultSecurityManager defaultSecurityManager = new DefaultSecurityManager();
        //IniRealm realm = new IniRealm("classpath:shiro.ini");
        //设置为自定义realm获取认证数据
        CustomerRealm customerRealm = new CustomerRealm();
        //设置md5加密
        HashedCredentialsMatcher credentialsMatcher = new HashedCredentialsMatcher();
        credentialsMatcher.setHashAlgorithmName("MD5");
        credentialsMatcher.setHashIterations(1024);//设置散列次数
        customerRealm.setCredentialsMatcher(credentialsMatcher);
        defaultSecurityManager.setRealm(customerRealm);
        //将安装工具类中设置默认安全管理器
        SecurityUtils.setSecurityManager(defaultSecurityManager);
        //获取主体对象
        Subject subject = SecurityUtils.getSubject();
        //创建token令牌
        UsernamePasswordToken token = new UsernamePasswordToken("xiaochen", "123");
        subject.login(token);//用户登录
          
        // 认证通过
        if(subject.isAuthenticated()){
            // 基于角色权限管理
            // 每执行一次就会访问一次认证方法
            boolean admin = subject.hasRole("admin");
            System.out.println(admin);

            boolean permitted = subject.isPermitted("product:create:001");
            System.out.println(permitted);
        }

    }
}
```



## 六，整合SpringBoot项目实战

### 1，整合思路

（需要观看）

### 2，依赖

```xml
<dependency>
  <groupId>org.apache.shiro</groupId>
  <artifactId>shiro-spring-boot-starter</artifactId>
  <version>1.5.3</version>
</dependency>
<!--引入JSP解析依赖-->
<dependency>
     <groupId>org.apache.tomcat.embed</groupId>
     <artifactId>tomcat-embed-jasper</artifactId>
</dependency>
<dependency>
     <groupId>jstl</groupId>
     <artifactId>jstl</artifactId>
     <version>1.2</version>
</dependency>
```

### 3，配置文件

```properties
server.port=8080
server.servlet.context-path=/shiro
spring.application.name=shiro

spring.mvc.view.prefix=/
spring.mvc.view.suffix=.jsp
```



### 4，配置shiro环境❤

##### （1）配置类

配置后访问`index.jsp`认证不通过就会跳转到登录界面

```java
/**
 * 用来整合shiro框架相关的配置类
 */
@Configuration
public class ShiroConfig {

    //1.创建shiroFilter  //负责拦截所有请求
    @Bean
    public ShiroFilterFactoryBean getShiroFilterFactoryBean(DefaultWebSecurityManager defaultWebSecurityManager){

        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();
        //给filter设置安全管理器
        shiroFilterFactoryBean.setSecurityManager(defaultWebSecurityManager);

        //配置系统受限资源
        //配置系统公共资源
        Map<String,String> map = new HashMap<String,String>();

        map.put("/index.jsp","authc");//authc 请求这个资源需要认证和授权

        //默认认证界面路径---当认证不通过时跳转
        shiroFilterFactoryBean.setLoginUrl("/login.jsp");
        shiroFilterFactoryBean.setFilterChainDefinitionMap(map);

        return shiroFilterFactoryBean;
    }
    //3.创建自定义realm
    @Bean
    public CustomerRealm getRealm(){
        CustomerRealm customerRealm = new CustomerRealm();
        return customerRealm;
    }
    
    
    //2.创建安全管理器
    @Bean
    public DefaultWebSecurityManager getDefaultWebSecurityManager(CustomerRealm customerRealm){
        DefaultWebSecurityManager defaultWebSecurityManager = new DefaultWebSecurityManager();
        //给安全管理器设置
        //设置时用原来的配置出了错误
        //如果这个方法的参数是Realm，那么就会注入错误，默认会注入一个Realm
        //既然自定义了一个Realm，那么就使用自己的 CustomerRealm
        //但是，也很有可能会是shiro.ini文件的原因
        //因为我创建了shiro.ini文件，所以shiro会创建默认的realm，springboot则注入
        //以上的猜想是正确的
        defaultWebSecurityManager.setRealm(customerRealm);
        return defaultWebSecurityManager;
    }
}
```

版本二(因为以上的BUG)

```java
@Bean
public DefaultWebSecurityManager getDefaultWebSecurityManager(Realm realm){}

@Bean
public Realm getRealm(){
    CustomerRealm customerRealm = new CustomerRealm();
    return customerRealm;
}
```



配置`shiroFilterFactoryBean`

（需要听 p14）

```java
@Bean
public ShiroFilterFactoryBean getShiroFilterFactoryBean(DefaultWebSecurityManager Manage){
    
}
```



配置`WebSecurityManager`

```java
@Bean
public DefaultWebSecurityManager getSecurityManager(Realm realm){}
```



创建自定义`realm`

```java
public class CustomerRealm extends AuthorizingRealm {}
```



配置自定义`realm`

```java
@Bean
public Realm getRealm(){}
```



##### （2）控制器

```java
@Controller
public class IndexController {
    @RequestMapping("index")
    public String index(){
        System.out.println("跳转至主页");
        return "index";
    }
}
```



##### （3）启动

- 注意: 默认在配置好shiro环境后默认环境中没有对项目中任何资源进行权限控制,所有现在项目中所有资源都可以通过路径访问



##### （4）加入权限控制

- 修改ShiroFilterFactoryBean配置

  ```java
  //注入安全管理器
  shiroFilterFactoryBean.setSecurityManager(securityManager);
  Map<String,String> map =  new LinkedHashMap<>();
  map.put("/**","authc");
  //配置认证和授权规则
  shiroFilterFactoryBean.setFilterChainDefinitionMap(map);
  ```


`**` 代表拦截项目中一切资源 

`authc`代表`shiro`的一个filter的别名,详细内容看`shirofilter`列表





### 5，常见过滤器❤

- 注意: **shiro提供和多个默认的过滤器，我们可以用这些过滤器来配置控制指定url的权限：**

| 配置缩写          | 对应的过滤器                   | 功能                                                         |
| ----------------- | ------------------------------ | ------------------------------------------------------------ |
| anon              | AnonymousFilter                | 指定url可以匿名访问                                          |
| authc             | FormAuthenticationFilter       | 指定url需要form表单登录，默认会从请求中获取`username`、`password`,`rememberMe`等参数并尝试登录，如果登录不了就会跳转到loginUrl配置的路径。我们也可以用这个过滤器做默认的登录逻辑，但是一般都是我们自己在控制器写登录逻辑的，自己写的话出错返回的信息都可以定制嘛。 |
| authcBasic        | BasicHttpAuthenticationFilter  | 指定url需要basic登录                                         |
| logout            | LogoutFilter                   | 登出过滤器，配置指定url就可以实现退出功能，非常方便          |
| noSessionCreation | NoSessionCreationFilter        | 禁止创建会话                                                 |
| perms             | PermissionsAuthorizationFilter | 需要指定权限才能访问                                         |
| port              | PortFilter                     | 需要指定端口才能访问                                         |
| rest              | HttpMethodPermissionFilter     | 将http请求方法转化成相应的动词来构造一个权限字符串，这个感觉意义不大，有兴趣自己看源码的注释 |
| roles             | RolesAuthorizationFilter       | 需要指定角色才能访问                                         |
| ssl               | SslFilter                      | 需要https请求才能访问                                        |
| user              | UserFilter                     | 需要已登录或“记住我”的用户才能访问                           |



### 6，验证认证

##### （1）认证界面

```html
<form action="${pageContext.request.contextPath}/user/login" method="post">
  用户名:<input type="text" name="username" > <br/>
  密码  : <input type="text" name="password"> <br>
  <input type="submit" value="登录">
</form>
```

##### （2）controller

```java
@Controller
@RequestMapping("user")
public class UserController {
  /**
    * 用来处理身份认证
    * @param username
    * @param password
    * @return
    */
  @RequestMapping("login")
  public String login(String username,String password){
    //获取主体对象
    //在认证过程中使用subject.login进行认证
    Subject subject = SecurityUtils.getSubject();
    try {
      subject.login(new UsernamePasswordToken(username,password));
      return  "redirect:/index.jsp";
    } catch (UnknownAccountException e) {
      e.printStackTrace();
      System.out.println("用户名错误!");
    }catch (IncorrectCredentialsException e){
      e.printStackTrace();
      System.out.println("密码错误!");
    }
    return "redirect:/login.jsp";
  }
}
```



##### （3）测试

```java
@Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
        System.out.println("==========================");
        String principal = (String) token.getPrincipal();
        if("xiaochen".equals(principal)){
            return new SimpleAuthenticationInfo(principal,"123",this.getName());
        }
        return null;
    }
}
```





### 7，退出认证

##### （1）退出

```html
<a href="${pageContext.request.contextPath}/user/logout">退出登录</a>
```

##### （2）controller

```java
@Controller
@RequestMapping("user")
public class UserController {
  @RequestMapping("logout")
  public String logout(){
    Subject subject = SecurityUtils.getSubject();
    subject.logout();//退出用户
    return "redirect:/login.jsp";
  }
}
```





### 七，MD5、Salt的认证实现❤

#### 1，数据库

#### 2，注册界面

```html
<h1>用户注册</h1>
<form action="${pageContext.request.contextPath}/user/register" method="post">
  用户名:<input type="text" name="username" > <br/>
  密码  : <input type="text" name="password"> <br>
  <input type="submit" value="立即注册">
</form>
```

#### 3，数据表

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
-- ----------------------------
-- Table structure for t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id` int(6) NOT NULL AUTO_INCREMENT,
  `username` varchar(40) DEFAULT NULL,
  `password` varchar(40) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;
```



#### 4，依赖

```xml
<!--mybatis相关依赖-->
<dependency>
  <groupId>org.mybatis.spring.boot</groupId>
  <artifactId>mybatis-spring-boot-starter</artifactId>
  <version>2.1.2</version>
</dependency>

<!--mysql-->
<dependency>
  <groupId>mysql</groupId>
  <artifactId>mysql-connector-java</artifactId>
  <version>5.1.38</version>
</dependency>

<!--druid-->
<dependency>
  <groupId>com.alibaba</groupId>
  <artifactId>druid</artifactId>
  <version>1.1.19</version>
</dependency>
```



#### 5，配置文件

```properties
server.port=8888
server.servlet.context-path=/shiro
spring.application.name=shiro

spring.mvc.view.prefix=/
spring.mvc.view.suffix=.jsp

#新增配置
spring.datasource.type=com.alibaba.druid.pool.DruidDataSource
spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/shiro?characterEncoding=UTF-8
spring.datasource.username=root
spring.datasource.password=root

mybatis.type-aliases-package=com.baizhi.springboot_jsp_shiro.entity
mybatis.mapper-locations=classpath:com/baizhi/mapper/*.xml
```



#### 6，实体类

```java
@Data
@Accessors(chain = true)
@AllArgsConstructor
@NoArgsConstructor
public class User {
    private String  id;
    private String username;
    private String password;
    private String salt;
}
```

#### 7，DAO

```java
@Mapper
public interface UserDAO {
    void save(User user);
}
```

#### 8，mapper映射

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.lut.dao.UserDao">
    <insert id="save" parameterType="User" useGeneratedKeys="true" keyProperty="id">
        insert into t_user values(#{id},#{username},#{password},#{salt})
    </insert>
</mapper>
```

#### 9，service

```java
public interface UserService {
    //注册用户方法
    void register(User user);
}
```

#### 10，salt工具类

```java
public class SaltUtils {
    /**
     * 生成salt的静态方法
     * @param n
     * @return
     */
    public static String getSalt(int n){
        char[] chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890!@#$%^&*()".toCharArray();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            char aChar = chars[new Random().nextInt(chars.length)];
            sb.append(aChar);
        }
        return sb.toString();
    }
}
```

#### 11，service实现

```java
@Service
@Transactional
public class UserServiceImpl implements UserService {

    @Autowired
    private UserDAO userDAO;

    @Override
    public void register(User user) {
        //处理业务调用dao
        //1.生成随机盐
        String salt = SaltUtils.getSalt(8);
        //2.将随机盐保存到数据
        user.setSalt(salt);
        //3.明文密码进行md5 + salt + hash散列
        Md5Hash md5Hash = new Md5Hash(user.getPassword(),salt,1024);
        user.setPassword(md5Hash.toHex());
        userDAO.save(user);
    }
}
```

#### 12，Controller

```java
@Controller
@RequestMapping("user")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 用户注册
     */
    @RequestMapping("register")
    public String register(User user) {
        try {
            userService.register(user);
            return "redirect:/login.jsp";
        }catch (Exception e){
            e.printStackTrace();
            return "redirect:/register.jsp";
        }
    }
}
```

##### 





#### 12，数据库认证

> 访问数据库进行认证

##### （1）开发DAO

```java
@Mapper
public interface UserDAO {
	//根据身份信息认证的方法
    User findByUserName(String username);
}
```

##### （2）mapper

```xml
<select id="findByUserName" parameterType="String" resultType="User">
  select id,username,password,salt from t_user
  where username = #{username}
</select>
```

##### （3）Service

```java
public interface UserService {
    //注册用户方法
    void register(User user);
    //根据用户名查询业务的方法
    User findByUserName(String username);
}
```



##### （4）Service实现

```java

@Service("userService")
@Transactional
public class UserServiceImpl implements UserService {
    @Autowired
    private UserDAO userDAO;
    @Override
    public User findByUserName(String username) {
        return userDAO.findByUserName(username);
    }
}
```



##### （5）获取bean对象的工具类

```java
@Component
public class ApplicationContextUtils implements ApplicationContextAware {
    
    private static ApplicationContext context;
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.context = applicationContext;
    }
    //根据bean名字获取工厂中指定bean 对象
    public static Object getBean(String beanName){
        return context.getBean(beanName);
    }
}
```



##### （6）修改自定义realm

```java
 @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
        System.out.println("==========================");

        //根据身份信息
        String principal = (String) token.getPrincipal();
        /**
        	在工厂中获取service对象
        	应该是采用这种方式才不会重新注入
        	springboot会破坏单例模式吗？
        **/
        UserService userService = (UserService) ApplicationContextUtils.getBean("userService");
				//根据身份信息查询
        User user = userService.findByUserName(principal);

        if(!ObjectUtils.isEmpty(user)){
            //返回数据库信息
            return new SimpleAuthenticationInfo(user.getUsername(),user.getPassword(), 
                                               ByteSource.Util.bytes(user.getSalt()),this.getName());
        }
        return null;
    }
```



##### （7）修改`realm`

> ##### 修改`ShiroConfig`中`realm`使用凭证匹配器以及hash散列
>

> 配置这个有什么用？

```java
@Bean
public Realm getRealm(){
  CustomerRealm customerRealm = new CustomerRealm();
  //设置hashed凭证匹配器
  HashedCredentialsMatcher credentialsMatcher = new HashedCredentialsMatcher();
  //设置md5加密
  credentialsMatcher.setHashAlgorithmName("md5");
  //设置散列次数
  credentialsMatcher.setHashIterations(1024);
  customerRealm.setCredentialsMatcher(credentialsMatcher);
  return customerRealm;
}
```



### 八，授权实现

##### 页面资源授权

> 这个shiro是做什么用的

```jsp
<%@taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<shiro:hasAnyRoles name="user,admin">
        <li><a href="">用户管理</a>
            <ul>
                <shiro:hasPermission name="user:add:*">
                <li><a href="">添加</a></li>
                </shiro:hasPermission>
                <shiro:hasPermission name="user:delete:*">
                    <li><a href="">删除</a></li>
                </shiro:hasPermission>
                <shiro:hasPermission name="user:update:*">
                    <li><a href="">修改</a></li>
                </shiro:hasPermission>
                <shiro:hasPermission name="user:find:*">
                    <li><a href="">查询</a></li>
                </shiro:hasPermission>
            </ul>
        </li>
        </shiro:hasAnyRoles>
        <shiro:hasRole name="admin">
            <li><a href="">商品管理</a></li>
            <li><a href="">订单管理</a></li>
            <li><a href="">物流管理</a></li>
        </shiro:hasRole>
```



##### 代码方式授权

```java
@RequestMapping("save")
public String save(){
  System.out.println("进入方法");
  //获取主体对象
  Subject subject = SecurityUtils.getSubject();
  //代码方式
  if (subject.hasRole("admin")) {
    System.out.println("保存订单!");
  }else{
    System.out.println("无权访问!");
  }
  //基于权限字符串
  //....
  return "redirect:/index.jsp";
}
```



##### 方法调用授权

> 这几个注解有什么用？

- @RequiresRoles               用来基于角色进行授权
- @RequiresPermissions    用来基于权限进行授权

```java
@RequiresRoles(value={"admin","user"})//用来判断角色  同时具有 admin user
@RequiresPermissions("user:update:01") //用来判断权限字符串
@RequestMapping("save")
public String save(){
  System.out.println("进入方法");
  return "redirect:/index.jsp";
}
```



----

##### 数据表

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for t_pers
-- ----------------------------
DROP TABLE IF EXISTS `t_pers`;
CREATE TABLE `t_pers` (
  `id` int(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for t_role
-- ----------------------------
DROP TABLE IF EXISTS `t_role`;
CREATE TABLE `t_role` (
  `id` int(6) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for t_role_perms
-- ----------------------------
DROP TABLE IF EXISTS `t_role_perms`;
CREATE TABLE `t_role_perms` (
  `id` int(6) NOT NULL,
  `roleid` int(6) DEFAULT NULL,
  `permsid` int(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for t_user
-- ----------------------------
DROP TABLE IF EXISTS `t_user`;
CREATE TABLE `t_user` (
  `id` int(6) NOT NULL AUTO_INCREMENT,
  `username` varchar(40) DEFAULT NULL,
  `password` varchar(40) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for t_user_role
-- ----------------------------
DROP TABLE IF EXISTS `t_user_role`;
CREATE TABLE `t_user_role` (
  `id` int(6) NOT NULL,
  `userid` int(6) DEFAULT NULL,
  `roleid` int(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS = 1;

```

----

##### dao

```java
 //根据用户名查询所有角色
User findRolesByUserName(String username);
//根据角色id查询权限集合
List<Perms> findPermsByRoleId(String id);
```

##### mapper

```xml
<resultMap id="userMap" type="User">
  <id column="uid" property="id"/>
  <result column="username" property="username"/>
  <!--角色信息-->
  <collection property="roles" javaType="list" ofType="Role">
    <id column="id" property="id"/>
    <result column="rname" property="name"/>
  </collection>
</resultMap>

<select id="findRolesByUserName" parameterType="String" resultMap="userMap">
  SELECT u.id uid,u.username,r.id,r.NAME rname
  FROM t_user u
  LEFT JOIN t_user_role ur
  ON u.id=ur.userid
  LEFT JOIN t_role r
  ON ur.roleid=r.id
  WHERE u.username=#{username}
</select>

<select id="findPermsByRoleId" parameterType="String" resultType="Perms">
  SELECT p.id,p.NAME,p.url,r.NAME
  FROM t_role r
  LEFT JOIN t_role_perms rp
  ON r.id=rp.roleid
  LEFT JOIN t_perms p ON rp.permsid=p.id
  WHERE r.id=#{id}
</select>
```

##### Service

```java
//根据用户名查询所有角色
User findRolesByUserName(String username);
//根据角色id查询权限集合
List<Perms> findPermsByRoleId(String id);
```

##### Service实现

```java
@Override
public List<Perms> findPermsByRoleId(String id) {
  return userDAO.findPermsByRoleId(id);
}

@Override
public User findRolesByUserName(String username) {
  return userDAO.findRolesByUserName(username);
}
```



##### 修改realm

> **注意：**如果你创建了一个用户，并为这个用户授予了一个角色，但这个角色并未关联任何的 授权字符串，那么调用数据库获得的结果是 
>
> List<Perms> perms=[null]，
>
> 此时 perms已经被初始化，里面只有一个属性null，使用判空的方法无法判别，此时继续遍历会报出空指针异常，
>
> 此时应当添加判断条件 perms.get(0)!=null

```java
public class CustomerRealm extends AuthorizingRealm {
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        //获取身份信息
        String primaryPrincipal = (String) principals.getPrimaryPrincipal();
        System.out.println("调用授权验证: "+primaryPrincipal);
        //根据主身份信息获取角色 和 权限信息
        UserService userService = (UserService) ApplicationContextUtils.getBean("userService");
        User user = userService.findRolesByUserName(primaryPrincipal);
        //授权角色信息
        if(!CollectionUtils.isEmpty(user.getRoles())){
            SimpleAuthorizationInfo simpleAuthorizationInfo = new SimpleAuthorizationInfo();
            user.getRoles().forEach(role->{
                simpleAuthorizationInfo.addRole(role.getName());
                //权限信息
                List<Perms> perms = userService.findPermsByRoleId(role.getId());
                if(!CollectionUtils.isEmpty(perms)){
                    perms.forEach(perm->{
                        simpleAuthorizationInfo.addStringPermission(perm.getName());
                    });
                }
            });
            return simpleAuthorizationInfo;
        }
        return null;
    }
}
```





---

### 九，使用CacheManager❤

Cache 作用

- Cache 缓存: **计算机内存中一段数据**  
- 作用: **用来减轻DB的访问压力,从而提高系统的查询效率**
- 流程: 

> 需要学习
>



#### 默认EhCache实现缓存

##### 依赖

```xml
<!--引入shiro和ehcache-->
<dependency>
  <groupId>org.apache.shiro</groupId>
  <artifactId>shiro-ehcache</artifactId>
  <version>1.5.3</version>
</dependency>
```

##### 开启缓存

```java
//3.创建自定义realm
@Bean
public Realm getRealm(){
    CustomerRealm customerRealm = new CustomerRealm();
    //修改凭证校验匹配器
    HashedCredentialsMatcher credentialsMatcher = new HashedCredentialsMatcher();
    //设置加密算法为md5
    credentialsMatcher.setHashAlgorithmName("MD5");
    //设置散列次数
    credentialsMatcher.setHashIterations(1024);
    customerRealm.setCredentialsMatcher(credentialsMatcher);

    //开启缓存管理器
    customerRealm.setCachingEnabled(true);
    customerRealm.setAuthorizationCachingEnabled(true);
    customerRealm.setAuthorizationCachingEnabled(true);
    customerRealm.setCacheManager(new EhCacheManager());
    return customerRealm;
}
```

##### 测试

- 注意:如果控制台没有任何sql展示说明缓存已经开启



#### 使用Redis作为缓存实现

##### 依赖

```xml
<!--redis整合springboot-->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

##### 配置

```properties
spring.redis.port=6379
spring.redis.host=localhost
spring.redis.database=0
```

##### 启动redis

```powershell
➜  bin ls
dump.rdb        redis-check-aof redis-cli       redis-server    redis.conf
redis-benchmark redis-check-rdb redis-sentinel  redis-trib.rb
➜  bin ./redis-server redis.conf
```



##### 开发RedisCacheManager

> 这个有什么用

```java
public class RedisCacheManager implements CacheManager {
    @Override
    public <K, V> Cache<K, V> getCache(String cacheName) throws CacheException {
        System.out.println("缓存名称: "+cacheName);
        return new RedisCache<K,V>(cacheName);
    }
}
```

##### RedisCache实现

```java
//自定义redis缓存的实现
public class RedisCache<k,v> implements Cache<k,v> {

    private String cacheName;

    public RedisCache() {
    }

    public RedisCache(String cacheName) {
        this.cacheName = cacheName;
    }

    @Override
    public v get(k k) throws CacheException {
        System.out.println("get key:"+k);
        return (v) getRedisTemplate().opsForHash().get(this.cacheName,k.toString());
    }

    @Override
    public v put(k k, v v) throws CacheException {
        System.out.println("put key: "+k);
        System.out.println("put value:"+v);
        getRedisTemplate().opsForHash().put(this.cacheName,k.toString(),v);
        return null;
    }

    @Override
    public v remove(k k) throws CacheException {
        System.out.println("=============remove=============");
        return (v) getRedisTemplate().opsForHash().delete(this.cacheName,k.toString());
    }

    @Override
    public void clear() throws CacheException {
        System.out.println("=============clear==============");
        getRedisTemplate().delete(this.cacheName);
    }

    @Override
    public int size() {
        return getRedisTemplate().opsForHash().size(this.cacheName).intValue();
    }

    @Override
    public Set<k> keys() {
        return getRedisTemplate().opsForHash().keys(this.cacheName);
    }

    @Override
    public Collection<v> values() {
        return getRedisTemplate().opsForHash().values(this.cacheName);
    }

    private RedisTemplate getRedisTemplate(){
        RedisTemplate redisTemplate = (RedisTemplate) ApplicationContextUtils.getBean("redisTemplate");
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setHashKeySerializer(new StringRedisSerializer());
        return redisTemplate;
    }
}

```

##### 启动项目测试发现报错

- 错误解释: **由于shiro中提供的simpleByteSource实现没有实现序列化,所有在认证时出现错误信息**

- 解决方案: **需要自动salt实现序列化**

  - 自定义salt实现序列化

    ```java
    //自定义salt实现  实现序列化接口
    public class MyByteSource extends SimpleByteSource implements Serializable {
        public MyByteSource(String string) {
            super(string);
        }
    }
    ```

  - 在realm中使用自定义salt

    ```java
     @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {
      System.out.println("==========================");
      //根据身份信息
      String principal = (String) token.getPrincipal();
      //在工厂中获取service对象
      UserService userService = (UserService) ApplicationContextUtils.getBean("userService");
      User user = userService.findByUserName(principal);
      if(!ObjectUtils.isEmpty(user)){
        return new SimpleAuthenticationInfo(user.getUsername(),user.getPassword(), 
                                          new MyByteSource(user.getSalt()),this.getName());
      }
      return null;
    }
    ```





### 十，注解使用

注解的使用需要开启注解支持

`@RequiresAuthentication`

注解要求当前的`Subject`在身份验证后才能执行被注解修饰的方法

类似于在身份认证的`controller`方法中，如果没有认证就无法执行

```java
public void updateAccount(Account userAccount) {
    if (!SecurityUtils.getSubject().isAuthenticated()) {
        throw new AuthorizationException(...);
    }
    ...
}
```



`@RequiresGuest`

要求`subject`是访客或者匿名用户的时候才能执行方法



`@RequiresPermissions`

注解要求当前`Subject`有一个或多个权限才能执行被注解标记的方法

```java
@RequiresPermissions("account:search")
public void find(Account account) {}
```

类似于

```java
if (!subject.isPermitted("account:search")) {
	throw new AuthorizationException(...);
}
// ....
```



`@RequiresRoles`

注解要求当前`Subject`具有所指定的角色

```java
@RequiresRoles("admin")
public void deleteUser(User user) {}
```



`@RequiresUser`

注解要求要访问或调用被注解标记的类/实例/方法的应用程序用户是当前会话中具有已知身份的`Subject`，

其通常是在当前会话期间进行身份验证或者从先前会话的`“RememberMe”`服务中记住





----

#### 验证码验证

##### 验证码

- 控制器

  ```java
  @RequestMapping("getImage")
  public void getImage(HttpSession session, HttpServletResponse response) throws IOException {
    //生成验证码
    String code = VerifyCodeUtils.generateVerifyCode(4);
    //验证码放入session
    session.setAttribute("code",code);
    //验证码存入图片
    ServletOutputStream os = response.getOutputStream();
    response.setContentType("image/png");
    VerifyCodeUtils.outputImage(220,60,os,code);
  }
  ```

- 验证码

  ```JAVA
  public class VerifyCodeUtils {
      //使用到Algerian字体，系统里没有的话需要安装字体，字体只显示大写，去掉了1,0,i,o几个容易混淆的字符
      public static final String VERIFY_CODES = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
      private static Random random = new Random();
  
  
      /**
       * 使用系统默认字符源生成验证码
       * @param verifySize    验证码长度
       * @return
       */
      public static String generateVerifyCode(int verifySize){
          return generateVerifyCode(verifySize, VERIFY_CODES);
      }
      /**
       * 使用指定源生成验证码
       * @param verifySize    验证码长度
       * @param sources   验证码字符源
       * @return
       */
      public static String generateVerifyCode(int verifySize, String sources){
          if(sources == null || sources.length() == 0){
              sources = VERIFY_CODES;
          }
          int codesLen = sources.length();
          Random rand = new Random(System.currentTimeMillis());
          StringBuilder verifyCode = new StringBuilder(verifySize);
          for(int i = 0; i < verifySize; i++){
              verifyCode.append(sources.charAt(rand.nextInt(codesLen-1)));
          }
          return verifyCode.toString();
      }
  
      /**
       * 生成随机验证码文件,并返回验证码值
       * @param w
       * @param h
       * @param outputFile
       * @param verifySize
       * @return
       * @throws IOException
       */
      public static String outputVerifyImage(int w, int h, File outputFile, int verifySize) throws IOException{
          String verifyCode = generateVerifyCode(verifySize);
          outputImage(w, h, outputFile, verifyCode);
          return verifyCode;
      }
  
      /**
       * 输出随机验证码图片流,并返回验证码值
       * @param w
       * @param h
       * @param os
       * @param verifySize
       * @return
       * @throws IOException
       */
      public static String outputVerifyImage(int w, int h, OutputStream os, int verifySize) throws IOException{
          String verifyCode = generateVerifyCode(verifySize);
          outputImage(w, h, os, verifyCode);
          return verifyCode;
      }
  
      /**
       * 生成指定验证码图像文件
       * @param w
       * @param h
       * @param outputFile
       * @param code
       * @throws IOException
       */
      public static void outputImage(int w, int h, File outputFile, String code) throws IOException{
          if(outputFile == null){
              return;
          }
          File dir = outputFile.getParentFile();
          if(!dir.exists()){
              dir.mkdirs();
          }
          try{
              outputFile.createNewFile();
              FileOutputStream fos = new FileOutputStream(outputFile);
              outputImage(w, h, fos, code);
              fos.close();
          } catch(IOException e){
              throw e;
          }
      }
  
      /**
       * 输出指定验证码图片流
       * @param w
       * @param h
       * @param os
       * @param code
       * @throws IOException
       */
      public static void outputImage(int w, int h, OutputStream os, String code) throws IOException{
          int verifySize = code.length();
          BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
          Random rand = new Random();
          Graphics2D g2 = image.createGraphics();
          g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
          Color[] colors = new Color[5];
          Color[] colorSpaces = new Color[] { Color.WHITE, Color.CYAN,
                  Color.GRAY, Color.LIGHT_GRAY, Color.MAGENTA, Color.ORANGE,
                  Color.PINK, Color.YELLOW };
          float[] fractions = new float[colors.length];
          for(int i = 0; i < colors.length; i++){
              colors[i] = colorSpaces[rand.nextInt(colorSpaces.length)];
              fractions[i] = rand.nextFloat();
          }
          Arrays.sort(fractions);
  
          g2.setColor(Color.GRAY);// 设置边框色
          g2.fillRect(0, 0, w, h);
  
          Color c = getRandColor(200, 250);
          g2.setColor(c);// 设置背景色
          g2.fillRect(0, 2, w, h-4);
  
          //绘制干扰线
          Random random = new Random();
          g2.setColor(getRandColor(160, 200));// 设置线条的颜色
          for (int i = 0; i < 20; i++) {
              int x = random.nextInt(w - 1);
              int y = random.nextInt(h - 1);
              int xl = random.nextInt(6) + 1;
              int yl = random.nextInt(12) + 1;
              g2.drawLine(x, y, x + xl + 40, y + yl + 20);
          }
  
          // 添加噪点
          float yawpRate = 0.05f;// 噪声率
          int area = (int) (yawpRate * w * h);
          for (int i = 0; i < area; i++) {
              int x = random.nextInt(w);
              int y = random.nextInt(h);
              int rgb = getRandomIntColor();
              image.setRGB(x, y, rgb);
          }
  
          shear(g2, w, h, c);// 使图片扭曲
  
          g2.setColor(getRandColor(100, 160));
          int fontSize = h-4;
          Font font = new Font("Algerian", Font.ITALIC, fontSize);
          g2.setFont(font);
          char[] chars = code.toCharArray();
          for(int i = 0; i < verifySize; i++){
              AffineTransform affine = new AffineTransform();
              affine.setToRotation(Math.PI / 4 * rand.nextDouble() * (rand.nextBoolean() ? 1 : -1), (w / verifySize) * i + fontSize/2, h/2);
              g2.setTransform(affine);
              g2.drawChars(chars, i, 1, ((w-10) / verifySize) * i + 5, h/2 + fontSize/2 - 10);
          }
  
          g2.dispose();
          ImageIO.write(image, "jpg", os);
      }
  
      private static Color getRandColor(int fc, int bc) {
          if (fc > 255)
              fc = 255;
          if (bc > 255)
              bc = 255;
          int r = fc + random.nextInt(bc - fc);
          int g = fc + random.nextInt(bc - fc);
          int b = fc + random.nextInt(bc - fc);
          return new Color(r, g, b);
      }
  
      private static int getRandomIntColor() {
          int[] rgb = getRandomRgb();
          int color = 0;
          for (int c : rgb) {
              color = color << 8;
              color = color | c;
          }
          return color;
      }
  
      private static int[] getRandomRgb() {
          int[] rgb = new int[3];
          for (int i = 0; i < 3; i++) {
              rgb[i] = random.nextInt(255);
          }
          return rgb;
      }
  
      private static void shear(Graphics g, int w1, int h1, Color color) {
          shearX(g, w1, h1, color);
          shearY(g, w1, h1, color);
      }
  
      private static void shearX(Graphics g, int w1, int h1, Color color) {
  
          int period = random.nextInt(2);
  
          boolean borderGap = true;
          int frames = 1;
          int phase = random.nextInt(2);
  
          for (int i = 0; i < h1; i++) {
              double d = (double) (period >> 1)
                      * Math.sin((double) i / (double) period
                      + (6.2831853071795862D * (double) phase)
                      / (double) frames);
              g.copyArea(0, i, w1, 1, (int) d, 0);
              if (borderGap) {
                  g.setColor(color);
                  g.drawLine((int) d, i, 0, i);
                  g.drawLine((int) d + w1, i, w1, i);
              }
          }
  
      }
  
      private static void shearY(Graphics g, int w1, int h1, Color color) {
  
          int period = random.nextInt(40) + 10; // 50;
  
          boolean borderGap = true;
          int frames = 20;
          int phase = 7;
          for (int i = 0; i < w1; i++) {
              double d = (double) (period >> 1)
                      * Math.sin((double) i / (double) period
                      + (6.2831853071795862D * (double) phase)
                      / (double) frames);
              g.copyArea(i, 0, 1, h1, 0, (int) d);
              if (borderGap) {
                  g.setColor(color);
                  g.drawLine(i, (int) d, i, 0);
                  g.drawLine(i, (int) d + h1, i, h1);
              }
  
          }
  
      }
      public static void main(String[] args) throws IOException {
          //获取验证码
          String s = generateVerifyCode(4);
          //将验证码放入图片中
          outputImage(260,60,new File("/Users/chenyannan/Desktop/安工资料/aa.jpg"),s);
          System.out.println(s);
      }
  }
  
  ```

  

- 开发页面

  ```HTML
  请输入验证码: <input type="text" name="code"><img src="${pageContext.request.contextPath}/user/getImage" alt=""><br>
  ```

  

- 修改认证流程

  ```java
  @RequestMapping("login")
      public String login(String username, String password,String code,HttpSession session) {
          //比较验证码
          String codes = (String) session.getAttribute("code");
          try {
              if (codes.equalsIgnoreCase(code)){
                  //获取主体对象
                  Subject subject = SecurityUtils.getSubject();
                      subject.login(new UsernamePasswordToken(username, password));
                      return "redirect:/index.jsp";
              }else{
                  throw new RuntimeException("验证码错误!");
              }
          } catch (UnknownAccountException e) {
              e.printStackTrace();
              System.out.println("用户名错误!");
          } catch (IncorrectCredentialsException e) {
              e.printStackTrace();
              System.out.println("密码错误!");
          }catch (Exception e){
              e.printStackTrace();
              System.out.println(e.getMessage());
          }
          return "redirect:/login.jsp";
      }
  ```

- 修改salt不能序列化的问题

  ```java
  //自定义salt实现  实现序列化接口
  public class MyByteSource implements ByteSource,Serializable {
  
      private  byte[] bytes;
      private String cachedHex;
      private String cachedBase64;
  
      //加入无参数构造方法实现序列化和反序列化
      public MyByteSource(){
  
      }
  
      public MyByteSource(byte[] bytes) {
          this.bytes = bytes;
      }
  
      public MyByteSource(char[] chars) {
          this.bytes = CodecSupport.toBytes(chars);
      }
  
      public MyByteSource(String string) {
          this.bytes = CodecSupport.toBytes(string);
      }
  
      public MyByteSource(ByteSource source) {
          this.bytes = source.getBytes();
      }
  
      public MyByteSource(File file) {
          this.bytes = (new MyByteSource.BytesHelper()).getBytes(file);
      }
  
      public MyByteSource(InputStream stream) {
          this.bytes = (new MyByteSource.BytesHelper()).getBytes(stream);
      }
  
      public static boolean isCompatible(Object o) {
          return o instanceof byte[] || o instanceof char[] || o instanceof String || o instanceof ByteSource || o instanceof File || o instanceof InputStream;
      }
  
      public byte[] getBytes() {
          return this.bytes;
      }
  
      public boolean isEmpty() {
          return this.bytes == null || this.bytes.length == 0;
      }
  
      public String toHex() {
          if (this.cachedHex == null) {
              this.cachedHex = Hex.encodeToString(this.getBytes());
          }
  
          return this.cachedHex;
      }
  
      public String toBase64() {
          if (this.cachedBase64 == null) {
              this.cachedBase64 = Base64.encodeToString(this.getBytes());
          }
  
          return this.cachedBase64;
      }
  
      public String toString() {
          return this.toBase64();
      }
  
      public int hashCode() {
          return this.bytes != null && this.bytes.length != 0 ? Arrays.hashCode(this.bytes) : 0;
      }
  
      public boolean equals(Object o) {
          if (o == this) {
              return true;
          } else if (o instanceof ByteSource) {
              ByteSource bs = (ByteSource)o;
              return Arrays.equals(this.getBytes(), bs.getBytes());
          } else {
              return false;
          }
      }
  
      private static final class BytesHelper extends CodecSupport {
          private BytesHelper() {
          }
  
          public byte[] getBytes(File file) {
              return this.toBytes(file);
          }
  
          public byte[] getBytes(InputStream stream) {
              return this.toBytes(stream);
          }
      }
  }
  ```

  ----





## thymeleaf权限控制

### 1.引入扩展依赖

```xml
<dependency>
    <groupId>com.github.theborakompanioni</groupId>
    <artifactId>thymeleaf-extras-shiro</artifactId>
    <version>2.0.0</version>
</dependency>
```

### 2.页面中引入命名空间

-  xmlns:shiro="http://www.pollix.at/thymeleaf/shiro"

```html
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:th="http://www.thymeleaf.org"
      xmlns:shiro="http://www.pollix.at/thymeleaf/shiro">
......
```

### 3.常见权限控制标签使用

```html
<!-- 验证当前用户是否为“访客”，即未认证（包含未记住）的用户。 -->
<p shiro:guest="">Please <a href="login.html">login</a></p>


<!-- 认证通过或已记住的用户。 -->
<p shiro:user="">
    Welcome back John! Not John? Click <a href="login.html">here</a> to login.
</p>

<!-- 已认证通过的用户。不包含已记住的用户，这是与user标签的区别所在。 -->
<p shiro:authenticated="">
    Hello, <span shiro:principal=""></span>, how are you today?
</p>
<a shiro:authenticated="" href="updateAccount.html">Update your contact information</a>

<!-- 输出当前用户信息，通常为登录帐号信息。 -->
<p>Hello, <shiro:principal/>, how are you today?</p>


<!-- 未认证通过用户，与authenticated标签相对应。与guest标签的区别是，该标签包含已记住用户。 -->
<p shiro:notAuthenticated="">
    Please <a href="login.html">login</a> in order to update your credit card information.
</p>

<!-- 验证当前用户是否属于该角色。 -->
<a shiro:hasRole="admin" href="admin.html">Administer the system</a><!-- 拥有该角色 -->

<!-- 与hasRole标签逻辑相反，当用户不属于该角色时验证通过。 -->
<p shiro:lacksRole="developer"><!-- 没有该角色 -->
    Sorry, you are not allowed to developer the system.
</p>

<!-- 验证当前用户是否属于以下所有角色。 -->
<p shiro:hasAllRoles="developer, 2"><!-- 角色与判断 -->
    You are a developer and a admin.
</p>

<!-- 验证当前用户是否属于以下任意一个角色。  -->
<p shiro:hasAnyRoles="admin, vip, developer,1"><!-- 角色或判断 -->
    You are a admin, vip, or developer.
</p>

<!--验证当前用户是否拥有指定权限。  -->
<a shiro:hasPermission="userInfo:add" href="createUser.html">添加用户</a><!-- 拥有权限 -->

<!-- 与hasPermission标签逻辑相反，当前用户没有制定权限时，验证通过。 -->
<p shiro:lacksPermission="userInfo:del"><!-- 没有权限 -->
    Sorry, you are not allowed to delete user accounts.
</p>

<!-- 验证当前用户是否拥有以下所有角色。 -->
<p shiro:hasAllPermissions="userInfo:view, userInfo:add"><!-- 权限与判断 -->
    You can see or add users.
</p>

<!-- 验证当前用户是否拥有以下任意一个权限。  -->
<p shiro:hasAnyPermissions="userInfo:view, userInfo:del"><!-- 权限或判断 -->
    You can see or delete users.
</p>
<a shiro:hasPermission="pp" href="createUser.html">Create a new User</a>

```

### 4.加入shiro的方言配置

- 页面标签不起作用一定要记住加入方言处理

```java
@Bean(name = "shiroDialect")
public ShiroDialect shiroDialect(){
  return new ShiroDialect();
}
```




