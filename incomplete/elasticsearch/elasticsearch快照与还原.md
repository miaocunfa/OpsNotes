# elasticsearch 的快照和还原

> 官网链接  
> https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-snapshots.html#modules-snapshots

## 一、创建仓库
在elasticsearch中进行快照、还原时，首先需要创建创建一个仓库。使用仓库存放快照
但是在再创建仓库时，es要求仓库路径必须配置到 path.repo 属性中，相当于一个白名单列表。
如果elasticsearch是以集群部署，则仓库路径必须得是一个共享存储，以保证所有节点都能访问这个仓库。

在我们的示例中，elasticsearch是一个三节点集群，使用nfs作为共享存储，最后要实现从生产集群拷贝快照还原至测试环境中。

### 1.1、共享存储、用户权限修改
由于所有es集群都是已经安装完成的，es集群必须使用非root用户启动，所以当时安装的时候已经创建了es用户，
最恶心的就是这块儿，nfs对于用户uid、gid要求严格，所以使用共享存储前需要先统一用户uid、gid。
我们这里使用没有使用过的2xxx段进行配置。

用户权限修改
``` bash
# 每个节点都执行
$ mkdir -p /ahdata/elasticsearch-repository/         # 创建 elasticsearch-repository 目录
$ usermod  -u 2000 es                                # 修改 es用户 uid
$ groupmod -g 2000 es                                # 修改 es用户 gid
$ chown -R es:es /opt/elasticsearch-7.1.1/           # 因 es用户 uid、gid 修改，需要重新配置 es目录 属主属组
$ chown -R es:es /ahdata/es                          # 因 es用户 uid、gid 修改，需要重新配置 data目录 属主属组              
$ chown -R es:es /ahdata/elasticsearch-repository/   # 因 es用户 uid、gid 修改，需要重新配置 repo目录 属主属组
$ chown -R es:es /var/log/history/elasticsearch      # 因 es用户 uid、gid 修改，需要重新配置 es用户日志记录目录
```

共享存储
``` bash
# 所有节点安装nfs
$ yum install -y nfs-utils

# node1配置nfs
$ cat /etc/exports
/ahdata/elasticsearch-repository 192.168.100.0/24(rw,no_root_squash)
$ systemctl start nfs  # 启动nfs服务

# node2、node3执行挂载共享存储，并验证可行性
$ mount -t nfs DB1:/ahdata/elasticsearch-repository /ahdata/elasticsearch-repository
```

### 1.2、配置仓库

``` bash
$ cd /opt/elasticsearch-7.1.1/config
$ vi elasticsearch.yml
path.repo: /mnt                 # 单仓库路径
path.repo: ["/data", "/mnt"]    # 多仓库路径
```

### 1.3、创建仓库
``` json
curl -XPOST "192.168.100.217:9200/_snapshot/ah_backup" -H 'Content-Type: application/json' -d '
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

### 1.4、查看仓库
``` json
curl -X GET "localhost:9200/_snapshot/ah_backup/_all"
```

## 二、创建快照
### 2.1、指定索引快照
``` json
# 创建快照名为 snapshot_info-ad-topic 的快照，仅将索引 info-ad-topic 写入快照。
# wait_for_completion=true

curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_info-ad?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad",
  "ignore_unavailable": true,
  "include_global_state": false
}'

# return
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
			"successful": 1     # 创建快照成功
		}
	}
}
```

### 2.2、全索引快照
``` json
curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_20191213?wait_for_completion=true"

# return
{
	"snapshot": {
		"snapshot": "ahprod_snapshot_20191213",
		"uuid": "B5zo-yumRA-w4NBtlWhT8Q",
		"version_id": 7010199,
		"version": "7.1.1",
		"indices": ["info_scenic_spot", "info_group_purchase", "info-history", "info-favorite", "info-history-label", "info-follow", "user-growth", "ad-label", "info-ad"],
		"include_global_state": true,
		"state": "SUCCESS",
		"start_time": "2019-12-13T06:35:10.571Z",
		"start_time_in_millis": 1576218910571,
		"end_time": "2019-12-13T06:35:12.461Z",
		"end_time_in_millis": 1576218912461,
		"duration_in_millis": 1890,
		"failures": [],
		"shards": {
			"total": 9,
			"failed": 0,
			"successful": 9
		}
	}
}
```

## 三、还原快照
### 3.1、指定索引还原
```  json
curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_info-ad-topic/_restore" -H 'Content-Type: application/json' -d'
{
  "indices": "info-ad-topic",
  "ignore_unavailable": true,
  "include_global_state": true,
  "rename_pattern": "info-ad-topic",
  "rename_replacement": "restored_info-ad-topic"
}'

# return
{
	"acknowledged":true
}
```

### 3.2、根据正则还原索引
``` json
curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-*",                          # 根据索引设置匹配规则
    "rename_pattern": "info-(.+)",                # 设置重命名模板
    "rename_replacement": "prodrestored-info-$1"  # 设置重命名后的索引名
}'

# return
{
	"acknowledged":true
}
```

## 四、清除仓库
``` bash
curl -X DELETE "localhost:9200/_snapshot/ah_backup"
```

## 五、重建索引
``` json
curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d '
{
  "source": {
    "index": "info-ad"         # 源索引
  },
  "dest": {
    "index": "info-ad-test"    # 目标索引
  }
}'
```

> 参考列表
> https://blog.csdn.net/diyiday/article/details/82691977  
> https://blog.csdn.net/it_lihongmin/article/details/78725376  
> https://blog.csdn.net/ale2012/article/details/82702128  
> https://elasticsearch.cn/question/895  
> https://juejin.im/post/5b799dcb6fb9a019be279bd7  
>