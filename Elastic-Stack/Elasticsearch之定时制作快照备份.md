---
title: "Elasticsearch之定时制作快照备份"
date: "2020-09-16"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "运维"
toc: false
original: true
---

## 一、备份脚本

脚本可在执行运维操作前手动执行备份快照，也可写入crontab，做定时快照，用于数据恢复。

``` shell
#!/bin/bash

# Describe:     create elasticsearch snapshot by date
# Create Date： 2020-09-14
# Create Time:  16:26
# Update Date： 2020-09-16
# Update Time:  16:10
# Author:       MiaoCunFa
#
# Usage:
#
# 1、查看仓库
# ➜  curl -X GET "localhost:9200/_snapshot/infov3_backup/_all"

#---------------------------Variable--------------------------------------

curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M'`
error_reason=${var:-default}

repository="/ahdata/elasticsearch-repository"
es_Repo="infov3_test"
es_Snapshot="infov3_${curDate}-${curTime}"
#es_Snapshot="infov3_${curDate}"

logFile="${repository}/snapshot_bydate.log"
resultFile="${repository}/result.log"

#---------------------------Function--------------------------------------

function __Write_LOG()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> ${logFile}
}

function __Register_Repo()
{
    curl -s -X POST "localhost:9200/_snapshot/${es_Repo}" -H 'Content-Type: application/json' -d '
    {
        "type": "fs",
        "settings": {
          "location": "'"${repository}/${es_Repo}"'"
        }
    }' > $resultFile
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

# 判断仓库状态
if [ ! -d ${repository}/${es_Repo} ]
then
    __Register_Repo
    unset error_reason
    __error_reason

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

# 制作快照
__Write_LOG  "LOG"  "Make Snapshot: ${es_Snapshot}: Begin!"
curl -s -X PUT "localhost:9200/_snapshot/${es_Repo}/${es_Snapshot}?wait_for_completion=true" > $resultFile
__Write_LOG  "LOG"  "Make Snapshot: ${es_Snapshot}: Done!"

# 判断状态
unset error_reason
__error_reason

if [ $? == 0 ]
then
    snapshot_result=$(cat $resultFile | jq .snapshot.state | awk -F'"' '{print $2}')
    __Write_LOG  "LOG"  "Result: ${es_Snapshot}: ${snapshot_result}"
else
    __Write_LOG  "ERR"  "Error Reason: ${es_Snapshot}: ${error_reason}"
fi
```

## 二、crontab

``` zsh
➜  crontab -l
01 00 * * * /opt/elasticsearch-7.1.1/bin/es_snapshot_by_date.sh;
```

## 三、脚本日志

``` zsh
# 原先是Start、Stop，后来修改为Begin、Done
➜  cat snapshot_bydate.log
2020-09-16 16:06:26 [ERR] Register Repo: infov3_test: Fail!
2020-09-16 16:06:26 [ERR] Register Repo: infov3_test: ErrorReason: [infov3_test] failed to create repository
2020-09-16 16:08:02 [LOG] Register Repo: infov3_test: true!
2020-09-16 16:08:02 [LOG] Make Snapshot: infov3_20200916: Begin!
2020-09-16 16:08:03 [LOG] Make Snapshot: infov3_20200916: Done!
2020-09-16 16:08:04 [LOG] Result: infov3_20200916: SUCCESS
2020-09-16 16:08:17 [LOG] Make Snapshot: infov3_20200916: Begin!
2020-09-16 16:08:17 [LOG] Make Snapshot: infov3_20200916: Done!
2020-09-16 16:08:17 [ERR] Error Reason: infov3_20200916: [infov3_test:infov3_20200916] Invalid snapshot name [infov3_20200916], snapshot with the same name already exists
2020-09-16 16:08:43 [LOG] Make Snapshot: infov3_20200916-1608: Begin!
2020-09-16 16:08:44 [LOG] Make Snapshot: infov3_20200916-1608: Done!
2020-09-16 16:08:44 [LOG] Result: infov3_20200916-1608: SUCCESS
2020-09-16 16:09:03 [LOG] Make Snapshot: infov3_20200916-1609: Begin!
2020-09-16 16:09:04 [LOG] Make Snapshot: infov3_20200916-1609: Done!
2020-09-16 16:09:04 [LOG] Result: infov3_20200916-1609: SUCCESS
```
