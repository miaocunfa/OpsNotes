---
title: "Zabbix 批量添加主机 && 自动发现"
date: "2021-03-05"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
    - "自动化运维"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-05 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |

## 思路

最近公司主机，要使用 Zabbix 监控起来，但由于需要加的节点太多了，一台台机器手动添加累死个人。

这个时候要充分发挥自动化运维的能力。要实现这个过程分为两步。

- 一、zabbix agent：  
  - 1、首先配置 ansible 环境
  - 2、批量安装 zabbix agent
  - 3、修改配置 && 批量推送
  - 4、启动 agent
- 二、zabbix server：  
  - 配置自动发现
  - 配置动作

## ansible 配置

``` zsh
➜  yum install -y ansible

# 修改 hosts文件 && 使用密码登录
➜  vim /etc/ansible/hosts
[bitdata-prod]
192.168.189.187 ansible_ssh_port= ansible_ssh_user= ansible_ssh_pass=''
192.168.189.192
192.168.189.193

[bitdata-test]
192.168.196.[82:84]

[es]
192.168.189.[185:186]

[log]
192.168.189.[166:168]

[mq]
192.168.189.[161:163]

[web]
192.168.189.171
192.168.189.[175:178]
192.168.189.180

[web-devops]
192.168.189.174
192.168.189.182

[lb]
192.168.189.[164:165]

# 允许密码
➜  vim /etc/ansible/ansible.cfg
host_key_checking = False

# 使用 ping模块 验证
➜  ansible all -m ping
192.168.189.186 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
192.168.196.84 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

## zabbix agent

``` zsh
# 安装 agent && 验证
➜  ansible all -m shell -a "rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm && yum -y install zabbix-agent"
➜  ansible all -m shell -a "yum list installed | grep zabbix-agent"

# 修改配置文件
➜  mkdir -p /root/ansible         # 用于存放ansible推送的文件
➜  cat /root/ansible/zabbix_agentd.conf | grep -v ^# | grep -v ^$
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=192.168.189.181
ServerActive=192.168.189.181
HostnameItem=system.hostname       # 自动发现要配置这一项
Include=/etc/zabbix/zabbix_agentd.d/*.conf

# 推送配置文件 && 启动 agent && 验证 agent
➜  ansible all -m copy -a "src=/root/ansible/zabbix_agentd.conf dest=/etc/zabbix/zabbix_agentd.conf"
➜  ansible all -m shell -a "systemctl start zabbix-agent && systemctl enable zabbix-agent"
➜  ansible all -m shell -a "systemctl status zabbix-agent |grep running"
```

## zabbix server

### 自动发现

配置 --> 自动发现 --> 创建发现规则

![自动发现](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_discovery.jpg)

### 动作

配置 --> 动作 --> 创建动作

![动作](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_discovery_action.jpg)

在 "条件" 选项下添加触发条件  
- A：自动发现规则 为 Find Hosts - 189  
- B：自动发现状态 为 上  
- C：服务类型     为 zabbix客户端  

![动作细节](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_discovery_action_detail.jpg)

在 "操作" --> "细节" 下添加操作细节  
- 发送消息给用户 admin 通过Email  
- 添加主机  
- 添加到主机群组 Discovered hosts，Linux servers  
- 链接到模板 Template OS Linux  

### 验证

检测 --> 自动发现

![自动发现列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_discovery_list.jpg)

我们能看到通过自动发现规则发现的主机列表

配置 --> 主机群组

![主机群组列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_discovery_group.jpg)

我们看到自动发现的主机 已经添加至主机群组 Discovered hosts 中了。

> 参考文章：  
> 1、[Zabbix自动发现和自动注册](https://blog.csdn.net/achenyuan/article/details/87806272)  
> 2、[Zabbix配置自动发现，实现批量添加主机](https://blog.csdn.net/qq_39626154/article/details/86306252)  
>