---
title: "Zabbix 监控 Kafka"
date: "2021-03-19"
categories:
    - "技术"
tags:
    - "Zabbix"
    - "Kafka"
    - "ZooKeeper"
toc: false
original: true
draft: true
---

## 更新记录

| 时间       | 内容                      |
| ---------- | ------------------------- |
| 2021-03-19 | 初稿                      |
| 2021-03-22 | 增加 ZooKeeper 参数检测脚本 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| Zabbix server | 4.0.21  |
| Zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |
| Ncat          | 7.50    |
| ZooKeeper     | 3.4.14  |

## 准备工作

我们是基于 `nc` 来获取 `Zookeeper` 状态，所以先将环境准备好。

``` zsh
➜  yum install -y nc
```

我们尝试使用 `nc` 来获取一下 `Zookeeper` 的状态

``` zsh
# ruok 意思是 are you ok？
➜  echo ruok | nc 127.0.0.1 2181
imok
# 这个返回也是挺有意思的，i'm ok
```

再来看一下能获取的其他状态

``` zsh
➜  echo mntr | nc 127.0.0.1 2181
zk_version      3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
zk_avg_latency  0
zk_max_latency  42
zk_min_latency  0
zk_packets_received     6662063
zk_packets_sent 7525029
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

➜  echo srvr | nc 127.0.0.1 2181
Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Latency min/avg/max: 0/0/42
Received: 6662106
Sent: 7525078
Connections: 2
Outstanding: 0
Zxid: 0x1000e2bb1
Mode: follower
Node count: 143
```

## ZooKeeper监控要点

``` txt
内存使用量                        ZooKeeper应当完全运行在内存中，不能使用到SWAP。Java Heap大小不能超过可用内存。
Swap使用量                       使用Swap会降低ZooKeeper的性能，设置vm.swappiness = 0
网络带宽占用                      如果发现ZooKeeper性能降低关注下网络带宽占用情况和丢包情况，通常情况下ZooKeeper是20%写入80%读入
磁盘使用量                        ZooKeeper数据目录使用情况需要注意
磁盘I/O                          ZooKeeper的磁盘写入是异步的，所以不会存在很大的I/O请求，如果ZooKeeper和其他I/O密集型服务公用应该关注下磁盘I/O情况
zk_avg/min/max_latency           响应一个客户端请求的时间，建议这个时间大于10个Tick就报警
zk_outstanding_requests          排队请求的数量，当ZooKeeper超过了它的处理能力时，这个值会增大，建议设置报警阀值为10
zk_packets_received              接收到客户端请求的包数量
zk_packets_sent                  发送给客户单的包数量，主要是响应和通知
zk_max_file_descriptor_count     最大允许打开的文件数，由ulimit控制
zk_open_file_descriptor_count    打开文件数量，当这个值大于允许值得85%时报警
Mode                             运行的角色，如果没有加入集群就是standalone,加入集群式follower或者leader
zk_followers                     leader角色才会有这个输出,集合中follower的个数。正常的值应该是集合成员的数量减1
zk_pending_syncs                 leader角色才会有这个输出，pending syncs的数量
zk_znode_count                   znodes的数量
zk_watch_count                   watches的数量
Java Heap Size                   ZooKeeper Java进程的
```

## Zabbix Agent

### 检测ZooKeeper状态

``` zsh
# 检测 状态
➜  vim /etc/zabbix/scripts/zookeeper_check.sh
#!/bin/bash
zk=$(echo ruok | nc 127.0.0.1 2181)
if [[ "$zk" == "imok" ]]; then
    echo 1
else
    echo 0
fi
```

### 检测ZooKeeper参数

``` zsh
# 检测 mntr
➜  vim /etc/zabbix/scripts/zookeeper_mntr.sh
#!/bin/bash
para=$1
echo mntr | nc localhost 2181 | grep $para | awk '{print $2}'

# 检测 srvr
➜  vim /etc/zabbix/scripts/zookeeper_srvr.sh
#!/bin/bash
para=$1
echo srvr | nc localhost 2181 | grep $para | awk '{print $2}'
```

### 配置文件

``` zsh
# 配置文件
➜  vim /etc/zabbix/zabbix_agentd.d/zookeeper.conf
UserParameter=zookeeper.status, /bin/sh /etc/zabbix/scripts/zookeeper_check.sh
UserParameter=zookeeper.mntr.[*], /bin/sh /etc/zabbix/scripts/zookeeper_mntr.sh $1
UserParameter=zookeeper.srvr.[*], /bin/sh /etc/zabbix/scripts/zookeeper_srvr.sh $1
```

## Zabbix Server

> 参考文档：
> [1] [Zabbix监控Zookeeper健康状况](https://www.cnblogs.com/wjoyxt/p/6738437.html)  
>