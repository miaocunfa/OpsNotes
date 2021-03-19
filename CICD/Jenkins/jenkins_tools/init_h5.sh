#!/bin/bash

# Describe:     init project: local path and remote path
# Create Date： 2021-03-19
# Create Time:  11:29
# Update Date:  2021-03-19
# Update Time:  17:30
# Author:       MiaoCunFa
# Version:      v0.0.3

#===================================================================

project=$1
domain=$2
configName=$3

ng1="192.168.189.164"
ng2="192.168.189.165"
vhost="/usr/local/nginx/conf/vhost"
tools="/script/jenkins-tools/"

function Usage(){
    echo
    echo "Usage:"
    echo "    init_h5.sh [project] [configName] [domain]"
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

# 本地 位置初始化
mkdir -p /script/h5_pack/$project

# nginx 位置初始化
ssh root@$ng1 "mkdir -p /var/www/$project"
ssh root@$ng2 "mkdir -p /var/www/$project"

# 推送配置文件模板
scp $tools/sample_nginx.conf root@ng1:$vhost/${configName}.conf
scp $tools/sample_nginx.conf root@ng2:$vhost/${configName}.conf

# 将模板文件进行替换 && 重启Nginx
ssh root@$ng1 "cd $vhost; sed -i 's@domain@$domain@g; s@roothome@/var/www/$project@g' ${configName}.conf; nginx -s reload"
ssh root@$ng2 "cd $vhost; sed -i 's@domain@$domain@g; s@roothome@/var/www/$project@g' ${configName}.conf; nginx -s reload"
