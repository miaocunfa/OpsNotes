---
title: "MongoDB 部署单节点"
date: "2021-03-26"
categories:
    - "技术"
tags:
    - "MongoDB"
    - "NoSQL"
    - "复制集"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-26 | 初稿 |

## 软件版本

| soft    | Version |
| ------- | ------- |
| Mongodb | 4.2.13  |

## 环境准备

``` zsh
# 下载安装包并解压
➜  cd /usr/local
➜  wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.13.tgz
➜  tar -zxf mongodb-linux-x86_64-rhel70-4.2.13.tgz

# 创建软连接
➜  ln -s mongodb-linux-x86_64-rhel70-4.2.13 mongodb

# 验证版本信息
➜  cd mongodb
➜  bin/mongo --version
MongoDB shell version v4.2.13
git version: 82dd40f60c55dae12426c08fd7150d79a0e28e23
OpenSSL version: OpenSSL 1.0.1e-fips 11 Feb 2013
allocator: tcmalloc
modules: none
build environment:
    distmod: rhel70
    distarch: x86_64
    target_arch: x86_64
```

## 配置文件

``` zsh
# 创建mongodb配置文件目录
➜  mkdir conf

# 创建数据目录
➜  mkdir -p /data/mongodb/{data,logs}

# 配置文件
➜  cat > /usr/local/mongodb/conf/mongodb.conf << EOF
port=28018
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log

# 使用追加的方式写日志  
logappend=true

# 以守护程序的方式启用，在后台运行
fork=true

# 最大同时连接数  
maxConns=100

# 启用验证
auth=false

# 每次写入会记录一条操作日志（通过journal可以重新构造出写入的数据）
journal=true

# 存储引擎有mmapv1、wiretiger、mongorocks，即使宕机，启动时wiredtiger会先将数据恢复到最近一次的checkpoint点，然后重放后续的journal日志来恢复
storageEngine=wiredTiger

# 监听地址
bind_ip = 0.0.0.0

EOF
```

## 用户鉴权

``` zsh
# 启动服务
➜  cd /usr/local/mongodb
➜  bin/mongod -f conf/mongodb.conf

# 连接mongo
➜  bin/mongo --port 28018
> use admin;
> db.createUser({
    user: 'root',
    pwd: 'gjr_mongo_2021',
    roles: [
    'clusterAdmin',
    'dbAdminAnyDatabase',
    'userAdminAnyDatabase',
    'readWriteAnyDatabase'
    ]
})

# 关闭服务
➜  bin/mongod -f conf/mongodb.conf --shutdown

# 修改配置文件
➜  vim conf/mongodb.conf
auth=true  # 启用验证

# 重新启动服务
➜  bin/mongod -f conf/mongodb.conf
```

> 参考文档：  
> [1] [Mongodb单节点部署以及简单使用](https://www.jianshu.com/p/56c7e486919f)  
> [2] [单节点mongo安装](https://blog.csdn.net/baishancha/article/details/109277750)  
> [3] [Mongodb官网](https://www.mongodb.com/download-center/community)  
>