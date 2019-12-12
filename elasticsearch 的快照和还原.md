# elasticsearch 的快照和还原

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

mkdir -p /data/elasticsearch-repository
chown -R zyes:zyes /data

curl -XPOST "localhost:9200/_snapshot/my_backup" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "/data/elasticsearch-repository/my_backup"
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
curl -X PUT "localhost:9200/_snapshot/my_backup/info-ad?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad",
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
curl -X POST "localhost:9200/_snapshot/my_backup/info-ad/_restore" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad",
  "ignore_unavailable": true,
  "include_global_state": true,
  "rename_pattern": "info-ad",
  "rename_replacement": "restored_info-ad"
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
