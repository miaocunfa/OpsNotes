---
title: "Harbor 部署"
date: "2021-05-25"
categories:
    - "技术"
tags:
    - "harbor"
    - "容器化"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-05-25 | 初稿 |

## 软件版本

| soft   | Version |
| ------ | ------- |
| CentOS | 7.6     |
| harbor | v2.2.2  |


## 环境

``` zsh
# 下载离线安装包

➜  wget https://github.com/goharbor/harbor/releases/download/v2.2.2/harbor-offline-installer-v2.2.2.tgz
➜  tar -zxf harbor-offline-installer-v2.2.2.tgz

➜  cd harbor
➜  ll
total 494976
-rw-r--r--. 1 root root      3361 May 15 05:30 common.sh
-rw-r--r--. 1 root root 506818941 May 15 05:30 harbor.v2.2.2.tar.gz
-rw-r--r--. 1 root root      7840 May 15 05:30 harbor.yml.tmpl
-rwxr-xr-x. 1 root root      2500 May 15 05:30 install.sh
-rw-r--r--. 1 root root     11347 May 15 05:30 LICENSE
-rwxr-xr-x. 1 root root      1881 May 15 05:30 prepare
```

## 配置

``` zsh
➜  
```

> 参考文档：  
> [1] [企业级镜像仓库 Harbor 的安装与配置](https://learnku.com/articles/29884)  