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
---

## 更新记录

| 时间       | 内容            |
| ---------- | --------------- |
| 2020-08-07 | 初稿            |

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

## 数据查询

``` zsh
db.getCollection("concern_store").find( {"user_id": NumberLong("4478710120144633929")} );
db.getCollection("info").find( {"description":"个人一信息1"} );
```
