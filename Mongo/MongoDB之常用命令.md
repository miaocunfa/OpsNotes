---
title: "MongoDB之常用命令"
date: "2020-08-07"
categories:
    - "技术"
tags:
    - "Mongo"
    - "常用命令"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                           |
| ---------- | ------------------------------ |
| 2020-08-07 | 初稿                           |
| 2021-03-30 | 文档结构优化 && 用户 && 数据库 |

## 软件版本

| soft    | Version |
| ------- | ------- |
| Mongodb | 4.2.13  |

## 常用命令

``` zsh
mongos> help
    db.help()                    help on db methods
    db.mycoll.help()             help on collection methods
    sh.help()                    sharding helpers
    rs.help()                    replica set helpers
    help admin                   administrative help
    help connect                 connecting to a db help
    help keys                    key shortcuts
    help misc                    misc things to know
    help mr                      mapreduce

    show dbs                     show database names
    show collections             show collections in current database
    show users                   show users in current database
    show profile                 show most recent system.profile entries with time >= 1ms
    show logs                    show the accessible logger names
    show log [name]              prints out the last segment of log in memory, 'global' is default
    use <db_name>                set current database
    db.foo.find()                list objects in collection foo
    db.foo.find( { a : 1 } )     list objects in foo where a == 1
    it                           result of the last line evaluated; use to further iterate
    DBQuery.shellBatchSize = x   set default number of items to display on shell
    exit                         quit the mongo shell
```

## 数据库

``` zsh
# 查看数据库列表
> show dbs
admin      0.000GB
config     0.000GB
craftsman  0.000GB
local      0.000GB
```

## 数据

### 数据查询

``` zsh
> db.getCollection("info").find( {"description":"个人一信息1"} );

> db.getCollection("concern_store").find( {"user_id": NumberLong("4478710120144633929")} );

> db.getCollection('conversation').find({"_id":ObjectId("5f3f82598dd9e24bce25e167")});
```

### 数据删除

``` zsh
> db.conversation.remove({"receiverType":"group"});
> db.getCollection('conversation').remove({"receiverType":"group"});
```

## 用户

### 创建用户

``` zsh
# root用户
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

# 程序用户
> use craftsman
> db.createUser(
{
    user: "craftsman",
    pwd: "cm_mongo_2021",
    roles: [ 
        { role: "readWrite", db: "craftsman" } 
    ]
});
```

### 删除用户

``` zsh
> use craftsman
> db.dropUser("craftsman");
true
```

> 参考文档：  
> [1] [MongoDB 教程](https://www.runoob.com/mongodb/mongodb-tutorial.html)  
>