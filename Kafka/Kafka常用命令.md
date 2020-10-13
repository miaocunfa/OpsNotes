---
title: "Kafka常用命令"
date: "2020-10-13"
categories:
    - "技术"
tags:
    - "Kafka"
    - "消息队列"
    - "常用命令"
toc: false
original: true
---

## 一、topic

### 1.1、列表

``` zsh
./kafka-topics.sh --zookeeper DB3:2181 --list
__consumer_offsets
info_goods
info_topic
info_topic-1
kafakaTest
...
```

### 1.2、描述

``` zsh
./kafka-topics.sh --zookeeper DB3:2181 --describe --topic info_topTopic:info_topic-1    PartitionCount:3    ReplicationFactor:1 Configs:
    Topic: info_topic-1 Partition: 0    Leader: 1   Replicas: 1 Isr: 1
    Topic: info_topic-1 Partition: 1    Leader: 3   Replicas: 3 Isr: 3
    Topic: info_topic-1 Partition: 2    Leader: 1   Replicas: 1 Isr: 1
```

## 记录

### 删除

``` zsh
./kafka-delete-records.sh
This tool helps to delete records of the given partitions down to the specified offset.
Option                                 Description
------                                 -----------
--bootstrap-server <String: server(s)  REQUIRED: The server to connect to.
  to use for bootstrapping>
--command-config <String: command      A property file containing configs to
  config property file path>             be passed to Admin Client.
--help                                 Print usage information.
--offset-json-file <String: Offset     REQUIRED: The JSON file with offset
  json file path>                        per partition. The format to use is:
                                       {"partitions":
                                         [{"topic": "foo", "partition": 1,
                                         "offset": 1}],
                                        "version":1
                                       }
--version                              Display Kafka version.
```
