elasticsearch 的快照和还原

> 官网链接  
> https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-snapshots.html#modules-snapshots


```
curl localhost:9200/_cat/snapshots/

# return
{
	"error": {
		"root_cause": [{
			"type": "action_request_validation_exception",
			"reason": "Validation Failed: 1: repository is missing;"
		}],
		"type": "action_request_validation_exception",
		"reason": "Validation Failed: 1: repository is missing;"
	},
	"status": 400
}
```

```
curl -XPOST "localhost:9200/_snapshot/my_backup" -d '
{
  "type": "fs",
  "settings": {
    "location": "/data"
  }
}'

# return
{
	"error": "Content-Type header [application/x-www-form-urlencoded] is not supported",
	"status": 406
}
```

```
curl -XPOST "localhost:9200/_snapshot/my_backup" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "/data"
  }
}'

# return
{
	"error": {
		"root_cause": [{
			"type": "repository_exception",
			"reason": "[my_backup] location [/data] doesn't match any of the locations specified by path.repo because this setting is empty"
		}],
		"type": "repository_exception",
		"reason": "[my_backup] failed to create repository",
		"caused_by": {
			"type": "repository_exception",
			"reason": "[my_backup] location [/data] doesn't match any of the locations specified by path.repo because this setting is empty"
		}
	},
	"status": 500
}


```

# 创建仓库
```
在为es集群环境做灾备和恢复时候，首先需要创建创建一个仓库，并往仓库中存放快照（每个快照中会区分不同的索引）。但是在创建仓库的时候，要求仓库的地址必须在每个集群环境中的elasticsearch.yml中进行配置（相当于一个白名单列表）：
    单个：path.repo: /mnt
    多个：path.repo: [“/data” , “/mnt”]
[zyes@localhost ~]$cd /opt/elasticsearch-7.1.1/config
[zyes@localhost /opt/elasticsearch-7.1.1/config]$vi elasticsearch.yml

mkdir -p /ahdata/elasticsearch-repository
chown -R zyes:zyes /data

curl -XPOST "localhost:9200/_snapshot/ah_backup" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "/ahdata/elasticsearch-repository/ah_backup"
  }
}'

# return
{
	"acknowledged": true
}
```

# 查看仓库
```
curl -X GET "localhost:9200/_snapshot/my_backup"

return
{
	"my_backup": {
		"type": "fs",
		"settings": {
			"location": "/data/elasticsearch-repository/my_backup"
		}
	}
}
```

# 创建快照
```
curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_info-ad-topic?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad-topic",
  "ignore_unavailable": true,
  "include_global_state": false
}
'

return
{
	"snapshot": {
		"snapshot": "info-ad",
		"uuid": "TFfLTx1TRe2w35f558tFpw",
		"version_id": 7010199,
		"version": "7.1.1",
		"indices": ["info-ad"],
		"include_global_state": false,
		"state": "SUCCESS",
		"start_time": "2019-12-12T07:57:43.597Z",
		"start_time_in_millis": 1576137463597,
		"end_time": "2019-12-12T07:57:44.382Z",
		"end_time_in_millis": 1576137464382,
		"duration_in_millis": 785,
		"failures": [],
		"shards": {
			"total": 1,
			"failed": 0,
			"successful": 1
		}
	}
}
```


# 还原快照
```
curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_info-ad-topic/_restore" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad-topic",
  "ignore_unavailable": true,
  "include_global_state": true,
  "rename_pattern": "info-ad-topic",
  "rename_replacement": "restored_info-ad-topic"
}
'

# return
{
	"accepted": true
}
```

curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d '
{
  "source": {
    "index": "restored_info-ad"
  },
  "dest": {
    "index": "info-ad-restored"
  }
}
'

