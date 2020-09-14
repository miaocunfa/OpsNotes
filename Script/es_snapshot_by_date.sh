#!/bin/bash

# Describe:     create elasticsearch snapshot by date
# Create Date： 2020-09-14 
# Create Time:  16:26
# Update Date： -
# Update Time:  -
# Author:       MiaoCunFa

# Usage:
# echo "注册仓库"
# curl -s -X POST "localhost:9200/_snapshot/infov3_backup" -H 'Content-Type: application/json' -d '
# {
#   "type": "fs",
#   "settings": {
#     "location": "/ahdata/elasticsearch-repository/infov3_backup"
#   }
# }' | jq .

#---------------------------Variable--------------------------------------

curDate=`date +'%Y%m%d'`
repository="/ahdata/elasticsearch-repository"
esSnapshot="infov3_${curDate}"
logFile="/ahdata/elasticsearch-repository/snapshot_bydate.log"

#---------------------------Function--------------------------------------

function __write_log()
{
  echo "$(date "+%Y-%m-%d %H:%M:%S") [$1] $2" >> ${logFile}
}

#--------------------------Main Script------------------------------------
# 制作快照
__write_log  "LOG"  "${esSnapshot}: Make Snapshot Start!"
snapshot_result=$(curl -s -X PUT "localhost:9200/_snapshot/infov3_backup/${esSnapshot}?wait_for_completion=true")
__write_log  "LOG"  "${esSnapshot}: Make Snapshot Stop!"

result_flag=$(echo ${snapshot_result} | jq .snapshot.state)

if [ ${result_flag} == "null" ]
then
    error_reason=$(echo ${snapshot_result} | jq .error.reason)
    __write_log  "ERR"  "${esSnapshot}: Error Reason: ${error_reason}"
else
    result_flag=$(echo ${snapshot_result} | jq .snapshot.state | awk -F'"' '{print $2}')
    if [ $result_flag == "SUCCESS" ]
    then
        __write_log  "LOG"  "${esSnapshot}: Make Snapshot Result: ${result_flag}"
    fi
fi