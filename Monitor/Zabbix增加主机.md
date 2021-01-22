---
title: "Zabbix增加主机"
date: "2020-07-30"
categories:
    - "技术"
tags:
    - "Zabbix"
toc: false
indent: false
original: true
draft: true
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-07-30 | 初稿 |

## 版本信息

| Server        | Version |
| ------------- | ------- |
| Zabbix-Server | 4.0.7   |
| Zabbix-Agent  | 4.0.23  |

## 一、部署Agent

``` zsh
# 拷贝 repo && gpg key 至新主机
➜  cd /etc/yum.repos.d/
➜  scp zabbix.repo 172.19.26.11:~
➜  scp zabbix.repo 172.19.26.12:~

➜  cd /etc/pki/rpm-gpg/
ll
total 24
-rw-r--r--  1 root root 1333 Sep 18  2018 RPM-GPG-KEY-ZABBIX
-rw-r--r--  1 root root 1719 Sep 18  2018 RPM-GPG-KEY-ZABBIX-A14FE591

➜  scp *ZABBIX* 172.19.26.11:~
➜  scp *ZABBIX* 172.19.26.12:~

# 新主机执行操作
➜  cp ~/*ZABBIX* /etc/pki/rpm-gpg/
➜  cp ~/zabbix.repo /etc/yum.repos.d/
➜  yum clean all
➜  yum makecache

# zabbix-agent Info
➜  yum info zabbix-agent
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Available Packages
Name        : zabbix-agent
Arch        : x86_64
Version     : 4.0.23
Release     : 1.el7
Size        : 426 k
Repo        : zabbix/x86_64
Summary     : Zabbix Agent
URL         : http://www.zabbix.com/
License     : GPLv2+
Description : Zabbix agent to be installed on monitored systems.

# 安装 zabbix-agent
➜  yum install -y zabbix-agent
```

## 二、配置Agent

``` zsh
# 修改 Agent配置文件
➜  vim /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=172.19.26.8
ServerActive=172.19.26.8
Hostname=pg1.aihangxunxi.com
MaxLinesPerSecond=6
Include=/etc/zabbix/zabbix_agentd.d/*.conf

# 启动 zabbix-agent
➜  systemctl start zabbix-agent
# Agent 默认监听 10050端口
➜  ss -tnlp|grep 10050
LISTEN     0      128          *:10050                    *:*                   users:(("zabbix_agentd",pid=16612,fd=4),("zabbix_agentd",pid=16611,fd=4),("zabbix_agentd",pid=16610,fd=4),("zabbix_agentd",pid=16609,fd=4),("zabbix_agentd",pid=16608,fd=4),("zabbix_agentd",pid=16607,fd=4))
LISTEN     0      128         :::10050                   :::*                   users:(("zabbix_agentd",pid=16612,fd=5),("zabbix_agentd",pid=16611,fd=5),("zabbix_agentd",pid=16610,fd=5),("zabbix_agentd",pid=16609,fd=5),("zabbix_agentd",pid=16608,fd=5),("zabbix_agentd",pid=16607,fd=5))
```

## 三、Web UI 配置

打开Zabbix Web端

依次打开 [配置] --> [主机] --> [创建主机]

[主机tab页]

![创建主机-主机](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_20200730_01.png)

[模板tab页]

![创建主机-模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_20200730_02.png)
