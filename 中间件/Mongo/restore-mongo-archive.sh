#!/bin/bash

# Describe:     MongoDB Restore From archive
# Create Date： 2020-10-23 
# Create Time:  16:30
# Update Date:  2020-10-26
# Update Time:  14:45
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset archiveTar
archiveTar=$1
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
    ./restore-mongo-archive.sh [tar]

EOF

    exit 1
}

#===================================================================

# 判断是否传入 archive
if [ "$archiveTar" == "" ]
then
    __usage
fi

# 判断 归档文件 是否存在
if [ ! -f $dumpDir/$archiveTar ]
then
    echo "$dumpDir/$archiveTar: no such file or directory"
    __exit_handler
fi

# 判断 归档文件夹 是否存在
if [ ! -d $dumpDir/$restoreDir ]
then
    mkdir -p $restoreDir
fi

# 名称校验
if [[ ! $archiveTar =~ "archive" ]]
then
    echo "$dumpDir/$archiveTar: The file is not correct"
    __exit_handler
fi

mv $archiveTar $restoreDir

# 还原
# mongodump -h $host:$port --archive=${archive} -d $db