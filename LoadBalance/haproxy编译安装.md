---
title: "haproxy编译安装"
date: "2020-03-27"
categories:
    - "技术"
tags:
    - "Haproxy"
    - "负载均衡"
toc: false
indent: false
original: true
---

## 一、下载源码包
``` zsh
➜  wget http://www.haproxy.org/download/2.1/src/haproxy-2.1.3.tar.gz
```

## 二、编译安装
``` zsh
# 解压源码包
➜  tar -zxf haproxy-2.1.3.tar.gz

➜  cd haproxy-2.1.3

# 以通用模式编译
➜  make TARGET=generic
➜  make install
```

## 三、haproxy版本号
``` bash
➜  haproxy -v
HA-Proxy version 2.1.3 2020/02/12 - https://haproxy.org/
Status: stable branch - will stop receiving fixes around Q1 2021.
Known bugs: http://www.haproxy.org/bugs/bugs-2.1.3.html
```

## 四、示例配置文件
``` zsh
➜  vim 
global
    log     127.0.0.1  local0 info
    log     127.0.0.1  local1 notice
    daemon
    maxconn 4096

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    retries 3
    option  abortonclose
    maxconn 4096
    timeout connect  5000ms
    timeout client  3000ms
    timeout server  3000ms
    balance roundrobin

listen private_monitoring
    bind    192.168.100.242:8100
    mode    http
    option  httplog
    stats   refresh  5s
    stats   uri  /stats
    stats   realm   Haproxy
    stats   auth  admin:admin

listen rabbitmq_admin
    bind    192.168.100.242:8102
    server  MQ1  192.168.100.217:15672
    server  MQ2  192.168.100.218:15672
    server  MQ3  192.168.100.219:15672

listen rabbitmq_cluster
    bind    192.168.100.242:8101
    mode    tcp
    option  tcplog
    balance roundrobin
    server  MQ1  192.168.100.217:5672  check  inter  5000  rise  2  fall  3
    server  MQ2  192.168.100.218:5672  check  inter  5000  rise  2  fall  3
    server  MQ3  192.168.100.219:5672  check  inter  5000  rise  2  fall  3
```