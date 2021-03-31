---
title: "Nginx 日志规划"
date: "2031-03-31"
categories:
    - "技术"
tags:
    - "Nginx"
    - "日志备份"
    - "脚本"
toc: false
indent: false
original: true
draft: false
---

## 规划目标

公司现在有几十个nginx配置文件，日志文件位置乱七八糟的，有往/var/log输出的，有往logs/输出的，现在要统一将所有的日志文件输出到同一位置

``` zsh
/logs/nginx                      # 用于存放access、error日志
/logs/nginx.backup               # 用于存放定时切分的日志
/logs/nginx.backup/202101        # 按月存放
/logs/nginx.backup/202102
/logs/nginx.backup/202103
/logs/nginx.backup/202103/0329   # 按天存放
/logs/nginx.backup/202103/0330
/logs/nginx.backup/202103/0331
```

## 日志配置

在本地修改好所有的配置文件后打包成vhost.zip上传至服务器。

``` zsh
➜  mkdir -p /logs/{nginx,nginx.backup}  # 创建日志路径
➜  cd /usr/local/nginx/conf/
➜  cp -R vhost vhost.20210331    # 备份原配置
➜  unzip vhost.zip               # 覆盖配置文件
➜  nginx -t                      # 测试配置文件
➜  nginx -s reload               # 重载配置文件
```

## 切分脚本

修改好所有的配置文件后，需要对新生成的日志文件按天做切分，编写shell脚本来切分。

``` zsh
➜  mkdir -p /script/nginx
➜  vim /script/nginx/nginx_reload_logfile.sh
#!/bin/bash

# Describe:     split nginx log
# Create Date： 2021-03-31
# Create Time:  11:47
# Update Date:  2021-03-31
# Update Time:  11:47
# Author:       MiaoCunFa
# Version:      v0.0.1

#===================================================================

pid="/usr/local/nginx/logs/nginx.pid"
logs="/logs/nginx"
backup="/logs/nginx.backup"
month=$(date +"%Y%m")
day=$(date +"%m%d")

# create backup directory
if [ ! -d $backup/$month ];
then
    mkdir -p $backup/$month
fi

if [ ! -d $backup/$month/$day ];
then
    cd $backup/$month
    mkdir $day
fi

#===================================================================

for access in $(find $logs -name "*.access.log" -print)
do
    #echo $access
    mv $access $backup/$month/$day
done

for error in $(find $logs -name "*.error.log" -print)
do
    #echo $error
    mv $error $backup/$month/$day
done

# reload logfile
kill -USR1 $(cat $pid)

# 执行权限
➜  chmod u+x nginx_reload_logfile.sh
```

## 定时任务

使用crontab每天定时执行脚本切分日志。

``` zsh
➜  crontab -e
59 23 * * * sh /script/nginx/nginx_reload_logfile.sh
```
