---
title: "Elasticsearch 的快照与还原"
date: "2019-12-03"
categories:
    - "技术"
tags:
    - "Elasticsearch"
  - "搜索引擎"
  - "数据迁移"
toc: false
original: true
---

## 更新记录

| 时间       | 内容                                      |
| ---------- | ----------------------------------------- |
| 2019-12-03 | 初稿                                      |
| 2020-08-10 | 1、增加指定多个索引 </br> 2、全部索引还原 |

> 官网链接：
> <https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-snapshots.html#modules-snapshots>

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
➜  mkdir -p /ahdata/elasticsearch-repository/         # 创建 elasticsearch-repository 目录
➜  usermod  -u 2000 es                                # 修改 es用户 uid
➜  groupmod -g 2000 es                                # 修改 es用户 gid
➜  chown -R es:es /opt/elasticsearch-7.1.1/           # 因 es用户 uid、gid 修改，需要重新配置 es目录 属主属组
➜  chown -R es:es /ahdata/es                          # 因 es用户 uid、gid 修改，需要重新配置 data目录 属主属组
➜  chown -R es:es /ahdata/elasticsearch-repository/   # 因 es用户 uid、gid 修改，需要重新配置 repo目录 属主属组
➜  chown -R es:es /var/log/history/elasticsearch      # 因 es用户 uid、gid 修改，需要重新配置 es用户日志记录目录
```

共享存储

``` bash
# 所有节点安装nfs
➜  yum install -y nfs-utils

# node1配置nfs
➜  cat /etc/exports
/ahdata/elasticsearch-repository 192.168.100.0/24(rw,no_root_squash)
➜  systemctl start nfs  # 启动nfs服务

# 导出挂载
➜  exportfs -arv
exporting 192.168.100.0/24:/ahdata/elasticsearch-repository
# 查看挂载
➜  showmount -e

# node2、node3执行挂载共享存储，并验证可行性
➜  mount -t nfs DB1:/ahdata/elasticsearch-repository /ahdata/elasticsearch-repository
```

### 1.2、配置仓库

``` bash
➜  cd /usr/local/elasticsearch/config
➜  vim elasticsearch.yml
path.repo: /ahdata/elasticsearch-repository                 # 单仓库路径
path.repo: ["/ahdata/elasticsearch-repository", "/mnt"]     # 多仓库路径
```

### 1.3、创建仓库

``` bash
➜  curl -XPOST "localhost:9200/_snapshot/ah_backup" -H 'Content-Type: application/json' -d '
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

查看仓库下的所有快照

``` json
➜  curl -X GET "localhost:9200/_snapshot/ah_backup/_all"

# return
{
  "snapshots": [{
    "snapshot": "prod_snapshot_20191214",
    "uuid": "ZF69-I98QyW4L5xaNAFnQQ",
    "version_id": 7010199,
    "version": "7.1.1",
    "indices": ["info_scenic_spot", "info_group_purchase", "info-history", "info-favorite", "info-history-label", "restored2-info-ad", "restored-info-ad", "info-follow", "user-growth", "ad-label", "info-ad"],
    "include_global_state": true,
    "state": "SUCCESS",
    "start_time": "2019-12-14T09:35:21.561Z",
    "start_time_in_millis": 1576316121561,
    "end_time": "2019-12-14T09:35:23.287Z",
    "end_time_in_millis": 1576316123287,
    "duration_in_millis": 1726,
    "failures": [],
    "shards": {
      "total": 11,
      "failed": 0,
      "successful": 11
    }
  }, {
    "snapshot": "snapshot_infov2_20200517",
    "uuid": "47zRZ4t8SjGiF7Arrr8Qdw",
    "version_id": 7010199,
    "version": "7.1.1",
    "indices": ["info_scenic_spot", "info-ad", "info_group_purchase", "info-history", "info-favorite", "info-history-label", "info-ad-exchange", "user-growth", "info-follow", "ad-label"],
    "include_global_state": false,
    "state": "SUCCESS",
    "start_time": "2020-05-17T09:50:31.287Z",
    "start_time_in_millis": 1589709031287,
    "end_time": "2020-05-17T09:50:32.879Z",
    "end_time_in_millis": 1589709032879,
    "duration_in_millis": 1592,
    "failures": [],
    "shards": {
      "total": 10,
      "failed": 0,
      "successful": 10
    }
  }]
}
```

## 二、创建快照

### 2.1、指定索引快照

