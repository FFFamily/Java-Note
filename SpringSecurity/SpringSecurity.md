# SpringSecurity

> 问题
>
> 1，基于权限的授权没搞懂
>
> 2，登录页面的设置未成功

## 概念

### 主题（principal）

使用系统的用户或设备或从其他系统远程登录的用户等

### 认证（authentication）

系统确认一个主体的身份

### 授权（authorrization）

系统决定主体具有什么样的功能权限





## 入门

导入依赖

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <dependency>
        <groupId>org.thymeleaf</groupId>
        <artifactId>thymeleaf-spring5</artifactId>
    </dependency>
    
    <dependency>
        <groupId>org.thymeleaf.extras</groupId>
        <artifactId>thymeleaf-extras-java8time</artifactId>
    </dependency>
</dependencies>
```

在 `Security` 的依赖中包含

```properties
org.springframework.boot:spring-boot-starter:2.4.4
org.springframework:spring-aop:5.3.5
org.springframework.security:spring-security-config:5.4.5
org.springframework.security:spring-security-web:5.4.5
```

配置

```properties
# 取消缓存
spring.thymeleaf.cache=false
# 配置 thymeleaf，这样就能在 template 中访问html文件
spring.mvc.view.prefix= /
spring,mvc.view.suffix = .html
```

控制器

```java
@Controller
public class UserController {
    @RequestMapping("/index")
    public String inde(){
        // 随便在template目录下创建index.html页面
        return "webapp/index";
    }
}
```

运行，访问，即可出现`SpringSecurity`的默认登录界面

输入 `user` 

密码会打印在控制台，这样就完成了`SpringSecurity`的基本入门



## 配置文件

```java
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
    
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {}
    
    protected void configure(HttpSecurity http) throws Exception {}
    /**
     * 密码加密器
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        /**
         * BCryptPasswordEncoder：相同的密码明文每次生成的密文都不同，安全性更高
         */
        return new BCryptPasswordEncoder();
    }
}
```



## 认证

在配置文件中配置认证规则

```java
protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    // 配置用户名以及密码，对应的角色为“admin","user"
    auth.inMemoryAuthentication().passwordEncoder(new BCryptPasswordEncoder())
                .withUser("admin").password(new BCryptPasswordEncoder().encode("123456")).roles("admin","user");
}
```

当然，基本上角色的认证，是需要访问数据库的

当什么也没有配置的时候，账号和密码是由 Spring Security 定义生成的。而在实际项目中  

账号和密码都是从数据库中查询出来的。 所以我们要通过自定义逻辑控制认证逻辑。  

如果需要自定义逻辑时，只需要实现 UserDetailsService 接口即可

```java
@Autowired
private UserDetailsService service;

@Override
protected void configure(AuthenticationManagerBuilder auth) throws Exception {
    /**
    * 指定用户认证时，默认从哪里获取认证用户信息
    
    */
	auth.userDetailsService(service);
}
```

在service层实现用户的认证

```java
public class UserDetailsServiceImpl implements UserDetailsService {
    /**
     * 根据用户名获取认证用户信息
     */
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        if(StringUtils.isEmpty(username)) {
            throw new UsernameNotFoundException("用户名为空");
        } else {
            // 根据用户名查找用户信息
            // 注意: 密码验证是security处理的
            User user = dao.getUserByUsername(username);
            if(authUser == null) {
                throw new UsernameNotFoundException("登录的用户不存在");
            }
            List<GrantedAuthority> grantedAuthorities = new ArrayList<>();
            for (String role : user.getRoles()) {
                //封装用户信息和角色信息到SecurityContextHolder全局缓存中
                grantedAuthorities.add(new SimpleGrantedAuthority(role));
            }
            // 这个User是security自带的User，User继承了UserDetails
            return new User(authUser.getUsername(), authUser.getPassword(), grantedAuthorities);
        }
    }
}
```



测试

```java
/**
 * 用户接口类（返回JSON）
 */
