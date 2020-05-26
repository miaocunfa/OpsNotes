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

# PostgreSQL常用命令

## 元命令

```
    \d    查看用户所有对象，被解释为\dtvsE, E代表外部表
    \dt   查看表
    \ds
    \dv   查看视图
    \df   查看函数
    \du+
    \dp+
    \o
    \timing
    \conninfo
    \h
    \?
    \!
    \q    退出
```

## 角色和权限

一个角色几乎与一个用户相同，角色不能登录
最重要的角色是postgres，具有超级用户属性

### 角色操作

``` SQL
postgres=# CREATE USER my_user;

postgres=# CREATE ROLE my_role;
postgres=# DROP   ROLE my_role;

# 可以从 shell 命令行调用
➜  createuser name
➜  ropuser name

# 给角色登录权限
postgres=# ALTER ROLE my_role WITH login;
```

### 查询角色
``` SQL
postgres=# SELECT rolname FROM pg_roles;
或使用元命令
postgres=# \du
```

### 查询权限

``` SQL
postgres=# \dp+
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

也可以使用SQL查到权限输出

``` SQL
    SELECT pu.usename, pc.tbl, pc.privilege_typ
           FROM pg_user pu JOIN (
                SELECT oid::regclass tbl, (aclexplode(relacl)).grantee,
                    (aclexplode(relacl)).privilege_type FROM pg_class
                WHERE
                relname='emp'
           ) pc ON pc.grantee=pu.usesysid;
```
