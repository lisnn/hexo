---
title: elk搭建入门并与SpringBoot项目整合
categories:
  - elasticsearch
tags:
  - elk
  - 日志分析
date: 2021-04-04 21:47:03
---



## 引言

**ELK是一款非常流行的日志分析系统，在微服务架构中，我们可以使用ELK来跟踪分析各个微服务的日志，从而来了解服务的运行情况。**



## 介绍

**ELK是由三个开源工具搭建而成一个系统，分别是：**

- ElasticSearch: ES是个开源分布式搜索引擎，它的特点有：分布式，零配置，自动发现，索引自动分片，索引副本机制，restful风格接口，多数据源，自动搜索负载等。
- Logstash：一个完全开源的工具，可以对日志进行收集、分析、并将其存储供以后使用。
- Kibana：一个开源和免费的工具，他Kibana可以为Logstash和ES提供的日志分析友好的Web界面，可以帮助您汇总、分析和搜索重要数据日志。

**环境**

- Window 10

- jdk 1.8

- ElasticSearch-6.2.2

- logstash-6.2.2

- kibana-6.2.2-windows-x86_64

  

## **ELK安装**

1. **jdk 1.8**

   其实只需要java运行环境即可，具体安装与环境变量配置过程这时不记录了

2. **ElasticSearch** 

   Window下的安装比较简单。在官网下载对应平台的安装包即可。官网：https://www.elastic.co/downloads/elasticsearch

   下载下来后是一个zip的压缩文件，直接解压到安装目录即可。

   ES的启动也非常简单，打开/bin目录双击 elasticsearch.bat 即可。

   当然我们也可以选择作为服务启动，在命令行模式下切换到ES的/bin执行 Service install 再通过/bin目录下的 elasticsearch-service-mgr.exe来管理与启动服务。这里我选的第一种，使用的时候直接打开就行了。

   启动后直接访问：http://localhost:9200/ 若出现如下页面表示ES已经启动成功了。

   ![Image](Image-3.png)

3. **Logstash**

   官网下载：https://www.elastic.co/downloads/logstash
   我下载的是ZIP格式的，将压缩包解压到安装目录即可。

   配置

   在其bin目录可以看到已有一些配置文件，我们可以按自己的要求来新建一个配置文件,在此目录新建一个logstash-springboot.conf内容如下 ：

   ```xml
   input {
     tcp {
       mode => "server"
       host => "0.0.0.0"
       port => 4560
       codec => json_lines
     }
   }
   output {
     elasticsearch {
       hosts => "localhost:9200"
       index => "springboot-logstash-%{+YYYY.MM.dd}"
     }
   }
   ```

   这里的配置比较简单，logstash主要是收集日志给ElasticSearch。因此 input{}中主要是配置logstash监听的端口，后面我们在项目中配置日志向这个端口传输，logstash就会收集。

   output{}则配置ElasticSearch的地址，logstash将收集的日志向ES的地址进行输出，index 可以指定索引名。

   input中 codec => json_lines是一个json解析器，接收json的数据。这个要装logstash-codec-json_lines 插件。在命令行中切换到Logstash的 /bin目录下，执行以下命令：

   ```bat
   logstash-plugin install logstash-codec-json_lines
   ```

   命令行中切换到Logstash的 /bin目录下，执行以下命令，使用我们上面的配置文件启动Logstash

   ```
   logstash -f logstash-springboot.conf
   ```

   出现以下内容，就是启动成功。

   ![Image](Image-4.png)

   

4. **Kibana**

   官网下载：https://www.elastic.co/downloads/kibana

   这里下载的是Window版本，下载下来是一个压缩包，直接解压到指定的安装目录即可。

   启动则直接在/bin目录双击kibana.bat





## 创建springboot项目

项目目录D:\IdeaWorkSpace\gitee\mall-learning\mall-tiny-elk 	[地址](https://gitee.com/macrozheng/mall-learning/tree/master/mall-tiny-elk)

启动springboot项目，日志会在控制台打印出来。

### 可视化查看

打开kibana的地址：[http://localhost:5601](http://localhost:5601/) 默认是没有密码可以直接登陆的。

![Image](Image-5.png)

### **创建index pattern**

![tech_screen_04](tech_screen_04.png)

![tech_screen_05](tech_screen_05.png)

![tech_screen_06](tech_screen_06.png)

### **查看收集的日志**

![tech_screen_07](tech_screen_07.png)

### **调用接口进行测试**

![tech_screen_08](tech_screen_08.png)



![tech_screen_09](tech_screen_09.png)

### **制造一个异常并查看**

#### 	**修改获取所有品牌列表接口**

​	![Image](Image-6.png)

#### 	**调用该接口并查看日志**

![Image](Image-7.png)

![Image](Image-8.png)





## 总结

搭建了ELK日志收集系统之后，我们如果要查看SpringBoot应用的日志信息，就不需要查看日志文件了，直接在Kibana中查看即可。
