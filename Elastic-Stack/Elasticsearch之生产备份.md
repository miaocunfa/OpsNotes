---
title: "Elasticsearch生产备份"
date: "2020-07-24"
categories:
    - "技术"
tags:
    - "生产备份"
toc: false
original: true
draft: true
---

| 时间       | 内容               |
| ---------- | ------------------ |
| 2020-07-24 | 初稿               |
| 2020-08-14 | 增加jq解析返回json |

## 一、注册仓库

``` zsh
➜  curl -s -XPOST "localhost:9200/_snapshot/ahprod_backup_20200724" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "/ahdata/elasticsearch-repository/ahprod_backup_20200724"
  }
}' | jq .
```

## 二、备份

``` zsh
➜  curl -s -X PUT "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724?wait_for_completion=true" | jq .

# 压缩快照
➜  cd /ahdata/elasticsearch-repository
➜  tar -zcf ahprod_backup_20200724.tgz ./ahprod_backup_20200724
```

## 三、还原

### 3.1、检查nfs

``` zsh
➜  systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
➜  systemctl start nfs

# n211
➜  exportfs -arv
exporting 192.168.100.0/24:/ahdata/elasticsearch-repository
➜  showmount -e

# n212、n213
➜  mount -t nfs DB1:/ahdata/elasticsearch-repository /ahdata/elasticsearch-repository
```

### 3.2、注册仓库

``` zsh
➜  curl -s -XPOST "localhost:9200/_snapshot/ahprod_backup_20200724" -H 'Content-Type: application/json' -d '
{
  "type": "fs",
  "settings": {
    "location": "/ahdata/elasticsearch-repository/ahprod_backup_20200724"
  }
}' | jq .

# 解压快照
➜  cd /ahdata/elasticsearch-repository
➜  tar -zxf ahprod_backup_20200724.tgz
```

### 3.3、es还原

``` zsh
curl -s -X POST "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info-*",
    "rename_pattern": "info-(.+)",
    "rename_replacement": "prod-restored-0724-info-$1"
}' | jq .

curl -s -X POST "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info_scenic_spot",
    "ignore_unavailable": true,
    "include_global_state": true,
    "rename_pattern": "info_scenic_spot",
    "rename_replacement": "prod-restored-0724-info_scenic_spot"
}' | jq .

curl -s -X POST "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "info_group_purchase",
    "ignore_unavailable": true,
    "include_global_state": true,
    "rename_pattern": "info_group_purchase",
    "rename_replacement": "prod-restored-0724-info_group_purchase"
}' | jq .

curl -s -X POST "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "user-growth",
    "ignore_unavailable": true,
    "include_global_state": true,
    "rename_pattern": "user-growth",
    "rename_replacement": "prod-restored-0724-user-growth"
}' | jq .

curl -s -X POST "localhost:9200/_snapshot/ahprod_backup_20200724/snapshot_infov2_20200724/_restore"  -H 'Content-Type: application/json' -d '
{
    "indices": "ad-label",
    "ignore_unavailable": true,
    "include_global_state": true,
    "rename_pattern": "ad-label",
    "rename_replacement": "prod-restored-0724-ad-label"
}' | jq .
```
