---
title: "MySQL 常用 SQL语句"
date: "2022-08-04"
categories:
    - "技术"
tags:
    - "MySQL"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                 |
| ---------- | ------------------- |
| 2022-08-04 | 初稿                |
| 2022-08-05 | 导出部分             |

## 一、常规

``` zsh
# 数据库
mysql> create database [dbname]; //创建数据库

# 用户
mysql> create user //创建用户
mysql> grant all privileges on *.* to root@'%' identified by "123456"; //授权所有IP 都可以使用密码123456 登陆root用户
mysql> flush privileges; //刷新系统权限表
```

## 二、管理

用户部分

``` zsh
# 修改密码策略
mysql> set global validate_password.policy = low;

mysql> show VARIABLES LIKE 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password.check_user_name    | ON    |
| validate_password.dictionary_file    |       |
| validate_password.length             | 8     |
| validate_password.mixed_case_count   | 1     |
| validate_password.number_count       | 1     |
| validate_password.policy             | LOW   |
| validate_password.special_char_count | 1     |
+--------------------------------------+-------+
```

备份部分

``` zsh
# 导出
# 普通全量导出, -B 或 --databases
➜  mysqldump -root -p -B zabbix > zabbix_20220804.sql
➜  mysqldump -uroot -p --databases confluence > confluence_20220805.sql

# 导出 忽略某些表, --ignore-table=[db].[table]
➜  mysqldump -uroot -p --databases zabbix --ignore-table=zabbix.history_text --ignore-table=zabbix.history_uint > zabbix_ignore_20220804.sql

# 导出表结构, -d 选项
➜  mysqldump -uroot -p -d zabbix history_text history_uint > zabbix_ignore_create_20220804.sql
```

查看空间大小

``` zsh
# root用户 查看各数据库的 大小
mysql> SELECT
    table_schema AS '数据库',
    TRUNCATE ( sum( data_length )/ 1024 / 1024, 2 ) AS '数据容量(MB)',
    TRUNCATE ( sum( index_length )/ 1024 / 1024, 2 ) AS '索引容量(MB)' 
FROM
    information_schema.TABLES 
GROUP BY
    table_schema;

# 查看指定 数据库中 各表的 大小
mysql> use [db];
mysql> SELECT
    table_schema AS '数据库',
    table_name AS '表名',
    table_rows AS '记录数',
    TRUNCATE ( data_length / 1024 / 1024, 2 ) AS '数据容量(MB)',
    TRUNCATE ( index_length / 1024 / 1024, 2 ) AS '索引容量(MB)' 
FROM
    information_schema.TABLES 
WHERE
    table_schema = 'zabbix' 
ORDER BY
    table_rows DESC,
    index_length DESC;
```
