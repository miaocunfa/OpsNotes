#!/bin/bash

# Describe:     MongoDB Restore From dir
# Create Date： 2020-10-27
# Create Time:  11:03
# Update Date:  2020-10-27
# Update Time:  14:45
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset dirTar
dirTar=$1
dumpDir="/opt/mongodump"
restoreDir="/opt/mongodump/restore"
host="192.168.100.226"
port="21000"

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF

Usage:
    ./restore-mongo-dir.sh [tar]

EOF

    exit 1
}

#===================================================================

# 判断是否传入 dir tar
if [ "$dirTar" == "" ]
then
    __usage
fi

# 判断 归档文件 是否存在
if [ ! -f $dumpDir/$dirTar ]
then
    echo "$dumpDir/$dirTar: no such file or directory"
    __exit_handler
fi

# 判断 归档文件夹 是否存在
if [ ! -d $dumpDir/$restoreDir ]
then
    mkdir -p $restoreDir
fi

# 名称校验
if [[ ! $dirTar =~ "dir" ]]
then
    echo "$dumpDir/$dirTar: The file is not correct"
fi

mv $dirTar $restoreDir

# 归档
#mongodump -h $host:$port --archive=${archive} -d $db