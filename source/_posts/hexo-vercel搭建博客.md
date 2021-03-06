---
title: hexo-vercel搭建博客
categories:
  - 博客搭建
tags:
  - vercel
  - hexo
date: 2021-04-04 22:32:31
---


## 1.	前言  

也许你想拥有一套自己的博客，方便面试的时候想展示自我，或者想记录自己的生活，但是一直没有找到合适的平台；也许你有一些自己的小玩意想部署到服务器，但是服务器有有点小贵，打工人又舍不得，那么 vercel 平台可能是你不错的选择，不用花钱，访问速度快，域名也有！本文的主要目的是帮助想拥有自己的博客的朋友，提供一套完整的博客搭建方案，那么现在就开干吧！

## 2.	介绍

[vercel](https://vercel.com/): Vercel 提供了一个云平台，可以优化整个项目开发和部署体验，它有很强大的功能值得去探索，个人使用是免费的，提供了域名访问，使用方便快捷。

[hexo](https://hexo.io/): Hexo 是一个基于 nodejs 的静态博客网站生成器，通过使用脚手架安装后，命令操作简单，直接开箱使用，支持丰富的主题，支持高度的自定义化，主要使用 markdown 语法。你可以自行开发插件，优化你的博客。



## 3.	搭建

在搭建博客之前，我们需要一些准备工作，首先是 vercel 平台的账号，其次是安装 nodejs 以及 hexo-cli 脚手架。

### 3.1	注册 vercel

1、首先，在 Vercel 官网（https://vercel.com/）注册一个新账户，注册新用户必须使用 Github、Gitlab 或者 Bitbucket 的账户进行授权，并绑定手机号。注册完成后，可以在配置页面修改自己的邮箱地址。这里建议使用 Github 进行授权登陆，后续可以选择 Github 上的项目直接部署也会很方便的。

![008eGmZEly1gmg7p22pf8j31j50u00zl](008eGmZEly1gmg7p22pf8j31j50u00zl.jpg)



2、注册成功后，就可以登陆系统，查看和设置相关的东西啦。这里是我目前部署的一些东西。

![image-20210404210310697](008eGmZEly53423423317t0u01ap.jpg)



### 3.2	安装 hexo-cli

在安装 hexo-cli 前，需要保证电脑安装了 nodejs。 nodejs 需要在[node 官网](https://nodejs.org/en/)下载，安装好 nodejs 后，也会相应的安装上 npm，接下来就可以安装 hexo-cli 了。

安装命令：`npm install hexo-cli -g`

检测是否安装成功，在终端执行：`hexo -v` 命令，如果出现以下内容则表示安装成功。

![image-20210404210513020](image-20210404210513020.png)



### 3.3	vercel+hexo 创建项目

vercel 平台中支持选择多种项目模版，包括但不限于 Next.js，Nuxt.js，Hexo，Angular 等多种类型，这里我们选择的当然是 hexo 模版。

![image-20210404210612405](image-20210404210612405.png)



登陆系统后点击**new project**，创建新项目

![image-20210404210654694](image-20210404210654694.png)



进入到项目选择，可以选择 git 仓库中已存在的项目，也可以选择系统提供的模版项目，这里我们选择系统提供的模版项目，点击右方下面的Browse All Templates找到 Hexo 模版项目。

![image-20210404210716635](image-20210404210716635.png)



选择模版后，进入创建项目位置选择，目前团队项目是需要专业版的，是需要收费的，选择个人，点击PERSONAL ACCOUNT后面的 select 按钮。

![image-20210404210802384](image-20210404210802384.png)

进入到创建仓库位置，可以选择 Github、Gitlab、Bitbucket，根据自己的需要选择仓库保存地址。这里我选择 Github。

![image-20210404210831807](image-20210404210831807.png)



选择 Github 后，因为我登陆的时候时使用了 Github 了授权，这里也就直接显示了我的 GitHub 名称，我们填入仓库名称为 hexo，你也可以填入其他的仓库名称，比如 blog、myblog 等。Create private Git Repository 可以勾选，也可以不勾选，勾选的话会创建私人仓库，这样别人看你的 Github 的时候不会看到这个仓库。选择好后，点击 Continue 进入下一步。

![image-20210404210939488](image-20210404210939488.png)



进入下一步后，这里需要配置项目名称 PROJECT NAME，即在项目生成后的 package.json 中的 name 字段，这里我们保持默认就好，也可以填自己喜欢的名字；FRAMEWORK PRESET 默认选择 Hexo 不变，因为我们要创建的是 hexo 的博客；Build and Output Seettings 中可以配置自定义打包命令，打开后面的 override 选项后，可以设置我们的自定义打包命令和打包后输出的文件夹名字。

![image-20210404211030358](image-20210404211030358.png)



设置完毕后，点击 Depoly 进行项目创建，部署即可。等待大概不到 1 分钟，项目就部署好了。会跳转到恭喜你，项目创建成功的页面。这时就可以点击 visit 按钮进行访问了，因为 vercel 提供了免费的域名，所以直接访问即可。

返回到cercel主页，可以看到你的hexo已经初步搭建好了。

![image-20210404211208812](image-20210404211208812.png)



至此，我们的 Hexo 博客就搭建完成了，在 GitHub 中也已经自动创建了这个博客项目，整个过程的操作还是很简单、很友好的。

![image-20210404211244982](image-20210404211244982.png)





## 4.	基本使用

### 4.1	下载github代码

在 GitHub 中将我们创建好的博客项目 clone 到本地：git clone XXX，打开后会有以下文件目录：

![image-20210404211356850](image-20210404211356850.png)

主要有三个文件夹：**scaffolds（模版文件夹）、source（源文件夹）、themes（主题文件夹），以及最外层的_config.yml 项目配置文件。**

在搭建之前我们已经在本地安装了 hexo-cli 的脚手架，这个时候就可以使用了。在项目文件夹下，打开终端，首先需要安装项目依赖，通过 `npm install`  或  `cnpm install`  或 `yarn install` 皆可安装依赖。

依赖安装成功后，执行 `hexo server -p $PORT` 即可启动项目，其中$PORT 默认 4000，你也可以修改端口。hexo 也提供了简易方式启动命名：`hexo s`，启动后在浏览器访问：[http://localhosst:4000](http://localhosst:4000/)即可打开。

![image-20210404211544388](image-20210404211544388.png)



### 4.2	hexo常见的命令

- hexo s 启动本地服务
- hexo clean 清除缓存
- hexo g 打包
- hexo new post article 创建一个名称为 article 的文章
- hexo new page about 创建一个名称为 about 的路由页面



### 4.3	配置主题

目前 hexo 官方有 330 套主题可供选择，另外 GitHub 上也有许多个人开发的主题可以使用，部分主题支持了使用 npm 包的方式进行安装配置。默认的主题配置方式是将主题仓库中的内容直接 clone 下来放到 themes 文件夹下，并根据主题名称在_config.yml 中进行配置。具体的博客主题配置方式需要根据主题中的设置项进行。还有一种是通过安装 npm 包的方式，这时候就不需要 themes 这个文件夹了，在 package.json 中安装了主题包以后，根据主题开发者的指导进行配置即可。



## 5.	总结

至此，我们的博客就成功搭建并可供外部访问啦。vercel 中也支持自定义域名，如果你有自己的域名也可以在其中配置使用自己的域名进行访问。**另外你也<font color=red>无需关注部署发布</font>的问题，只要你在 GitHub 中将你新建的文章进行了 git 提交，vercel 会自触发打包部署，完事还可以给你发邮件告诉你：大哥，我给你部署成功啦！你可以访问下看看滴！**



**注意：**

- 成功之后只需要将代码提交到github上，会自动部署到vercel上。

- 在本地启动的命令：

  ​	先安装依赖：`npm install`

  ​	再启动：`hexo clean & hexo s`

- 新建文章：

  `hexo new post bean的生命周期`

  这时候会生成一个文件夹`bean的生命周期`和文件`bean的生命周期.md`，把图片放文件夹`bean的生命周期`中，直接在md中写图片名字即可，不用带路径。

  ![image-20210404212457158](image-20210404212457158.png)



![image-20210404212536455](image-20210404212536455.png)

















