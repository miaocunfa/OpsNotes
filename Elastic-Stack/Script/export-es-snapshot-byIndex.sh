#!/bin/bash

# Describe:     export elasticsearch snapshot by index
# Create Date： 2020-10-14 
# Create Time:  16:15
# Update Date:  2021-01-06
# Update Time:  14:40
# Author:       MiaoCunFa
# Version:      v1.1.0

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
repository="/ahdata/elasticsearch-repository"
resultFile="${repository}/result.log"
error_reason=${var:-default}
EXITCODE=0
tag="test"

# 索引信息
unset esIndex
esIndex=$1
esRepo="${esIndex}.${curDate}"
esSnapshot="${esIndex}.${curDate}"

#===================================================================

function __exit_handler()
{
    exit $EXITCODE
}

function __usage(){

    cat << EOF

Usage:
    ./export-es-snapshot-byIndex.sh [index]

EOF

    exit 1
}

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

function __index_info()
{
    # 清空结果文件 && 获取状态
    truncate -s 0 $resultFile
    curl -s localhost:9200/_cat/indices/$1 > $resultFile

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

function __make_snapshot()
{
    curl -s -X PUT "localhost:9200/_snapshot/$1/$2?wait_for_completion=true" -H 'Content-Type: application/json' -d'
    {
        "indices": "'"$3"'",
        "ignore_unavailable": true,
        "include_global_state": false
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

#===================================================================

cd ${repository}

# 判断是否传入索引
if [ "$esIndex" == "" ]
then
    __usage
fi

#-------------------------------------------------------------------------

# 判断索引是否存在
echo
echo "索引"
echo "${esIndex}: 检测索引"

__index_info $esIndex    # 查看索引信息

if [ $? == 0 ]
then
    echo "${esIndex}: 存在, 继续导出!"
else
    echo "${esIndex}: 不存在, 程序退出!"
    __exit_handler
fi

#-------------------------------------------------------------------------

# 清理仓库
rm -rf ${repository}/${esRepo}

echo
echo "仓库"
echo "${esRepo}: 注册仓库"
__register_repo $esRepo

if [ $? == 0 ]
then
    echo "${esRepo}: 注册成功!"
else
    echo "${esRepo}: 注册失败!"
    echo "${esRepo}: ${error_reason}"
    __exit_handler
fi

#-------------------------------------------------------------------------

echo
echo "快照"
echo "${esSnapshot}: 开始制作"
__make_snapshot ${esRepo} ${esSnapshot} ${esIndex}

if [ $? == 0 ]
then
    echo "${esSnapshot}: 制作成功"
    cat $resultFile | jq .
else
    echo "${esSnapshot}: 制作失败!"
    echo "${esSnapshot}: ${error_reason}"
    __exit_handler
fi

tar -zcf ${esSnapshot}.tgz ${esSnapshot}
echo
echo "打包成功"
echo "${repository}/${esSnapshot}.tgz"
