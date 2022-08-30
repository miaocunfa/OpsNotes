---
title: "Oracle 定时备份脚本"
date: "2019-11-06"
categories:
    - "技术"
tags:
    - "Oracle"
    - "数据备份"
    - "脚本"
toc: false
indent: false
original: true
draft: false
---

## 脚本主程序

``` shell
[root@master ~]-cat expDB_DailyBackup.sh 
#---------------------------Set Parameter----------------------------------------
ENVFILE="/etc/profile"
EXITCODE=0
uDate=`date +'%Y%m%d'`
Week=`date +'%a'`
dbBackup=/home/app/backup/db_Daily
tarName=app_${uDate}_DB_DailyBk.tar.gz

#---------------------------Exit Program----------------------------------------
exit_handler()
{
	exit $EXITCODE
}

#---------------------------Load the environment file----------------------------------------
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	exit_handler
fi

#---------------------------Backup Application To Directory----------------------------------------
cd $dbBackup

# Export Database To File
exp app_admin/app_admin file=app_${uDate}_DB_DailyBk.dmp 

#---------------------------Send The File To Remote Host----------------------------------------
cd $dbBackup
tar -zcvf $tarName app_${uDate}_DB_DailyBk.dmp

# Rename Backup For Remote Host
cp $tarName app_${Week}_DB_DailyBk.tar.gz 

lftp << EOF
 open sftp://10.0.0.18:1022
 user backup backup!@#
 cd db_Daily
 put app_${Week}_DB_DailyBk.tar.gz
 exit
EOF

# Delete Rename Backup
rm -f app_${Week}_DB_DailyBk.tar.gz 
rm -f app_${uDate}_DB_DailyBk.dmp

# Exit Shell Script
exit_handler
```

## 定时任务

crontab设置定时任务，每天23:55分开始备份。

``` zsh
# app Daily Backup 
55 23 * * * sh /home/app/bin/expDB_DailyBackup.sh
```
