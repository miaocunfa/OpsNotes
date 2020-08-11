---
title: "使用 Patroni + etcd 构建高可用 PostgreSQL 集群"
date: "2020-08-05"
categories:
    - "技术"
tags:
    - "Postgre"
    - "etcd"
    - "Patroni"
toc: false
original: false
---

## 更新记录

| 时间       | 内容                                                                                                                                                                    |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2020-08-05 | 初稿                                                                                                                                                                    |
| 2020-08-06 | 1、etcd 注册 systemd </br> 2、patroni 启动脚本 && 添加 patroni 配置文件解析 </br> 3、增加错误部分 </br> 4、增加运行时信息解析 </br> 5、移除postgres用户部分为一篇新Blog |
| 2020-08-11 | 修改 patroni 字段说明                                                                                                                                                   |

## 环境

| Server  | Version |
| ------- | ------- |
| patron  | 1.6.5   |
| etcd    | 3.3.11  |
| postgre | 10.13   |
| python  | 3.6.8   |

## 一、etcd

### 1.1、安装

``` zsh
➜  yum install -y etcd
```

### 1.2、配置文件

``` zsh
# 每台主机都执行
➜  mkdir -p /opt/pg-HA/etcd

# etcd默认API为v3版本，Patroni 现阶段不支持 v3 API，因此在etcd集群中增加--enable-v2属性
➜  vim /opt/pg-HA/etcd/start_etcd.sh
etcd --name pg-etcd-db1 \
  --initial-advertise-peer-urls http://192.168.0.106:2380 \
  --listen-peer-urls http://192.168.0.106:2380 \
  --listen-client-urls http://192.168.0.106:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.106:2379 \
  --initial-cluster-token pg-etcd-cluster \
  --initial-cluster pg-etcd-db1=http://192.168.0.106:2380,pg-etcd-db2=http://192.168.0.207:2380,pg-etcd-db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2

➜  vim /opt/pg-HA/etcd/start_etcd.sh
etcd --name pg-etcd-db2 \
  --initial-advertise-peer-urls http://192.168.0.207:2380 \
  --listen-peer-urls http://192.168.0.207:2380 \
  --listen-client-urls http://192.168.0.207:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.207:2379 \
  --initial-cluster-token pg-etcd-cluster \
  --initial-cluster pg-etcd-db1=http://192.168.0.106:2380,pg-etcd-db2=http://192.168.0.207:2380,pg-etcd-db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2

➜  vim /opt/pg-HA/etcd/start_etcd.sh
etcd --name pg-etcd-db3 \
  --initial-advertise-peer-urls http://192.168.0.100:2380 \
  --listen-peer-urls http://192.168.0.100:2380 \
  --listen-client-urls http://192.168.0.100:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.100:2379 \
  --initial-cluster-token pg-etcd-cluster \
  --initial-cluster pg-etcd-db1=http://192.168.0.106:2380,pg-etcd-db2=http://192.168.0.207:2380,pg-etcd-db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2
```

### 1.3、启动

``` zsh
➜  cd /opt/pg-HA/etcd
➜  chmod u+x start_etcd.sh
➜  ./start_etcd.sh > pg-etcd-cluster.log 2>&1 &

# 查看 etcd 集群状态
➜  etcdctl member list
9189cbf3a208e0c3: name=pg-etcd-db1 peerURLs=http://192.168.0.106:2380 clientURLs=http://192.168.0.106:2379 isLeader=false
b856c4d6d5c9da33: name=pg-etcd-db2 peerURLs=http://192.168.0.207:2380 clientURLs=http://192.168.0.207:2379 isLeader=false
bc130bda08a94509: name=pg-etcd-db3 peerURLs=http://192.168.0.100:2380 clientURLs=http://192.168.0.100:2379 isLeader=true
```

### 1.4、注册systemd Unit File

``` zsh
# Unit File
➜  vim /usr/lib/systemd/system/pg-etcd.service
[Unit]
Description=The etcd Server for postgre
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/pg-HA/etcd/start_etcd.sh > /opt/pg-HA/etcd/pg-etcd-cluster.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target

# 重载 systemd && 启动 etcd
➜  systemctl daemon-reload
➜  systemctl start pg-etcd
```

