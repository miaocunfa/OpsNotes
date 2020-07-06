---
title: "使用Loki进行日志监控和报警"
date: "2020-07-06"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "Loki"
    - "日志监控"
toc: false
indent: false
original: false
---

## 一、概述

对于生产环境以及一个有追求的运维人员来说，哪怕是毫秒级别的宕机也是不能容忍的。对基础设施及应用进行适当的日志记录和监控非常有助于解决问题，还可以帮助优化成本和资源，以及帮助检测以后可能会发生的一些问题。前面我们介绍了使用 EFK 技术栈来收集和监控日志，本文我们将使用更加轻量级的 Grafana Loki 来实现日志的监控和报警，一般来说 Grafana Loki 包括3个主要的组件：Promtail、Loki 和 Grafana（简称 PLG），最为关键的是如果你熟悉使用 Prometheus 的话，对于 Loki 的使用也完全没问题，因为他们的使用方法基本一致的，如果是在 Kubernetes 集群中自动发现的还具有相同的 Label 标签。

## 二、组件

在使用 Grafana Loki 之前，我们先简单介绍下他包含的3个主要组件。

### 2.1、Promtail

Promtail 是用来将容器日志发送到 Loki 或者 Grafana 服务上的日志收集工具，该工具主要包括发现采集目标以及给日志流添加上 Label 标签，然后发送给 Loki，另外 Promtail 的服务发现是基于 Prometheus 的服务发现机制实现的。

### 2.2、Loki

Loki 是一个受 Prometheus 启发的可以水平扩展、高可用以及支持多租户的日志聚合系统，使用了和 Prometheus 相同的服务发现机制，将标签添加到日志流中而不是构建全文索引。正因为如此，从 Promtail 接收到的日志和应用的 metrics 指标就具有相同的标签集。所以，它不仅提供了更好的日志和指标之间的上下文切换，还避免了对日志进行全文索引。

### 2.3、Grafana

Grafana 是一个用于监控和可视化观测的开源平台，支持非常丰富的数据源，在 Loki 技术栈中它专门用来展示来自 Prometheus 和 Loki 等数据源的时间序列数据。此外，还允许我们进行查询、可视化、报警等操作，可以用于创建、探索和共享数据 Dashboard，鼓励数据驱动的文化。

## 三、部署

为了方便部署 Loki 技术栈，我们这里使用更加方便的 Helm Chart 包进行安装，根据自己的需求修改对应的 Values 值。

``` zsh
# 首先添加loki的仓库地址
➜  helm repo add loki https://grafana.github.io/loki/charts
"loki" has been added to your repositories

# 更新仓库
➜  helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "loki" chart repository
Update Complete. ⎈ Happy Helming!⎈

# 由于我们之前已经安装了Grafana、Prometheus等组件
# 所以我们分别下载Promtail、Loki两个组件即可
➜ mkdir loki
➜ helm pull loki/loki -d loki
➜ helm pull loki/promtail -d loki

➜ cd loki; ll
total 16
-rw-r--r--. 1 root root 6383 Jul  6 17:41 loki-0.30.1.tgz
-rw-r--r--. 1 root root 6569 Jul  6 17:53 promtail-0.23.2.tgz
```

### 配置values

> 参考文章：
> 1、<https://hub.helm.sh/charts/loki/loki>  
> 2、<https://www.qikqiak.com/post/use-loki-monitor-alert/>  
> 3、<https://www.cnblogs.com/ssgeek/p/11584870.html>  
>