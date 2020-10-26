#!/bin/bash

# Describe:     MongoDB Backup To archive
# Create Date： 2020-10-23 
# Create Time:  15:09
# Update Date:  2020-10-26
# Update Time:  17:39
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset db
db=$1
dumpDir="/opt/mongodump/archive"
tarDir="/opt/mongodump/tar"
env_tag="test"
host="192.168.100.226"
port="21000"
archive="${db}.${env_tag}.${curDate}.archive"

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF

Usage:
    ./dump-mongo-archive.sh [db]

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
mongodump -h $host:$port --archive=${dumpDir}/${archive} -d $db

cd $dumpDir
tar -zcf $archive.tgz  $archive
mv $archive.tgz $tarDir