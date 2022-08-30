---
title: "Zabbix 监控 Java"
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

## 监控脚本

``` zsh
# 修改 zabbix conf
➜  vim /etc/zabbix/zabbix_agentd.d/jps.conf
UserParameter=jps[*], sudo /usr/local/jdk1.8.0_251/bin/jps | grep -w "$1" | wc -l

# 修改 sudo 权限
➜  vim /etc/sudoers
zabbix  ALL=NOPASSWD:/usr/local/jdk1.8.0_251/bin/jps

# 重启 zabbix agent 服务
➜  systemctl restart zabbix-agent
```

## 测试验证

``` zsh
➜  zabbix_get -s 192.168.189.193 -k jps[ThriftServer]
1
```

## Zabbix UI

①创建模板

点击 '配置' --> '模板' --> '创建模板'

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_05.jpg)

②创建应用集 big-prod

③创建监控项

在模板下 --> 点击 '监控项' --> '创建监控项'

![创建监控项](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_01.jpg)

④创建触发器

在模板下 --> 点击 '触发器' --> '创建触发器'

![创建触发器](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_02.jpg)

## Zabbix 验证

①监控项列表

![监控项列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_03.jpg)

②最新数据

![最新数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zbx_jps_20210810_04.jpg)