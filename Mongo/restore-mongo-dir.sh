#!/bin/bash

# Describe:     MongoDB Restore From dir
# Create Date： 2020-10-27
# Create Time:  11:03
# Update Date:  2020-10-30
# Update Time:  18:05
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

mongoBin="/opt/mongodb-linux-x86_64-rhel70-4.2.2/bin"
dumpDir="/ahdata/mongodump/tar"
restoreDir="/ahdata/mongodump/restore"
host="192.168.100.226"
port="21000"

dirTar=$1
restoreDB=$2
UnTar=$(echo $1 | awk -F '.' '{print $1}')

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF

Usage:
    ./restore-mongo-dir.sh [tar] [db]

EOF

    exit 1
}

#===================================================================

# 判断是否传入 dir tar
if [ "$dirTar" == "" ]
then
    __usage
fi

# 判断是否传入 db
if [ "$restoreDB" == "" ]
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
    __exit_handler
fi

cp $dumpDir/$dirTar $restoreDir

cd $restoreDir
rm -rf $UnTar
tar -zxf $dirTar

# 还原
$mongoBin/mongorestore -h $host:$port --dir=$restoreDir/$UnTar -d $restoreDB
