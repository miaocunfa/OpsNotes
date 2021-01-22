---
title: "使用 Patroni 的 REST API 管理 Postgre集群"
date: "2020-08-13"
categories:
    - "技术"
tags:
    - "Postgre"
    - "Patroni"
toc: false
original: false
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-13 | 初稿 |

## 版本信息

| Server     | Version |
| ---------- | ------- |
| PostgreSQL | 10.10   |
| Patroni    | 1.6.5   |

## 一、配置节点

### 1.1、查看配置

``` zsh
# 查看 Postgre 的配置
➜  curl -s http://localhost:8008/config | jq .
{
  "ttl": 30,
  "loop_wait": 10,
  "retry_timeout": 10,
  "maximum_lag_on_failover": 1048576,
  "postgresql": {
    "use_pg_rewind": true,
    "parameters": null
  }
}
```

### 1.2、修改配置

PATCH /config

``` zsh
# 修改 最大连接数 并查看修改后的配置
➜  curl -s -XPATCH -d \
        '{"postgresql":{"parameters":{"max_connections":"200"}}}' \
        http://localhost:8008/config | jq .

{
  "ttl": 30,
  "loop_wait": 10,
  "retry_timeout": 10,
  "maximum_lag_on_failover": 1048576,
  "postgresql": {
    "use_pg_rewind": true,
    "parameters": {
      "max_connections": "200"
    }
  }
}

# 在我们修改 postgre的配置后，pending_restart标志 会为true
➜  curl -s http://localhost:8008/patroni| jq '.'
{
  "state": "running",
  "postmaster_start_time": "2020-08-06 18:37:49.535 CST",
  "role": "master",
  "server_version": 100013,
  "cluster_unlocked": false,
  "xlog": {
    "location": 384199064
  },
  "timeline": 1,
  "replication": [
    {
      "usename": "rep",
      "application_name": "ty-db2",
      "client_addr": "192.168.0.207",
      "state": "streaming",
      "sync_state": "async",
      "sync_priority": 0
    },
    {
      "usename": "rep",
      "application_name": "ty-db3",
      "client_addr": "192.168.0.100",
      "state": "streaming",
      "sync_state": "async",
      "sync_priority": 0
    }
  ],
  "database_system_identifier": "6857818384330525938",
  "pending_restart": true,
  "patroni": {
    "version": "1.6.5",
    "scope": "pgcluster"
  }
}
```

## 二、重启

### 3.1、REST API 重启

POST /restart

实测使用 REST API 重启速度更快

在重启时可以指定条件:

- restart_pending：布尔值，如果设置为true，Patroni则仅在`pending_restart`标志位挂起时才会重新启动PostgreSQL，以便在PostgreSQL配置中应用某些更改。
- role：仅当节点的当前角色与POST请求中的角色匹配时，才执行重新启动。
- postgres_version：仅当当前postgres版本小于POST请求中指定的版本时，才执行重新启动。
- timeout：PostgreSQL开始接受连接之前我们应该等待多长时间。覆盖master_start_timeout。
- schedule：带有时区的时间戳，计划将来的某个地方重新启动。

``` zsh


# 重启 postgre集群
➜  curl -s -XPOST -d '{"restart_pending":"true"}' http://localhost:8008/restart
restarted successfully

# pending_restart 标志位消失
➜  curl -s http://localhost:8008/patroni| jq '.'
{
  "state": "running",
  "postmaster_start_time": "2020-08-13 19:54:53.171 CST",
  "role": "master",
  "server_version": 100013,
  "cluster_unlocked": false,
  "xlog": {
    "location": 384199288
  },
  "timeline": 1,
  "replication": [
    {
      "usename": "rep",
      "application_name": "ty-db2",
      "client_addr": "192.168.0.207",
      "state": "streaming",
      "sync_state": "async",
      "sync_priority": 0
    },
    {
      "usename": "rep",
      "application_name": "ty-db3",
      "client_addr": "192.168.0.100",
      "state": "streaming",
      "sync_state": "async",
      "sync_priority": 0
    }
  ],
  "database_system_identifier": "6857818384330525938",
  "patroni": {
    "version": "1.6.5",
    "scope": "pgcluster"
  }
}

# 使用 psql 登录验证修改是否生效
➜  psql -h ty-db1
Password:
psql (10.13)
Type "help" for help.

postgres=# show max_connections;
 max_connections
-----------------
 200
(1 row)

# ty-db2节点也生效了，所以使用REST API所做的修改在所有节点都生效
➜  psql -h ty-db2
Password:
psql (10.13)
Type "help" for help.

postgres=# show max_connections ;
 max_connections
-----------------
 200
(1 row)
```

### 3.2、使用 patronictl restart

``` zsh
# 重启 postgre集群
➜  patronictl -d localhost:2379 restart pgcluster
2020-08-13 19:54:26,597 - WARNING - Retrying (Retry(total=0, connect=None, read=None, redirect=0, status=None)) after connection broken by 'NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f0357b8a3c8>: Failed to establish a new connection: [Errno 111] Connection refused',)': /v2/machines
2020-08-13 19:54:26,598 - ERROR - Failed to get list of machines from http://[::1]:2379/v2: MaxRetryError("HTTPConnectionPool(host='::1', port=2379): Max retries exceeded with url: /v2/machines (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x7f0357b8a860>: Failed to establish a new connection: [Errno 111] Connection refused',))",)
+ Cluster: pgcluster (6857818384330525938) -----------+-----------------+
| Member |  Host  |  Role  |  State  | TL | Lag in MB | Pending restart |
+--------+--------+--------+---------+----+-----------+-----------------+
| ty-db1 | ty-db1 | Leader | running |  1 |           |        *        |
| ty-db2 | ty-db2 |        | running |  1 |         0 |        *        |
| ty-db3 | ty-db3 |        | running |  1 |         0 |        *        |
+--------+--------+--------+---------+----+-----------+-----------------+
When should the restart take place (e.g. 2020-08-13T20:54)  [now]: now
Are you sure you want to restart members ty-db1, ty-db2, ty-db3? [y/N]: y
Restart if the PostgreSQL version is less than provided (e.g. 9.5.2)  []:
Success: restart on member ty-db1
Success: restart on member ty-db2
Success: restart on member ty-db3
```

## 三、重新初始化

POST /reinitialize

在指定节点上重新初始化PostgreSQL数据目录。只允许在副本上执行它。调用后，它将删除数据目录并启动pg_basebackup或其他替代副本创建方法。

如果Patroni处于试图恢复（重新启动）失败的Postgres的循环中，则调用可能会失败。为了克服这个问题，可以 `{"force":true}` 在请求正文中指定。

还可以使用 `patronictl reinit`

``` zsh
➜  curl -s -XPOST http://localhost:8008/reinitialize
```

> 参考链接：
> 1、[patroni官方手册 -- REST API](https://patroni.readthedocs.io/en/latest/rest_api.html)  
>