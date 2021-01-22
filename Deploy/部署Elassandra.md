---
title: "部署使用elassandra"
date: "2020-01-02"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "Cassandra"
    - "elassandra"
    - "搜索引擎"
    - "服务部署"
toc: false
indent: false
original: true
draft: false
---

## 一、环境准备

``` bash
$ wget https://github.com/strapdata/elassandra/releases/download/v6.2.3.22/elassandra-6.2.3.22.tar.gz
$ tar -zxvf elassandra-6.2.3.22.tar.gz
$ useradd elassandra
$ chown -R elassandra:elassandra elassandra-6.2.3.22
```

## 二、配置部署

### 2.1、目录结构

``` bash
$ su - elassandra               #切换用户
$ cd /opt/elassandra-6.2.3.22   #进入工作路径
$ ls -rtl
total 264
-rw-r--r--.  1 elassandra elassandra  12319 Dec 11 17:51 README.md
-rw-r--r--.  1 elassandra elassandra  11358 Dec 11 17:51 LICENSE.txt
-rw-r--r--.  1 elassandra elassandra  21612 Dec 11 17:51 CHANGES.txt
-rw-r--r--.  1 elassandra elassandra 194935 Dec 11 18:19 NOTICE.txt
drwxr-xr-x.  2 elassandra elassandra      6 Dec 11 18:20 plugins
drwxr-xr-x.  3 elassandra elassandra     94 Dec 11 18:20 pylib
drwxr-xr-x.  4 elassandra elassandra    135 Dec 11 18:20 tools
drwxr-xr-x. 16 elassandra elassandra   4096 Dec 11 18:20 modules
drwxr-xr-x.  4 elassandra elassandra   4096 Jan  2 00:39 lib
drwxr-xr-x.  2 elassandra elassandra   4096 Jan  2 00:39 bin
drwxr-xr-x.  3 elassandra elassandra   4096 Jan  2 02:30 conf
drwxr-xr-x.  6 elassandra elassandra     68 Jan  2 02:33 data
drwxr-xr-x.  2 elassandra elassandra     48 Jan  2 03:19 logs
```

### 2.2、修改limits.conf文件

``` zsh
$ vi /etc/security/limits.conf
# allow user 'elassandra' mlockall
elassandra soft memlock unlimited
elassandra hard memlock unlimited
```

### 2.3、修改.bash_profile文件

``` zsh
$ vi ~/.bash_profile
export CASSANDRA_HOME=/opt/elassandra-6.2.3.22
export CASSANDRA_CONF=/opt/elassandra-6.2.3.22/conf
$ source ~/.bash_profile
```

### 2.4、Cassandra配置文件

``` zsh
$ cat cassandra.yaml | grep -v ^# | grep -v ^$
cluster_name: 'Test Cluster'
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "192.168.100.217"
listen_address: 192.168.100.217
rpc_address: 192.168.100.217
endpoint_snitch: GossipingPropertyFileSnitch
```

### 2.5、删除cassandra拓扑

该文件存在时GossipingPropertyFileSnitch始终加载cassandra-topology.properties

``` zsh
$ mv cassandra-topology.properties topology
```

## 三、启动验证

### 3.1、启动

``` bash
# -e 选项启动 elasticsearch, 否则只启动 cassandra
# -f 选项启动在前台, 否则启动在后台
$ bin/cassandra -e -f
```

### 3.2、验证

``` bash
$ bin/nodetool status
Datacenter: DC1
===============
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address          Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.100.217  70.86 KiB  8            100.0%            3eca39ee-614e-44be-8dc3-24a57e258588  r1
```

> 参考文档：  
> 1、https://www.strapdata.com/blog/?__hstc=45866619.604d7d24da3130719d6ad13e1d96868c.1577946442157.1577946442157.1577946442157.1&__hssc=45866619.1.1577946442157&__hsfp=156548688&_ga=2.21459963.1978597677.1577946441-1461110499.1577946441  
> 2、https://medium.com/rahasak/deploy-multi-data-center-elassandra-cluster-c6cb4abf50d1  
> 3、http://opensourceforu.com/2017/07/elassandra-to-leverage-huge-data-stack/  
>