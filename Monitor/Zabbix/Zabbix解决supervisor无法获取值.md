---
title: "Zabbix 解决 supervisorctl 无法获取值"
date: "2021-07-23"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
    - "supervisorctl"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-07-23 | 初稿 |
| 2021-08-06 | 修改解决方法为sudo权限 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.32  |
| zabbix agent  | 4.0.29  |

## 问题描述

``` zsh
# 命令执行效果
➜  supervisorctl status
prod_auto                        RUNNING   pid 16604, uptime 15 days, 0:24:23
prod_cycle                       RUNNING   pid 16602, uptime 15 days, 0:24:23
prod_offline                     RUNNING   pid 16605, uptime 15 days, 0:24:23
prod_one_to_one                  RUNNING   pid 16598, uptime 15 days, 0:24:23
prod_online_orders               RUNNING   pid 16603, uptime 15 days, 0:24:23
prod_online_tables               RUNNING   pid 16601, uptime 15 days, 0:24:23
prod_server_list                 RUNNING   pid 16597, uptime 15 days, 0:24:23
prod_server_manual               RUNNING   pid 16599, uptime 15 days, 0:24:23
prod_timer                       RUNNING   pid 16600, uptime 15 days, 0:24:23

# 获取 python 程序执行状态
➜  supervisorctl status | grep prod_auto | awk '{print $2}'
RUNNING

# 配置 supervisor.conf
➜  vim /etc/zabbix/zabbix_agentd.d/supervisor.conf
UserParameter=py_status[*], supervisorctl status | grep $1 | awk '{print $2}'
```

Zabbix 配置好监控项以后无法获取数据

![zabbix-最新数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/20210723_zabbix_supervisor_01.png)

## 问题解决

查到这个问题是因为 Zabbix在调用 `supervisorctl` 时试用 `zabbix` 用户执行没有权限，

解决办法是给 `zabbix` 用户加 `sudo` 权限

``` zsh
➜  vim /etc/sudoers
zabbix  ALL=NOPASSWD:/usr/bin/supervisorctl
```

> 参考文档：  
> [1] [centos环境下使用zabbix配合python脚本对supervisor中的进程运行状态进行监控](https://my.oschina.net/u/4396922/blog/4310178)  
> [2] [修改sudo权限](https://blog.csdn.net/liaoyaonline/article/details/88562129)  
> [3] [Zabbix远程命令权限不足问题解决方法](https://blog.csdn.net/lvshaorong/article/details/80533615)  
