---
title: "MongoDB 部署分片集群"
date: "2020-01-09"
categories:
    - "技术"
tags:
    - "MongoDB"
    - "NoSQL"
    - "分片集群"
toc: false
original: true
---

## 更新记录

| 时间       | 内容         |
| ---------- | ------------ |
| 2020-01-09 | 初稿         |
| 2020-08-04 | 修改节点规划 |

## 一、环境准备

> [官网地址](https://www.mongodb.com/download-center/community)  
>

### 1.1、安装包准备(V4.2.2)

``` zsh
# 下载安装包并解压
➜  wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.2.tgz
➜  tar -zxvf mongodb-linux-x86_64-rhel70-4.2.2.tgz -C /opt

# 验证版本信息
➜  cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
➜  ./mongo --version
MongoDB shell version v4.2.2

# 创建mongodb配置文件目录
➜  mkdir -p /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf
```

### 1.2、节点规划

| Node            | config servers | mongos | shard1 | shard2 |
| --------------- | -------------- | ------ | ------ | ------ |
| 192.168.100.226 | 20000          | 21000  | 27001  | 27003  |
| 192.168.100.227 | 20000          | 21000  | 27001  | 27003  |
| 192.168.100.228 | 20000          | 21000  | 27001  | 27003  |

### 1.3、hosts文件

``` zsh
# 在每个节点都执行
➜  vi /etc/hosts
192.168.100.226    mongo1
192.168.100.227    mongo2
192.168.100.228    mongo3
```

## 二、配置服务器(config-server)

### 2.1、config-server配置文件

``` zsh
# 在每个节点都执行，按节点配置bindIp

# 创建config-server数据目录
➜  mkdir -p /ahdata/mongodb/config/
# 创建config-server配置文件
➜  cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf/config.yaml << EOF
sharding:
  clusterRole: configsvr
replication:
  replSetName: config
  oplogSizeMB: 2048
systemLog:
  destination: file
  #日志存储位置
  path: "/ahdata/mongodb/config.log"
  logAppend: true
storage:
  journal:
    enabled: true
  # 数据文件存储位置
  dbPath: "/ahdata/mongodb/config/"
  #是否一个库一个文件夹
  directoryPerDB: true
  # WT引擎配置
  wiredTiger:
    engineConfig:
      #WT最大使用cache (根据服务器实际情况调节)
      cacheSizeGB: 1
      #是否将索引也按数据库名单独存储
      directoryForIndexes: true
    #表压缩配置
    collectionConfig:
      blockCompressor: zlib
    #索引配置
    indexConfig:
      prefixCompression: true
#端口配置
net:
  #按节点配置
  bindIp: mongo1
  port: 20000
processManagement:
  fork: true
EOF
```

### 2.2、启动config-server副本集的每个成员

``` zsh
# 在每个节点都执行
➜  cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
➜  bin/mongod -f conf/config.yaml
```

### 2.3、启动config-server副本集

连接到其中一台配置服务器

``` zsh
➜  bin/mongo --host mongo1 --port 20000

# 启动副本集
rs.initiate(
  {
    _id: "config",
    configsvr: true,
    members: [
      { _id : 0, host : "mongo1:20000" },
      { _id : 1, host : "mongo2:20000" },
      { _id : 2, host : "mongo3:20000" }
    ]
  }
)

# 返回信息
{
  "ok" : 1,
  "$gleStats" : {
    "lastOpTime" : Timestamp(1578628539, 1),
    "electionId" : ObjectId("000000000000000000000000")
  },
  "lastCommittedOpTime" : Timestamp(0, 0),
  "$clusterTime" : {
    "clusterTime" : Timestamp(1578628539, 1),
    "signature" : {
      "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
      "keyId" : NumberLong(0)
    }
  },
  "operationTime" : Timestamp(1578628539, 1)
}
```

## 三、分片shard1

### 3.1、shard1 配置文件

``` zsh
# 在每个节点都执行，按节点配置bindIp

# 创建shard1数据目录
➜  mkdir -p /ahdata/mongodb/shard1
# 创建shard1配置文件
➜  cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf/shard1.yaml <<EOF
sharding:
   clusterRole: shardsvr
replication:
   replSetName: "shard1"
systemLog:
   destination: file
   path: "/ahdata/mongodb/shard1.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/ahdata/mongodb/shard1"
processManagement:
   fork: true
net:
   #按节点配置
   bindIp: mongo1
   port: 27001
setParameter:
   enableLocalhostAuthBypass: false
EOF
```

### 3.2、启动shard1副本集的每个成员

``` zsh
# 在每个节点都执行
➜  cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
➜  bin/mongod -f conf/shard1.yaml
```

### 3.3、启动shard1副本集

``` zsh
连接到分片副本集中的一个成员
➜  bin/mongo --host mongo1 --port 27001

# 启动副本集
rs.initiate(
  {
    _id : "shard1",
    members: [
      { _id : 0, host : "mongo1:27001" },
      { _id : 1, host : "mongo2:27001" },
      { _id : 2, host : "mongo3:27001" }
    ]
  }
)

# 返回信息
{
  "ok" : 1,
  "$clusterTime" : {
    "clusterTime" : Timestamp(1578628705, 1),
    "signature" : {
      "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
      "keyId" : NumberLong(0)
    }
  },
  "operationTime" : Timestamp(1578628705, 1)
}
```

## 四、分片shard2

### 4.1、shard2 配置文件

``` zsh
# 在每个节点都执行，按节点配置bindIp

# 创建shard1数据目录
➜  mkdir -p /ahdata/mongodb/shard2
# 创建shard1配置文件
➜  cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf/shard2.yaml <<EOF
sharding:
   clusterRole: shardsvr
replication:
   replSetName: "shard2"
systemLog:
   destination: file
   path: "/ahdata/mongodb/shard2.log"
   logAppend: true
storage:
   journal:
      enabled: true
   dbPath: "/ahdata/mongodb/shard2"
processManagement:
   fork: true
net:
   #按节点配置
   bindIp: mongo1
   port: 27002
setParameter:
   enableLocalhostAuthBypass: false
EOF
```

### 4.2、启动shard2副本集的每个成员

``` zsh
# 在每个节点都执行
➜  cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
➜  bin/mongod -f conf/shard2.yaml
```

### 4.3、启动shard2副本集

``` zsh
连接到分片副本集中的一个成员
➜  bin/mongo --host mongo1 --port 27002

# 启动副本集
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 0, host : "mongo1:27002" },
      { _id : 1, host : "mongo2:27002" },
      { _id : 2, host : "mongo3:27002" }
    ]
  }
)

# 返回信息
{
  "ok" : 1,
  "$clusterTime" : {
    "clusterTime" : Timestamp(1578628869, 1),
    "signature" : {
      "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
      "keyId" : NumberLong(0)
    }
  },
  "operationTime" : Timestamp(1578628869, 1)
}
```

## 五、路由服务器(mongos)

### 5.1、mongos配置文件

``` zsh
# 在每个节点都执行，按节点配置bindIp

# 创建mongos数据目录
➜  mkdir -p /ahdata/mongodb/mongos
# 创建mongos配置文件
➜  cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf/mongos.yaml <<EOF
#将confige-server添加到路由
sharding:
  configDB: config/mongo1:20000,mongo2:20000,mongo3:20000
systemLog:
  destination: file
  path: "/ahdata/mongodb/mongos.log"
  logAppend: true
net:
  bindIp: mongo1
  port: 21000
processManagement:
  fork: true
EOF
```

### 5.2、启动 mongos

``` zsh
# 视情况，启动一个或多个路由服务器
➜  cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
➜  bin/mongos -f conf/mongos.yaml
```

### 5.3、连接至分片集群

``` zsh
➜  bin/mongo --host mongo1 --port 21000
```

### 5.4、将分片集添加至分片集群中

``` zsh
mongos> sh.addShard( "shard1/mongo1:27001,mongo2:27001,mongo3:27001")
mongos> sh.addShard( "shard2/mongo1:27002,mongo2:27002,mongo3:27002")

mongos> sh.status()
  shards:
        {  "_id" : "shard1",  "host" : "shard1/mongo1:27001,mongo2:27001,mongo3:27001",  "state" : 1 }
        {  "_id" : "shard2",  "host" : "shard2/mongo1:27002,mongo2:27002,mongo3:27002",  "state" : 1 }
```

### 5.5、启动数据库

``` zsh
mongos> sh.enableSharding("ahtest")
```

### 5.6、分片集合

``` zsh
# 基于hash
mongos> sh.shardCollection("<database>.<collection>", { <shard key field> : "hashed" } )

# 基于key值
mongos> sh.shardCollection("<database>.<collection>", { <shard key field> : 1, ... } )
```
