---
title: "Zabbix钉钉告警分组优化"
date: "2021-08-02"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-08-02 | 初稿 |


## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.32  |
| zabbix agent  | 4.0.29  |

## 告警脚本

在Zabbix中使用一个用户来进行钉钉告警，很容易出现，消息太多、重要消息遗漏的问题。
我们进行告警改造，首先是定义各种报警等级，普通告警信息发送一遍即可、灾难级别告警要一直不断的发送。

在Zabbix中要达到这种效果，就是通过动作发给不同用户来实现。

``` zsh

```
