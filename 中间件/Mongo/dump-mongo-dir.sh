#!/bin/bash

# Host: PG1
# Path: /ahdata/mongodump
# Name: dump-mongo-dir.sh

# Describe:     MongoDB Backup To dir
# Create Date： 2020-10-23
# Create Time:  15:48
# Update Date:  2020-10-30
# Update Time:  17:17
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d'`
curDateTime=`date +'%Y%m%d-%H%M'`
EXITCODE=0

mongoBin="/opt/mongodb-linux-x86_64-rhel70-4.2.2/bin"
dumpDir="/ahdata/mongodump/dir"
tarDir="/ahdata/mongodump/tar"

# env_tag="test"
# host="192.168.100.226"

env_tag="prod"
host="pg1"

port="21000"
db=$1
dumpTar="${db}.${env_tag}.${curDateTime}.dir.tgz"

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF

Usage:
    ./dump-mongo-dir.sh [db]

EOF

    exit 1
}

#===================================================================

# 判断是否传入db
if [ "$db" == "" ]
then
    __usage
fi

# 判断是否存在归档目录，若不存在即创建
if [ ! -d $dumpDir ]
then
    mkdir -p $dumpDir
fi

# 判断是否存在tar目录，若不存在即创建
if [ ! -d $tarDir ]
then
    mkdir -p $tarDir
fi

# 归档
$mongoBin/mongodump -h $host:$port -o $dumpDir/$curDate -d $db

cd $dumpDir/$curDate

if [ ! -d $db ]
then
    echo "dump Mongo database: $db: Failed!"
    __exit_handler
fi

echo "dump Mongo database: $dumpTar: SUCCESS!"
tar -zcf $dumpTar $db
mv $dumpTar $tarDir