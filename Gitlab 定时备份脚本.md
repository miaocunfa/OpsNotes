```
#===========================Set Parameter========================================
ENVFILE="/etc/profile"
EXITCODE=0
fileDate=`date +'%Y_%m_%d'`
curDate=`date +'%Y%m%d'`
backupDir=/var/opt/gitlab/backups
backupFile=`find $backupDir -name "*${fileDate}*gitlab_backup.tar" -print`
mailContext="邮件内容初始化"

#===========================Exit Program=========================================
exit_handler()
{
	exit $EXITCODE
}

#===========================Load the environment file============================
if [ -r "$ENVFILE" ]
then
	source $ENVFILE
else
	EXITCODE=-1
	exit_handler
fi

#===========================Backup And Send The File To Remote Host=========================
cd $backupDir

gitlab-rake gitlab:backup:create

lftp << EOF
 open sftp://10.0.0.18:1022
 user backup backup!@#
 put $backupFile
 exit
EOF

if [ $? == 0 ]
then
    mailContext="gitlab 备份成功及上传ftp成功"
    
    # Delete BackupFile
    rm -f $backupFile
else
    mailContext="gitlab 备份成功但上传ftp不成功"
fi

# Send Mail to admin
echo $mailContext | mail -s "gitlab $curDate 备份" shu-xian@163.com

# Exit Shell Script
exit_handler
```
