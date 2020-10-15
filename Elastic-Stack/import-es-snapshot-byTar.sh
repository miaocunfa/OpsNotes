#!/bin/bash

# Describe:     import elasticsearch snapshot by tarball
# Create Date： 2020-10-15
# Create Time:  09:15
# Update Date： 2020-10-15
# Update Time:  18:28
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d'`
EXITCODE=0
dataDir="/home/miaocunfa/data"
repository="/ahdata/elasticsearch-repository"
esUser=zyes

# es 快照信息
tar=$1
snapshot=$(echo $tar | awk -F. '{print $1}')
esIndex=$(echo $tar | awk -F_ '{print $1}')

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF

Usage:
    ./import-es-snapshot-byTar.sh [tar]

EOF

    exit 1
}

#===================================================================

# 判断是否传入tar包
if [ "$tar" == "" ]
then
    __usage
fi

# 判断是否存在tar包
if [ ! -f $dataDir/$tar ]
then
    echo "$dataDir/$tar: no such file or directory"
    __exit_handler
fi

# 清理仓库
rm -rf $repository/$snapshot

echo "注册仓库"
curl -s -X POST "localhost:9200/_snapshot/${snapshot}" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "'"/ahdata/elasticsearch-repository/${snapshot}"'"
  }
}' | jq .

# 整理快照文件
mv $dataDir/$tar $repository
cd $repository
tar -zxf $tar
chown -R $esUser:$esUser $repository

echo
echo "索引信息: $esIndex"
curl localhost:9200/_cat/indices/${esIndex}

echo
echo "删除索引：$esIndex"
curl -s -X DELETE localhost:9200/infos | jq .

echo
echo "快照还原：$snapshot"
curl -s -X POST "localhost:9200/_snapshot/${snapshot}/${snapshot}/_restore" | jq .

echo
echo "索引信息：$esIndex"
curl localhost:9200/_cat/indices/$esIndex
