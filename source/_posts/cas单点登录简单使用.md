---
title: cas单点登录简单使用
categories:
  - cas
tags:
  - java单点登录
  - 单点登录
date: 2021-04-04 21:42:37
---


## 背景

有几个相对独立的java的web应用系统， 各自有自己的登陆验证功能，用户在使用不同的系统的时候，需要登陆不同的系统。现在需要提供一个统一的登陆/登出界面， 而不修改各个系统原来的登陆验证机制。于是采用单点登录系统CAS。

## 使用步骤

- 要使用单点登录，需要部署CAS系统， CAS服务端可以直接部署在tomcat下运行， 对于CAS服务端来说，所有要集成单点登录的web应用都是它的一个客户端， CAS有客户端jar包， 客户端web应用需要引入CAS客户端的jar包，这样CAS系统的服务端和客户端web应用程序端才能通信。 
- 客户端web应用程序的通过配置web.xml，添加CAS需要的各种过滤器，来实现和CAS服务器通信， 用户信息验证工作在CAS服务端统一完成， 验证通过后，客户端web应用程序只需要补全自己的Session信息即可。
- 各个客户端web应用程序需要使用一个公用的用户表。



## 第一步 部署CAS系统服务端

1. 从官网http://developer.jasig.org/cas/下载CAS Server， 将cas-server-webapp-3.4.12.war解压， 可以看到是一个标准的java的web应用， 可以直接部署到tomcat的webapps目录下的，我这里假设部署的路径是{tomcat_home}/webapps/cas。

2. CAS默认需要tomcat配置SSL协议，使用https协议通信的。 由于项目是企事业单位内部的系统，不需要这么高的安全级别， 可以简化操作，不走SSL协议。修改下配置文件\WEB-INF\spring-configuration\ticketGrantingTicketCookieGenerator.xml， 如下， 将默认的true改成false即可。

   ```xml
   <bean id="ticketGrantingTicketCookieGenerator" class="org.jasig.cas.web.support.CookieRetrievingCookieGenerator"  
   	p:cookieSecure="false"  
   	p:cookieMaxAge="-1"  
   	p:cookieName="CASTGC"  
   	p:cookiePath="/cas" />
   ```

3. 配置登录的验证逻辑， 修改配置文件cas\WEB-INF\deployerConfigContext.xml。在authenticationHandlers中配置验证方式，我这里配置数据库查询语句来实现用户名和密码的验证。

   ```xml
   <property name="authenticationHandlers">  
       <list>  
                   <!--  
                       | This is the authentication handler that authenticates services by means of callback via SSL, thereby validating  
                       | a server side SSL certificate.  
                       +-->   
           <bean class="org.jasig.cas.authentication.handler.support.HttpBasedServiceCredentialsAuthenticationHandler"  
                 p:httpClient-ref="httpClient" />  
           <!--  
                       | This is the authentication handler declaration that every CAS deployer will need to change before deploying CAS   
                       | into production.  The default SimpleTestUsernamePasswordAuthenticationHandler authenticates UsernamePasswordCredentials  
                       | where the username equals the password.  You will need to replace this with an AuthenticationHandler that implements your  
                       | local authentication strategy.  You might accomplish this by coding a new such handler and declaring  
                       | edu.someschool.its.cas.MySpecialHandler here, or you might use one of the handlers provided in the adaptors modules.  
                       +-->  
           <bean class="org.jasig.cas.adaptors.jdbc.SearchModeSearchDatabaseAuthenticationHandler">
               <property name="dataSource" ref="ds"/>
   
               <property name="tableUsers" value="user"/>
               <property name="fieldUser" value="username"/>
               <property name="fieldPassword" value="password"/>
           </bean>
           <!-- <bean class="org.jasig.cas.authentication.handler.support.SimpleTestUsernamePasswordAuthenticationHandler" /> -->  
   
           <bean class="org.jasig.cas.adaptors.jdbc.QueryDatabaseAuthenticationHandler">  
               <property name="sql" value="select password from userTable where userName=?" />  
               <property name="passwordEncoder" ref="passwordEncoder"/>  
               <property name="dataSource" ref="dataSource" />  
           </bean>  -->
       </list>  
   </property>  
   
   
   ```

   **密码加密方法我这里使用MD5， 配置passwordEncoder的bean**

   ```xml
    <bean id="passwordEncoder" class="org.jasig.cas.authentication.handler.DefaultPasswordEncoder" autowire="byName">  
           <constructor-arg value="MD5"/>   
    </bean>  
   ```

   **在配置一个名称为dataSource的数据源**

   ```xml
   <bean id="dataSource" class="org.logicalcobwebs.proxool.ProxoolDataSource">  
           <property name="driver" value="com.microsoft.sqlserver.jdbc.SQLServerDriver"></property>  
           <property name="driverUrl" value="jdbc:sqlserver://localhost:1433;databaseName=testDB;">				</property>  
           <property name="user" value="sa"></property>  
           <property name="password" value="123456"></property>  
           <property name="maximumConnectionCount" value="100"></property>  
           <property name="minimumConnectionCount" value="1"></property>  
    </bean>  
   ```

   数据源的配置根据自己的实际情况来配置， 需要的jar如果lib下面没有，自己复制进去， 不然数据源连不上报错。