集群nfs
{
	"error": {
		"root_cause": [{
			"type": "repository_verification_exception",
			"reason": "[ah_backup] [[cib4J3-9S-Gu-HxzElx1KQ, 'RemoteTransportException[[node-1][172.19.26.3:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-1}{cib4J3-9S-Gu-HxzElx1KQ}{rcOvdo8VQ4eVJEqDRVwExQ}{172.19.26.3}{172.19.26.3:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];'], [tdlv8aquS_qiKOi7S1ODbg, 'RemoteTransportException[[node-3][172.19.26.4:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-3}{tdlv8aquS_qiKOi7S1ODbg}{MSLA7qUeTJWoQ0Qr90E-ug}{172.19.26.4}{172.19.26.4:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];']]"
		}],
		"type": "repository_verification_exception",
		"reason": "[ah_backup] [[cib4J3-9S-Gu-HxzElx1KQ, 'RemoteTransportException[[node-1][172.19.26.3:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-1}{cib4J3-9S-Gu-HxzElx1KQ}{rcOvdo8VQ4eVJEqDRVwExQ}{172.19.26.3}{172.19.26.3:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];'], [tdlv8aquS_qiKOi7S1ODbg, 'RemoteTransportException[[node-3][172.19.26.4:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-3}{tdlv8aquS_qiKOi7S1ODbg}{MSLA7qUeTJWoQ0Qr90E-ug}{172.19.26.4}{172.19.26.4:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];']]"
	},
	"status": 500
}

```
node01
yum install -y nfs-utils
mkdir -p /ahdata/elasticsearch-repository

cd ahdata/
chown -R elasticsearch:elasticsearch elasticsearch-repository/

---------------------
node02
yum install -y nfs-utils
mkdir -p /ahdata/elasticsearch-repository

cd ahdata/
chown -R elasticsearch:elasticsearch elasticsearch-repository/

mount -t nfs DB1:/ahdata/elasticsearch-repository /ahdata/elasticsearch-repository

----------------------
node03
yum install -y nfs-utils
mkdir -p /ahdata/elasticsearch-repository

cd ahdata/
chown -R elasticsearch:elasticsearch elasticsearch-repository/

mount -t nfs DB1:/ahdata/elasticsearch-repository /ahdata/elasticsearch-repository

```

[root@DB1 /ahdata]#ps -ef | grep 17244
elastic+ 17244 17243  0 Dec12 pts/2    00:00:03 -bash
root     19378  5097  0 09:22 pts/1    00:00:00 grep --color=auto 17244
[root@DB1 /ahdata]#
[root@DB1 /ahdata]#
[root@DB1 /ahdata]#usermod  -u 2000 elasticsearch
usermod: user elasticsearch is currently used by process 17244
[root@DB1 /ahdata]#usermod  -u 2000 elasticsearch
usermod: user elasticsearch is currently used by process 17244
[root@DB1 /ahdata]#pkill -kill -t pts/2


usermod  -u 2000 elasticsearch
groupmod -g 2000 elasticsearch
chown -R elasticsearch:elasticsearch /ahdata/elasticsearch-repository/
chown -R elasticsearch:elasticsearch /ahdata/elasticsearch
chown -R elasticsearch:elasticsearch /var/log/history/elasticsearch

chown -R elasticsearch:elasticsearch /usr/local/elasticsearch

curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_test_20191213?wait_for_completion=true"

{
	"snapshot": {
		"snapshot": "snapshot_test_20191213",
		"uuid": "H3KcPXsxQ3m7_H7Cz90ySw",
		"version_id": 7010199,
		"version": "7.1.1",
		"indices": ["info-ad", "info-ad-topic", "ad-label", "info-history", "user-growth", "restored_info-ad", "restored_info-ad-topic", "info-ad-exchange", "info-follow", "info-history-label", "info-favorite", "move-to"],
		"include_global_state": true,
		"state": "SUCCESS",
		"start_time": "2019-12-13T02:49:44.170Z",
		"start_time_in_millis": 1576205384170,
		"end_time": "2019-12-13T02:49:57.183Z",
		"end_time_in_millis": 1576205397183,
		"duration_in_millis": 13013,
		"failures": [],
		"shards": {
			"total": 12,
			"failed": 0,
			"successful": 12
		}
	}
}



[root@DB1 /ahdata/elasticsearch-repository]#curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_test_20191213/_restore"  -H 'Content-Type: application/json' -d '
> {
>     "rename_pattern": "info-(.+)", 
>     "rename_replacement": "restored1213-info-$1" 
> }
> '

{
	"error": {
		"root_cause": [{
			"type": "snapshot_restore_exception",
			"reason": "[ah_backup:snapshot_test_20191213/H3KcPXsxQ3m7_H7Cz90ySw] cannot restore index [ad-label] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
		}],
		"type": "snapshot_restore_exception",
		"reason": "[ah_backup:snapshot_test_20191213/H3KcPXsxQ3m7_H7Cz90ySw] cannot restore index [ad-label] because an open index with same name already exists in the cluster. Either close or delete the existing index or restore the index under a different name by providing a rename pattern and replacement name"
	},
	"status": 500
}