``` json
# 创建快照名为 snapshot_info-ad-topic 的快照，并指定将索引 info-ad-topic 写入快照。
# wait_for_completion=true

➜  curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_info-ad?wait_for_completion=true" -H 'Content-Type: application/json' -d'
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

# 指定多个索引
curl -X PUT "localhost:9200/_snapshot/ahtest_backup_20200810/snapshot_aihang3?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": ["infos","relatedwords"],
  "ignore_unavailable": true,
  "include_global_state": false
}'
```

### 2.2、全索引快照

``` json
➜  curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_20200517?wait_for_completion=true"

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

### 2.3、测试备份

``` bash
➜  curl -X PUT "localhost:9200/_snapshot/ah_backup/snapshot_ahxx_20200517?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": ["info-ad", "info-ad-update", "info-favorite", "info-follow", "info-history", "info-history-label", "ad-label", "user-growth", "info-ad-exchange"],
  "ignore_unavailable": true,
  "include_global_state": false
}'

# return
{
  "snapshot": {
    "snapshot": "snapshot_ahxx_20200517",
    "uuid": "4PO7N3g4QmStZQijCIXp_w",
    "version_id": 7010199,
    "version": "7.1.1",
    "indices": ["info-ad", "info-history", "ad-label", "user-growth", "info-ad-exchange", "info-follow", "info-history-label", "info-favorite"],
    "include_global_state": false,
    "state": "SUCCESS",
    "start_time": "2020-05-17T06:29:35.581Z",
    "start_time_in_millis": 1589696975581,
    "end_time": "2020-05-17T06:31:16.427Z",
    "end_time_in_millis": 1589697076427,
    "duration_in_millis": 100846,
    "failures": [],
    "shards": {
      "total": 8,
      "failed": 0,
      "successful": 8
    }
  }
}
```

### 2.4、生产备份

``` curl
# 指定索引备份
➜  curl -X PUT "localhost:9200/_snapshot/ahprod_backup/snapshot_infov2_20200517?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "indices": ["info_scenic_spot", "info-ad", "info_group_purchase", "info-history", "info-favorite", "info-history-label", "info-ad-exchange", "user-growth", "info-follow", "ad-label"],
  "ignore_unavailable": true,
  "include_global_state": false
}'

# 全库备份
➜  curl -X PUT "localhost:9200/_snapshot/ahprod_backup/snapshot_infov2_20200724?wait_for_completion=true"

# return
{
  "snapshot": {
    "snapshot": "snapshot_infov2_20200517",
    "uuid": "47zRZ4t8SjGiF7Arrr8Qdw",
    "version_id": 7010199,
    "version": "7.1.1",
    "indices": ["info_scenic_spot", "info-ad", "info_group_purchase", "info-history", "info-favorite", "info-history-label", "info-ad-exchange", "user-growth", "info-follow", "ad-label"],
    "include_global_state": false,
    "state": "SUCCESS",
    "start_time": "2020-05-17T09:50:31.287Z",
    "start_time_in_millis": 1589709031287,
    "end_time": "2020-05-17T09:50:32.879Z",
    "end_time_in_millis": 1589709032879,
    "duration_in_millis": 1592,
    "failures": [],
    "shards": {
      "total": 10,
      "failed": 0,
      "successful": 10
    }
  }
}
```

## 三、还原快照

### 3.1、指定索引还原

```  json
➜  curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_info-ad-topic/_restore" -H 'Content-Type: application/json' -d'
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
➜  curl -X POST "localhost:9200/_snapshot/ah_backup/snapshot_20191213/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-*",                             # 根据索引设置匹配规则
    "rename_pattern": "info-(.+)",                   # 设置重命名模板
    "rename_replacement": "prodrestored-info-$1"     # 设置重命名后的索引名
}'

# return
{
  "acknowledged":true
}
```

### 3.3、全部索引还原

es中不能有跟快照中索引重名的，否则还原失败

``` json
➜  curl -X POST "localhost:9200/_snapshot/ahtest_backup_20200810/snapshot_aihang3/_restore"
```

## 四、清除仓库

``` bash
➜  curl -X DELETE "localhost:9200/_snapshot/ah_backup"
```

## 五、重建索引

``` json
➜  curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d '
{
  "source": {
    "index": "info-ad"         # 源索引
  },
  "dest": {
    "index": "info-ad-test"    # 目标索引
  }
}'
```

> 参考列表：
> 1、<https://blog.csdn.net/diyiday/article/details/82691977>
> 2、<https://blog.csdn.net/it_lihongmin/article/details/78725376>
> 3、<https://blog.csdn.net/ale2012/article/details/82702128>
> 4、<https://elasticsearch.cn/question/895>
> 5、<https://juejin.im/post/5b799dcb6fb9a019be279bd7>
>