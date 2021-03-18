#!/bin/bash

# Describe:     monitor Kafka lag common tools
# Create Date： 2021-03-18
# Create Time:  15:19
# Update Date:  2021-03-18
# Update Time:  16:02
# Author:       MiaoCunFa
# Version:      v0.0.2

#===================================================================

source /etc/profile
source ~/.bash_profile

curDate=$(date +'%Y-%m-%d %H:%M:%S')
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=3a5304eedad3d97413073803ff2c2878727c037938adb7b99cbcb45b6c325f3c"

threshold=$3
Name=$4
Topic=$1
Group=$2
Bootstrap="192.168.189.193:9092,192.168.189.192:9092,192.168.189.187:9092"

#===================================================================

# 值校验

if [ "$1" == "" ];
then
    Usage
    exit 0
fi

if [ "$2" == "" ];
then
    Usage
    exit 0
fi

if [ "$3" == "" ];
then
    Usage
    exit 0
fi

if [ "$4" == "" ];
then
    Usage
    exit 0
fi

function Usage(){
    echo "Usage: kafka_lag [Topic] [Group] [threshold] [name]"
}

#===================================================================

lag=$(kafka-consumer-groups.sh --bootstrap-server $Bootstrap --describe --group $Group |awk 'NR>1{num+=$5}END{print num}')

 content="报警通知：$Name\n"
content+="告警时间：$curDate\n"
content+="Topic名称：$Topic\n"
content+="Group名称：$Group\n"
content+="堆积情况：一分钟堆积$lag个\n"
content+="堆积详情：请快速登录服务器查看处理哦"

if [ "$lag" -ge $threshold ];
then
    echo "lag值过大"
    curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
        "msgtype": "text",
        "text": {
            "content": "'"$content"'"
        }
    }"
fi

echo "$lag"