[root@DB1 /ahdata/elasticsearch-repository]#curl localhost:9200/_cat/indices
green open info-ad                kis7Ilr8RSSEAoAFLNsv1A 1 1      0 0   566b    283b
green open info-ad-topic          qm680macTM-rsJ0PQKai7w 1 1  15200 0 31.3mb  15.6mb
green open info-history           jTvN9vncSxCi-XJ0CyLTuQ 1 1    500 1  401kb 200.5kb
green open ad-label               qFmZNVsHQ7WzE8fEaL6sEg 1 1      0 0   566b    283b
green open user-growth            C-Ct7qupTBuerbTc1SplUw 1 1 245445 0 26.5mb  13.2mb
green open restored_info-ad       DJEpWWdvSCmgRSzR9kZrRw 1 1      0 0   566b    283b
green open restored_info-ad-topic 3DPm9oLuRbGL7wiFUbcUUg 1 1  15200 0 31.3mb  15.6mb
green open info-ad-exchange       JMwRipeJRk25NavipcYkZA 1 1      0 0   566b    283b
green open info-follow            TUEFaL52RAiYHbKXNSJ_Uw 1 1      0 0   576b    288b
green open info-history-label     0Cyx_tMLShqx8FFw2SHi1Q 1 1      0 0   566b    283b
green open info-favorite          Zd_zh7sNQGWtDPTRXVAKYQ 1 1      1 0   26kb    13kb
green open move-to                4vSnWQ5kRqiReqHlMxs6gw 1 1      4 0 55.3kb  27.6kb




curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_test_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
	"indices": "info-ad,info-ad-topic,info-history,info-ad-exchange,info-follow,info-history-label,info-favorite",
    "rename_pattern": "info-(.+)",
    "rename_replacement": "restored1213-info-$1"
}
'

{
	"error": {
		"root_cause": [{
			"type": "json_parse_exception",
			"reason": "Unexpected character ('a' (code 97)): was expecting double-quote to start field name\n at [Source: org.elasticsearch.transport.netty4.ByteBufStreamInput@15aa1a76; line: 3, column: 2]"
		}],
		"type": "json_parse_exception",
		"reason": "Unexpected character ('a' (code 97)): was expecting double-quote to start field name\n at [Source: org.elasticsearch.transport.netty4.ByteBufStreamInput@15aa1a76; line: 3, column: 2]"
	},
	"status": 500
}

curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_test_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-*",
    "rename_pattern": "info-(.+)",
    "rename_replacement": "restored2-info-$1"
}
'


curl -X DELETE "localhost:9200/_snapshot/ah_backup"

{"acknowledged":true}

curl -XPOST "localhost:9200/_snapshot/ahprod_backup" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "ahprod_backup"
  }
}'

{"acknowledged":true}

curl -X PUT "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot_20191213?wait_for_completion=true"


{"snapshot":{"snapshot":"ahprod_snapshot_20191213","uuid":"B5zo-yumRA-w4NBtlWhT8Q","version_id":7010199,"version":"7.1.1","indices":["info_scenic_spot","info_group_purchase","info-history","info-favorite","info-history-label","info-follow","user-growth","ad-label","info-ad"],"include_global_state":true,"state":"SUCCESS","start_time":"2019-12-13T06:35:10.571Z","start_time_in_millis":1576218910571,"end_time":"2019-12-13T06:35:12.461Z","end_time_in_millis":1576218912461,"duration_in_millis":1890,"failures":[],"shards":{"total":9,"failed":0,"successful":9}}}


curl -X POST "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-*",
    "rename_pattern": "info-(.+)",
    "rename_replacement": "prodrestored-info-$1"
}
'

curl -X POST "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "user-growth",
    "rename_pattern": "user-growth",
    "rename_replacement": "prodrestored-user-growth"
}
'

curl -X POST "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "ad-label",
    "rename_pattern": "ad-label",
    "rename_replacement": "prodrestored-ad-label"
}
'

curl -X POST "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-ad",
    "rename_pattern": "info-ad",
    "rename_replacement": "restored-info-ad"
}
'

curl -X PUT "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot2_20191213?wait_for_completion=true"

curl -X POST "localhost:9200/_snapshot/ahprod_backup/ahprod_snapshot2_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-ad",
    "rename_pattern": "info-ad",
    "rename_replacement": "restored2-info-ad"
}
'


curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "restored2-info-ad"
  },
  "dest": {
    "index": "info-ad"
  }
}'
