#!/bin/bash

# Describe:     Deploy.sh
# Create Date： 2019-12-04
# Create Time:  13:36
# Update Date： 2020-09-07
# Update Time:  13:36
# Author:       MiaoCunFa
#
# Usage:
# 1、put the JAR packages into the deploy directory
# 2、Execute this script

#---------------------------Variable--------------------------------------

EXITCODE=0
cur_datetime=$(date +'%Y%m%d.%H%M')
workPath="/opt/aihangxunxi"
worklibPath="$workPath/lib"

messagelib="AitalkServer.jar"
tcpMessagePort=":8080 "
tcpMessageSock=":9666 "
tcpMessagePortNum=1
tcpMessageSocktNum=1

deployPath="/home/miaocunfa/deployJar"
tail_logfile_CMD="$workPath/bin/tail.logfile.cmd"
check_logfile_Exception_Script="$workPath/bin/check_logfile_Exception.sh"

#---------------------------Function--------------------------------------

function __exit_handler()
{
    exit $EXITCODE
}

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

function __tail_logfile()
{
    echo -e "\t\t tail -f -n 200 $workPath/logs/$1" >> $tail_logfile_CMD
}

function __check_logfile_Exception()
{
    echo "grep Exception $workPath/logs/$1" >> $check_logfile_Exception_Script
}

#--------------------------Main Script------------------------------------

# 判断部署目录下是否有jar包需要部署，没有则退出
deployJarNum=$(ls $deployPath | wc -w)

if [ $deployJarNum -eq 0 ]
then
    echo "$deployPath: There are no JARS to deploy!"
    __exit_handler
fi

# 清空临时文件
> $tail_logfile_CMD
> $check_logfile_Exception_Script

# 循环遍历部署目录，执行部署
for i in $(ls $deployPath)
do
    cd $workPath/bin

    ./stop.sh $i

    if [ $i == $messagelib ]
    then
        # Waiting for MessageService Port Connection Close
        __checkMessagePortStopping
    fi

    mv $worklibPath/$i    $worklibPath/$i.$cur_datetime
    mv $deployPath/$i     $worklibPath/$i

    sleep 1
    ./start.sh $i

    logFile=$(echo $i | awk -F'.' '{print $1".log"}')
    __tail_logfile $logFile
    __check_logfile_Exception $logFile
done

echo
echo -e "Wait For Service Running!"
echo

# 判断是否有报错信息
sleep 5
chmod u+x $check_logfile_Exception_Script
sh $check_logfile_Exception_Script

# 输出 tail logfile 命令
echo
echo -e "\tIf you want to See logfile! Please execute this Command: "
echo 
cat $tail_Logfile_CMD
echo