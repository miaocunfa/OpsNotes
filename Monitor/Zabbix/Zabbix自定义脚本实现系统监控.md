---
title: "Zabbix 自定义脚本实现系统监控"
date: "2021-03-08"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
    - "ansible"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-08 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |

## 一、zabbix agent配置

需要先将 zabbix agent 的配置做一下修改

``` zsh
# 要加下面这句
➜  vim /etc/zabbix/zabbix_agentd.conf
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

## 二、zabbix server配置

zabbix server创建新模板

配置 --> 模板 --> 创建模板

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_template_20210308.jpg)

## 三、CPU

### 3.1、脚本 && 配置

``` zsh
➜  vim /etc/zabbix/scripts/cpu_load_status.sh
#!/bin/bash
############################################################
# @Name:            cpu_load_status.sh
# @Version:         v1.1
# @Function:        cpu Status
# @Author:          guozhimin
# @Create Date:     2018-06-23
# @Update Date：    2021-03-08
# @Description:     Monitor CPU Service Status
############################################################

function minute_1(){
        uptime | awk '{print $10}'
}

function minute_5(){
       uptime | awk '{print $11}'
}

function minute_15(){
       uptime | awk '{print $12}'
}

[ $# -ne 1 ] && echo "minute_1|minute_5|minute_15" && exit 1

$1

# 配置文件
➜  vim /etc/zabbix/zabbix_agentd.d/cpu_load_status.conf
UserParameter=cpu_load_status[*],/bin/bash /etc/zabbix/scripts/cpu_load_status.sh "$1"
```

### 3.2、使用ansible 批量推送

``` zsh
➜  ansible all -m shell -a "mkdir -p /etc/zabbix/scripts/"
➜  ansible all -m copy -a "src=/root/ansible/cpu_load_status.conf dest=/etc/zabbix/zabbix_agentd.d/cpu_load_status.conf"
➜  ansible all -m copy -a "src=/root/ansible/cpu_load_status.sh   dest=/etc/zabbix/scripts/cpu_load_status.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```

### 3.3、zabbix server 添加监控项

配置 --> 模板 --> [找到自定义模板] --> 点击'监控项'

![进入自定义模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_template_02_20210308.jpg)

点击 --> 创建监控项

