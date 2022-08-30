---
title: "yum部署rabbitMQ集群"
date: "2021-06-04"
categories:
    - "技术"
tags:
    - "消息队列"
    - "rabbit MQ"
toc: false
original: true
draft: false
---

## 更新信息

| 时间       | 内容         |
| ---------- | ------------ |
| 2021-06-04 | 初稿         |

## 软件版本

| 时间       | 内容         |
| ---------- | ------------ |
| 2021-06-04 | 初稿         |

## 安装

①下载安装包 && 安装

``` zsh
# 三台主机都执行

➜  unzip rabbitMQ3.7.7.zip 
➜  cd rabbitMQ3.7.7

# 安装
➜  yum install erlang-21.3.8.6-1.el7.x86_64.rpm 
➜  yum install rabbitmq-server-3.7.7-1.el7.noarch.rpm
```

②查看安装文件路径

``` zsh
➜  rpm -ql rabbitmq-server-3.7.7-1.el7.noarch
/etc/logrotate.d/rabbitmq-server
/etc/profile.d/rabbitmqctl-autocomplete.sh
/etc/rabbitmq
/usr/lib/ocf/resource.d/rabbitmq/rabbitmq-server
/usr/lib/ocf/resource.d/rabbitmq/rabbitmq-server-ha
/usr/lib/rabbitmq/autocomplete/bash_autocomplete.sh
/usr/lib/rabbitmq/autocomplete/zsh_autocomplete.sh
/usr/lib/rabbitmq/bin/cuttlefish
```

## 配置

①host文件

``` zsh
# 三台主机都执行

➜  vim /etc/hosts
# rabbitMQ
192.168.31.30    MQ1
192.168.31.104   MQ2
192.168.31.155   MQ3
```

②创建持久化目录

``` zsh
# 三台主机都执行

➜  mkdir -p /disk2/rabbitmq/{store,logs}
➜  cd /disk2
➜  chown -R rabbitmq:rabbitmq rabbitmq/
```

③rabbit配置文件

``` zsh
➜  vim /etc/rabbitmq/rabbitmq-env.conf
# 指定节点的名字，默认rabbit@${hostname}
NODENAME=rabbit@MQ1
# 指定端口，默认5672
NODE_PORT=5672
# 配置持久目录
MNESIA_BASE=/disk2/rabbitmq/store
# 配置日志目录 默认文件名字：${NODENAME}.log 可以用配置修改
LOG_BASE=/disk2/rabbitmq/logs
```

## 启动服务

``` zsh
➜  systemctl start rabbitmq-server
➜  systemctl status rabbitmq-server
● rabbitmq-server.service - RabbitMQ broker
   Loaded: loaded (/usr/lib/systemd/system/rabbitmq-server.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2021-06-04 16:16:18 CST; 36s ago
 Main PID: 13071 (beam.smp)
   Status: "Initialized"
    Tasks: 127
   Memory: 57.7M
   CGroup: /system.slice/rabbitmq-server.service
           ├─13071 /usr/lib64/erlang/erts-10.3.5.4/bin/beam.smp -W w -A 96 -MBas ageffcbf -MHas ageffcbf -MBlmbcs 512 -MHlmbcs 512 -MMmcs 30 -P 1048576 -t 5000000 -stbt db -zdbbl 1280000...
           ├─13212 /usr/lib64/erlang/erts-10.3.5.4/bin/epmd -daemon
           ├─13419 erl_child_setup 1024
           ├─13446 inet_gethost 4
           └─13447 inet_gethost 4

Jun 04 16:16:16 master rabbitmq-server[13071]: ##  ##
Jun 04 16:16:16 master rabbitmq-server[13071]: ##  ##      RabbitMQ 3.7.7. Copyright (C) 2007-2018 Pivotal Software, Inc.
Jun 04 16:16:16 master rabbitmq-server[13071]: ##########  Licensed under the MPL.  See http://www.rabbitmq.com/
Jun 04 16:16:16 master rabbitmq-server[13071]: ######  ##
Jun 04 16:16:16 master rabbitmq-server[13071]: ##########  Logs: /disk2/rabbitmq/logs/rabbit@MQ1.log
Jun 04 16:16:16 master rabbitmq-server[13071]: /disk2/rabbitmq/logs/rabbit@MQ1_upgrade.log
Jun 04 16:16:16 master rabbitmq-server[13071]: Starting broker...
Jun 04 16:16:18 master rabbitmq-server[13071]: systemd unit for activation check: "rabbitmq-server.service"
Jun 04 16:16:18 master systemd[1]: Started RabbitMQ broker.
Jun 04 16:16:18 master rabbitmq-server[13071]: completed with 0 plugins.
```

## 集群

①erlang.cookie

yum部署的rabbitmq, `.erlang.cookie` 在 `/var/lib/rabbitmq` 下

``` zsh
➜  cat /var/lib/rabbitmq/.erlang.cookie
DGXKRZAJARTBMFEXIRGV

➜  scp .erlang.cookie root@MQ2:/var/lib/rabbitmq
➜  scp .erlang.cookie root@MQ3:/var/lib/rabbitmq

# 在MQ2、MQ3执行
➜  cd /var/lib/rabbitmq/; chown -R rabbitmq:rabbitmq ./.erlang.cookie
```

②加入集群

``` zsh
# MQ2
➜  rabbitmqctl stop_app
➜  rabbitmqctl join_cluster rabbit@MQ1
➜  rabbitmqctl start_app

# MQ3
➜  rabbitmqctl stop_app
➜  rabbitmqctl join_cluster rabbit@MQ1 --ram
➜  rabbitmqctl start_app
```

## WEB管理

``` zsh
➜  rabbitmq-plugins enable rabbitmq_management
➜  rabbitmqctl add_user gongjiangren-test gongjiangrenQAWSED@@
➜  rabbitmqctl set_user_tags gongjiangren-test administrator
```

``` zsh
➜  ss -tnlp|grep 5672
LISTEN     0      128          *:25672                    *:*                   users:(("beam.smp",pid=13071,fd=65))
LISTEN     0      128          *:15672                    *:*                   users:(("beam.smp",pid=13071,fd=80))
LISTEN     0      128       [::]:5672                  [::]:*                   users:(("beam.smp",pid=13071,fd=76))
```
