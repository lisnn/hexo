---
title: solr查询空格问题
categories:
  - solr
tags:
  - solr查询空格
date: 2021-04-04 22:03:43
---


**空格在solr中属于特殊字符，solr在查询条件有空格时需要转义。**

例如 

```json
xfrxm:*Virgle 来访生成条码*
```

 需要转义成  

```json
xfrxm:*Virgle\ 来访生成条码* 
```



如果查询

```json
 xfrxm:*Virgle 来访生成条码*
```

 就相当于查询 

```
xfrxm:*Virgle* OR xfrxm:*来访生成条码*
```

tower中描述的问题，信访人姓名最后有空格 

```
xfrxm:*Virgle来访生成条码 *
```

 就相当于查询 

```
xfrxm:*Virgle来访生成条码* OR xfrxm:*
```

 需要在查询前处理字符串，用转义或者去空格都可以