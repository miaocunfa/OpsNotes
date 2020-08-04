---
title: "Elasticsearch之常用命令"
date: "2020-08-04"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "常用命令"
toc: false
original: true
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-04 | 初稿 |

## 一、删除索引

``` zsh
# 批量删除
➜  curl -XDELETE localhost:9200/prod-restored-0724-*

# 删除指定索引
➜  curl -XDELETE 192.168.100.211:9200/user-growth
```
