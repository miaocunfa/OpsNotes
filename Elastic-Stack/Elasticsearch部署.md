---
title: "Elasticsearch部署"
date: "2019-12-27"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "服务部署"
toc: false
original: true
---

## 一、环境准备

在elastic官网下载最新版的elasticsearch安装包
> <https://www.elastic.co/cn/downloads/past-releases>

### 1.1、创建用户

自elasticsearch x.x版本开始，为了安全已经不能使用root用户启动

``` bash
$ useradd es
```

## 二、部署配置

### 2.1、软件包准备

``` bash
$ tar -zxvf elasticsearch-7.5.1-linux-x86_64.tar.gz
$ chown -R es:es elasticsearch-7.5.1 # 将目录属主属组修改给es用户
```

### 2.2、目录结构介绍

``` bash
$ cd elasticsearch-7.5.1
$ ll
total 556
drwxr-xr-x.  2 es es   4096 Dec 16 18:01 bin            # 二进制程序
drwxr-xr-x.  2 es es    178 Dec 27 05:21 config         # 配置文件
drwxrwxr-x.  3 es es     19 Dec 27 04:46 data           # es数据目录
drwxr-xr-x.  9 es es    107 Dec 16 18:01 jdk            # jdk目录
drwxr-xr-x.  3 es es   4096 Dec 16 18:01 lib            # lib库
-rw-r--r--.  1 es es  13675 Dec 16 17:54 LICENSE.txt
drwxr-xr-x.  2 es es   4096 Dec 27 05:21 logs           # 日志文件
drwxr-xr-x. 38 es es   4096 Dec 16 18:01 modules        # 模块
-rw-r--r--.  1 es es 523209 Dec 16 18:01 NOTICE.txt
drwxr-xr-x.  2 es es      6 Dec 16 18:01 plugins        # 插件
-rw-r--r--.  1 es es   8499 Dec 16 17:54 README.textile
```

### 2.3、配置文件

``` conf
$ cat elasticsearch.yml | grep -v ^# | grep -v ^$
cluster.name: mytest
node.name: mytest-1
path.data: data
path.logs: logs
path.repo: repository
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["192.168.100.217"]
cluster.initial_master_nodes: ["mytest-1"]
```

## 三、启动验证

``` bash
$ ./elasticsearch -d
$ curl localhost:9200
{
  "name" : "mytest-1",
  "cluster_name" : "mytest",
  "cluster_uuid" : "liqXd2BMS0i6qfoTHKx9tA",
  "version" : {
    "number" : "7.5.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "3ae9ac9a93c95bd0cdc054951cf95d88e1e18d96",
    "build_date" : "2019-12-16T22:57:37.835892Z",
    "build_snapshot" : false,
    "lucene_version" : "8.3.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```