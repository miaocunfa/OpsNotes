---
title: "Postgre慢查询之pg_stat_statements"
date: "2020-07-30"
categories:
    - "技术"
tags:
    - "Postgre"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容         |
| ---------- | ------------ |
| 2020-07-30 | 初稿         |
| 2020-08-13 | 增加采样配置 |

## 版本信息

| Server               | Version |
| -------------------- | ------- |
| PostgreSQL           | 10.10   |
| postgresql10-contrib | 10.10   |

## 概述

pg_stat_statements模块提供一种方法追踪一个服务器所执行的所有 SQL 语句的执行统计信息。

该模块必须通过在 postgresql.conf 的 shared_preload_libraries 中增加 pg_stat_statements 来载入，因为它需要额外的共享内存。这意味着增加或移除该模块需要一次服务器重启。

当 pg_stat_statements 被载入时，它会跟踪该服务器的所有数据库的统计信息。该模块提供了一个视图 pg_stat_statements 以及函数 pg_stat_statements_reset 和 pg_stat_statements 用于访问和操纵这些统计信息。这些视图和函数不是全局可用的，但是可以用 CREATE EXTENSION pg_stat_statements 为特定数据库启用它们。

## 一、安装依赖包

需要安装相同版本的 contrib包

``` zsh
# 获取本地 PG版本
➜  yum list installed | grep pg
postgresql10.x86_64              10.10-1PGDG.rhel7              @pgdg10

# 下载 postgresql10-contrib-10.10 RPM包 && 安装
➜  wget https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7.6-x86_64/postgresql10-contrib-10.10-1PGDG.rhel7.x86_64.rpm
➜  yum install -y postgresql10-contrib-10.10-1PGDG.rhel7.x86_64.rpm
```

## 二、配置 postgresql.conf

``` zsh
➜  cd /var/lib/pgsql/10/data/
➜  vim postgresql.conf
shared_preload_libraries = 'pg_stat_statements'

➜  systemctl start postgresql-10.service
```

## 三、数据库

### 3.1、数据库配置

由于pg_stat_statements针对的是数据库级别，所以需要首先进入指定数据库

``` psql
➜  ./psql -p 9999 -h 192.168.100.212
Password:
psql (10.10)
Type "help" for help.

postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 bench     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 info      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 infov3    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pgpool    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pms       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(8 rows)

postgres=# \c info
You are now connected to database "info" as user "postgres".

info=# create extension pg_stat_statements;
CREATE EXTENSION
```

### 3.2、数据库资源

创建好扩展后，多出一个视图资源 pg_stat_statements 和 两个函数资源 pg_stat_statements_reset

查看函数

``` psql
info=# \df
                                                                                                                                                              List of functions
 Schema |           Name           | Result data type |
                                                                                                                                                                                    Argument
data types
                                                                                                                                        |  Type  
--------+--------------------------+------------------+--------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------+--------
 public | pg_stat_statements       | SETOF record     | showtext boolean, OUT userid oid, OUT dbid oid, OUT queryid bigint, OUT query text, OUT calls bigint, OUT total_time double precision
, OUT min_time double precision, OUT max_time double precision, OUT mean_time double precision, OUT stddev_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blk
s_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written b
igint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision | normal
 public | pg_stat_statements_reset | void             |


                                                                                                                                        | normal
(2 rows)

info=# \df+ pg_stat_statements


                        List of functions
 Schema |        Name        | Result data type |
                                                                                                                                                                              Argument data t
ypes
                                                                                                                                  |  Type  | Volatility | Parallel |  Owner   | Security | Ac
cess privileges | Language |      Source code       | Description
--------+--------------------+------------------+--------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------+--------+------------+----------+----------+----------+---
----------------+----------+------------------------+-------------
 public | pg_stat_statements | SETOF record     | showtext boolean, OUT userid oid, OUT dbid oid, OUT queryid bigint, OUT query text, OUT calls bigint, OUT total_time double precision, OUT 
min_time double precision, OUT max_time double precision, OUT mean_time double precision, OUT stddev_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read
 bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint,
 OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision | normal | volatile   | safe     | postgres | invoker  |
                | c        | pg_stat_statements_1_3 |
(1 row)
```

查看视图