## 二、postgre

### 2.1、安装

``` zsh
➜  vim /etc/yum.repos.d/pg10.repo
[pgdg10]
name=PostgreSQL 10 $releasever - $basearch
baseurl=https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-$releasever-$basearch
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG

➜  yum makecache
➜  yum install -y postgresql10 postgresql10-server postgresql10-contrib
```

## 三、Patroni

Patroni（帕特罗尼）

### 3.1、安装

``` zsh
➜  yum install -y python3 pip3 python3-devel
➜  pip3 install psycopg2-binary -i https://mirrors.aliyun.com/pypi/simple/
➜  pip3 install patroni[etcd] -i https://mirrors.aliyun.com/pypi/simple/
```

### 3.2、配置文件

``` zsh
➜  mkdir -p /opt/pg-HA/patroni

➜  vim /opt/pg-HA/patroni/patroni_pg.yml
scope: pgcluster
# 按节点修改
name: ty-db1

restapi:
  # 按节点修改
  listen: 0.0.0.0:8008
  connect_address: ty-db1:8008

etcd:
  hosts: ty-db1:2379, ty-db2:2379, ty-db3:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      parameters:

  initdb:  
  - encoding: UTF8
  - data-checksums

  pg_hba:  
  - host replication rep 192.168.0.106/0 md5
  - host replication rep 192.168.0.207/0 md5
  - host replication rep 192.168.0.100/0 md5
  - host all all 0.0.0.0/0 md5

  users:
    admin:
      password: test%123
      options:
        - createrole
        - createdb
    rep:
      password: test%123
      options:
        - replication

postgresql:
  listen: 0.0.0.0:5432
  # 按节点修改
  connect_address: ty-db1:5432
  data_dir: /var/lib/pgsql/10/data
  bin_dir: /usr/pgsql-10/bin
  pgpass: /tmp/pgpass0
  authentication:
    replication:
      username: rep
      password: test%123
    superuser:
      username: admin
      password: test%123

  parameters:
    unix_socket_directories: '.'
    synchronous_commit: "remote_write"
    synchronous_standby_names: ""
    max_wal_senders: "100"
    wal_keep_segments: "0"
    wal_level: "logical"
    wal_log_hints: "off"

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
```

这是字段的说明：

- **scope**：集群的名称，可使用 `patronictl` 管理集群集群。所有节点值一。
- **name**：节点的名称，在集群中是唯一的。
- **restapi**：Patroni 有一个 REST API，`listen` 是监听地址。`connect_address` 是其他节点可以用来连接到该API的地址，因此这里的IP应该是可以从其他节点（通常是通过专用VLAN）到达此节点的IP。
- **etcd**：用于连接到etcd集群的配置。对于3节点的etcd群集，请使用 `hosts: IP1:Port1, IP2:Port, IP3:Port3`。
- **bootstrap**：创建 Patroni 集群时使用这些值。`postgresql.parameters` 下的值是实际的 `postgresql.conf` 配置参数。一些值（例如 `wal_level` 和 `max_wal_senders`）是流复制正常工作所必需的。
- **initdb**：当引导群集的第一个节点并且 PostgreSQL `数据目录不存在` 时，这些参数将用于调用 `initdb`。
- **pg_hba**：这个选项的值将添加至 Patroni 创建的数据库中的 `pg_hba.conf` 配置文件
- **users**：Patroni 创建此处指定的用户列表。然后 pg_hba 在 postgresql.authentication下面的部分中使用这些用户，允许 Patroni 登录到 Postgres 服务器。在这里，创建了用户`admin`（用于Patroni的管理员访问）和 `rep`（用于从备用数据库的复制访问）。
- **postgresql**：这个选项包含了 Patroni 创建 PostgreSQL 服务的大量信息。`connect_address` 配置得是可以访问Postgre服务的地址。`bin_dir` 是Postgre的程序目录，`data_dir` 配置了Postgre的数据存储目录，在使用Patroni初始化之前该目录需要为空。`authentication` 参数应引用我们在 `users` 部分中上面创建的有复制权限和管理权限的用户。

### 3.3、启动脚本

