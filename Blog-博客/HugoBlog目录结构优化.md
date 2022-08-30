---
title: "Hugo Blog 目录结构优化"
date: "2021-10-19"
categories:
    - "技术"
tags:
    - "git submodule"
    - "Hugo"
    - "Blog"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-10-19 | 初稿 |

## 软件版本

| soft | Version                   |
| ---- | ------------------------- |
| hugo | v0.87.0-B0C541E4+extended |

## Hugo 目录结构

首先我们来看一下 Hugo的目录层级

``` zsh
➜  cd fage.io/
➜  ll
total 106452
drwxr-xr-x.  2 root root     4096 Sep  1 07:18 archetypes
drwxr-xr-x.  3 root root     4096 Sep  1 07:18 config
drwxr-xr-x.  3 root root     4096 Oct 11 08:23 content        # 要生成的 markdown 存放路径
-rwxr-xr-x.  1 root root 53642520 Aug  3 12:09 hugo
-rw-r--r--.  1 root root 55318528 Sep  1 07:18 hugo.exe
drwxr-xr-x. 21 root root     4096 Sep  1 07:21 public         # 生成出来的 静态站路径
-rw-r--r--.  1 root root       18 Sep  1 07:18 README.md
drwxr-xr-x.  3 root root     4096 Sep  1 07:18 resources
drwxr-xr-x.  5 root root     4096 Sep  1 07:18 static         # 静态文件，优先级高于主题下的 static 文件夹
drwxr-xr-x.  3 root root     4096 Sep  1 07:18 themes         # Hugo 主题
```

我计划是将 fage.io 改造成三个仓库，并将public中生成出来的内容删除，不上传 git仓库

``` zsh
fage.io        # 主仓库     Hugo 站点所有内容 && 配置文件变更等
content        # 内容子仓库 用于文章更新
themes         # 主题子仓库 用于主题更新
```

## 生成部分修改

①Nginx修改

``` zsh
# 创建文件夹 用于存放 hugo生成的站点
➜  cd /usr/local/nginx-1.16.1/html
➜  mkdir fage.io-zoo

# 修改 Nginx配置文件
➜  vim /usr/local/nginx-1.16.1/conf/nginx.conf
location / {
            root   html/fage.io-zoo; 
            index  index.html index.htm;
        }
➜  nginx -s reload
```

②hugo命令

``` zsh
# 首先清空 原先的public文件夹
➜  cd fage.io/public
➜  rm -rf ./*

# 生成站点 至Nginx html文件夹中
➜  ./hugo -d "/usr/local/nginx-1.16.1/html/fage.io-zoo"
```

## 内容子仓库

将内容仓库初始化

``` zsh
# github 上创建子仓库 并clone至本地
➜   git clone https://github.com/miaocunfa/fage.io-content-zoo.git

# 拷贝主仓库 内容 至子仓库 
➜  cp fage.io/content/* fage.io-content-zoo

# 初始化仓库 && 提交
➜  cd fage.io-content-zoo
➜  git add . && git commit -m "init repo"
➜  git push origin master
```

## 主仓库

``` zsh
# 先将原先的content目录删除，本地需提交，远程仓库可稍后提交
➜  cd fage.io
➜  rm -rf content
➜  git add .
➜  git commit -m "init: rm content for git submodule"

# 添加内容子仓库
➜  git submodule add https://github.com/miaocunfa/fage.io-content-zoo.git content
➜  cd content; ll
total 8
drwxr-xr-x. 7 root root 4096 Oct 19 07:58 en
-rw-r--r--. 1 root root   45 Oct 19 07:58 README.md
```

## 设置子仓库Token

``` zsh
➜  git pull
Username for 'https://github.com': miaocunf@163.com
Password for 'https://miaocunf@163.com@github.com': 
remote: Support for password authentication was removed on August 13, 2021. Please use a personal access token instead.
remote: Please see https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/ for more information.
fatal: Authentication failed for 'https://github.com/miaocunfa/fage.io-content-zoo.git/'
```

因为github不允许直接使用密码拉取代码了，所以需要设置一下仓库的Url
[点击链接生成](https://github.com/settings/tokens/new)一个Token，并使用Token更新仓库Url

``` zsh
➜  git remote set-url origin https://[你的token]@github.com/miaocunfa/fage.io-content-zoo.git
```

## 更新脚本

关于Hugo Blog 目录结构优化就到此为止了，但是身为一个运维，万物皆可脚本，不写一个脚本收尾不是一个合格的运维

``` zsh
vim /root/fage.io/update.sh
#!/bin/bash

# Describe:     auto update Hugo Blog
# Create Date： 2021-10-19
# Create Time:  16:50
# Update Date:  2021-10-19
# Update Time:  17:20
# Author:       MiaoCunFa
# Version:      v0.0.2

#===================================================================

html="/usr/local/nginx-1.16.1/html/fage.io-zoo"
fage="/root/fage.io"

# Cleaning Nginx html
rm -rf $html/*

# git update 
cd $fage/content
git pull

# blog update
cd $fage
./hugo -d "$html"
```

> 参考文档：  
>
> - [hugo中文文档 - hugo命令](https://www.gohugo.org/doc/commands/hugo/)
> - [Git Submoudle使用完整教程](http://www.360doc.com/content/12/0608/17/10058718_216893323.shtml)
> - [git中submodule子模块的添加、使用和删除](https://blog.csdn.net/guotianqing/article/details/82391665)
> - [github开发人员在七夕搞事情：remote: Support for password authentication was removed on August 13, 2021.](https://blog.csdn.net/weixin_41010198/article/details/119698015)
>