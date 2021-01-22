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

为什么写那么多，不发出来？那我就要给你聊聊发一篇文章有多么不便利了，写那么多东西不是所有的文章都能发来吧？是的。

一方面文笔有限，写的不好。一方面水平有限，写的浅薄。

每次想想我要

由此引出我给自己的博客搞一个自动化部署的想法了。

## 思路

## Webhook 选型

## 自动化脚本

``` zsh
#!/bin/bash

# Describe:     DevOps for fage.io
# Create Date： 2021-01-22
# Create Time:  14:25
# Update Date:  2021-01-22
# Update Time:  14:25
# Author:       MiaoCunFa
# Version:      v0.0.1

# ---------------------------------------------------

gitURL="https://github.com/miaocunfa/OpsNotes.git"
local="~/OpsNotes"
blog="/root/blog"
post="$blog/content/post"
baseurl="http://fage.io"

# ---------------------------------------------------

git clone $giturl $local

for md in $(find $local -name "*.md" -type f -print)
do
    mv $md $post
done

cd $blog
./hugo -b $baseurl
```
