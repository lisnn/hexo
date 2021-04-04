---
title: CAS开发，登陆日志配置
categories:
  - cas
tags:
  - 登录日志
  - cas
date: 2019-04-04 21:42:43
---


步骤：

1. cas-server-webapp-support/src/test/resources/inspektrThrottledSubmissionContext.xml文件到/cas-server-webapp/src/main/webapp/WEB-INF文件夹下

   

2. 注释掉 deployerConfigContext.xml文件下的

   ```xml
   <beanid="auditTrailManager"class="com.github.inspektr.audit.support.Slf4jLoggingAuditTrailManager"/>
   ```

3. 修改web.xml文件，添加inspektrThrottledSubmissionContext.xml 见：

   ```xml
   <param-value>   
       /WEB-INF/spring-configuration/*.xml    
       /WEB-INF/inspektrThrottledSubmissionContext.xml    
       /WEB-INF/deployerConfigContext.xml 
   </param-value>
   ```

4. 创建日志表，需要主键可以添加一个int自增长的主键。

   ```sql
    CREATETABLE `com_audit_trail` (  
     `AUD_USER` varchar(100) NOTNULL,    -- 用户登陆名
     `AUD_CLIENT_IP` varchar(15) NOTNULL,  -- 客户端 ip
     `AUD_SERVER_IP` varchar(15) NOTNULL,   -- 服务端ip
     `AUD_RESOURCE` varchar(500) NOTNULL,   -- 访问系统地址，可区分系统
     `AUD_ACTION` varchar(100) NOTNULL,     -- 票据状态
     `APPLIC_CD` varchar(5) NOTNULL,  
     `AUD_DATE` timestampNOTNULL    -- 登陆时间
   ) 
   ```

5. 当用了nginx代理时，无法获取客户端真实ip，获取的是代理后的ip，也就是nginx部署服务器的ip。要获取客户端真实ip，在上面的配置中增加：

   1. 在web.xml中配置了filter:（这个filter本身已存在，只要添加init-param即可）

      ```xml
      <filter>
          <filter-name>CAS Client Info Logging Filter</filter-name>
          <filter-class>com.github.inspektr.common.web.ClientInfoThreadLocalFilter</filter-class>
            <!-- 当 cas负载均衡时，配置如下参数，获取用户真实ip -->
                  <init-param>
                       <param-name>alternativeIpAddressHeader</param-name>
                      <param-value>X-Forwarded-For</param-value>
               </init-param>
        </filter>
        <filter-mapping>
          <filter-name>CAS Client Info Logging Filter</filter-name>
          <url-pattern>/*</url-pattern>
        </filter-mapping>
      ```

      2.在nginx中的location中加上

      ```xml
      #PortalSys转发配置
          upstream PortalSys{
                      server 143.105.10.33:8989 weight=10;
                      }
          server {
              listen       81;
              server_name  jxsjcywz.com;
      
              location / {
                  #root   html;
                  #index  index.html index.htm;
                      proxy_pass http://PortalSys;
                      proxy_set_header Host jxsjcywz.com:81;
                      
                      proxy_set_header X-Real-IP $remote_addr;#保留代理之前的真实客户端ip
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header HTTP_X_FORWARDED_FOR $remote_addr;#在多级代理的情况下，记录每次代理之前的客户端真实ip
                      proxy_set_header X-Forwarded-Proto $scheme; #表示客户端真实的协议（http还是https）
                      
              }
              
              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   html;
              }
          }
      ```

      