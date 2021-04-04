---
title: SpringBoot集成SpringSecurity和JWT做登陆鉴权
categories:
  - spring
tags:
  - springsecurity
  - jwt
  - 登录
  - taken
date: 2021-04-04 22:16:48
---



## **废话**

目前流行的前后端分离让Java程序员可以更加专注的做好后台业务逻辑的功能实现，提供如返回Json格式的数据接口就可以。SpringBoot的易用性和对其他框架的高度集成，用来快速开发一个小型应用是最佳的选择。

一套前后端分离的后台项目，刚开始就要面对的就是登陆和授权的问题。这里提供一套方案供大家参考。

主要看点：

- 登陆后获取token，根据token来请求资源
- 根据用户角色来确定对资源的访问权限
- 统一异常处理
- 返回标准的Json格式数据



## **正文**

### 首先是**pom文件**：

```xml
<dependencies>
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
    </dependency>
    <!--这是不是必须，只是我引用了里面一些类的方法-->
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-solr</artifactId>
    </dependency>
    <!--这是不是必须，只是我引用了里面一些类的方法-->
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>1.3.2</version>
    </dependency>
    <dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <scope>runtime</scope>
    </dependency>
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
    </dependency>
    <dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.6.1</version>
    </dependency>
    <dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.6.1</version>
    </dependency>
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-rest</artifactId>
    </dependency>
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
    <groupId>org.springframework.security</groupId>
    <artifactId>spring-security-jwt</artifactId>
    <version>1.0.9.RELEASE</version>
    </dependency>
    <dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>
    <version>0.9.0</version>
    </dependency>
    <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
    </dependency>
</dependencies>
```

### **application.yml:**

```yml
spring :
datasource :
url : jdbc:mysql://127.0.0.1:3306/les_data_center?useUnicode=true&amp;characterEncoding=UTF-8&allowMultiQueries=true&useAffectedRows=true&useSSL=false
username : root
password : 123456
driverClassName : com.mysql.jdbc.Driver
jackson:
data-format: yyyy-MM-dd HH:mm:ss
time-zone: GMT+8
mybatis :
config-location : classpath:/mybatis-config.xml
# JWT
jwt:
header: Authorization
secret: mySecret
#token有效期一天
expiration: 86400
tokenHead: "Bearer "
```

### **接着是对security的配置，让security来保护我们的API**

SpringBoot推荐使用配置类来代替xml配置。那这里，我也使用配置类的方式。

```java
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    private final JwtAuthenticationEntryPoint unauthorizedHandler;

    private final AccessDeniedHandler accessDeniedHandler;

    private final UserDetailsService CustomUserDetailsService;

    private final JwtAuthenticationTokenFilter authenticationTokenFilter;

    @Autowired
    public WebSecurityConfig(JwtAuthenticationEntryPoint unauthorizedHandler,
    @Qualifier("RestAuthenticationAccessDeniedHandler") AccessDeniedHandler accessDeniedHandler,
    @Qualifier("CustomUserDetailsService") UserDetailsService CustomUserDetailsService,
    JwtAuthenticationTokenFilter authenticationTokenFilter) {
        this.unauthorizedHandler = unauthorizedHandler;
        this.accessDeniedHandler = accessDeniedHandler;
        this.CustomUserDetailsService = CustomUserDetailsService;
        this.authenticationTokenFilter = authenticationTokenFilter;
    }

    @Autowired
    public void configureAuthentication(AuthenticationManagerBuilder authenticationManagerBuilder) throws Exception {
        authenticationManagerBuilder
        // 设置UserDetailsService
        .userDetailsService(this.CustomUserDetailsService)
        // 使用BCrypt进行密码的hash
        .passwordEncoder(passwordEncoder());
    }
    // 装载BCrypt密码编码器
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(HttpSecurity httpSecurity) throws Exception {
        httpSecurity
        .exceptionHandling().accessDeniedHandler(accessDeniedHandler).and()
        // 由于使用的是JWT，我们这里不需要csrf
        .csrf().disable()
        .exceptionHandling().authenticationEntryPoint(unauthorizedHandler).and()
        // 基于token，所以不需要session
        .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()

        .authorizeRequests()

        // 对于获取token的rest api要允许匿名访问
        .antMatchers("/api/v1/auth", "/api/v1/signout", "/error/**", "/api/**").permitAll()
        // 除上面外的所有请求全部需要鉴权认证
        .anyRequest().authenticated();

        // 禁用缓存
        httpSecurity.headers().cacheControl();

        // 添加JWT filter
        httpSecurity
        .addFilterBefore(authenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);
    }

    @Override
    public void configure(WebSecurity web) throws Exception {
        web.ignoring().antMatchers("/v2/api-docs",
        "/swagger-resources/configuration/ui",
        "/swagger-resources",
        "/swagger-resources/configuration/security",
        "/swagger-ui.html"
        );
    }

    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }
}
```

**该类中配置了几个bean来供security使用。**

- JwtAuthenticationTokenFilter：token过滤器来验证token有效性
- UserDetailsService：实现了DetailsService接口，用来做登陆验证
- JwtAuthenticationEntryPoint ：认证失败处理类
- RestAuthenticationAccessDeniedHandler： 权限不足处理类



### 一些实现类

那么，接下来一个一个实现这些类

##### JwtAuthenticationTokenFilter

