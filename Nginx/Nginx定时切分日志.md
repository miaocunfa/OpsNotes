---
title: "nginx定时切分日志"
date: "2019-11-06"
categories:
    - "技术"
tags:
    - "Nginx"
    - "日志备份"
    - "脚本"
toc: false
indent: false
original: true
---

## 切分日志
nginx日志随着时间而增长一直挺令人头疼，其实我们可以向nginx主进程发送信号`USR1`来生成新的日志文件，然后将旧的日志文件归档，下面是我用来切分日志的脚本。

``` shell
$ cat /home/test/bin/nginx_reload_logfile.sh

#!/bin/bash
# log_path
base_path='/usr/local/nginx-1.12.1/logs'
# get year and month
year_month=$(date -d yesterday +"%Y%m")
# get yesterday
day=$(date -d yesterday +"%d")

# create backup directory
mkdir -p $base_path/$year_month

# copy logfile to backup
mv $base_path/access.log $base_path/$year_month/access_$day.log

# 
echo $base_path/$year_month/access_$day.log
# reload logfile
kill -USR1 `cat /usr/local/nginx-1.12.1/logs/nginx.pid`
```

## 定时切分
crontab中添加定时任务，在每天23:59分执行切分日志的脚本
``` bash
# nginx access log backup
59 23 * * * sh /home/ysyf/bin/nginx_reload_logfile.sh
```

## 切分效果
切分后的效果如下，当然你也可以自定义你喜欢的路径，修改一下脚本即可。
``` bash
[root@master /usr/local/nginx-1.12.1/logs]# ll
总用量 490828
drwxr-xr-x 2 root   root      4096 10月  1 23:59 201909
drwxr-xr-x 2 root   root      4096 10月 31 23:59 201910
-rw-r--r-- 1 nobody root   2477169 11月  1 23:24 access.log
-rw-r--r-- 1 nobody root 499617441 11月  1 23:24 error.log
-rw-r--r-- 1 root   root         6 12月 31 2018 nginx.pid
[root@master /usr/local/nginx-1.12.1/logs]# cd 201910
[root@master /usr/local/nginx-1.12.1/logs/201910]# ll
总用量 64348
-rw-r--r-- 1 nobody root  956103 10月  2 23:58 access_01.log
-rw-r--r-- 1 nobody root  955541 10月  3 23:53 access_02.log
-rw-r--r-- 1 nobody root 1328787 10月  4 23:46 access_03.log
-rw-r--r-- 1 nobody root  533591 10月  5 23:54 access_04.log
-rw-r--r-- 1 nobody root 1048041 10月  6 23:59 access_05.log
-rw-r--r-- 1 nobody root  402311 10月  7 23:56 access_06.log
-rw-r--r-- 1 nobody root 3036879 10月  8 23:58 access_07.log
-rw-r--r-- 1 nobody root 2848916 10月  9 23:48 access_08.log
-rw-r--r-- 1 nobody root 2814881 10月 10 23:58 access_09.log
-rw-r--r-- 1 nobody root 3424007 10月 11 23:51 access_10.log
```