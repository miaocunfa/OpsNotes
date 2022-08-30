---
title: "部署高可用seata"
date: "2020-07-28"
categories:
    - "技术"
tags:
    - "seata"
    - "分布式事务"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容            |
| ---------- | --------------- |
| 2020-07-28 | 初稿            |
| 2020-07-29 | 增加systemd服务 |

## 环境

| Server | Version |
| ------ | ------- |
| Seata  | 1.3.0   |
| CentOS | 7.6     |
| Redis  | 3.2.12  |
| Consul | v1.5.3  |

## 概述

Seata 是一款开源的分布式事务解决方案，致力于提供高性能和简单易用的分布式事务服务。Seata 将为用户提供了 AT、TCC、SAGA 和 XA 事务模式，为用户打造一站式的分布式解决方案。

## 一、下载

``` zsh
# 下载 seata安装包
➜  wget https://github.com/seata/seata/releases/download/v1.3.0/seata-server-1.3.0.tar.gz
➜  tar zxf seata-server-1.3.0.tar.gz -C /opt

# 将安装包拷贝至另外两个节点
➜  scp seata-server-1.3.0.tar.gz n222:/opt
➜  scp seata-server-1.3.0.tar.gz n225:/opt
```

## 二、配置

Seata 的高可用依赖于注册中心、配置中心和数据库来实现

### 2.1、注册中心

``` zsh
➜  cd /opt/seata/conf
➜  vim registry.conf
registry {
  # 注册中心指定为consul
  type = "consul"

  consul {
    cluster = "default"
    serverAddr = "192.168.100.223:8500"
  }
}

config {
  # 配置中心指定为文件
  type = "file"

  file {
    name = "file.conf"
  }
}
```

### 2.2、数据库

#### 2.2.1、db 配置

``` zsh
# 修改存储为 db
➜  vim file.conf
store {
  mode = "db"

  db {
    datasource = "druid"
    dbType = "postgresql"
    driverClassName = "org.postgresql.Driver"
    url = "jdbc:postgresql://192.168.100.241:9999/seata"
    user = "postgres"
    password = "test%123"
    minConn = 5
    maxConn = 30
    globalTable = "global_table"
    branchTable = "branch_table"
    lockTable = "lock_table"
    queryLimit = 100
    maxWait = 5000
  }
}
```

postgre SQL

``` SQL
-- Server
-- Create database Seata
CREATE DATABASE seata;

-- the table to store GlobalSession data
DROP TABLE IF    EXISTS "global_table";
CREATE TABLE "global_table" (
"xid" VARCHAR (128) NOT NULL,
"transaction_id" INT8,
"status" INT4 NOT NULL,
"application_id" VARCHAR (100),
"transaction_service_group" VARCHAR (100),
"transaction_name" VARCHAR (128),
"timeout" INT4,
"begin_time" INT8,
"application_data" text,
"gmt_create" TIMESTAMP,
"gmt_modified" TIMESTAMP,
PRIMARY KEY ("xid")
);
CREATE INDEX ON "global_table" ("gmt_modified", "status");
CREATE INDEX ON "global_table" ("transaction_id");

-- the table to store BranchSession data
DROP TABLE IF EXISTS "branch_table";
CREATE TABLE "branch_table" (
"branch_id" INT8 NOT NULL,
"xid" VARCHAR (128) NOT NULL,
"transaction_id" INT8,
"resource_group_id" VARCHAR (100),
"resource_id" VARCHAR (256),
"lock_key" VARCHAR (128),
"branch_type" VARCHAR (8),
"status" INT4,
"client_id" VARCHAR (100),
"application_data" text,
"gmt_create" TIMESTAMP,
"gmt_modified" TIMESTAMP,
PRIMARY KEY ("branch_id")
);
CREATE INDEX ON "branch_table" ("xid");

-- the table to store lock data
DROP TABLE IF EXISTS "lock_table";
CREATE TABLE "lock_table" (
"row_key" VARCHAR (128) NOT NULL,
"xid" VARCHAR (100),
"transaction_id" INT8,
"branch_id" INT8,
"resource_id" VARCHAR (256),
"table_name" VARCHAR (100),
"pk" VARCHAR (100),
"gmt_create" TIMESTAMP,
"gmt_modified" TIMESTAMP,
PRIMARY KEY ("row_key")
);


-- Client
-- the sequence of undo_log
CREATE SEQUENCE undo_log_id_seq
START 1
INCREMENT 1;

DROP TABLE IF    EXISTS "undo_log";
CREATE TABLE "undo_log" (
"id" INT8 NOT NULL DEFAULT nextval('undo_log_id_seq'),
"branch_id" INT8 NOT NULL,
"xid" VARCHAR (100) NOT NULL,
"context" VARCHAR (128) NOT NULL,
"rollback_info" BYTEA NOT NULL,
"log_status" INT4 NOT NULL,
"log_created" TIMESTAMP,
"log_modified" TIMESTAMP,
"ext" VARCHAR (100) DEFAULT NULL,
PRIMARY KEY ("id"),
UNIQUE ("branch_id", "xid")
);
```

