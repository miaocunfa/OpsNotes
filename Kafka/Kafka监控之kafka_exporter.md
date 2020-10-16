---
title: "Kafka 监控之 kafka_exporter"
date: "2020-10-16"
categories:
    - "技术"
tags:
    - "Kafka"
    - "监控系统"
    - "prometheus"
toc: false
original: true
---

## kafka 指标收集器

``` zsh
# 下载收集器
➜  cd /opt
➜  wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.2.0/kafka_exporter-1.2.0.linux-amd64.tar.gz

# 所有 kafka节点解压
➜  tar -zxf kafka_exporter-1.2.0.linux-amd64.tar.gz
```

## systemd 服务

``` zsh
➜  vim /usr/lib/systemd/system/kafka_exporter.service
[Unit]
Description=The node_exporter Client
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/kafka_exporter-1.2.0.linux-amd64/kafka_exporter --kafka.server=DB1:9092 --kafka.server=DB2:9092 --kafka.server=DB3:9092 > /opt/kafka_exporter-1.2.0.linux-amd64/kafka_exporter.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target

➜  systemctl daemon-reload
➜  systemctl start kafka_exporter
```

## prometheus 配置

``` zsh

```

## grafana

> 参考文档：
> 1、[源码地址](https://github.com/danielqsj/kafka_exporter/)  
>