---
title: "使用 Webhook 自动化部署 Blog"
date: "2021-01-22"
categories:
    - "技术"
tags:
    - "Blog"
toc: false
original: true
draft: false
---

## 楔子

上一篇说到今年不要那么咸鱼了，github 积累了那么多文章，也不发到小站上来。其实还是懒癌犯了。

为什么不发出来？那我就要给你聊聊发一篇文章有多么不便利了。

首先，写那么多东西不是所有的文章都能发来吧？是的。一方面文笔有限，写的不好；一方面水平有限，写的浅薄。

每次想想我要面对我那一长串的目录去把哪些文章发，哪些文章不发挑出来就觉得很难。再就是哪天我如果对历史文章做了修改，没有顺手把他上传到博客服务器更新的话，事后想起来就得一篇篇文章的去比对更新时间，再去把他更新上来。实在是太难了。

有鉴于此，自动化部署就迫在眉睫了。

## 思路

简单点来说就是 通过 `github` 上的 `webhook 机制`来监听代码的变化，比如说代码提交就触发这个事件，源网站调用定义好的`回调地址` (发起一个`HTTP请求`来告诉你，源网站发生变化了，快来拉代码啊)

![devops 流程图](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/deploy_fage.png)

## github-webhook（回调监听）

这是一个监听 github 回调请求的服务 [源码地址](https://github.com/yezihack/github-webhook) && [下载地址](http://img.sgfoot.com/github-webhook1.4.1.linux-amd64.tar.gz)

``` zsh
# 下载
➜  wget http://img.sgfoot.com/github-webhook1.4.1.linux-amd64.tar.gz
➜  tar -zxf github-webhook1.4.1.linux-amd64.tar.gz
➜  mkdir webhook && mv github-webhook webhook
```

## 使用方法

``` zsh
➜  ./github-webhook --help
GLOBAL OPTIONS:
   --bash value, -b value    Execute the script path. eg: /home/hook.sh
   --port value, -p value    http port (default: 2020)
   --secret value, -s value  github hook secret
   --quiet, -q               quiet operation (default: false)
   --verbose, --vv           print verbose (default: false)
   --help, -h                show help (default: false)
   --version, -v             print the version (default: false)

-b：指定运行脚本
-p：指定监听端口
-s：指定 hook 密码
-q：安全模式，不输出任何信息 默认关闭
```

## 自动化脚本

``` zsh
➜  vim /root/webhook/deploy_fage.sh
➜  chmod u+x deploy_fage.sh
#!/bin/bash

# Describe:     DevOps for fage.io
# Create Date： 2021-01-22
# Create Time:  14:25
# Update Date:  2021-01-22
# Update Time:  19:18
# Author:       MiaoCunFa
# Version:      v0.0.2

# ---------------------------------------------------

repo="/root/OpsNotes"
blog="/root/blog"
post="/root/blog/content/post"
baseurl="http://fage.io"

# ---------------------------------------------------

if [ ! -f $repo ]
then
    git clone https://github.com/miaocunfa/OpsNotes.git $repo
else
    cd $repo
    git pull
fi

for md in $(find /root/OpsNotes -name "*.md" -type f -print)
do
    cp $md $post
done

cd $blog
./hugo -b $baseurl

exit 0
```

## 启动回调监听

``` zsh
➜  ./github-webhook -b /root/webhook/deploy_fage.sh -p 2020 -s hook@2020

# 监听在后台
➜  ./github-webhook -b /root/webhook/deploy_fage.sh -p 2020 -s hook@2020 >> /root/webhook/hook.log 2>&1 &
```

## Github 需要做什么

![github-webhook-1](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/1102222-20200524234602944-445101555.png)

![github-webhook-2](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/1102222-20200524234632847-222882855.png)

## Markdown

现在的配置会让 Git 仓库中所有的 Markdown 文档生成出来，我们需要做一下控制，哪些展示在博客里，哪些不展示。修改元数据的 `draft 标签`，draft 中文是草稿的意思, 如果设置为 true，只能本地预览，不会生成到最终产物。

Metadata 示例

``` zsh
---
title: "使用 Webhook 自动化部署 Blog"
date: "2021-01-22"
categories:
    - "技术"
tags:
    - "Blog"
toc: false
original: true
draft: false
---
```

## 测试

``` zsh

# 本机做一次提交
# Blog 主机已经监听到了 github的提交
# 并执行了指定的 部署脚本

➜  ./github-webhook -b /root/webhook/deploy_fage.sh -p 2020 -s hook@2020
[Gorestful-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using code:  gorestful.SetMode(gorestful.ReleaseMode)

[Gorestful-debug] GET    /ping                     --> github.com/yezihack/github-webhook/router.pong
[Gorestful-debug] POST   /web-hook                 --> github.com/yezihack/github-webhook/internal.Handler.func1
Event: push ,for: OpsNotes                                       # push 事件；仓库 OpsNotes
Can clone repo at: https://github.com/miaocunfa/OpsNotes.git     # 仓库地址
Commit information:
Name:miao
Email:miaocunf@163.com
Branch:refs/heads/master
CommitID:175f10d626d5f3083134bdf2a16940a2d617c233
Time:2021-01-22 18:31:11                                         # 提交时间
```

> 参考文档：  
> 1、[GO 使用Webhook 实现github 自动化部署](https://www.cnblogs.com/phpper/p/12951970.html)  
> 2、[Hugo + Even + GithubPages + Google Domains搭建个人博客（二）](https://tinocheng.app/post/%E6%90%AD%E5%BB%BA%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A22/)  
> 3、[使用 Travis CI 自动更新 GitHub Pages](https://notes.iissnan.com/2016/publishing-github-pages-with-travis-ci/)  
> 4、[Webhook到底是个啥？](https://segmentfault.com/a/1190000015437514)  
>