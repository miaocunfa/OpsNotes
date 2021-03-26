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
draft: true
---

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |

## 告警脚本

``` zsh
# 查找alertscripts路径
➜  cd /etc/zabbix/
➜  grep alertscripts /etc/zabbix/zabbix_server.conf
AlertScriptsPath=/usr/lib/zabbix/alertscripts

# 创建钉钉告警程序路径
➜  cd /usr/lib/zabbix/alertscripts
➜  mkdir -p dingding/{bin,logs}

# 创建钉钉告警脚本
➜  vim dingding/bin/dingding.sh
#!/bin/bash

# Describe:     dingding.sh
# Create Date： 2021-03-26
# Create Time:  15:11
# Update Date:  2021-03-26
# Update Time:  17:25
# Author:       MiaoCunFa
# Version:      v0.0.5

#===================================================================

curDate=$(date +'%Y-%m-%d %H:%M:%S')
workdir="/usr/lib/zabbix/alertscripts/dingding"

##Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=3a5304eedad3d97413073803ff2c2878727c037938adb7b99cbcb45b6c325f3c"
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=7467a33248e96fb61c1ed610c00b6ea7ef07e6560abcb751a97e9b586c5da513"

logfile="$workdir/logs/dingding.log"

function __log(){
    echo $curDate $1 [$2]: "$3" >> $logfile
}

content=$1
#content="发布"
__log INFO content "$content"

request=$(cat<<EOF
curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
    "msgtype": "text",
    "text": {
        "content": "'"$content"'"
    }
}'
EOF
)
__log INFO request "$request"

eval $request > response
__log INFO response "$(cat response)"
```

## Zabbix Server

### 创建报警媒介

### 动作