4. 现在服务端就配置好了， 如果需要定制登录/登出页面的话（实际项目基本上都需要修改）， 修改cas\WEB-INF\view\jsp\default\ui\下面的casLoginView.jsp和casLogoutView.jsp就可以了



## 第二步 客户端web应用程序集成CAS

1. 从官网 [http://developer.jasig.org/cas-clients/](http://developer.jasig.org/cas-clients/cas-client-java-3.0.0.zip) 下载CAS Client， 将客户端的jar，如cas-client-core-3.2.1.jar引入到web应用程序的classpath中

2. 配置web.xml文件， 主要是添加过滤器拦截通信， 下面的实例代码， 假设web应用程序的端口是8080

   ```xml
   <!-- CAS 单点登录(SSO) 过滤器配置 (start) -->  
       <!-- 该过滤器用于实现单点登出功能。-->  
       <filter>  
           <filter-name>CAS Single Sign Out Filter</filter-name> 
           <filter-class>org.jasig.cas.client.session.SingleSignOutFilter</filter-class> 
       </filter>  
       <filter-mapping>  
           <filter-name>CAS Single Sign Out Filter</filter-name>  
           <url-pattern>/*</url-pattern>  
       </filter-mapping>  
       <!-- CAS: 用于单点退出 -->  
       <listener>  
           <listener-class>org.jasig.cas.client.session.SingleSignOutHttpSessionListener</listener-class>  
       </listener>  
       <!-- 该过滤器负责用户的认证工作，必须启用它 -->  
       <filter>  
           <filter-name>CASFilter</filter-name>  
           <filter-class>org.jasig.cas.client.authentication.AuthenticationFilter</filter-class>
           <init-param>  
               <param-name>casServerLoginUrl</param-name>  
               <!-- 下面的URL是Cas服务器的登录地址 --> 
               <param-value>http://CAS服务端所在服务器IP:8080/cas/login</param-value>  
           </init-param>  
           <init-param>  
               <param-name>serverName</param-name>  
               <!-- 下面的URL是具体某一个应用的访问地址 --> 
               <param-value>http://具体web应用程序所在服务器IP:8080</param-value>  
           </init-param>
       </filter>  
       <filter-mapping>  
           <filter-name>CASFilter</filter-name>  
           <url-pattern>/*</url-pattern>  
       </filter-mapping>  
       <!-- 该过滤器负责对Ticket的校验工作，必须启用它 -->  
       <filter>  
           <filter-name>CAS Validation Filter</filter-name>  
           <filter-class>org.jasig.cas.client.validation.Cas20ProxyReceivingTicketValidationFilter</filter-class>  
           <init-param>  
               <param-name>casServerUrlPrefix</param-name>  
               <!-- 下面的URL是Cas服务器的认证地址 -->  
               <param-value>http://CAS服务端所在服务器IP:8080/cas</param-value>  
           </init-param>  
           <init-param>  
               <param-name>serverName</param-name>  
               <!-- 下面的URL是具体某一个应用的访问地址 -->  
               <param-value>http://具体web应用程序所在服务器IP:8080</param-value> 
           </init-param>  
           <init-param>  
             <param-name>renew</param-name>  
             <param-value>false</param-value>  
           </init-param>  
           <init-param>  
             <param-name>gateway</param-name>  
             <param-value>false</param-value>  
           </init-param>  
       </filter>  
       <filter-mapping>  
           <filter-name>CAS Validation Filter</filter-name>  
           <url-pattern>/*</url-pattern>  
       </filter-mapping>  
       <!--  
       该过滤器负责实现HttpServletRequest请求的包裹，  
       比如允许开发者通过HttpServletRequest的getRemoteUser()方法获得SSO登录用户的登录名，可选配置。  
       --> 
       <filter>  
           <filter-name>CAS HttpServletRequest Wrapper Filter</filter-name>  
           <filter-class>org.jasig.cas.client.util.HttpServletRequestWrapperFilter</filter-class>  
       </filter>  
       <filter-mapping>  
           <filter-name>CAS HttpServletRequest Wrapper Filter</filter-name>  
           <url-pattern>/*</url-pattern>  
       </filter-mapping>  
       <!--  
       该过滤器使得开发者可以通过org.jasig.cas.client.util.AssertionHolder来获取用户的登录名。  
       比如AssertionHolder.getAssertion().getPrincipal().getName()。  
       -->  
       <filter>  
           <filter-name>CAS Assertion Thread Local Filter</filter-name>  
           <filter-class>org.jasig.cas.client.util.AssertionThreadLocalFilter</filter-class>  
       </filter>  
       <filter-mapping>  
           <filter-name>CAS Assertion Thread Local Filter</filter-name>  
           <url-pattern>/*</url-pattern>  
       </filter-mapping>  
       <!-- 自动根据单点登录的结果设置本系统的用户信息（具体某一个应用实现） -->  
       <filter>  
           <filter-name>CasForInvokeContextFilter</filter-name>  
           <filter-class>com.cm.demo.filter.CasForInvokeContextFilter</filter-class>  
           <init-param>  
             <param-name>appId</param-name>  
             <param-value>a5ea611bbff7474a81753697a1714fb0</param-value>  
           </init-param>  
       </filter>  
       <filter-mapping>  
           <filter-name>CasForInvokeContextFilter</filter-name>  
           <url-pattern>/*</url-pattern> 
       </filter-mapping>  
       <!-- CAS 单点登录(SSO) 过滤器配置 (end) --> 
   ```

3. 注意上步配置文件中，过滤器CasForInvokeContextFilter的实现是需要在具体的应用中实现的，他的目的是， CAS服务端登录验证成功后，会将登录用户的用户名携带回来， 这时客户端web应用程序需要根据用户名从数据库用户表中查询到用户的Id等信息， 并填充到Session中， 这样，客户端应用程序原来的验证逻辑就不会出问题了， 因为我们一般都是通过验证session中是否含有当前登录的用户的ID来进行登录验证的。下面是CasForInvokeContextFilter的一个简单实现。

   ```java
    /** 
    * 该过滤器用户从CAS认证服务器中获取登录用户用户名，并填充必要的Session. 
    * @author jiarong_cheng 
    * @created 2012-7-12 
    */  
   public class CasForInvokeContextFilter implements Filter {  
       @Override  
       public void destroy() {  
       }
       
       @Override  
       public void doFilter(ServletRequest request, ServletResponse response, 
                            FilterChain chain) throws IOException, ServletException {  
           HttpSession session = ((HttpServletRequest) request).getSession();  
           //如果session中没有用户信息，则填充用户信息  
           if (session.getAttribute("j_userId") == null) {  
               //从Cas服务器获取登录账户的用户名
               Assertion assertion = AssertionHolder.getAssertion();  
               String userName = assertion.getPrincipal().getName();  
               try {  
                   //根据单点登录的账户的用户名，从数据库用户表查找用户信息， 填充到session中  
                   User user = UserDao.getUserByName(userName);  
                   session.setAttribute("username", userName);  
                   session.setAttribute("userId", user.getId()); 
               } catch (Exception e) {  
                   e.printStackTrace();  
               }  
           }  
           chain.doFilter(request, response);  
       }  
       @Override  
       public void init(FilterConfig config) throws ServletException {  
       }  
   }  
   ```

   **到此，就完成了， 当你访问具体应用的网址, 如http://具体应用IP: 8080/ ，就会跳转到CAS服务器的登陆页面: http://CAS服务器IP: 8080/  进行登录验证， 验证通过后， 又会跳转回应用的网址。**

   

## 第三步 单点登出

这个比较简单， 只要在系统的登出事件中， 将URL访问地址指向CAS服务登出的servlet， 就可以了。

```tex
http://cas服务器IP:8080/cas/logout
```