#### 2.2.2、redis 配置

``` zsh
# 修改存储为 redis
➜  vim file.conf
store {
  mode = "redis"

  redis {
    host = "192.168.100.223"
    port = "6379"
    password = ""
    database = "0"
    minConn = 1
    maxConn = 10
    queryLimit = 100
  }
}
```

安装redis

``` zsh
# 安装 redis
➜  yum install -y redis

# 修改配置文件
➜  vim /etc/redis.conf
bind 0.0.0.0

# 启动 redis
➜  systemctl start redis
```

## 三、启动

### 3.1、启动选项

``` log
    启动选项：
    -h: 注册到注册中心的ip
    -p: Server rpc 监听端口
    -m: 全局事务会话信息存储模式，file、db、redis，优先读取启动参数 (Seata-Server 1.3及以上版本支持redis)
    -n: Server node，多个Server时，需区分各自节点，用于生成不同区间的transactionId，以免冲突
    -e: 多环境配置参考 http://seata.io/en-us/docs/ops/multi-configuration-isolation.html
```

### 3.2、脚本启动

``` zsh
# n222
➜  sh ./bin/seata-server.sh -n 1

# n223
➜  sh ./bin/seata-server.sh -n 2

# n225
➜  sh ./bin/seata-server.sh -n 3
```

### 3.3、注册为systemd服务

systemd 服务脚本

``` zsh
➜  vim /usr/lib/systemd/system/seata@.service
[Unit]
Description=The Seata Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/seata/bin/seata-server.sh -n %i > /opt/seata/logs/seata-%i.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

启动服务

``` zsh
➜  systemctl daemon-reload
➜  systemctl start seata@3
➜  systemctl status seata@3
● seata@3.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-07-29 08:43:43 CST; 1s ago
 Main PID: 17960 (sh)
   CGroup: /system.slice/system-seata.slice/seata@3.service
           ├─17960 /bin/sh -c /opt/seata/bin/seata-server.sh -n 3 2>&1 > /opt/seata/logs/seata-3.log
           └─17961 /usr/bin/java -server -Xmx2048m -Xms2048m -Xmn1024m -Xss512k -XX:SurvivorRatio=10 -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=1024m -XX:-O...

Jul 29 08:43:43 node225 systemd[1]: Started The Seata Server.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN No appenders could be found for logger (org.apache.http.client.protocol.RequestAddCookies).
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN Please initialize the log4j system properly.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
➜  cd /opt/seata/logs/
➜  ll
total 32
-rw-r--r-- 1 root root 28037 Jul 29 08:46 seata-3.log
-rw-r--r-- 1 root root   986 Jul 29 08:44 seata_gc.log
```

> 参考链接:  
> 1、[Seata直接部署文档](https://seata.io/zh-cn/docs/ops/deploy-server.html)  
> 2、[Seata高可用部署](https://seata.io/zh-cn/docs/ops/deploy-ha.html)  
> 3、[Seata参数配置](https://seata.io/zh-cn/docs/user/configurations.html)  
> 4、[七步带你集成Seata 1.2 高可用搭建](https://blog.csdn.net/qq_35721287/article/details/105947941)  
> 5、[Seata GitHub](https://github.com/seata/seata)  
> 6、[Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)  
> 7、[systemctl服务编写，及日志控制](https://blog.csdn.net/jeccisnd/article/details/103166554/)  
> 8、[linux kill信号列表](https://www.cnblogs.com/the-tops/p/5604537.html)  
>