@RestController
public class UserController {
    /**
     * 获取登录后的Principal
     */
    @GetMapping("/getPrincipal")
    public Object getPrincipal(@AuthenticationPrincipal Principal principal){
        return principal;
    }
    /**
     * 获取登录后的UserDetails
     */
    @GetMapping("/getUserDetails")
    public Object getUserDetails(@AuthenticationPrincipal UserDetails userDetails) {
        return userDetails;
    }
}
```

使用自己的登录页面时需要注意

> 1，必须是post
>
> 2，必须是username，password，因为有个验证密码的过滤器会验证password和username参数
>
> 可以在配置文件中配置http.usernameParameter("") 和 http.passwordParameter("")



用户认证过滤链

```properties
org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter
org.springframework.security.web.context.SecurityContextPersistenceFilter
org.springframework.security.web.header.HeaderWriterFilter
org.springframework.security.web.csrf.CsrfFilter
org.springframework.security.web.authentication.logout.LogoutFilter
org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
org.springframework.security.web.authentication.ui.DefaultLoginPageGeneratingFilter
org.springframework.security.web.authentication.ui.DefaultLogoutPageGeneratingFilter
org.springframework.security.web.savedrequest.RequestCacheAwareFilter
org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter
org.springframework.security.web.authentication.AnonymousAuthenticationFilter
org.springframework.security.web.session.SessionManagementFilter
org.springframework.security.web.access.ExceptionTranslationFilter
org.springframework.security.web.access.intercept.FilterSecurityInterceptor
```

几个核心的过滤链

FilterSecurityInterceptor：是一个方法级的权限过滤器, 基本位于过滤链的最底部

ExceptionTranslationFilter：是个异常过滤器，用来处理在认证授权过程中抛出的异常  

UsernamePasswordAuthenticationFilter ：对/login 的 POST 请求做拦截，校验表单中用户名，密码



## 授权

1，启动类，开启授权

```java
@EnableGlobalMethodSecurity(prePostEnabled = true)
```

2，在配置文件中配置权限规则

```java
protected void configure(HttpSecurity http) throws Exception {
    /**
    	* 	注意：Controller中也对URL配置了权限，如果WebSecurityConfig中和Controller中都对某文化URL配置了权限，则取较小的权限
    */
        http
            .formLogin() //表单登录：使用默认的表单登录页面和登录端点/login进行登录
                .defaultSuccessUrl("/toHome", false)
                .permitAll()
                .and()
            .logout() // 退出登录：使用默认的退出登录端点/logout退出登录
                .permitAll()
                .and()
            .rememberMe() // 记住我：使用默认的“记住我”功能，把已登录的Token保存在内存里，30分钟
                .tokenValiditySeconds(1800)
                .and()
            .authorizeRequests() // 授权：除了/toHome和/toUser之外的其它请求都要求用户已登录
                .antMatchers("/toHome", "/toUser").permitAll()
                .anyRequest()
                .authenticated();// 如果用户不是匿名的，则返回true
    			.antMatchers("/user").hasRole("admin")// 授权：只有admin才能访问 /user 地址
    	// 取消一些页面攻击验证
    	http.csrf().disable();
}
```

3，控制器

```java
@Controller
public class PageController {
    @GetMapping("/index")
    @PreAuthorize("hasRole('ADMIN')")//需要 admin角色
    public String toAdmin() {
        return "admin.html";
    }
}
```



## 自定义登录页

配置文件

```
http.formLogin() // 表单登录
    .loginPage("/loginPage") // 在哪个页面登录
    .successForwardUrl("/success") // 登录成功后跳转的页面
    .loginProcessingUrl("/login") // 登录提交的URL
    .failureForwardUrl("/fail") // 登录失败的页面
```



## 自定义403页面



## 记住我

配置类

```java
@Configuration
public class BrowserSecurityConfig {
    @Autowired
    private DataSource dataSource;
    @Bean
    public PersistentTokenRepository persistentTokenRepository(){
        JdbcTokenRepositoryImpl jdbcTokenRepository = new JdbcTokenRepositoryImpl();
        // 赋值数据源
        jdbcTokenRepository.setDataSource(dataSource);
        // 自动创建表,第一次执行会创建，以后要执行就要删除掉
        //jdbcTokenRepository.setCreateTableOnStartup(true);
        return jdbcTokenRepository;
    }
}

```

修改`security`配置文件

```java
//配置记住我
http.rememberMe().tokenRepository(persistentTokenRepository);
http.rememberMe().tokenValiditySeconds(1800)// 设置时间,单位是秒
```

这样，在默认的登录页面就可以看到记住我的选项



## 退出

自定义退出按钮

```html
<a href="/logout">退出</a>
```

配置类中配置

```java
http.logout().logoutSuccessUrl("/index").permitAll(); // 设置退出成功跳转
http.logout().logoutUrl("/logout").permitAll();
```



## CSRF

跨站请求攻击

```java
// 关闭安全配置的类中的 CSRF
http.csrf().disable();
```

原理

1，生成token保存到HttpSession或者Cookie中

2，请求到来时，从请求中提取 token 值，和本身保存的 CSRFToken 做比较，从而判断当前请求是否合法，主要通过`CsrfFiltter` 完成