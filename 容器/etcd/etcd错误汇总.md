---
title: "etcd 错误汇总"
date: "2020-07-21"
categories:
    - "技术"
tags:
    - "etcd"
toc: false
indent: false
original: true
draft: true
---

## 更新记录

| 时间       | 内容     |
| ---------- | -------- |
| 2020-07-21 | 初稿     |
| 2022-09-01 | 文档整理 |

## 1、etcd API v2 - 已弃用

etcd2和 etcd3是不兼容的，两者的 api参数也不一样，详细请查看 etcdctl -h

``` zsh
# 刚开始使用 etcdctl get 读取有问题，我设置API为3
➜  export ETCDCTL_API=3

# 发现etcdctl 参数都变了, 刚开始设置的 --ca-file都不认了, 所以别名无法使用了
#
➜  etcdctl get -h
Error: unknown flag: --ca-file
```
