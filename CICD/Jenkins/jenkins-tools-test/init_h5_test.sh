#!/bin/bash

# Describe:     init H5 project: TEST
#               mkdir: local and remote
#               configuration: scp and sed
#               Nginx: check and reload
#
# Create Date： 2021-03-24
# Create Time:  13:45
# Update Date:  2021-04-06
# Update Time:  16:26
# Author:       MiaoCunFa
# Version:      v0.0.5

#===================================================================

project=$1
domain=$2
configName=$3

ngbin="/usr/local/nginx/sbin"
vhost="/usr/local/nginx/conf/vhost"
tools="/script/jenkins-tools"

roothome="/var/www/h5/$project"

function Usage(){
    echo
    echo "Usage:"
    echo "    init_h5.sh [project] [domain] [configName]"
    echo
}

if [ "$1" == "" ]; then
    Usage
    exit 0
fi

if [ "$2" == "" ]; then
    Usage
    exit 0
fi

if [ "$3" == "" ]; then
    Usage
    exit 0
fi

#===================================================================

# 先判断Nginx是否已存在该配置文件

if [ -f $vhost/${configName}.conf ]; then
    echo "$vhost/${configName}.conf: is already exists, Please Check it";
    exit 130;
fi

# 本地 位置初始化
mkdir -p /script/h5-pack/$project

# nginx 位置初始化
mkdir -p $roothome

#===================================================================

# 推送配置文件模板
cp $tools/sample_nginx.conf $vhost/${configName}.conf

# sed 替换命令
cd $vhost

sed -i "s@domain@$domain@g" ${configName}.conf;
sed -i "s@roothome@$roothome@g" ${configName}.conf;
sed -i "s@accesslog@/logs/nginx/${configName}.access.log@g" ${configName}.conf;
sed -i "s@errorlog@/logs/nginx/${configName}.error.log@g" ${configName}.conf;

# nginx -t
syntax_status=$($ngbin/nginx -t 2>&1 | grep syntax | awk '{print $8}');
test_status=$($ngbin/nginx -t 2>&1 | grep test | awk '{print $7}');
if ([ "$syntax_status" == "ok" ] && [ "$test_status" == "successful" ]); then
    echo "Nginx configuration is ok";
else
    echo "Nginx configuration is not ok";
    exit 1;
fi

$ngbin/nginx -s reload
