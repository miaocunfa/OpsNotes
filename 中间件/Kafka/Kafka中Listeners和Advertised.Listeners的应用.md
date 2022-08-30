---
title: "Kafka 中 Listeners 和 Advertised.Listeners 的应用"
date: "2019-12-03"
categories:
    - "技术"
tags:
    - "kafka"
    - "消息队列"
toc: false
original: false
draft: false
---

## 介绍区别

在公司内网部署kafka集群只需要用到listeners，所以一直也不用管advertised.listeners是做啥的，刚开始有查过，因为经验不足，始终理解的不够，后来发现在docker部署和云服务器上部署，内外网需要作区分时，发挥了它强大的作用。

那么先看看文字类描述：

``` zsh
listeners: 学名叫监听器，其实就是告诉外部连接者要通过什么协议访问指定主机名和端口开放的 Kafka 服务。
advertised.listeners：和listeners相比多了个advertised。Advertised的含义表示宣称的、公布的，就是说这组监听器是Broker用于对外发布的。
```

比如说：

``` zsh
listeners: INSIDE://172.17.0.10:9092,OUTSIDE://172.17.0.10:9094
advertised.listeners: INSIDE://172.17.0.10:9092,OUTSIDE://<公网 ip>:端口

kafka_listener_security_protocol_map: "INSIDE:SASL_PLAINTEXT,OUTSIDE:SASL_PLAINTEXT"
kafka_inter_broker_listener_name: "INSIDE"
```

advertised_listeners监听器会注册在zookeeper中;

当我们对172.17.0.10:9092请求建立连接，kafka服务器会通过zookeeper中注册的监听器，找到INSIDE监听器，然后通过listeners中找到对应的通讯ip和端口;

同理，当我们对 **<公网ip>:端口** 请求建立连接，kafka服务器会通过zookeeper中注册的监听器，找到OUTSIDE监听器，然后通过listeners中找到对应的通讯ip和端口172.17.0.10:9094;

总结：advertised_listeners是对外暴露的服务端口，真正建立连接用的是listeners。

## 什么场景用到

### 只有内网

比如在公司搭建的kafka集群，只有内网中的服务可以用，这种情况下，只需要用listeners就行

``` zsh
listeners: <协议名称>://<内网ip>:<端口>
```

#### 例如

``` zsh
listeners: SASL_PLAINTEXT://192.168.0.4:9092
```

### 内外网

在docker中或者在类似阿里云主机上部署kafka集群，这种情况下是需要用到 advertised_listeners。

以docker为例：

``` zsh
listeners: INSIDE://0.0.0.0:9092,OUTSIDE://0.0.0.0:9094
advertised_listeners: INSIDE://localhost:9092,OUTSIDE://<宿主机ip>:<宿主机暴露的端口>

kafka_listener_security_protocol_map: "INSIDE:SASL_PLAINTEXT,OUTSIDE:SASL_PLAINTEXT"
kafka_inter_broker_listener_name: "INSIDE"
```

> 参考文档:  
> 1、[kafka listeners 和 advertised.listeners 的应用](https://segmentfault.com/a/1190000020715650)
