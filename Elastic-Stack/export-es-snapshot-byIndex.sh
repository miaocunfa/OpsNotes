#!/bin/bash
curDate=`date +'%Y%m%d-%H%M'`
repository="/ahdata/elasticsearch-repository"

# 索引信息
esIndex=$1
esSnapshot="${esIndex}_${curDate}"

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
