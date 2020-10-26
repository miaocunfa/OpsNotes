#!/bin/bash

# Describe:     MongoDB Backup To dir
# Create Date： 2020-10-23
# Create Time:  15:48
# Update Date:  2020-10-26
# Update Time:  17:40
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d'`
curDateTime=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset db
db=$1
dumpDir="/opt/mongodump/dir"
tarDir="/opt/mongodump/tar"
env_tag="test"
host="192.168.100.226"
port="21000"
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

# 归档
mongodump -h $host:$port -o $dumpDir/$curDate -d $db

cd $dumpDir/$curDate

if [ ! -d $db ]
then
    echo "dump Mongo database: $db: Failed!"
    __exit_handler
fi

echo "dump Mongo database: $dumpTar: SUCCESS!"
tar -zcf $dumpTar $db
mv $dumpTar $dumpDir