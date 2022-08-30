#!/bin/bash
############################################################
# @Name:            cpu_load_status.sh
# @Version:         v1.1
# @Function:        cpu Status
# @Author:          guozhimin
# @Create Date:     2018-06-23
# @Update Date：    2021-03-11
# @Description:     Monitor CPU Service Status
############################################################

export TERM=linux

function minute_1(){
        uptime | awk '{print $10}'
}

function minute_5(){
       uptime | awk '{print $11}'
}

function minute_15(){
       uptime | awk '{print $12}'
}

function Usage(){
        cpucore=`cat /proc/cpuinfo | grep 'processor' |wc -l`
        cpuload=`top -bn 1 | grep 'load average' | awk -F":" '{print $5}' | awk -F"," '{print $1*100}'`
        cpuload_percent=$[${cpuload}/${cpucore}]
        echo $cpuload_percent
}

[ $# -ne 1 ] && echo "minute_1|minute_5|minute_15|Usage" && exit 1

$1