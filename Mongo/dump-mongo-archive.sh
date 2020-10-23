#!/bin/bash

# Describe:     MongoDB Backup To archive
# Create Date： 2020-10-23 
# Create Time:  15:09
# Update Date:  2020-10-23
# Update Time:  15:38
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset db
db=$1
dumpDir="/opt/mongodump"
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

# 归档
mongodump -h $host:$port --archive=${archive} -d $db