```java
/**
 * token校验,引用的stackoverflow一个答案里的处理方式
 * Author: JoeTao
 * createAt: 2018/9/14
 */
@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {

    @Value("${jwt.header}")
    private String token_header;

    @Resource
    private JWTUtils jwtUtils;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain) throws ServletException, IOException {
        String auth_token = request.getHeader(this.token_header);
        final String auth_token_start = "Bearer ";
        if (StringUtils.isNotEmpty(auth_token) && auth_token.startsWith(auth_token_start)) {
            auth_token = auth_token.substring(auth_token_start.length());
        } else {
// 不按规范,不允许通过验证
            auth_token = null;
        }

        String username = jwtUtils.getUsernameFromToken(auth_token);

        logger.info(String.format("Checking authentication for user %s.", username));

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            User user = jwtUtils.getUserFromToken(auth_token);
            if (jwtUtils.validateToken(auth_token, user)) {
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(user, null, user.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                logger.info(String.format("Authenticated user %s, setting security context", username));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }
        chain.doFilter(request, response);
    }
}
```

##### JwtAuthenticationEntryPoint

```java
/**
 * 认证失败处理类，返回401
 * Author: JoeTao
 * createAt: 2018/9/20
 */
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint, Serializable {

    private static final long serialVersionUID = -8970718410437077606L;

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
//验证为未登陆状态会进入此方法，认证错误
        System.out.println("认证失败：" + authException.getMessage());
        response.setStatus(200);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=utf-8");
        PrintWriter printWriter = response.getWriter();
        String body = ResultJson.failure(ResultCode.UNAUTHORIZED, authException.getMessage()).toString();
        printWriter.write(body);
        printWriter.flush();
    }
}
```



##### RestAuthenticationAccessDeniedHandler

**因为我们使用的REST API,所以我们认为到达后台的请求都是正常的，所以返回的HTTP状态码都是200，用接口返回的code来确定请求是否正常。**

```java
/**
 * 权限不足处理类，返回403
 * Author: JoeTao
 * createAt: 2018/9/21
 */
@Component("RestAuthenticationAccessDeniedHandler")
public class RestAuthenticationAccessDeniedHandler implements AccessDeniedHandler {
    @Override
    public void handle(HttpServletRequest httpServletRequest, HttpServletResponse response, AccessDeniedException e) throws IOException, ServletException {
//登陆状态下，权限不足执行该方法
        System.out.println("权限不足：" + e.getMessage());
        response.setStatus(200);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=utf-8");
        PrintWriter printWriter = response.getWriter();
        String body = ResultJson.failure(ResultCode.FORBIDDEN, e.getMessage()).toString();
        printWriter.write(body);
        printWriter.flush();
    }
}
```

##### CustomUserDetailsService

```java
/**
 * 登陆身份认证
 * Author: JoeTao
 * createAt: 2018/9/14
 */
@Component(value="CustomUserDetailsService")
public class CustomUserDetailsService implements UserDetailsService {
    private final AuthMapper authMapper;

    public CustomUserDetailsService(AuthMapper authMapper) {
        this.authMapper = authMapper;
    }

    @Override
    public User loadUserByUsername(String name) throws UsernameNotFoundException {
        User user = authMapper.findByUsername(name);
        if (user == null) {
            throw new UsernameNotFoundException(String.format("No user found with username '%s'.", name));
        }
        Role role = authMapper.findRoleByUserId(user.getId());
        user.setRole(role);
        return user;
    }
}
```



##### **登陆逻辑：**

```java
 public ResponseUserToken login(String username, String password) {
        //用户验证
        final Authentication authentication = authenticate(username, password);
        //存储认证信息
        SecurityContextHolder.getContext().setAuthentication(authentication);
        //生成token
        final User user = (User) authentication.getPrincipal();
        // User user = (User) userDetailsService.loadUserByUsername(username);
        final String token = jwtTokenUtil.generateAccessToken(user);
        //存储token
        jwtTokenUtil.putToken(username, token);
        return new ResponseUserToken(token, user);
    }

    private Authentication authenticate(String username, String password) {
        try {
            //该方法会去调用userDetailsService.loadUserByUsername()去验证用户名和密码，如果正确，则存储该用户名密码到“security 的 context中”
            return authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(username, password));
        } catch (DisabledException | BadCredentialsException e) {
            throw new CustomException(ResultJson.failure(ResultCode.LOGIN_ERROR, e.getMessage()));
        }
    }
```



##### **自定义异常：**

```java
@Getter
public class CustomException extends RuntimeException{
    private ResultJson resultJson;

    public CustomException(ResultJson resultJson) {
        this.resultJson = resultJson;
    }
}
```



##### **统一异常处理：**

```java
/**
 * 异常处理类
 * controller层异常无法捕获处理，需要自己处理
 * Created by jt on 2018/8/27.
 */
@RestControllerAdvice
@Slf4j
public class DefaultExceptionHandler {

    /**
     * 处理所有自定义异常
     * @param e
     * @return
     */
    @ExceptionHandler(CustomException.class)
    public ResultJson handleCustomException(CustomException e){
        log.error(e.getResultJson().getMsg().toString());
        return e.getResultJson();
    }
}
```

所有经controller转发的请求抛出的自定义异常都会被捕获处理，一般情况下就是返回给调用方一个json的报错信息，包含自定义状态码、错误信息及补充描述信息。

值得注意的是，在请求到达controller之前，会被Filter拦截，如果在controller或者之前抛出的异常，自定义的异常处理器是无法处理的，需要自己重新定义一个全局异常处理器或者直接处理。



##### **Filter拦截请求两次的问题**

跨域的post的请求会验证两次，get不会。网上的解释是，post请求第一次是预检请求，Request Method： OPTIONS。

解决方法：在webSecurityConfig里添加

```java
.antMatchers(HttpMethod.OPTIONS, "/**").permitAll()
```

就可以不拦截options请求了。

这里只给出了最主要的代码，还有controller层的访问权限设置，返回状态码，返回类定义等等。

所有代码已上传GitHub，[项目地址](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fpipijoe%2Fauth)