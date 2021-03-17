#!/bin/bash

datebegin=$(date +'%Y-%m-%d %H:%M:%S')

# 生产URL
Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token="
# 测试URl
#Dingding_Url="https://oapi.dingtalk.com/robot/send?access_token="

# 消息内容
 content="项目名:      $1\n"
content+="发布人:      $2\n"
content+="发布版本:   $3\n"
content+="发布原因:   $5\n"
content+="发布状态:   开始发布\n"
content+="开始时间:   $datebegin\n"
content+="链接地址:   $4\n"

echo $content

# 发送钉钉消息
curl -s $Dingding_Url -H 'Content-Type: application/json' -d '{
    "msgtype": "text",
    "text": {
        "content": "'"$content"'"
    }
}'