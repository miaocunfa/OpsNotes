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

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-05 | 初稿 |

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
# 每台主机
➜  mkdir -p /opt/etcd-scripts

➜  vim /opt/etcd-scripts/start_etcd.sh
etcd --name etcd_db1 \
  --initial-advertise-peer-urls http://192.168.0.106:2380 \
  --listen-peer-urls http://192.168.0.106:2380 \
  --listen-client-urls http://192.168.0.106:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.106:2379 \
  --initial-cluster-token etcd-cluster-db \
  --initial-cluster etcd_db1=http://192.168.0.106:2380,etcd_db2=http://192.168.0.207:2380,etcd_db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2

➜  vim /opt/etcd-scripts/start_etcd.sh
etcd --name etcd_db2 \
  --initial-advertise-peer-urls http://192.168.0.207:2380 \
  --listen-peer-urls http://192.168.0.207:2380 \
  --listen-client-urls http://192.168.0.207:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.207:2379 \
  --initial-cluster-token etcd-cluster-db \
  --initial-cluster etcd_db1=http://192.168.0.106:2380,etcd_db2=http://192.168.0.207:2380,etcd_db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2

➜  vim /opt/etcd-scripts/start_etcd.sh
etcd --name etcd_db3 \
  --initial-advertise-peer-urls http://192.168.0.100:2380 \
  --listen-peer-urls http://192.168.0.100:2380 \
  --listen-client-urls http://192.168.0.100:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://192.168.0.100:2379 \
  --initial-cluster-token etcd-cluster-db \
  --initial-cluster etcd_db1=http://192.168.0.106:2380,etcd_db2=http://192.168.0.207:2380,etcd_db3=http://192.168.0.100:2380 \
  --initial-cluster-state new \
  --enable-v2
```

### 1.3、启动

``` zsh
➜  cd /opt/etcd-scripts
➜  ./start_etcd.sh > etcd-cluster-db.log 2>&1 &

# 查看 etcd 集群状态
➜  etcdctl member list
1fcdb0fb895ecd29: name=etcd_db3 peerURLs=http://192.168.0.100:2380 clientURLs=http://192.168.0.100:2379 isLeader=false
4e1f2488a171bb23: name=etcd_db2 peerURLs=http://192.168.0.207:2380 clientURLs=http://192.168.0.207:2379 isLeader=false
75e901ebd206ed11: name=etcd_db1 peerURLs=http://192.168.0.106:2380 clientURLs=http://192.168.0.106:2379 isLeader=true
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

### 2.2、初始化库

``` zsh
➜  mkdir -p /home/postgres
➜  usermod -d /home/postgres postgres
➜  chown -R postgres:postgres /home/postgres

➜  su - postgres
➜  cp /var/lib/pgsql/.bash_profile ~
➜  vi .bash_profile
export PGHOME=/usr/pgsql-10
export LD_LBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH
➜  source .bash_profile

# 初始化数据库
➜  initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/pgsql/10/data
```

### 2.3、配置文件

``` zsh
cd /var/lib/pgsql/10/data
cp postgresql.conf postgresql.conf.bak
vim postgresql.conf
```

## 三、Patroni

### 3.1、安装

``` zsh
➜  yum install -y python3 pip3 python3-devel
➜  pip3 install psycopg2-binary -i https://mirrors.aliyun.com/pypi/simple/
➜  pip3 install patroni -i https://mirrors.aliyun.com/pypi/simple/
```

### 3.2、配置文件

包括全局参数、restapi模块参数、etcd模块参数、bootstrap启动参数、postgresql模块参数，主要参数解释如下:

scope: 标记cluster名称，同 postgresql.conf 的 cluster_name 参数，二级目录名: /<namespace>/<scope>/config。
namespace: 一级目录名: /<namespace>/<scope>/config。
name: patroni节点名称。
更多参数解释详见: YAML Configuration Settings。

ydtf02、ydtf03的参数大部分和ydtf01相同，仅需修改全局参数name、restapi模块的listen和connect_address参数、etcd模块的host参数，以及postgresql模块的connect_address参数。

``` zsh
scope: pgcluster
name: postgres212

restapi:
  listen: 0.0.0.0:8008
  connect_address: 192.168.100.212:8008

etcd:
  hosts: 192.168.100.211:2379 ,192.168.100.212:2379,192.168.100.213:2379

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
  - host replication replicator 127.0.0.1/32 md5
  - host replication rep 192.168.100.211/0 md5
  - host replication rep 192.168.100.212/0 md5
  - host replication rep 192.168.100.213/0 md5
  - host all all 0.0.0.0/0 md5

  users:
    admin:
      password: admin
      options:
        - createrole
        - createdb

postgresql:
  listen: 0.0.0.0:5432
  connect_address: 192.168.100.212:5432
  data_dir: /var/lib/pgsql/10/data
  bin_dir: /usr/pgsql-10/bin
  pgpass: /tmp/pgpass0
  authentication:
    replication:
      username: rep
      password: test%123
    superuser:
      username: postgres
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
