---
title: 消息队列ActiveMQ—安全配置
date: 2021-04-04 21:33:24
categories:
    - activemq 
tags: 
    - activemq
---



**ActiveMQ分为2个安全配置：一个是Web控制台的安全配置；另外一个是对于队列/主题的访问安全配置。**



## **Web控制台的安全配置**

打开conf/jetty.xml文件，找到

```xml
<bean id="securityConstraint" class="org.eclipse.jetty.util.security.Constraint">
    <property name="name" value="BASIC" />
    <property name="roles" value="user,admin" />
    <!-- set authenticate=false to disable login --><!-- 这里开启登录 -->
    <property name="authenticate" value="true" />
</bean>
<bean id="adminSecurityConstraint" class="org.eclipse.jetty.util.security.Constraint">
    <property name="name" value="BASIC" />
    <property name="roles" value="admin" />
    <!-- set authenticate=false to disable login --><!-- 这里开启登录 -->
    <property name="authenticate" value="true" />
</bean>
```

用户名密码保存在conf/jetty-realm.properties文件中admin: admin, adminuser: user, user用户格式定义: 用户名:密码[,角色…]



## **对于队列/主题的访问安全配置**

客户端三种权限：read(读取队列)，write(写入队列)，

admin(主题不存在时是否可以创建队列)有两种安全配置策略: **Simple Authentication(简单的身份验证)** 和  **JAAS身份验证** 

### **Simple Authentication(简单的身份验证)**

在conf/activemq.xml文件中加入以下内容，如配置了systemUsage，应该放到systemUsage前

```xml
<plugins>
<!-- Configure authentication; Username, passwords and groups -->
<simpleAuthenticationPlugin>
<users>
<authenticationUser username="admin" password="admin" groups="users,admins"/>
<authenticationUser username="user" password="user" groups="users"/>
<authenticationUser username="guest" password="${guest.password}" groups="guests"/>
</users>
</simpleAuthenticationPlugin>
</plugins>
```

占位引用可在conf/credential.properties中配置

```xml
activemq.username=system
activemq.password=manager
guest.password=password
```

配置好后，创建ActiveMQConnectionFactory需要用户名密码

```java
ConnectionFactory connectionFactory = new ActiveMQConnectionFactory(username,password,url);
```



### **JAAS身份验证**

在conf/activemq.xml文件中加入以下内容，如配置了systemUsage，应该放到systemUsage前

```xml
<plugins>
<!--use JAAS to authenticate using the login.config file on the classpath to configure JAAS -->
<jaasAuthenticationPlugin configuration="activemq" />
<!-- lets configure a destination based authorization mechanism -->
<authorizationPlugin>
<map>
<authorizationMap>
<authorizationEntries>
<!-->表示通配符,例如USERS.>表示以USERS.开头的主题,>表示所有主题,read表示读的权限,write表示写的权限，admin表示是否能创建-->
<authorizationEntry queue=">" read="admins" write="admins" admin="admins" />
<authorizationEntry topic=">" read="admins" write="admins" admin="admins" />
<authorizationEntry queue="ActiveMQ.Advisory.>" read="tests" write="tests" admin="tests" />
<authorizationEntry topic="ActiveMQ.Advisory.>" read="tests" write="tests" admin="tests" />

<!-- tests组具有tests.>的queue和topic的所有权限，没有其他的权限 -->
<authorizationEntry queue="test.>" read="tests" write="tests" admin="tests" />
<authorizationEntry topic="test.>" read="tests" write="tests" admin="tests" />
</authorizationEntries>
</authorizationMap>
</map>
</authorizationPlugin>
</plugins>
```

**login.config文件**

```xml
activemq {
org.apache.activemq.jaas.PropertiesLoginModule required
org.apache.activemq.jaas.properties.user="users.properties"
org.apache.activemq.jaas.properties.group="groups.properties";
};
```

**用户名、密码文件users.properties**

```xml
#用户名=密码
admin=admin
test=123
```

**分组文件groups.properties**

```xml
#角色=用户1，用户2
admins=admin
tests=test
```

注意：configuration=”activemq”，这里的名字与login.config中的名字对应上



