---
title: "Zabbix实现钉钉告警"
date: "2021-03-26"
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
| 2021-03-26 | 初稿 |
| 2021-03-29 | 文档结构优化 && Zabbix UI |
| 2021-04-06 | 调试钉钉告警脚本：去掉多余"引号" |
| 2021-07-22 | 调整 Zabbix UI 操作顺序 && 增加告警内容 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |

## 告警脚本

Zabbix的自定义告警脚本, 要放在Zabbix Server的AlertScripts路径下, 首先我们查看zabbix_server.conf

``` zsh
# 查找alertscripts路径
➜  cd /etc/zabbix/
➜  grep alertscripts /etc/zabbix/zabbix_server.conf
AlertScriptsPath=/usr/lib/zabbix/alertscripts

# 创建钉钉告警程序路径
➜  cd /usr/lib/zabbix/alertscripts
➜  mkdir -p dingding/{bin,logs}
```

钉钉告警脚本

``` zsh
➜  vim dingding/bin/dingding.sh
#!/bin/bash

# Describe:     dingding.sh
# Create Date： 2021-03-26
# Create Time:  15:11
# Update Date:  2021-04-06
# Update Time:  17:21
# Author:       MiaoCunFa
# Version:      v0.0.8

#===================================================================

curDate=$(date +'%Y-%m-%d %H:%M:%S')
workdir="/usr/lib/zabbix/alertscripts/dingding"
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token="
logfile="$workdir/logs/dingding.log"

function __log(){
    echo $curDate $1 [$2]: "$3" >> $logfile
}

content=$(echo $1 | sed 's/\"//g')
__log INFO content "$content"

response=$(curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
    "msgtype": "text",
    "text": {
        "content": "'"$content"'"
    }
}')
__log INFO response "$response"
```

告警脚本权限

``` zsh
➜  cd /usr/lib/zabbix/alertscripts
➜  chown -R zabbix:zabbix dingding
➜  chmod u+x dingding/bin/dingding.sh
```

## Zabbix UI

### 创建用户群组

①点击 '管理' --> '用户群组' --> '创建用户群组'

![创建用户群组](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_07.jpg)

### 创建报警媒介

①点击 '管理' --> '报警媒介类型' --> '创建媒体类型'

![创建报警媒介](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_04.jpg)

### 创建动作

点击 '配置' --> '动作' --> '创建动作'

①创建动作 - '动作'选项卡

![创建动作 - 动作](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_03.jpg)

②创建动作 - '操作'选项卡

![创建动作 - 操作](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_01.jpg)

```

标题：
Problem:{EVENT.NAME}

内容：
{TRIGGER.STATUS}: {TRIGGER.NAME}\n告警主机: {HOST.NAME}\n主机地址: {HOST.IP}\n告警时间: {EVENT.DATE}-{EVENT.TIME}\n告警等级: {TRIGGER.SEVERITY}告警信息: {TRIGGER.NAME}\n问题详情: {ITEM.NAME}:{ITEM.VALUE}\n事件代码: {EVENT.ID}

```

③创建动作 - '恢复操作'选项卡

![创建动作 - 恢复操作](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_02.jpg)

```

标题：
OK:{EVENT.NAME}

内容：
{TRIGGER.STATUS}:{TRIGGER.NAME}\n告警主机: {HOST.NAME}\n主机地址: {HOST.IP}\n故障持续时间: {EVENT.AGE}\n恢复时间: {EVENT.RECOVERY.TIME}\n告警等级: {TRIGGER.SEVERITY}告警信息: {TRIGGER.NAME}\n问题详情: {ITEM.NAME}:{ITEM.VALUE}\n事件代码: {EVENT.ID}

```

### 创建用户

点击 '管理' --> '用户' --> '创建用户'

①创建用户 - '用户'选项卡

![创建用户 - 用户](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_05.jpg)

②创建用户 - '报警媒介'选项卡

![创建用户 - 报警媒介](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_06.jpg)

③创建用户 - '权限'选项卡

![创建用户 - 权限](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_dingding_20210329_08.jpg)
