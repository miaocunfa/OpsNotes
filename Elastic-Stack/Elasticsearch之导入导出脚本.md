---
title: "Elasticsearch之导入导出脚本"
date: "2020-10-15"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "运维"
toc: false
original: true
---

## 概述

## 一、导出脚本

``` sh
#!/bin/bash

# Describe:     export elasticsearch snapshot by index
# Create Date： 2020-10-14
# Create Time:  16:15
# Update Date:  2020-10-15
# Update Time:  13:55
# Author:       MiaoCunFa

#===================================================================

curDate=`date +'%Y%m%d-%H%M'`
repository="/ahdata/elasticsearch-repository"
EXITCODE=0

# 索引信息
unset esIndex
esIndex=$1
esSnapshot="${esIndex}_${curDate}"

#===================================================================

__exit_handler()
{
    exit $EXITCODE
}

__usage(){

    cat << EOF
Usage:
    ./export-es-snapshot-byIndex.sh [index]
EOF

    exit 1
}

#===================================================================

if [ "$esIndex" == "" ]
then
    __usage
fi

rm -rf ${repository}/${esSnapshot}

echo "注册仓库"
curl -s -X POST "localhost:9200/_snapshot/ahtest_backup" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "'"/ahdata/elasticsearch-repository/${esSnapshot}"'"
  }
}' | jq .

echo
echo "制作快照"
curl -s -X PUT "localhost:9200/_snapshot/ahtest_backup/${esSnapshot}?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": "'"${esIndex}"'",
  "ignore_unavailable": true,
  "include_global_state": false
}' | jq .

cd ${repository}
tar -zcf ${esSnapshot}.tgz ${esSnapshot}
```

## 二、导入脚本

``` sh
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
```

## 三、脚本实例

导出部分的情景演示

``` zsh
# 1、不指定索引 提示Usage
➜  ./export-es-snapshot-byIndex.sh

Usage:
    ./export-es-snapshot-byIndex.sh [index]

# 2、正常导出
➜  ./export-es-snapshot-byIndex.sh infos
注册仓库
{
  "acknowledged": true
}

制作快照
{
  "snapshot": {
    "snapshot": "infos_20201015-1522",
    "uuid": "pCk0aCmHRO67ZtYjrnoLvw",
    "version_id": 7010199,
    "version": "7.1.1",
    "indices": [
      "infos"
    ],
    "include_global_state": false,
    "state": "SUCCESS",
    "start_time": "2020-10-15T07:22:44.746Z",
    "start_time_in_millis": 1602746564746,
    "end_time": "2020-10-15T07:22:58.479Z",
    "end_time_in_millis": 1602746578479,
    "duration_in_millis": 13733,
    "failures": [],
    "shards": {
      "total": 3,
      "failed": 0,
      "successful": 3
    }
  }
}

# 3、输入错误索引
➜  ./export-es-snapshot-byIndex.sh fdsf
no such index [fdsf]
```

导入部分的情景演示

``` zsh
# 1、不指定tar包 提示Usage
➜  ./import-es-snapshot-byTar.sh

Usage:
    ./import-es-snapshot-byTar.sh [tar]

# 2、指定错误文件
➜  ./import-es-snapshot-byTar.sh infos_20201015-fsd
/home/miaocunfa/data/infos_20201015-fsd: no such file or directory

# 3、正常导入
➜  ./import-es-snapshot-byTar.sh infos_20201015-1522.tgz
注册仓库
{
  "acknowledged": true
}

索引信息: infos
yellow open infos O8vUhI97Sc-ztwejg1Zalg 3 1 158 155 217.1kb 217.1kb

删除索引：infos
{
  "acknowledged": true
}

快照还原：infos_20201015-1522
{
  "accepted": true
}

索引信息：infos
yellow open infos SiYQZABwT-qRuQL2soRfFQ 3 1
```
