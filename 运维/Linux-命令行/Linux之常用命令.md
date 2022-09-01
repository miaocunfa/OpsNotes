---
title: "Linux 常用命令"
date: "2020-08-20"
categories: 
    - "技术"
tags: 
    - "linux"
    - "shell"
    - "运维"
toc: false
original: false
draft: false
---

## test命令

``` zsh
# 整数比较
-eq        =        if [ "$a" -eq "$b" ]
-ne        !=       if [ "$a" -ne "$b" ]
-gt        >        if [ "$a" -gt "$b" ]
-ge        >=       if [ "$a" -ge "$b" ]
-lt        <        if [ "$a" -lt "$b" ]
-le        <=       if [ "$a" -le "$b" ]

# 文件

```

## 1、定时查找删除180天之前的文件

``` zsh
➜  find /home/ysyf/backup -type f -name "ysyf_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;
➜  find /home/hsp/backup -type f -name "hsp_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;

-mtime +180 是查找修改日期在180以上的文件
-mtime -180 是查找修改日期在180以内的文件
```

加入crontab

``` zsh
# Remove 180 Ago ysyf-archive
00 02 * * * find /home/ysyf/backup -type f -name "ysyf_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;

# Remove 180 Ago hsp-archive
00 02 * * * find /home/hsp/backup -type f -name "hsp_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;
```

## 2、gbk 文件转 utf-8

``` zsh
➜  iconv -f gbk -t utf-8 source-file -o target-file
```

## 3、过滤文件 && 计数

``` zsh
# 过滤文件
➜  ls -l | grep ^-
-rwxr--r--. 1 root root 1533 Aug 31 11:28 bklog.sh
-rwxr--r--. 1 root root   31 Apr  9 13:46 copy-new-lib.sh
-rwxr--r--. 1 root root 2153 Aug 20 09:40 deploy.sh
-rwxr--r--. 1 root root 3157 Aug 19 16:47 deploy.sh.bak
-rwxr--r--. 1 root root  109 Apr  9 13:46 env.sh
-rwxr--r--. 1 root root 3382 Aug 19 09:25 restart.sh
-rwxr--r--. 1 root root  653 Apr  9 13:46 start.sh
-rwxr--r--. 1 root root  349 Apr  9 13:46 stop.sh
-rwxr--r--. 1 root root  182 Apr  9 13:46 test.sh

# 文件计数
# wc -l 是统计列数
➜  ls -l | grep ^- | wc -l
9

# wc -w 是统计单词数
➜  ls /home/miaocunfa/deployJar | wc -w
0
```

## 4、遍历文件每一行

``` zsh
    while read -r line
    do
        test_id=$(echo $line | awk '{print $1}')
        student_id=$(echo $line | awk '{print $2}')
        __getSidImage ${test_id} ${student_id}       # 根据学号将原始图片存入临时文件夹
    done < $sid_file
```

## 5、yum查看软件所有版本

``` zsh
yum --showduplicates list mysql-community-server
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
Available Packages
mysql-community-server.x86_64                                                                          8.0.22-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.23-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.24-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.25-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.26-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.27-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.28-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.29-1.el7                                                                           mysql80-community
mysql-community-server.x86_64                                                                          8.0.30-1.el7                                                                           mysql80-community
```
