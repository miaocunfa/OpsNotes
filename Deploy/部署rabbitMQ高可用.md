---
title: "部署rabbit MQ高可用"
date: "2020-03-25"
categories:
    - "技术"
tags:
    - "消息队列"
    - "rabbit MQ"
toc: false
original: true
---

## 版本信息
``` 
    rabbit MQ: 3.8.2
    Erlang: 官方建议最低21.3 推荐22.x
            这里用的是22.2.8
```

## 一、环境准备

### 1.1、主机规划
|主机           |节点   |
|---------------|-------|
|192.168.100.117|内存节点|
|192.168.100.118|磁盘节点|
|192.168.100.119|磁盘节点|


### 1.2、下载离线包
官网安装手册(https://www.rabbitmq.com/install-generic-unix.html)
``` 
    rabbit MQ：二进制版
        $ wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.2/rabbitmq-server-generic-unix-3.8.2.tar.xz

    Erlang: 无依赖版 -- 该软件包剥离了一些Erlang模块和依赖项，这些对运行RabbitMQ而言不是必需的。
        $ wget https://github.com/rabbitmq/erlang-rpm/releases/download/v22.2.8/erlang-22.2.8-1.el7.x86_64.rpm
```

### 1.3、安装离线包
``` bash
# 安装erlang
$ yum install -y yum install erlang-22.2.8-1.el7.x86_64.rpm

# 解压rabbitmq
xz -d rabbitmq-server-generic-unix-3.8.2.tar.xz
tar -xvf rabbitmq-server-generic-unix-3.8.2.tar -C /opt
```

### 1.4、hosts文件
```
192.168.100.217    MQ1
192.168.100.218    MQ2
192.168.100.219    MQ3
```

## 二、高可用集群

### 2.1、启动rabbit
``` bash
$ cd /opt/rabbitmq_server-3.8.2/sbin
$ ./rabbitmq-server -detached

# 查看节点状态
$ ./rabbitmqctl status
```

### 2.2、erlang.cookie

``` bash
$ cat /root/.erlang.cookie
IJPCAHDPWVYSDERZDUPG

# 保持cookie一致
$ scp /root/.erlang.cookie n218:/root/.erlang.cookie
$ scp /root/.erlang.cookie n219:/root/.erlang.cookie
```

### 2.3、加入集群
```

```
