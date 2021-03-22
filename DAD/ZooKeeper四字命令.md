---
title: "ZooKeeper四字命令"
date: "2021-03-22"
categories:
    - "技术"
tags:
    - "ZooKeeper"
    - "分布式架构"
toc: false
original: false
draft: true
---

ZooKeeper中有一系列的命令可以查看服务器的运行状态，它们的长度通常都是4个英文字母，因此又被称之为“四字命令”。

常用命令：
使用方式： `echo {command} | nc localhost 2181`

## conf

conf命令用于输出ZooKeeper服务器运行时使用的基本配置信息，包括clientPort、dataDir和tickTime等。

``` zsh
➜  echo conf | nc localhost 2181
clientPort=2181
dataDir=/usr/local/zookeeper/data/version-2
dataLogDir=/usr/local/zookeeper/data/logs/version-2
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=0
initLimit=10
syncLimit=5
electionAlg=3
electionPort=3888
quorumPort=2888
peerType=0
```

## cons

cons命令用于输出当前这台服务器上所有客户端连接的详细信息，包括每个客户端的客户端IP、会话ID和最后一次与服务器交互的操作类型等。

``` zsh
➜  echo cons | nc localhost 2181
 /192.168.189.171:33856[1](queued=0,recved=721282,sent=815217,sid=0x700c454730002,lop=PING,est=1615547349590,to=40000,lcxid=0xa23d2,lzxid=0xffffffffffffffff,lresp=45549580813,llat=0,minlat=0,avglat=0,maxlat=31)
 /127.0.0.1:34056[0](queued=0,recved=1,sent=0)

```

## stat

stat命令用于获取ZooKeeper服务器的运行时状态信息，包括基本的ZooKeeper版本、打包信息、运行时角色、集群数据节点个数等信息。

``` zsh
➜  echo stat | nc localhost 2181
Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Clients:
 /192.168.189.171:33856[1](queued=0,recved=721324,sent=815265)
 /127.0.0.1:34104[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/42
Received: 6899197
Sent: 7793039
Connections: 2
Outstanding: 0
Zxid: 0x1000e7c15
Mode: follower
Node count: 143
```

## mntr

mntr命令用于输出比stat命令更为详尽的服务器统计信息，包括请求处理的延迟情况、服务器内存数据库大小和集群的数据同步情况。

``` zsh
➜  echo mntr | nc localhost 2181
zk_version      3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
zk_avg_latency  0
zk_max_latency  42
zk_min_latency  0
zk_packets_received     6899199
zk_packets_sent 7793041
zk_num_alive_connections        2
zk_outstanding_requests 0
zk_server_state follower
zk_znode_count  143
zk_watch_count  252
zk_ephemerals_count     18
zk_approximate_data_size        16885
zk_open_file_descriptor_count   34
zk_max_file_descriptor_count    65535
zk_fsync_threshold_exceed_count 0
```

## crst

crst命令是一个功能性命令，用于重置所有的客户端连接统计信息。

## dump

dump命令用于输出当前集群的所有会话信息，包括这些会话的会话ID，以及每个会话创建的临时节点等信息。

## envi

envi命令用于输出ZooKeeper所在服务器运行时的环境信息，包括os.version、java.version和user.home等。

## ruok

ruok命令用于输出当前ZooKeeper服务器是否正在运行。该命令的名字非常有趣，其谐音正好是“Are you ok”。执行该命令后，如果当前ZooKeeper服务器正在运行，那么返回“imok”，否则没有任何响应输出。

``` zsh
➜  echo ruok | nc localhost 2181
imok
```

请注意，ruok命令的输出仅仅只能表明当前服务器是否正在运行，准确地讲，只能说明2181端口打开着，同时四字命令执行流程正常，但是不能代表ZooKeeper服务器是否运行正常。在很多时候，如果当前服务器无法正常处理客户端的读写请求，甚至已经无法和集群中的其他机器进行通信，ruok命令依然返回“imok”。

## srvr

srvr命令和stat命令的功能一致，唯一的区别是srvr不会将客户端的连接情况输出，仅仅输出服务器的自身信息。

``` zsh
➜  echo srvr | nc localhost 2181
Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Latency min/avg/max: 0/0/42
Received: 6899270
Sent: 7793118
Connections: 2
Outstanding: 0
Zxid: 0x1000e7c19
Mode: follower
Node count: 143
```

## srst

srst命令是一个功能行命令，用于重置所有服务器的统计信息。

## wchs

wchs命令用于输出当前服务器上管理的Watcher的概要信息。

``` zsh
➜  echo wchs | nc localhost 2181
1 connections watching 126 paths
Total watches:126
```

## wchc

wchc命令用于输出当前服务器上管理的Watcher的详细信息，以会话为单位进行归组，同时列出被该会话注册了Watcher的节点路径。

## wchp

wchp命令和wchc命令非常类似，也是用于输出当前服务器上管理的Watcher的详细信息，不同点在于wchp命令的输出信息以节点路径为单位进行归组。

> 原文作者: 十毛tenmao  
> 原文链接: https://www.jianshu.com/p/c96c9f8c2433?from=timeline
> 