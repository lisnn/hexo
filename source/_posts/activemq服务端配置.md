---
title: activemq服务端安全配置
date: 2021-01-04 21:32:59
categories:
    - activemq 
tags: 
    - activemq
---


1. **官网下载activemq，解压后，文件列表如下**

![Image](Image.png)

其中bin目录里面是启动停止activemq服务，conf里面是配置文件，data是数据，docs是文档，lib是一些jar包



2. **activemq是消息中间件，要使用它，需要有发送消息者，和消费消息者。消息分为队列模式和主题模式，主题模式发送消息者需要如下配置，**

![Image](Image-1.png)

![Image](Image-2.png)