---
title: "shell脚本加密"
date: "2021-09-29"
categories:
    - "技术"
tags:
    - "shell"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-09-29 | 初稿 |

## 软件版本

| soft | Version |
| ---- | ------- |
| shc  | 3.8.9b  |

## 概述

在我们编写shell脚本的时候，里面有一些敏感变量不方便让其他人看到，我们可以选择对脚本进行加密

## 一、shc

使用shc进行加密, 首先[点击此链接下载安装包](http://www.datsi.fi.upm.es/~frosal/)

``` zsh
➜  wget http://www.datsi.fi.upm.es/~frosal/sources/shc-3.8.9b.tgz
➜  tar -zxf shc-3.8.9b.tgz
➜  cd shc-3.8.9b
➜  make

# 将编译出来的可执行文件shc 拷贝到bin目录
➜  cp shc /usr/local/bin
```

使用

``` zsh
➜  shc -r -f recosys_pull.sh

# 执行加密以后 会生成两个文件 分别以.x 和.x.c 结尾, 前者为加密的可执行文件
➜  ll
-rwx--x--x 1 root root 11936 Sep 29 17:49 recosys_pull.sh.x
-rw-r--r-- 1 root root 12267 Sep 29 17:49 recosys_pull.sh.x.c
```
