#!/bin/bash

 d=`date --date today +%Y%m%d_%H:%M:%S`
#计算nginx进程数量
 n=`ps -C nginx --no-heading|wc -l`
#如果进程为0，则启动nginx，并且再次检测nginx进程数量，
#如果还为0，说明nginx无法启动，此时需要关闭keepalived
if [ $n -eq "0" ]; then
        nginx
        n2=`ps -C nginx --no-heading|wc -l`
        if [ $n2 -eq "0"  ]; then
                echo "$d nginx down,keepalived will stop" >> /var/log/check_ng.log
                systemctl stop keepalived
        fi
fi
