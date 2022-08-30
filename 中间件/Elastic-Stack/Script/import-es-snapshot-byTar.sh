#!/bin/bash

# Describe:     import elasticsearch snapshot by tarball
# Create Date： 2020-10-15
# Create Time:  09:15
# Update Date： 2021-01-06
# Update Time:  10:37
# Author:       MiaoCunFa
# Version:      v1.1.0

#===================================================================

curDate=`date +'%Y%m%d'`
EXITCODE=0
repository="/ahdata/elasticsearch-repository"
resultFile="${repository}/result.log"
error_reason=${var:-default}
esUser=zyes

# 导入信息
tar=$1         # 要导入的包
index=$2       # 要导入的索引

# 快照信息
esRepo=$(echo $tar | awk -F. '{print $1 "." $2}')       # 仓库   
snapshot=$(echo $tar | awk -F. '{print $1 "." $2}')     # 快照
snapshotIndex=$(echo $tar | awk -F. '{print $1}')       # 快照索引

#===================================================================

function __exit_handler()
{
    exit $EXITCODE
}

function __usage(){

    cat << EOF

Usage:
    ./import-es-snapshot-byTar.sh [tar] [index]

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

function __delete_info()
{
    # 清空结果文件 && 获取状态
    truncate -s 0 $resultFile
    curl -s -X DELETE localhost:9200/$1 > $resultFile

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

function __restore_snapshot()
{
    # 清空结果文件 && 获取状态
    truncate -s 0 $resultFile

    curl -s -X POST "localhost:9200/_snapshot/$1/$2/_restore" -H 'Content-Type: application/json' -d'
    {
        "indices": "'"$3"'",
        "ignore_unavailable": true,
        "include_global_state": true,
        "rename_pattern": "'"$3"'",
        "rename_replacement": "'"$4"'"
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

    # 若不报错，则返回0
    if [ "$status" == "null" ]
    then
        return 0
    else
        return 1
    fi
}

#===================================================================

cd $repository

# 判断是否传入tar包
if [ "$tar" == "" ]
then
    __usage
fi

# 判断是否传入index
if [ "$index" == "" ]
then
    __usage
fi

# 判断是否存在tar包
if [ ! -f $repository/$tar ]
then
    echo "$repository/$tar: no such file or directory"
    __exit_handler
fi

#-------------------------------------------------------------------------

# 清理仓库
rm -rf $repository/${esRepo}

echo
echo "注册仓库"
__register_repo ${esRepo}

if [ $? == 0 ]
then
    echo "${esRepo}: 注册成功!"
else
    echo "${esRepo}: 注册失败!"
    echo "${esRepo}: ${error_reason}"
fi

# 整理快照文件
tar -zxf $tar
chown -R $esUser:$esUser $repository

#-------------------------------------------------------------------------

echo
echo "索引"
echo "${index}: 检测索引"

__index_info $index    # 查看索引信息

if [ $? == 0 ]
then
    echo "${index}: 存在, 删除索引!"

    __delete_info $index   # 删除索引

    if [ $? == 0 ]
    then
        echo "${index}: 删除成功!" 
    else
        echo "${index}: 删除失败!" 
        __exit_handler
    fi
else
    echo "${index}: 不存在, 继续导入!"
fi

#-------------------------------------------------------------------------

echo
echo "还原"
echo "${snapshot}: 开始还原!"

__restore_snapshot ${esRepo} ${snapshot} ${snapshotIndex} ${index}    # 还原索引

if [ $? == 0 ]
then
    echo "${snapshot}: 还原成功!"
    cat $resultFile | jq .
else
    echo "${snapshot}: 还原失败!"
    echo "${snapshot}: ${error_reason}"
fi

#-------------------------------------------------------------------------

echo
echo "验证"

__index_info $index

if [ $? == 0 ]
then
    cat $resultFile
else
    echo "${index}: 不存在, 请重新导入!"
fi
