#!/bin/bash
# -------------------------------------------------------------------------------
# FileName:    check_mysql.sh
# Revision:    1.0
# Date:        2015/06/09
# Author:      DengYun
# Email:       dengyun@ttlsa.com
# Website:     www.ttlsa.com
# Description: 
# Notes:       ~
# -------------------------------------------------------------------------------
# Copyright:   2015 (c) DengYun
# License:     GPL 
# 用户名
MYSQL_USER='root'
 
# 密码
MYSQL_PWD='Zeng1978'
 
# 主机地址/IP
MYSQL_HOST='127.0.0.1'
 
# 端口
MYSQL_PORT='3306'
 
# 数据连接
MYSQL_CONN="/usr/bin/mysqladmin -u${MYSQL_USER} -p${MYSQL_PWD} -h${MYSQL_HOST} -P${MYSQL_PORT}"
 
# 参数是否正确
if [ $# -ne "1" ];then 
    echo "arg error!" 
fi 
 
# 获取数据
case $1 in 
    Uptime) 
        result=`${MYSQL_CONN} status|cut -f2 -d":"|cut -f1 -d"T"` 
        echo $result 
        ;; 
#Com-update：update操作语句个数/每秒
    Com_update) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_update"|cut -d"|" -f3` 
        echo $result 
        ;; 
#Slow_queries:慢查询
    Slow_queries) 
        result=`${MYSQL_CONN} status |cut -f5 -d":"|cut -f1 -d"O"` 
        echo $result 
        ;; 
#Com_select：select查询语句个数/每秒
    Com_select) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_select"|cut -d"|" -f3` 
        echo $result 
                ;; 
#mysql TPS
    Com_rollback) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_rollback"|cut -d"|" -f3` 
                echo $result 
                ;; 
#Questions:查询语句总量
    Questions) 
        result=`${MYSQL_CONN} status|cut -f4 -d":"|cut -f1 -d"S"` 
                echo $result 
                ;; 
#Com_insert：insert操作语句个数/每秒
    Com_insert) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_insert"|cut -d"|" -f3` 
                echo $result 
                ;; 
#Com-delete：delete操作语句个数/每秒
    Com_delete) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_delete"|cut -d"|" -f3` 
                echo $result 
                ;; 
#mysql TPS
    Com_commit) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_commit"|cut -d"|" -f3` 
                echo $result 
                ;; 
#mysql发送的流量
    Bytes_sent) 
        result=`${MYSQL_CONN} extended-status |grep -w "Bytes_sent" |cut -d"|" -f3` 
                echo $result 
                ;; 
#mysql接收的流量
    Bytes_received) 
        result=`${MYSQL_CONN} extended-status |grep -w "Bytes_received" |cut -d"|" -f3` 
                echo $result 
                ;; 
    Com_begin) 
        result=`${MYSQL_CONN} extended-status |grep -w "Com_begin"|cut -d"|" -f3` 
                echo $result 
                ;; 
#mysql当前大连接数
     Threads_connected)
        result=`${MYSQL_CONN} extended-status |grep -w "Threads_connected" |cut -d"|" -f3`                   
          echo $result
          ;;   
#mysql最大连接数
     max_connections)
        result=`${MYSQL_CONN} "show variables like max_connections" |grep max_connections`                   
          echo $result
          ;;   
      *) 
        echo "Usage:$0(Uptime|Com_update|Slow_queries|Com_select|Com_rollback|Questions|Com_insert|Com_delete|Com_commit|Bytes_sent|Bytes_received|Com_begin|Threads_connected|max_connections)" 
        ;; 
esac