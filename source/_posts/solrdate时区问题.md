---
title: 处理solr date 时区问题
categories:
  - solr
tags:
  - solr时区
date: 2021-04-04 22:03:13
---



> 集成的solr 中，我们可以通过solr管理界面进行查询，也可以通过java的api进行查询，但查询过程中，如果是时间类型的，可能会存在两者在界面上看上去不一致的问题，两者时间刚好相差本地的时区。



## **一：上传配置文件**　　

​	为了模拟现象，我们设置如下solr文档结构

![22672-20170215222939222-1289035321](22672-20170215222939222-1289035321.jpg)

```
solrctl instancedir --create date_demo /data/solr_s
```

## **二：创建collection**

```
solrctl collection --create date_demo -s 2 -m 2 -r 2
```

创建完后solr的collection如下

![22672-20170215222857019-1496237182](22672-20170215222857019-1496237182.jpg)

## **三：模拟程序**

### 	**一：编写程序**　　

​	编写模拟插入程序。为了容易查看，只插入2条数据。　　这里我们使用的solr版本为4.10.3。

```java
private void insert() throws SolrServerException, IOException,ParseException {
    String zhHost = "master1/solr";
    CloudSolrServer cloudSolrServer = new CloudSolrServer(zhHost);
    cloudSolrServer.setDefaultCollection("date_demo");
    String id_1 = UUID.randomUUID().toString().replaceAll("-", "")
    .toUpperCase();
    String name_1 = "1点前+8";
    Date createDate_1 = sdfDate.parse("2016-12-30 00:11:12");
    String day_1 = sdfDay.format(createDate_1);

    String id_2 = UUID.randomUUID().toString().replaceAll("-", "")
    .toUpperCase();
    String name_2 = "1点后+8";
    Date createDate_2 = sdfDate.parse("2016-12-30 10:13:14");
    String day_2 = sdfDay.format(createDate_2);

    SolrInputDocument solrInputDocument1 = create(id_1, name_1, day_1,
    createDate_1);
    SolrInputDocument solrInputDocument2 = create(id_2, name_2, day_2,
    createDate_2);

    cloudSolrServer.add(solrInputDocument1);
    cloudSolrServer.add(solrInputDocument2);
    cloudSolrServer.commit();

    System.out.println("success");
}
```

### **二：运行程序**

可以看到我们已经插入2条数据。

![22672-20170215223403160-495423024](22672-20170215223403160-495423024.jpg)

### **三：程序查询**

在程序查询的结果如下。

![22672-20170215223445082-1372851348](22672-20170215223445082-1372851348.jpg)

可以看到solr自己的查询界面使用的时间格式是UTC的，会有时差，我们这里是8小时。

CREATEDAY和CREATEDATE有时候不一致。



### **四：处理**

所以为了3方的统一，要么自己改solr界面查询的。要么自己改下时差，使得3方结果一致，方便使用。

这里我们采用自己修改时差来同步。

但工程量挺大，得在solr插入的时候转换下时间格式程utc。还的在每次查询的时候转换回来。

所以这里就自己恶心下自己，改下solr源码，在源码中找到对应的位置，固定的修改成自己这里的时差。

这样就间接的使3方同步了。

​		**找到solr相关的处理代码类**

```
org.apache.solr.common.util.JavaBinCodec.java
```

​		**在readVal下**

```java
return new Date(dis.readLong()-28800000l);//因为存储的时候solr的时间格式是utc的，所以这里减掉当前时区的值
```

​		**在writePrimitive下**

```java
daos.writeLong(((Date) val).getTime()+28800000l);//存入的时候为了同day string同步 加8小时
```

这样就可以了。　　

我们查看效果。　　

为了对比 将数据的名称加备注+8

![22672-20170215223726925-816507627](22672-20170215223726925-816507627.jpg)



**solr查询页面**

![22672-20170215223742472-1709699541](22672-20170215223742472-1709699541.jpg)

到此，本章节的内容讲述完毕。



**示例下载**

Github:https://github.com/sinodzh/HadoopExample/tree/master/2017/solr.demo/