``` psql
info=# \d
                              List of relations
 Schema |                     Name                     |   Type   |  Owner
--------+----------------------------------------------+----------+----------
 public | pg_stat_statements                           | view     | postgres
(121 rows)

info=# \d+ pg_stat_statements
                                 View "public.pg_stat_statements"
       Column        |       Type       | Collation | Nullable | Default | Storage  | Description
---------------------+------------------+-----------+----------+---------+----------+-------------
 userid              | oid              |           |          |         | plain    |
 dbid                | oid              |           |          |         | plain    |
 queryid             | bigint           |           |          |         | plain    |
 query               | text             |           |          |         | extended |
 calls               | bigint           |           |          |         | plain    |
 total_time          | double precision |           |          |         | plain    |
 min_time            | double precision |           |          |         | plain    |
 max_time            | double precision |           |          |         | plain    |
 mean_time           | double precision |           |          |         | plain    |
 stddev_time         | double precision |           |          |         | plain    |
 rows                | bigint           |           |          |         | plain    |
 shared_blks_hit     | bigint           |           |          |         | plain    |
 shared_blks_read    | bigint           |           |          |         | plain    |
 shared_blks_dirtied | bigint           |           |          |         | plain    |
 shared_blks_written | bigint           |           |          |         | plain    |
 local_blks_hit      | bigint           |           |          |         | plain    |
 local_blks_read     | bigint           |           |          |         | plain    |
 local_blks_dirtied  | bigint           |           |          |         | plain    |
 local_blks_written  | bigint           |           |          |         | plain    |
 temp_blks_read      | bigint           |           |          |         | plain    |
 temp_blks_written   | bigint           |           |          |         | plain    |
 blk_read_time       | double precision |           |          |         | plain    |
 blk_write_time      | double precision |           |          |         | plain    |
View definition:
 SELECT pg_stat_statements.userid,
    pg_stat_statements.dbid,
    pg_stat_statements.queryid,
    pg_stat_statements.query,
    pg_stat_statements.calls,
    pg_stat_statements.total_time,
    pg_stat_statements.min_time,
    pg_stat_statements.max_time,
    pg_stat_statements.mean_time,
    pg_stat_statements.stddev_time,
    pg_stat_statements.rows,
    pg_stat_statements.shared_blks_hit,
    pg_stat_statements.shared_blks_read,
    pg_stat_statements.shared_blks_dirtied,
    pg_stat_statements.shared_blks_written,
    pg_stat_statements.local_blks_hit,
    pg_stat_statements.local_blks_read,
    pg_stat_statements.local_blks_dirtied,
    pg_stat_statements.local_blks_written,
    pg_stat_statements.temp_blks_read,
    pg_stat_statements.temp_blks_written,
    pg_stat_statements.blk_read_time,
    pg_stat_statements.blk_write_time
   FROM pg_stat_statements(true) pg_stat_statements(userid, dbid, queryid, query, calls, total_time, min_time, max_time, mean_time, stddev_time, rows, shared_blks_hit, shared_blks_read, shared_blks_dirtied, shared_blks_written, local_blks_hit, local_blks_read, local_blks_dirtied, local_blks_written, temp_blks_read, temp_blks_written, blk_read_time, blk_write_time);

info=# select count(1) from pg_stat_statements;
 count
-------
    11
(1 row)

```

## 四、使用

使用Navicat查询视图获取统计信息

``` SQL
-- 可以使用 pg_stat_statements_reset() 函数来重置 pg_stat_statements，方便阶段性的分析慢sql，比如专项优化、大版本上线监控。
select pg_stat_statements_reset();


-- Top IO SQL
-- 平均单次 IO
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time)/calls desc limit 20;

-- 累计 IO
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time) desc limit 20;

-- Top Time SQL
-- 平均 Time
select userid::regrole, dbid, query from pg_stat_statements order by mean_time desc limit 20;

-- 累计 Time
select userid::regrole, dbid, query from pg_stat_statements order by total_time desc limit 20;

-- 不稳定，时快时慢
select userid::regrole, dbid, query from pg_stat_statements order by stddev_time desc limit 20;

-- Top Shared Memory
select userid::regrole, dbid, query from pg_stat_statements order by (shared_blks_hit+shared_blks_dirtied) desc limit 20;

-- Top Temp Memory
select userid::regrole, dbid, query from pg_stat_statements order by temp_blks_written desc limit 20;
```

## 五、采样配置

``` zsh
➜  vi $PGDATA/postgresql.conf
pg_stat_statements.max = 10000           # 在pg_stat_statements中最多保留多少条统计信息，通过LRU算法，覆盖老的记录。  
pg_stat_statements.track = all           # all - (所有SQL包括函数内嵌套的SQL), top - 直接执行的SQL(函数内的sql不被跟踪), none - (不跟踪)  
pg_stat_statements.track_utility = off   # 是否跟踪非DML语句 (例如DDL，DCL)， on表示跟踪, off表示不跟踪  
pg_stat_statements.save = on             # 重启后是否保留统计信息

track_io_timing = on                     # 如果要跟踪IO消耗的时间，还需要打开如下参数
track_activity_query_size = 3000         # 设置单条SQL的最长长度，超过被截断; 默认:1024 最低限度:100 最大:102400
```

> 参考链接：  
> 1、[postgresql 查找慢sql之二: pg_stat_statements](https://blog.csdn.net/ctypyb2002/article/details/83151836?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-2.channel_param)  
> 2、[postgre官方配置文件 -- track_activity_query_size](https://postgresqlco.nf/zh/doc/param/track_activity_query_size/10/)  
>