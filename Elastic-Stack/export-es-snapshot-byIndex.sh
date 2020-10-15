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
