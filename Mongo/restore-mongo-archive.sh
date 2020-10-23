#!/bin/bash

# Describe:     MongoDB Restore From archive
# Create Date： 2020-10-23 
# Create Time:  16:30
# Update Date:  2020-10-23
# Update Time:  
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
EXITCODE=0

unset archive
archive=$1
dumpDir="/opt/mongodump"
env_tag="test"
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
    ./restore-mongo-archive.sh [db]

EOF

    exit 1
}

#===================================================================

# 判断是否传入 archive
if [ "$archive" == "" ]
then
    __usage
fi

# 判断归档是否存在
if [ ! -f $dumpDir/$archive ]
then
    echo "$dumpDir/$archive: no such file or directory"
    __exit_handler
fi

# 名称校验
if [ ! $archive =~ ".archive" ]
then
    echo "$dumpDir/$archive: The file is not correct"
fi

# 归档
#mongodump -h $host:$port --archive=${archive} -d $db