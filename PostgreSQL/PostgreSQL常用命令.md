---
title: "PostgreSQL常用命令"
date: "2020-04-20"
categories:
    - "技术"
tags:
    - "postgre"
toc: false
indent: false
original: true
---

版本信息

``` log
以下所有内容整理自
    psql version 9.2, server version 10.0.
```

## 一、元命令

``` psql
    \l         查看所有数据库
    \d         查看用户所有对象，被解释为\dtvsE, E代表外部表
    \dt        查看表
    \ds        查看序列
    \dv        查看视图
    \df        查看函数
    \du+       查看用户列表
    \dp+       查询权限
    \o         重定向
    \timing    计时选项
    \conninfo  查看当前连接信息
    \c [database] [user] 切换数据库或密码，什么都不加显示当前连接数据库及用户信息
    \h         为SQL提供帮助
    \?         为psql命令提供帮助
    \!         执行shell命令
    \s         查看执行过的所有命令
    \q         退出
```

## 二、角色和权限

一个角色几乎与一个用户相同，角色不能登录
最重要的角色是postgres，具有超级用户属性

### 2.1、角色操作

``` SQL
postgres=# CREATE ROLE my_role;
postgres=# DROP   ROLE my_role;

# 可以从 shell 命令行调用
➜  createuser name
➜  ropuser name

# 给角色登录权限
postgres=# ALTER ROLE my_role WITH login;
```

### 2.2、查询角色

``` SQL
postgres=# SELECT rolname FROM pg_roles;

或使用元命令
postgres=# \du
```

### 2.3、查询权限

使用`dp+`获得一张权限列表

``` SQL
postgres=# grant all on myt to my_user;
GRANT
postgres=# grant select on myt to my_role;
GRANT
postgres=# \dp+
                                Access privileges
 Schema |  Name   | Type  |     Access privileges     | Column access privileges
--------+---------+-------+---------------------------+--------------------------
 public | company | table |                           |
 public | myt     | table | postgres=arwdDxt/postgres+|
        |         |       | my_user=arwdDxt/postgres +|
        |         |       | my_role=r/postgres        |
 public | test    | table |                           |
```

| 值  | 含义 | 值      | 含义     |
| --- | ---- | ------- | -------- |
| a   | 追加 | x       | 执行     |
| r   | 读   | U       | 使用     |
| w   | 写   | C       | 创建     |
| d   | 删除 | c       | 连接     |
| D   | 截断 | T       | 临时的   |
| x   | 参考 | arwdDxt | 所有权限 |
| t   | 引发 |

或使用下列SQL查询一个更易理解的格式  

``` SQL
SELECT pu.usename, pc.tbl, pc.privilege_type
       FROM pg_user pu JOIN (
            SELECT oid::regclass tbl, (aclexplode(relacl)).grantee,
                (aclexplode(relacl)).privilege_type FROM pg_class
            WHERE
            relname='myt'
       ) pc ON pc.grantee=pu.usesysid;

# return
 usename  | tbl | privilege_type
----------+-----+----------------
 postgres | myt | INSERT
 postgres | myt | SELECT
 postgres | myt | UPDATE
 postgres | myt | DELETE
 postgres | myt | TRUNCATE
 postgres | myt | REFERENCES
 postgres | myt | TRIGGER
 my_user  | myt | INSERT
 my_user  | myt | SELECT
 my_user  | myt | UPDATE
 my_user  | myt | DELETE
 my_user  | myt | TRUNCATE
 my_user  | myt | REFERENCES
 my_user  | myt | TRIGGER
```

## 三、模式与search_path

### 3.1、模式

postgre中的一个重要概念是模式，它是一个容器或者数据库内的一个命名空间。我们在数据库中创建的任何对象（例如表、索引、视图等）都会在一个模式下被创建。

当创建对象时，如果为指定模式，这些对象将会在默认的模式下被创建，这个模式叫public

``` SQL
postgres=# select current_schema;
 current_schema
----------------
 public
```

### 3.2、search_path

非常类似于系统中的PATH环境变量

系统将沿着一条搜索路径来决定该名称指的是哪个表，搜索路径是一个进行查看的模式列表。 搜索路径中第一个匹配的表将被认为是所需要的。如果在搜索路径中没有任何匹配，即使在数据库的其他模式中存在匹配的表名也将会报告一个错误。

``` SQL
postgres=# show search_path;
   search_path
-----------------
 "$user", public
```

第一个元素说明一个和当前用户同名的模式会被搜索。如果不存在这个模式，该项将被忽略。第二个元素指向我们已经见过的公共模式。

搜索路径中的第一个模式是创建新对象的默认存储位置。这就是默认情况下对象会被创建在公共模式中的原因。当对象在任何其他没有模式限定的环境中被引用（表修改、数据修改或查询命令）时，搜索路径将被遍历直到一个匹配对象被找到。因此，在默认配置中，任何非限定访问将只能指向公共模式。

公共模式没有什么特别之处，它只是默认存在而已，它也可以被删除。

### 3.3、示例1

``` SQL
postgres=# \dt;
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | company | table | postgres
 public | myt     | table | postgres
 public | test    | table | postgres
(3 rows)

postgres=# create schema mynewschema;
CREATE SCHEMA
postgres=# create table mynewschema.myt1 (id integer);
CREATE TABLE
postgres=# insert into myt1 values (1);
ERROR:  relation "myt1" does not exist
LINE 1: insert into myt1 values (1);
                    ^
postgres=# select current_schema;
 current_schema
----------------
 public
(1 row)

postgres=# show search_path;
   search_path
-----------------
 "$user", public            # search_path中没有模式mynewschema无法插入
(1 row)

# 修改search_path
postgres=# set search_path="$user", public, mynewschema;
SET
postgres=# insert into myt1 values (1);
INSERT 0 1
```

### 3.4、示例2

``` SQL
# 在不同模式下创建同名对象，无法插入
postgres=# create table mynewschema.myt (id integer, first_name text);
CREATE TABLE
postgres=# insert into myt(id, first_name) values (1, 'OldOne');
ERROR:  column "first_name" of relation "myt" does not exist
LINE 1: insert into myt(id, first_name) values (1, 'OldOne');
                            ^
postgres=# show search_path;
         search_path
------------------------------
 "$user", public, mynewschema
(1 row)

# 在这个版本，同名对象无法操作。先切换模式试下
# 使用 set schema 切换，与 set serach_path 效果一致
postgres=# set schema 'mynewschema';
SET
postgres=# show search_path;
 search_path
-------------
 mynewschema
(1 row)

postgres=# insert into myt(id, first_name) values (1, 'OldOne');
INSERT 0 1
postgres=# select * from myt;
 id | first_name
----+------------
  1 | OldOne
(1 row)

postgres=# \dt;
           List of relations
   Schema    | Name | Type  |  Owner
-------------+------+-------+----------
 mynewschema | myt  | table | postgres
 mynewschema | myt1 | table | postgres
(2 rows)
```

## 四、数据库

### 4.1、查看数据库列表

``` SQL
postgres=# \l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges
-----------+----------+----------+-------------+-------------+-----------------------
 bench     | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 info      | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pgpool    | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 pms       | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres  | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 template0 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
(7 rows)
```

### 4.2、切换数据库

``` SQL
postgres=# \c info
psql (9.2.24, server 10.10)
WARNING: psql version 9.2, server version 10.0.
         Some psql features might not work.
You are now connected to database "info" as user "postgres".
info=#
```

> 参考列表：  
> 1、<http://www.postgres.cn/docs/10>  
> 2、《 PostgreSQL for Data Architects 》
>