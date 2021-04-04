---
title: hexo-next为文章添加分类
categories:
  - 博客搭建
tags:
  - 主题
  - next
  - 文章分类
  - hexo
date: 2021-04-04 22:32:12
---

## 1.	**hexo next 添加分类页**

新建一个页面，命名为 categories 。命令如下：

`hexo new page categories`

编辑刚新建的页面，将页面的类型设置为 categories ，主题将自动为这个页面显示所有分类。

```markdown
---
title: 分类
date: 2020-12-22 12:39:04
type: "categories"
---
```

注意：如果有启用多说 或者 Disqus 评论，默认页面也会带有评论。需要关闭的话，请添加字段 comments 并将值设置为 false，如：

```markdown
---
title: 分类
date: 2020-12-22 12:39:04
type: "categories"
comments: false
---
```

在菜单中添加链接。编辑主题的 _config.yml ，将 menu 中的 categories: /categories 注释去掉，如下:

```
menu:
  home: / || fa fa-home
  about: /about/ || fa fa-user
  tags: /tags/ || fa fa-tags
  categories: /categories/ || fa fa-th
  archives: /archives/ || fa fa-archive
  #schedule: /schedule/ || fa fa-calendar
  #sitemap: /sitemap.xml || fa fa-sitemap
  #commonweal: /404/ || fa fa-heartbeat
```



## 2.	**添加文章分类关联**

hexo中有Front-matter这个概念，是文件最上方以 — 分隔的区域，用于指定个别文件的变量。举个栗子，在hexo new post article时会生成article.md文件，文件生成好的文章属性。

```
---
title: Bean的生命周期
date: 2020-01-04
categories:
    - spring 
tags: 
    - spring
    - 生命周期
password: 12341234
---
```

















