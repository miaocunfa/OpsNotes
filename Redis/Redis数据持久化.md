---
title: "Redis 数据持久化"
date: "2019-11-29"
categories:
    - "技术"
tags:
    - "Redis"
    - "NoSQL"
    - "数据库"
toc: false
original: false
draft: false
---

| 时间       | 内容 |
| ---------- | ---- |
| 2019-11-29 | 初稿 |
| 2020-07-29 | 1、修改命令提示符</br>2、Markdown文档优化 |

## 一、Redis 实现数据持久化的两种实现方式

RDB：指定的时间间隔内保存数据快照  
AOF：先把命令追加到操作日志的尾部，保存所有的历史操作

## 二、RDB 实现 Redis 数据持久化（默认方式）

### 1、配置redis.conf

#### 查找redis.conf

``` zsh
➜  rpm -ql redis
/etc/logrotate.d/redis
/etc/redis-sentinel.conf
/etc/redis.conf
```

#### 配置数据持久化

``` zsh
➜  vi /etc/redis.conf
save 900 1       #指定在多长时间内，有多少次更新操作，就将数据同步到数据文件，可以多个条件配合
save 300 10      #分别表示900秒（15分钟）内有1个更改，300秒（5分钟）内有10个更改以及60秒内有10000个更改。
save 60 10000

dbfilename dump.rdb   #指定本地数据库文件名，默认值为dump.rdb

dir /var/lib/redis    #指定本地数据库存放目录
```

#### 数据持久化后保存的文件

``` zsh
➜  cd /var/lib/redis
➜  ll
total 2624
-rw-r--r-- 1 redis redis 2683923 Nov 29 17:31 dump.rdb
```

### 2、RDB的缺点

因为是特定条件下进行一次持久化（每隔一段时间），就可能会发生一旦redis崩溃，再次恢复时，可能会导致部分数据丢失。  
注：如果设置的备份时间间隔较短，比较耗服务器性能，如果设置的备份时间间隔较长，又可能会导致数据恢复时部分数据丢失。

## 三、AOF持久化方案

先把命令追加到操作日志的尾部，保存所有的历史操作。

### 1、相比于RDB持久化方案的优点

（1）数据非常完整，故障恢复丢失数据少  
（2）可对历史操作进行处理  

### 2、开启AOF持久化

``` zsh
➜  vi redis.conf
appendonly yes                    # 打开AOF模式
appendfilename "appendonly.aof"   # 操作日志文件名
appendfsync everysec              # AOF同步方式，每秒一次
```

### 3、验证AOF

``` zsh
# 连接redis进行操作
➜  redis-cli
127.0.0.1:6379> select 5
OK
127.0.0.1:6379[5]> set name miao
OK
127.0.0.1:6379[5]> set day fri
OK
127.0.0.1:6379[5]> get name
"miao"
127.0.0.1:6379[5]> get day
"fri"
127.0.0.1:6379[5]> exit

# 打开AOF操作日志，刚才的操作都被记录在内。
➜  cat appendonly.aof
*2
$6
SELECT
$1
5
*3
$3
set
$4
name
$4
miao
*3
$3
set
$3
day
$3
fri
```

### 4、缺点  

（1）因为AOF模式要把每一步redis命令都记录下来，所以就导致文件的体积会很大  
（2）而且会导致速度低于RDB，并且恢复速度慢  

## 四、总结

在实际应用中，根据场景不同，选择的方式也不尽相同，各有优缺点。但我个人看法，RDB的快照方式相比于AOF的逐步记录模式要好一些。至于RDB丢数据的风险，我们完全可以通过控制备份的时间间隔来避免这个问题。当然，也是可以两种方式同时使用的，只是大多不会这么做。

> 作者：m_nanle_xiaobudiu  
> 出处：<https://blog.csdn.net/m_nanle_xiaobudiu/article/details/81001504>  
>
