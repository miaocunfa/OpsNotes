---
title: "go modules - GO11包管理工具"
date: "2020-07-21"
categories:
    - "技术"
tags:
    - "Golang"
    - "gomod"
toc: false
indent: false
original: false
draft: true
---

## 更新记录

| 时间       | 内容           |
| ---------- | -------------- |
| 2020-07-21 | 初稿           |
| 2020-07-21 | 编译etcdhelper |
| 2020-07-23 | 完成更新 |

## 1、go mod是什么

go mod 是Golang 1.11 版本引入的官方包（package）依赖管理工具，用于解决之前没有地方记录依赖包具体版本的问题，方便依赖包的管理。

之前Golang 主要依靠vendor和GOPATH来管理依赖库，vendor相对主流，但现在官方更提倡go mod。

## 2、go mod初始化及使用

Golang 提供一个环境变量 GO111MODULE 来设置是否使用 mod，它有3个可选值，分别是`off, on, auto（默认值）`，具体含义如下：

- off: GOPATH mode，查找vendor和GOPATH目录

- on：module-aware mode，使用 go module，忽略GOPATH目录

- auto：如果当前目录不在$GOPATH 并且当前目录（或者父目录）下有go.mod文件，则使用 GO111MODULE， 否则仍旧使用 GOPATH mode。

## 3、

> 参考链接：  
> 1、[go modules初探及踩坑（GO11包管理工具）](https://studygolang.com/articles/19236)  
>