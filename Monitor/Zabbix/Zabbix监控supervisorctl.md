---
title: "Zabbix 监控 supervisorctl"
date: "2021-08-06"
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
| 2021-08-06 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.32  |
| zabbix agent  | 4.0.29  |

## 监控脚本

``` shell
➜  vim /etc/zabbix/scripts/supervisor.sh
#!/bin/bash

# Describe:     monitor supervisorctl status
# Create Date： 2021-08-06
# Create Time:  17:06
# Update Date:  
# Update Time:  
# Author:       MiaoCunFa
# Version:      v0.0.1

#===================================================================

file=/etc/zabbix/scripts/supervisor.txt

# 值校验
if [ "$1" == "" ];
then
    Usage
    exit 0
fi

function Usage(){
    echo "Usage: supervisor.sh [programm]"
}

#===================================================================

sudo supervisorctl status > $file

CMD=$(grep "$1" $file|awk '{print $2}')

if [ "$CMD" == "RUNNING" ];
then
    echo "1"
else
    echo "0"
fi

# 执行权限
➜  chmod u+x supervisor.sh
➜  touch supervisor.txt
➜  chown zabbix:zabbix supervisor*

# 修改 zabbix conf
➜  vim /etc/zabbix/zabbix_agentd.d/supervisor.conf
UserParameter=py_status[*], /bin/bash /etc/zabbix/scripts/supervisor.sh $1

# 修改 sudo 权限
➜  vim /etc/sudoers
zabbix  ALL=NOPASSWD:/usr/bin/supervisorctl

# 重启 zabbix agent 服务
➜  systemctl restart zabbix-agent
```

## 测试验证

``` zsh
➜  zabbix_get -s 192.168.189.193 -k py_status[prod_auto]
1
```

## Zabbix UI

①创建模板

点击 '配置' --> '模板' --> '创建模板'

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_05.jpg)

②创建应用集 big-prod-node1

③创建监控项

在模板下 --> 点击 '监控项' --> '创建监控项'

![创建监控项](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_01.jpg)

④创建触发器

在模板下 --> 点击 '触发器' --> '创建触发器'

![创建触发器](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_04.jpg)

## Zabbix 验证

①监控项列表

![监控项列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_02.jpg)

②最新数据

![监控项列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_py_20210806_03.jpg)