``` zsh
# 编写启动脚本
➜  vim /opt/pg-HA/patroni/start_patroni.sh
su - postgres -c "patroni /opt/pg-HA/patroni/patroni_pg.yml > /opt/pg-HA/patroni/patroni.log 2>&1 &"

# 添加执行权限
➜  chmod u+x /opt/pg-HA/patroni/start_patroni.sh
➜  chown -R postgres:postgres /opt/pg-HA/patroni    # 用于写入patroni日志文件

# 启动 patroni 以初始化 Postgre集群
➜  /opt/pg-HA/patroni/start_patroni.sh

# 待三节点都初始化完毕后，验证集群
➜  patronictl -d etcd://localhost:2379 list pgcluster
+ Cluster: pgcluster (6857818384330525938) -----------+
| Member |  Host  |  Role  |  State  | TL | Lag in MB |
+--------+--------+--------+---------+----+-----------+
| ty-db1 | ty-db1 | Leader | running |  1 |           |
| ty-db2 | ty-db2 |        | running |  1 |        16 |
| ty-db3 | ty-db3 |        | running |  1 |         0 |
+--------+--------+--------+---------+----+-----------+
```

## 四、运行时信息

### 4.1、etcd

``` zsh
# 获取所有key
➜  etcdctl ls -r --sort /
/service
/service/pgcluster
/service/pgcluster/config
/service/pgcluster/initialize
/service/pgcluster/leader
/service/pgcluster/members
/service/pgcluster/members/ty-db1
/service/pgcluster/members/ty-db2
/service/pgcluster/members/ty-db3
/service/pgcluster/optime
/service/pgcluster/optime/leader

# 获取 leader 的值
➜  etcdctl get /service/pgcluster/leader
ty-db1

# 获取节点信息，返回为JSON，使用jq格式化返回信息
➜  etcdctl get /service/pgcluster/members/ty-db1 | jq '.'
{
  "conn_url": "postgres://ty-db1:5432/postgres",
  "api_url": "http://ty-db1:8008/patroni",    # ty-db1节点，patroni的api地址
  "state": "running",
  "role": "master",
  "version": "1.6.5",
  "xlog_location": 67109128,
  "timeline": 1
}
```

### 4.2、patroni

访问 patroni的 API 获取信息

``` zsh
➜  curl http://ty-db1:8008/patroni | jq '.'
{
  "state": "running",                                         # 运行状态
  "postmaster_start_time": "2020-08-06 18:37:49.535 CST",
  "role": "master",                                           # 本节点 - 主节点
  "server_version": 100013,
  "cluster_unlocked": false,
  "xlog": {
    "location": 67110664                                      # 日志的位置
  },
  "timeline": 1,
  "replication": [                                            # 从节点信息
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
  "database_system_identifier": "6857818384330525938",       # 标识符
  "patroni": {
    "version": "1.6.5",
    "scope": "pgcluster"
  }
}

➜  curl http://ty-db2:8008/patroni | jq '.'
{
  "state": "running",                                        # 运行状态
  "postmaster_start_time": "2020-08-06 18:37:51.599 CST",
  "role": "replica",                                         # 本节点 - 复制节点
  "server_version": 100013,
  "cluster_unlocked": false,
  "xlog": {
    "received_location": 67110664,                           # 接受的日志 位置
    "replayed_location": 67110664,                           # 已经同步 位置
    "replayed_timestamp": null,
    "paused": false
  },
  "timeline": 1,
  "database_system_identifier": "6857818384330525938",       # 标识符
  "patroni": {
    "version": "1.6.5",
    "scope": "pgcluster"
  }
}
```

## 五、错误

### 5.1、patroni 包无法导入

