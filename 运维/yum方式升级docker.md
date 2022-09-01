---
title: "yum方式升级docker"
date: "2021-11-06"
categories:
    - "技术"
tags:
    - "docker"
    - "yum"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-11-06 | 初稿 |
| 2021-11-13 | 完善 |

## 软件版本

| soft          | Version              |
| ------------- | -------------------- |
| CentOS        | 7.7                  |
| docker-ce     | 19.03.5 --> 20.10.10 |
| docker-ce-cli | 19.03.5 --> 20.10.10 |

①列出docker版本 两种方式

``` zsh
# 使用 yum包管理器
➜  yum list installed | grep docker
containerd.io.x86_64               1.2.10-3.2.el7                      @docker-ce-stable
docker-ce.x86_64                   3:19.03.5-3.el7                     @docker-ce-stable
docker-ce-cli.x86_64               1:19.03.5-3.el7                     @docker-ce-stable

# 使用 rpm命令查找已安装软件包
➜  rpm -qa | grep docker
docker-ce-cli-19.03.5-3.el7.x86_64
docker-ce-19.03.5-3.el7.x86_64
```

②移除旧版本

``` zsh
➜  yum remove docker-ce docker-ce-cli
```

③安装新版本

``` zsh
# 查看 yum仓库中的 docker版本
➜  yum info docker-ce
➜  yum info docker-ce-cli

# 安装新版本
➜  yum install -y docker-ce docker-ce-cli
```
