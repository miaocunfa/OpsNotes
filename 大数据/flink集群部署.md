---
title: "flink 集群部署"
date: "2021-05-24"
categories:
    - "技术"
tags:
    - "flink"
    - "bigdata"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-05-24 | 初稿 |
| 2021-05-25 |  |

## 软件版本

| soft   | Version |
| ------ | ------- |
| CentOS | 7.6     |
| flink  | 1.13.0  |


## 环境

``` zsh
# 下载安装包

➜  cd /usr/local
➜  wget https://mirrors.tuna.tsinghua.edu.cn/apache/flink/flink-1.13.0/flink-1.13.0-bin-scala_2.12.tgz
➜  tar -zxf flink-1.13.0-bin-scala_2.12.tgz

# 分发到其他节点
➜  scp flink-1.13.0-bin-scala_2.12.tgz miaocunfa@192.168.189.192:~
➜  scp flink-1.13.0-bin-scala_2.12.tgz miaocunfa@192.168.189.187:~

➜  mv /home/miaocunfa/flink-1.13.0-bin-scala_2.12.tgz && tar -zxf flink-1.13.0-bin-scala_2.12.tgz
```

## 配置

``` zsh
➜  
```

> 参考文档：  
> [1] [Flink 集群搭建,Standalone,集群部署,HA高可用部署](https://developer.aliyun.com/article/765741)  