# Gitlab 定时备份脚本
## 脚本主程序如下
```
#===========================Set Parameter========================================
ENVFILE="/etc/profile"
EXITCODE=0
fileDate=`date +'%Y_%m_%d'`
curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`
weekday=`date +'%a'`
backupDir=/var/opt/gitlab/backups
gitlab_backupLog=/var/opt/gitlab/backups/gitlab_backup.log
gitlab_optLog=gitlab_opt.log
mailContext="邮件内容初始化"

#===========================Function =========================================
function __exit_handler()
{
	exit $EXITCODE
}

function __write_log()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> $gitlab_backupLog
}

#===========================Load the environment file============================
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	__exit_handler
fi

#===========================Backup And Send The File To Remote Host=========================
cd $backupDir

__write_log "log" "gitlab-rake Start!"

gitlab-rake gitlab:backup:create > $gitlab_optLog

__write_log "log" "gitlab-rake Success!"

backupFile=$(cat $gitlab_optLog | grep "Creating backup archive:" | awk '{print $4}')
mv $backupFile gitlab_backup_$weekday.tar

__write_log "log" "gitlab-backupFile: gitlab_backup_$weekday.tar"

sshpass -p test123 scp gitlab_backup_$weekday.tar root@192.168.100.238:/root/gitlab/backup

if [ $? == 0 ]
then
    mailContext="gitlab 备份成功及上传ftp成功"
    __write_log "log" "SCP file Success!"
    
    # Delete BackupFile And OptLog
    rm -f gitlab_backup_$weekday.tar
    rm -f $gitlab_optLog
    __write_log "log" "Remove file: gitlab_backup_$weekday.tar"
    __write_log "log" "Remove file: $gitlab_optLog"
else
    mailContext="gitlab 备份成功但上传ftp不成功"
    __write_log "log" "SCP file Fail!"

    # Delete OptLog
    rm -f $gitlab_optLog
    __write_log "log" "Remove file: $gitlab_optLog"
fi

# Send Mail to admin
echo $mailContext | mail -s "gitlab $curDate 备份" shu-xian@126.com
echo $mailContext | mail -s "gitlab $curDate 备份" miaocunf@126.com

__write_log "log" "Mail Send Success!"
__write_log "log" "End of Program!"

# Exit Shell Script
__exit_handler
```

## 定时任务
``` shell
[root@localhost bin]# crontab -l
00 01 * * * /bin/bash /home/gitlab/bin/gitlab_backup.sh
```

## 日志打印
我特意在新改版的shell中添加了日志记录的功能，每次执行脚本记录的日志如下。
``` log
2019-12-03 14:32:15 [log] gitlab-rake Start!
2019-12-03 14:35:03 [log] gitlab-rake Success!
2019-12-03 14:35:03 [log] gitlab-backupFile: gitlab_backup_Tue.tar
2019-12-03 14:35:29 [log] SCP file Success!
2019-12-03 14:35:29 [log] Remove file: gitlab_backup_Tue.tar
2019-12-03 14:35:29 [log] Remove file: gitlab_opt.log
2019-12-03 14:35:29 [log] Mail Send Success!
2019-12-03 14:35:29 [log] End of Program!
```
