#!/bin/bash

# Describe:     dingding_start.sh
# Update Date:  2021-03-24
# Update Time:  10:28
# Version:      v0.0.2

curDate=$(date +'%Y-%m-%d %H:%M:%S')

# 生产URL
#Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=607de6b368d7d69a12965aeb205891e01b83002d283ab0ec2d5946d98cb1ba06"
# 测试URl
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token=7467a33248e96fb61c1ed610c00b6ea7ef07e6560abcb751a97e9b586c5da513"

# 消息内容
content=$(cat<<EOF
项目名:      $1
发布人:      $2
发布版本:   $3
发布原因:   $4
发布状态:   开始发布
开始时间:   $curDate\n\n
EOF
)

echo $content

# 发送钉钉消息
curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
    "msgtype": "text",
    "text": {
        "content": "'"$content"'"
    },
    "at": {
      "isAtAll": true
    }
}'