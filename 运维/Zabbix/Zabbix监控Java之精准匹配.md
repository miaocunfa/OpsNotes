---
title: "Zabbix监控Java进程之精准匹配"
date: "2021-08-10"
categories:
    - "技术"
tags:
    - "Zabbix"
    - "告警"
    - "Java"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-08-10 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.32  |
| zabbix agent  | 4.0.29  |

## 发现问题

![zabbix 检测](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_05.jpg)

明明使用jps做的匹配，怎么会获得进程数为2  
打开jps，发现问题了，grep把 `Master` 和 `HMaster` 都匹配出来了

![jps](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_06.jpg)

## 问题解决

①Agent 所做修改

``` zsh
# 修改 zabbix conf
# 将 grep 匹配修改为 精准匹配
➜  vim /etc/zabbix/zabbix_agentd.d/jps.conf
UserParameter=jps[*], sudo /usr/local/jdk1.8.0_251/bin/jps | grep -w "$1" | wc -l

# 重启 zabbix agent 服务
➜  systemctl restart zabbix-agent
```

## 验证

![数据验证](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_08.jpg)