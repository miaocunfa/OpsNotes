---
title: "Zabbix 监控官网"
date: "2021-03-31"
categories:
    - "技术"
tags:
    - "zabbix"
    - "web检测"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-31 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |

## 引言

由于今天修改Nginx配置文件，有一个参数没仔细看，导致官网挂掉了还不知道，痛定思痛，痛改前非，决定将公司的所有网站全部监控起来，这样好歹网站挂掉了能第一时间知道。

## Zabbix UI

使用Zabbix监控网站，只需要在Web UI上配置即可。废话不多说，直接上步骤。

### 创建模板

先创建一个模板，方便管理监控项。

点击 '配置' --> '模板' --> '创建模板'

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_01.jpg)

### 创建web场景

![web场景-场景](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_02.jpg)

![web场景-步骤](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_03.jpg)

### 创建触发器

![触发器](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_04.jpg)

## 验证

![web数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_05.jpg)
![web详细数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_www_20210331_06.jpg)


> 参考文档：  
> [1] [检测web场景官方手册](https://www.zabbix.com/documentation/4.0/zh/manual/web_monitoring)  
>