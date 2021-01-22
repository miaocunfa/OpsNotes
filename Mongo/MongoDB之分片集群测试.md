---
title: "MongoDB之分片集群测试"
date: "2020-08-07"
categories:
    - "技术"
tags:
    - "Mongo"
    - "分片集群"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容            |
| ---------- | --------------- |
| 2020-08-07 | 初稿            |

## 一、数据插入

## 1、切换数据库

``` json
mongos> use test
switched to db test

mongos> sh.enableSharding('test')
{
    "ok" : 1,
    "operationTime" : Timestamp(1596770447, 4),
    "$clusterTime" : {
        "clusterTime" : Timestamp(1596770447, 4),
        "signature" : {
            "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
            "keyId" : NumberLong(0)
        }
    }
}

mongos> sh.status()
--- Sharding Status ---
  shards:
        {  "_id" : "shard1",  "host" : "shard1/mongo1:27001,mongo2:27001,mongo3:27001",  "state" : 1 }
        {  "_id" : "shard2",  "host" : "shard2/mongo1:27002,mongo2:27002,mongo3:27002",  "state" : 1 }
  databases:
        {  "_id" : "test",  "primary" : "shard2",  "partitioned" : true,  "version" : {  "uuid" : UUID("51834159-2269-4108-a02e-49b9f74256a7"),  "lastMod" : 1 } }
```

## 2、增加索引

``` json
mongos> db.table1.ensureIndex({"id":1})

{
    "raw" : {
        "shard2/mongo1:27002,mongo2:27002,mongo3:27002" : {
            "createdCollectionAutomatically" : false,
            "numIndexesBefore" : 1,
            "numIndexesAfter" : 2,
            "ok" : 1
        }
    },
    "ok" : 1,
    "operationTime" : Timestamp(1596770677, 2),
    "$clusterTime" : {
        "clusterTime" : Timestamp(1596770677, 2),
        "signature" : {
            "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
            "keyId" : NumberLong(0)
        }
    }
}
```

## 3、对表进行分片

``` json
mongos> sh.shardCollection("test.table1",{"id":1})
{
    "collectionsharded" : "test.table1",
    "collectionUUID" : UUID("3eb4d4d5-f960-48be-a914-90fe6a3114f1"),
    "ok" : 1,
    "operationTime" : Timestamp(1596770769, 1),
    "$clusterTime" : {
        "clusterTime" : Timestamp(1596770769, 1),
        "signature" : {
            "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
            "keyId" : NumberLong(0)
        }
    }
}

mongos> sh.status()
  databases:
        {  "_id" : "test",  "primary" : "shard2",  "partitioned" : true,  "version" : {  "uuid" : UUID("51834159-2269-4108-a02e-49b9f74256a7"),  "lastMod" : 1 } }
                test.table1
                        shard key: { "id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                shard2  1
                        { "id" : { "$minKey" : 1 } } -->> { "id" : { "$maxKey" : 1 } } on : shard2 Timestamp(1, 0)
```

## 4、插入数据

``` json
for(var i=1;i<=1000000;i++){
    db.table1.save({"id":i,"x":Math.random(),"name":"testInsert","time":"20200807","ops":"testInsertTimes"});
}
```

## 二、分片均衡

``` mongo
mongos> sh.status()
  databases:
        {  "_id" : "test",  "primary" : "shard2",  "partitioned" : true,  "version" : {  "uuid" : UUID("51834159-2269-4108-a02e-49b9f74256a7"),  "lastMod" : 1 } }
                test.table1
                        shard key: { "id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                shard1  1
                                shard2  2
                        { "id" : { "$minKey" : 1 } } -->> { "id" : 2 } on : shard1 Timestamp(3, 0)
                        { "id" : 2 } -->> { "id" : 500002 } on : shard2 Timestamp(3, 1)
                        { "id" : 500002 } -->> { "id" : { "$maxKey" : 1 } } on : shard2 Timestamp(2, 3)
```
