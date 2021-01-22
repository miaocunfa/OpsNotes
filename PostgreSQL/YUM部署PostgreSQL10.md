---
title: "YUM 部署 PostgreSQL 10"
date: "2020-08-06"
categories:
    - "技术"
tags:
    - "PostgreSQL"
    - "数据库"
    - "服务部署"
toc: true
original: true
draft: false
---

| 时间       | 内容                              |
| ---------- | --------------------------------- |
| 2020-08-05 | patroni 构建 Postgre HA 集群      |
| 2020-08-06 | 将其中 安装 Postgre部分独立为本篇 |

## 1、安装

``` zsh
# 设置 YUM 仓库
➜  vim /etc/yum.repos.d/pg10.repo
[pgdg10]
name=PostgreSQL 10 $releasever - $basearch
baseurl=https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-$releasever-$basearch
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG

# 安装 PG10
➜  yum makecache
➜  yum install -y postgresql10 postgresql10-server postgresql10-contrib
```

## 2、用户

``` zsh
# 创建家目录
➜  mkdir -p /home/postgres
➜  usermod -d /home/postgres postgres
➜  chown -R postgres:postgres /home/postgres

# 修改profile
➜  su - postgres
➜  cp /var/lib/pgsql/.bash_profile ~
➜  vi .bash_profile
export PGHOME=/usr/pgsql-10
export LD_LBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH
➜  source .bash_profile
```

## 3、初始化数据库

``` zsh
➜  initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/pgsql/10/data
```

## 4、数据库操作

``` zsh
# 启动数据库
➜  pg_ctl -D /var/lib/pgsql/10/data start
waiting for server to start.... done
server started

# 关闭数据库
➜  pg_ctl -D /var/lib/pgsql/10/data stop
waiting for server to shut down.... done
server stopped
```
