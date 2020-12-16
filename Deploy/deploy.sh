#!/bin/bash

# Host: 所有部署机
# Path: /opt/aihangxunxi/bin
# Name: deploy.sh

# Describe:     deploy jar
# Create Date： 2020-05-28
# Create Time:  15:48
# Update Date:  2020-12-16
# Update Time:  15:38
# Author:       MiaoCunFa
# Version:      v1.0.2

#===================================================================
cur_datetime=$(date +'%Y%m%d.%H%M')
workPath="/opt/aihangxunxi"
worklibPath="$workPath/lib"

tcpMessagePort=":8080 "
tcpMessageSock=":9966 "
tcpMessagePortNum=1
tcpMessageSocktNum=1

deployPath="/home/miaocunfa/deployJar"
tailServiceLogFile="$workPath/bin/tail.service.log"
checkExceptionFile="$workPath/bin/checkException.sh"

#===================================================================

function __checkMessagePortStopping()
{
    echo
    echo "Waiting for MessageService Port Connection Close!"
    echo

    tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
    tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)

    while ( [ $tcpMessagePortNum -ge 1 ] || [ $tcpMessageSocktNum -ge 1 ] )
    do
        sleep 1
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
        tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)
    done
}

function __tailServiceLog()
{
    tailService=$(echo $1 | awk -F'.' '{print $1".log"}')
    echo -e "\t\ttail -f -n 200 $workPath/logs/$tailService" >> $tailServiceLogFile
}

function __printTailCommand()
{
    echo
    echo -e "\tIf you want to See logfile! Please execute this Command: "
    echo 
    cat $tailServiceLogFile
    echo
}

function __checkException()
{
    checkException=$(echo $1 | awk -F'.' '{print $1".log"}')
    echo "grep Exception $workPath/logs/$checkException" >> $checkExceptionFile
}

function __executeCheck()
{
    echo
    echo -e "Wait For Service Running!"
    echo
    sleep 5
    chmod u+x $checkExceptionFile
    sh $checkExceptionFile
}

function __stopAndStart()
{
    cd $workPath/bin

    # 停止部分
    ./stop.sh $1

    if [ $1 == "AitalkServer.jar" ]
    then
        # Waiting for MessageService Port Connection Close
        __checkMessagePortStopping
    fi

    # 替换备份
    mv $worklibPath/$1    $worklibPath/$1.$cur_datetime
    mv $deployPath/$1     $worklibPath/$1

    # 启动部分
    sleep 1
    ./start.sh $1
    __tailServiceLog $1
    #__checkException $1
}

#===================================================================
# reset
> $tailServiceLogFile
#> $checkExceptionFile

cd $deployPath

if [ -f "$deployPath/info-gateway.jar" ]
then
    __stopAndStart "info-gateway.jar"
fi

for i in $(ls $deployPath)
do
    __stopAndStart $i
done

#__executeCheck
__printTailCommand