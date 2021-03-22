#!/bin/bash

# Describe:     init H5 project: 
#               mkdir: local and remote 
#               configuration: scp and sed
#               Nginx: check and reload
#
# Create Date： 2021-03-19
# Create Time:  11:29
# Update Date:  2021-03-22
# Update Time:  14:40
# Author:       MiaoCunFa
# Version:      v0.0.13

#===================================================================

project=$1
domain=$2
configName=$3

ng1="192.168.189.164"
ng2="192.168.189.165"
ngbin="/usr/local/nginx/sbin"
vhost="/usr/local/nginx/conf/vhost"
tools="/script/jenkins-tools"

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

# 先判断远端Nginx是否已存在该配置文件
ssh root@$ng1 "if [ -f $vhost/${configName}.conf ]; then echo "$ng1: $vhost/${configName}.conf: is already exists, Please Check it"; exit 130; fi"

if [ $? == "130" ]; then
    exit 0
fi

ssh root@$ng2 "if [ -f $vhost/${configName}.conf ]; then echo "$ng2: $vhost/${configName}.conf: is already exists, Please Check it"; exit 130; fi"

if [ $? == "130" ]; then
    exit 0
fi

# 本地 位置初始化
mkdir -p /script/h5_pack/$project

# nginx 位置初始化
ssh root@$ng1 "mkdir -p /var/www/$project"
ssh root@$ng2 "mkdir -p /var/www/$project"

#===================================================================

# 推送配置文件模板
scp $tools/sample_nginx.conf root@$ng1:$vhost/${configName}.conf
scp $tools/sample_nginx.conf root@$ng2:$vhost/${configName}.conf

# sed 替换命令
sedcmd=$(cat<<EOF
    sed -i 's@domain@$domain@g' ${configName}.conf;
    sed -i 's@roothome@/var/www/$project@g' ${configName}.conf;
    sed -i 's@accesslog@/logs/${configName}.access.log@g' ${configName}.conf;
    sed -i 's@errorlog@/logs/${configName}.error.log@g' ${configName}.conf;
EOF
)

# 将模板文件进行替换
ssh root@$ng1 "cd $vhost; $sedcmd"
ssh root@$ng2 "cd $vhost; $sedcmd"

#===================================================================

# nginx -t
testcmd=$(cat<<EOF
    syntax_status=\`$ngbin/nginx -t 2>&1 | grep syntax | awk '{print \$8}'\`;
    test_status=\`$ngbin/nginx -t 2>&1 | grep test | awk '{print \$7}'\`;
    if ([ "\$syntax_status" == "ok" ] && [ "\$test_status" == "successful" ]); then
        echo "Nginx configuration is ok";
    else
        echo "Nginx configuration is not ok";
        exit 1;
    fi
EOF
)

# 测试Nginx配置文件
ssh root@$ng1 "$testcmd"

if [ $? == "1" ]; then
    exit 0
fi

ssh root@$ng2 "$testcmd"

if [ $? == "1" ]; then
    exit 0
fi

# 重启Nginx
ssh root@$ng1 "$ngbin/nginx -s reload"
ssh root@$ng2 "$ngbin/nginx -s reload"
