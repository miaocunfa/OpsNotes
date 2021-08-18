#!/bin/bash

# Describe:     run container && check status 
# Create Date： 2021-08-12
# Create Time:  11:19
# Update Date:  2021-08-17
# Update Time:  15:02
# Author:       MiaoCunFa
# Version:      v0.0.2

#===================================================================

programm=$(basename $0)

if [ "$1" == "" ];
then
    echo "$programm: harbor: is null! please check!"
    exit 0
fi

if [ "$2" == "" ];
then
    echo "$programm: service: is null! please check!"
    exit 0
fi

if [ "$3" == "" ];
then
    echo "$programm: BUILD_TAG: is null! please check!"
    exit 0
fi

if [ "$4" == "" ];
then
    echo "$programm: port: is null! please check!"
    exit 0
fi

harbor="$1"
service="$2"
BUILD_TAG="$3"
port="$4"

sleep_second='15'

#===================================================================

# Stop old container
# Remove old container
for c in `docker ps -a |grep -i $service | awk '{print $1}'`
do
   docker stop $c
   docker rm $c
done

# Delete old images
for i in `docker images | grep -i $service | awk '{print $3}'`
do
    docker rmi -f $i
done

#===================================================================

docker run -d  \
    --sysctl net.ipv4.tcp_keepalive_time=160  \
    --sysctl net.ipv4.tcp_keepalive_probes=2  \
    --sysctl net.ipv4.tcp_keepalive_intvl=2  \
    -p $port:$port  \
    -v /etc/localtime:/etc/localtime:ro  \
    --name=$service  \
    $harbor/$service:$BUILD_TAG

if [ $? -ne 0 ];
then
        echo -e  "Sir! \n    docker run Error! \n        Please contact Ops or check the log for resolution"
        exit 1
fi

#===================================================================

sleep $sleep_second
docker ps | grep $service &> /dev/null

if [ $? -ne 0 ]; 
then
    docker logs -f `docker ps -a|grep -i $service | awk '{print $1}'`
    
    echo
    echo "服务启动异常！！！请排查问题"
    exit 1
else
    echo "服务启动成功哦！！！"
fi
