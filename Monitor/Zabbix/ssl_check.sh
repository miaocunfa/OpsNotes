#!/bin/bash

# Describe:     ssl_check.sh
# Create Date： 2021-04-02
# Create Time:  15:48
# Update Date:  2021-04-02
# Update Time:  15:58
# Author:       MiaoCunFa
# Version:      v0.0.2

#===================================================================

function Usage(){
    echo "Usage: ssl_check [crtfile]"
}

crtfile=$1

if [ "$1" == "" ];
then
    Usage
    exit 0
fi

# 过期时间 && 过期时间时间戳
expire_date=$(openssl x509 -in $crtfile -noout -text | grep "Not After" | awk -F " : " '{print $2}')
expire_stamp=$(date -d "$expire_date" +%s)

# 提醒日期 && 提醒日期时间戳
alert_date=10
alert_stamp=$(($expire_stamp - $alert_date * 86400))

# 当前日期 && 当前日期时间戳
curdate_stamp=$(date +%s)

# 判断当期日期与提醒日期
if [ $curdate_stamp -ge $alert_stamp ]; then
    echo 1
else
    echo 0
fi