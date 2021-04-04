---
title: solr-tomcat启动报错
categories:
  - solr
tags:
  - solr启动报错
date: 2021-04-04 22:04:39
---




## 问题：solr集成tomcat启动时报错，错误内容:

```log
Unable to resolve canonical hostname for local host,&#8203; possible DNS misconfiguration. Set the 'solr.dns.prevent.reverse.lookup' sysprop to true on startup to prevent future lookups if DNS can not be fixed.
sadept2-180-233: localhost.localdomain
sadept2-180-233: unknown error
    at java.net.InetAddress.getLocalHost(InetAddress.java:1505) ~[?:1.8.0_65]
    ......
```



这是因为获取不到主机的localhost.localhostdomain，查看hosts文件

![Image](Image-11.png)

果然没有localhost.localhostdomain。



## 解决办法：编辑 /etc/hosts文件

在 127.0.0.1 和::1 后面添加 你的新主机名

```
127.0.0.1       localhost localhost.localdomain localhost4 localhost4.localdomain4
::1             localhost localhost.localdomain localhost4 localhost4.localdomain4
```

![Image](Image-12.png)