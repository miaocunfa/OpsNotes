---
title: "PostgreSQL-地理位置近邻查询性能"
date: "2020-12-29"
categories:
    - "技术"
tags:
    - "PostgreSQL"
toc: false
original: true
draft: false
---

## 创建表

``` psql
postgres=# create table tbl_point(id serial8, poi point);
CREATE TABLE

postgres=# \d tbl_point
                         Table "public.tbl_point"
 Column |  Type  |                       Modifiers                        
--------+--------+--------------------------------------------------------
 id     | bigint | not null default nextval('tbl_point_id_seq'::regclass)
 poi    | point  | 

postgres=# alter sequence tbl_point_id_seq cache 10000;
ALTER SEQUENCE
```

## 插入测试数据

``` zsh
➜  cat > insert.sql << EOF
insert into tbl_point(poi) select point(trunc(100000*(0.5-random())), trunc(100000*(0.5-random()))) from generate_series(1,10000);
EOF

➜  pgbench -p 9999 -M prepared -n -r -f ./insert.sql -P 1 -c 96 -j 96 -T 200
```

## 数据量

使用 pgbench 每秒插入3w条数据

``` zsh
transaction type: ./insert.sql
scaling factor: 1
query mode: prepared
number of clients: 96
number of threads: 96
duration: 200 s
number of transactions actually processed: 751
latency average = 26557.685 ms
latency stddev = 14031.224 ms
tps = 3.548172 (including connections establishing)
tps = 3.549777 (excluding connections establishing)
script statistics:
 - statement latencies in milliseconds:
     26621.815  insert into tbl_point(poi) select point(trunc(100000*(0.5-random())), trunc(100000*(0.5-random()))) from generate_series(1,10000);
```

总计插入751w数据

``` psql
postgres=# select count(*) from tbl_point;
  count  
---------
 7510000
(1 row)
```

## 当前表大小

``` psql
postgres=# \dt+
                        List of relations
 Schema |   Name    | Type  |  Owner   |    Size    | Description 
--------+-----------+-------+----------+------------+-------------
 public | company   | table | postgres | 8192 bytes | 
 public | hotel     | table | postgres | 8192 bytes | 酒店用户表
 public | tbl_point | table | postgres | 374 MB     | 
(3 rows)
```

## 创建索引

``` psql
postgres=# create index idx_tbl_point on tbl_point using gist(poi) with (buffering=on);
CREATE INDEX
```

## 再次插入数据

``` zsh
➜  pgbench -p 9999 -M prepared -n -r -f ./insert.sql -P 1 -c 96 -j 96 -T 100

# 加入索引后，每秒插入速度降至3700条
transaction type: ./insert.sql
scaling factor: 1
query mode: prepared
number of clients: 96
number of threads: 96
duration: 100 s
number of transactions actually processed: 96
latency average = 248996.571 ms
latency stddev = 8317.880 ms
tps = 0.374872 (including connections establishing)
tps = 0.375098 (excluding connections establishing)
script statistics:
 - statement latencies in milliseconds:
    246990.837  insert into tbl_point(poi) select point(trunc(100000*(0.5-random())), trunc(100000*(0.5-random()))) from generate_series(1,10000);

# 数据总量
postgres=# select count(*) from tbl_point;
  count  
---------
 8470000
(1 row)
```

## KNN 检索例子

``` psql
postgres=# select *,poi <-> point(1000,1000) dist from tbl_point where poi <-> point(1000,1000) < 100 order by poi <-> point(1000,1000) limit 10;
   id    |     poi     |       dist       
---------+-------------+------------------
 3629759 | (995,999)   | 5.09901951359279
 5108606 | (986,996)   |  14.560219778561
 7754233 | (974,994)   | 26.6833281282527
 3442609 | (971,1002)  | 29.0688837074973
 1621045 | (976,1029)  | 37.6430604494374
 2842550 | (983,1040)  | 43.4626276242015
 1348215 | (978,1041)  | 46.5295604965274
  145228 | (1002,951)  | 49.0407993409569
 6826184 | (1021,1057) | 60.7453701939498
  394438 | (1060,979)  | 63.5688603012513
(10 rows)
```

## KNN 执行计划

``` psql
postgres=# explain (analyze,verbose,buffers,timing,costs) select *,poi <-> point(10090,10090) dist from tbl_point where poi <-> point(10090,10090) < 100 order by poi <-> point(10090,10090) limit 10;
                                                                    QUERY PLAN                                                                     
---------------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=0.41..2.86 rows=10 width=32) (actual time=0.400..0.563 rows=10 loops=1)
   Output: id, poi, ((poi <-> '(10090,10090)'::point))
   Buffers: shared hit=15
   ->  Index Scan using idx_tbl_point on public.tbl_point  (cost=0.41..690944.22 rows=2823083 width=32) (actual time=0.399..0.559 rows=10 loops=1)
         Output: id, poi, (poi <-> '(10090,10090)'::point)
         Order By: (tbl_point.poi <-> '(10090,10090)'::point)
         Filter: ((tbl_point.poi <-> '(10090,10090)'::point) < '100'::double precision)
         Buffers: shared hit=15
 Planning time: 0.241 ms
 Execution time: 0.595 ms
(10 rows)
```

## KNN 检索压力测试

将数据持续添加至2000w行。

``` zsh
➜  vi test.sql
\set x random(-50000,50000)
\set y random(-50000,50000)
select * from tbl_point where poi <-> point(:x,:y) <100 order by poi <-> point(:x,:y) limit 1;
```

## 测试结果

``` zsh
➜  pgbench -p 9999 -M prepared -n -r -f ./test.sql -P 1 -c 64 -j 64 -T 100

transaction type: ./test.sql
scaling factor: 1
query mode: prepared
number of clients: 64
number of threads: 64
duration: 100 s
number of transactions actually processed: 5385082
latency average = 1.185 ms
latency stddev = 1.199 ms
tps = 53824.181105 (including connections establishing)
tps = 53952.015673 (excluding connections establishing)
script statistics:
 - statement latencies in milliseconds:
         0.002  \set x random(-50000,50000)
         0.000  \set y random(-50000,50000)
         1.183  select * from tbl_point where poi <-> point(:x,:y) <100 order by poi <-> point(:x,:y) limit 1;
```

> 参考文档：
> 1、[PostgreSQL 百亿地理位置数据 近邻查询性能](https://developer.aliyun.com/article/2999)  
> 2、[pgbench random设置](https://blog.csdn.net/weixin_30919235/article/details/102011692)  
>