``` log
2020-08-06 15:05:22,338 INFO: Failed to import patroni.dcs.consul
2020-08-06 15:05:22,339 INFO: Failed to import patroni.dcs.etcd
2020-08-06 15:05:22,340 INFO: Failed to import patroni.dcs.exhibitor
2020-08-06 15:05:22,341 INFO: Failed to import patroni.dcs.kubernetes
2020-08-06 15:05:22,341 INFO: Failed to import patroni.dcs.zookeeper
Traceback (most recent call last):
  File "/usr/local/bin/patroni", line 11, in <module>
    sys.exit(main())
  File "/usr/local/lib/python3.6/site-packages/patroni/__init__.py", line 235, in main
    return patroni_main()
  File "/usr/local/lib/python3.6/site-packages/patroni/__init__.py", line 197, in patroni_main
    patroni = Patroni(conf)
  File "/usr/local/lib/python3.6/site-packages/patroni/__init__.py", line 32, in __init__
    self.dcs = get_dcs(self.config)
  File "/usr/local/lib/python3.6/site-packages/patroni/dcs/__init__.py", line 106, in get_dcs
    Available implementations: """ + ', '.join(sorted(set(available_implementations))))
patroni.exceptions.PatroniException: 'Can not find suitable configuration of distributed configuration store\nAvailable implementations: '
```

错误解决

``` zsh
# 装了一个dnspython包成功解决
➜  pip3 install patroni[etcd] -i https://mirrors.aliyun.com/pypi/simple/
Successfully installed dnspython-2.0.0 python-etcd-0.4.5
```

### 5.2、没有找到 pg 复制用户

``` log
2020-08-06 15:22:12,853 ERROR: Can not fetch local timeline and lsn from replication connection
Traceback (most recent call last):
  File "/usr/local/lib/python3.6/site-packages/patroni/postgresql/__init__.py", line 685, in get_local_timeline_lsn_from_replication_connection
    with self.get_replication_connection_cursor(**self.config.local_replication_address) as cur:
  File "/usr/lib64/python3.6/contextlib.py", line 81, in __enter__
    return next(self.gen)
  File "/usr/local/lib/python3.6/site-packages/patroni/postgresql/__init__.py", line 679, in get_replication_connection_cursor
    with get_connection_cursor(**conn_kwargs) as cur:
  File "/usr/lib64/python3.6/contextlib.py", line 81, in __enter__
    return next(self.gen)
  File "/usr/local/lib/python3.6/site-packages/patroni/postgresql/connection.py", line 43, in get_connection_cursor
    with psycopg2.connect(**kwargs) as conn:
  File "/usr/local/lib64/python3.6/site-packages/psycopg2/__init__.py", line 127, in connect
    conn = _connect(dsn, connection_factory=connection_factory, **kwasync)
psycopg2.OperationalError: FATAL:  role "rep" does not exist
```

错误解决

``` zsh
# 先于 patroni 初始化数据库了，pg不应该启动，只用yum安装pg即可。仅使用 patroni 初始化数据库

# 清理原集群
➜  rm -rf /var/lib/pgsql/10/data    # 所有节点执行，清理pg的数据目录
➜  etcdctl rm -r /service           # 任意节点执行，清理etcd集群信息

# 重新初始化
➜  /opt/pg-HA/patroni/start_patroni.sh
```

### .3、只能初始化2个节点

``` zsh
➜  patronictl -d etcd://localhost:2379 list pgcluster
+ Cluster: pgcluster (6857789093999868370) -----------+
| Member |  Host  |  Role  |  State  | TL | Lag in MB |
+--------+--------+--------+---------+----+-----------+
| ty-db2 | ty-db2 | Leader | running |  1 |           |
| ty-db3 | ty-db3 |        | running |  1 |         0 |
+--------+--------+--------+---------+----+-----------+

➜  cat patroni.log
2020-08-06 16:57:25,166 INFO: Selected new etcd server http://192.168.0.100:2379
2020-08-06 16:57:25,170 INFO: No PostgreSQL configuration items changed, nothing to reload.
2020-08-06 16:57:25,185 CRITICAL: system ID mismatch, node ty-db1 belongs to a different cluster: 6857789093999868370 != 6857788489821861990
2020-08-06 16:57:25,678 INFO: Lock owner: ty-db2; I am ty-db1
```

清理集群数据，重新初始化

> 参考链接：  
> 1、[GETTING STARTED WITH PATRONI](https://www.opsdash.com/blog/postgres-getting-started-patroni.html)  
> 2、[如何删除etcd上的旧数据](https://www.mayanpeng.cn/archives/74.html)  
> 3、[patroni官方文档](https://patroni.readthedocs.io/en/latest/)  
>