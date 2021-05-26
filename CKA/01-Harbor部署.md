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

| 时间       | 内容         |
| ---------- | ------------ |
| 2021-05-25 | 初稿         |
| 2021-05-26 | 安装 && 使用 |

## 软件版本

| soft           | Version |
| -------------- | ------- |
| CentOS         | 7.6     |
| harbor         | v2.2.2  |
| docker-ce      | 20.10.6 |
| docker-compose | 1.18.0  |

## 环境

harbor 依赖 docker 以及 docker-compose

``` zsh
➜  yum install -y docker-ce.x86_64
➜  yum install -y docker-compose

# 启动 docker daemon
➜  systemctl start docker
```

下载 harbor 离线安装包

``` zsh
➜  cd /usr/local/
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
# 创建 data目录
mkdir -p /disk2/data/harbor/log

# 配置如下
➜  vim harbor.yml
# 配置域名地址
hostname: harbor.test.local
http:
  port: 80
# admin 密码
harbor_admin_password: gjr@@104#$$
database:
  password: root123
  max_idle_conns: 50
  max_open_conns: 1000
# data 存储位置
data_volume: /disk2/data/harbor
trivy:
  ignore_unfixed: false
  skip_update: false
  insecure: false
jobservice:
  max_job_workers: 10
notification:
  webhook_job_max_retry: 10
chart:
  absolute_url: disabled
log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    # 日志地址
    location: /disk2/data/harbor/log
_version: 2.2.0
proxy:
  http_proxy:
  https_proxy:
  no_proxy:
  components:
    - core
    - jobservice
    - trivy
```

## 安装

``` zsh
➜  ./install.sh

# 出现下列语句证明安装成功
? ----Harbor has been installed and started successfully.----

# 使用 docker-compose 查看容器状态
➜  docker-compose ps
      Name                     Command               State                  Ports                
-------------------------------------------------------------------------------------------------
harbor-core         /harbor/entrypoint.sh            Up                                          
harbor-db           /docker-entrypoint.sh            Up                                          
harbor-jobservice   /harbor/entrypoint.sh            Up                                          
harbor-log          /bin/sh -c /usr/local/bin/ ...   Up      127.0.0.1:1514->10514/tcp           
harbor-portal       nginx -g daemon off;             Up                                          
nginx               nginx -g daemon off;             Up      0.0.0.0:80->8080/tcp,:::80->8080/tcp
redis               redis-server /etc/redis.conf     Up                                          
registry            /home/harbor/entrypoint.sh       Up                                          
registryctl         /home/harbor/start.sh            Up
```

## 使用

本地环境在使用harbor的时候, 需要修改 `/etc/hosts` 文件。

``` zsh
➜  vim /etc/hosts
192.168.31.30     apiserver
192.168.31.104    node01       harbor.test.local
192.168.31.155    node02
```

使用浏览器访问 `harbor.test.local` 或者IP地址, 配置 harbor

①点击左边栏 '用户管理' --> '创建用户'

![用户管理](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_01.jpg)

②'用户名'为登录账号

![创建用户](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_02.jpg)

③点击左边栏 '项目' --> '新建项目'

![项目](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_03.jpg)

④不勾选公开即为私有项目

![私有项目](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_04.jpg)

⑤进入项目 点击'成员' --> '+用户'

![+用户](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_05.jpg)

⑥将成员添加为项目角色

![角色](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20210526_06.jpg)

> 参考文档：  
> [1] [企业级镜像仓库 Harbor 的安装与配置](https://learnku.com/articles/29884)  
>