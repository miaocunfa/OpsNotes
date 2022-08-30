#!/bin/bash

# Describe:     dingding.sh
# Create Date： 2021-03-26
# Create Time:  15:11
# Update Date:  2021-03-29
# Update Time:  13:35
# Author:       MiaoCunFa
# Version:      v0.0.7

#===================================================================

curDate=$(date +'%Y-%m-%d %H:%M:%S')
workdir="/usr/lib/zabbix/alertscripts/dingding"
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=66a26b11a6f054562db67b2a8e00d4e74b20a405a5c931cb08295364767e9563"
logfile="$workdir/logs/dingding.log"

function __log(){
    echo $curDate $1 [$2]: "$3" >> $logfile
}

content=$1
__log INFO content "$content"

response=$(curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
    "msgtype": "text",
    "text": {
        "content": "'"$content"'"
    }
}')
__log INFO response "$response"