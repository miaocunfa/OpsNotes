#!/bin/bash

# Describe:     create elasticsearch snapshot by date
# Create Date： 2020-09-14
# Create Time:  16:26
# Update Date： 2021-01-06
# Update Time:  14:32
# Author:       MiaoCunFa
# Version:      v1.0.2
#
# Usage:
#
# 1、查看仓库
# ➜  curMon=`date +'%Y%m'`; curl -s -X GET "localhost:9200/_snapshot/infov3.backup.${curMon}/_all" | jq .

#---------------------------Variable--------------------------------------

curDate=`date +'%Y%m%d'`
curMon=`date +'%Y%m'`
curTime=`date +'%H%M'`
error_reason=${var:-default}

repository="/ahdata/elasticsearch-repository"
esRepo="infov3.backup.${curMon}"
esSnapshot="infov3.${curDate}-${curTime}"

logFile="${repository}/snapshot_bydate.log"
resultFile="${repository}/result.log"

#---------------------------Function--------------------------------------

function __Write_LOG()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> ${logFile}
}

# 注册仓库
function __register_repo()
{
    curl -s -X POST "localhost:9200/_snapshot/$1" -H 'Content-Type: application/json' -d '
    {
        "type": "fs",
        "settings": {
          "location": "'"${repository}/$1"'"
        }
    }' > $resultFile

    isFail=$(cat $resultFile | grep 'error' | wc -l)

    if [ $isFail -ge 1 ]
    then
        # 获取报错信息
        unset error_reason
        __error_reason
    else
        # 返回成功
        return 0
    fi
}

function __error_reason()
{
    error_reason=$(cat $resultFile | jq .error.reason | awk -F'"' '{print $2}')
    status=$(cat $resultFile | jq .status)

    if [ "$status" == "null" ]
    then
        return 0
    else
        return 1
    fi
}

#--------------------------Main Script------------------------------------

# 仓库
if [ ! -d ${repository}/${esRepo} ]
then
    __register_repo ${esRepo}

    if [ $? == 0 ]
    then
        regRepo_result=$(cat $resultFile | jq .acknowledged)
        __Write_LOG  "LOG"  "Register Repo: ${es_Repo}: ${regRepo_result}!"
    else
        __Write_LOG  "ERR"  "Register Repo: ${es_Repo}: Fail!"
        __Write_LOG  "ERR"  "Register Repo: ${es_Repo}: ErrorReason: ${error_reason}"
        exit
    fi
fi

# 快照
__Write_LOG  "LOG"  "Make Snapshot: ${esSnapshot}: Begin!"
curl -s -X PUT "localhost:9200/_snapshot/${es_Repo}/${esSnapshot}?wait_for_completion=true" > $resultFile
__Write_LOG  "LOG"  "Make Snapshot: ${esSnapshot}: Done!"

isFail=$(cat $resulFile | grep 'error' | wc -l)

if [ $isFail -ge 1 ]
then
    # 获取报错信息
    unset error_reason
    __error_reason

    __Write_LOG  "ERR"  "Error Reason: ${esSnapshot}: ${error_reason}"
else
    snapshot_result=$(cat $resultFile | jq .snapshot.state | awk -F'"' '{print $2}')
    __Write_LOG  "LOG"  "Result: ${esSnapshot}: ${snapshot_result}"t
fi
