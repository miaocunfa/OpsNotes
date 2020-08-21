---
title: "Redis主从复制"
date: "2020-08-21"
categories:
    - "技术"
tags:
    - "Redis"
    - "NoSQL"
    - "主从复制"
toc: false
original: false
---

## 1、数据复制

``` zsh
# s4
redis-cli
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=9954,expires=942,avg_ttl=1138917408
db1:keys=1802,expires=0,avg_ttl=0
db2:keys=21767,expires=20155,avg_ttl=87716586
db6:keys=175,expires=0,avg_ttl=0
db7:keys=31,expires=0,avg_ttl=0
127.0.0.1:6379>

# pg1
redis-cli
127.0.0.1:6379> info keyspace
# Keyspace
127.0.0.1:6379>
```

``` zsh
vim /etc/redis/6379.conf
replicaof 172.19.26.5 6379

service redis_6379 restart
Stopping ...
Waiting for Redis to shutdown ...
Redis stopped
Starting Redis server...
```

``` zsh
# pg1
redis-cli
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=9954,expires=942,avg_ttl=0
db1:keys=1802,expires=0,avg_ttl=0
db2:keys=21767,expires=20155,avg_ttl=0
db6:keys=175,expires=0,avg_ttl=0
db7:keys=31,expires=0,avg_ttl=0
127.0.0.1:6379> quit
```

## 2、配置详解

## 3、Keepalived
