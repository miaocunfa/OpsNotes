---
title: "Elasticdump 迁移 Elasticsearch数据"
date: "2019-12-11"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "Elasticdump"
    - "Docker"
    - "数据迁移"
toc: false
original: true
draft: false
---

> elasticdump [github地址](https://github.com/taskrabbit/elasticsearch-dump)

折腾了一会nodejs耐心尽失，果断使用docker方式。

## 1、下载docker镜像

拉取镜像

``` bash
docker pull taskrabbit/elasticsearch-dump
```

## 2、导出数据

如果将数据导出为文件形式，需要将宿主机目录挂载至容器上。

``` bash
# 提前创建数据目录。
mkdir /data
```

导出数据至json文件中，将宿主机/data目录挂载到容器/tmp目录上，--output指定文件导出至/tmp目录中。

``` bash

docker run --net=host --rm -ti -v /data:/tmp taskrabbit/elasticsearch-dump \
   --input=http://localhost:9200/info-ad \
   --output=/tmp/info-ad-map.json \
   --type=data

# 导出日志
Wed, 11 Dec 2019 09:45:35 GMT | starting dump
Wed, 11 Dec 2019 09:45:35 GMT | got 16 objects from source elasticsearch (offset: 0)
Wed, 11 Dec 2019 09:45:35 GMT | sent 16 objects to destination file, wrote 16
Wed, 11 Dec 2019 09:45:35 GMT | got 0 objects from source elasticsearch (offset: 16)
Wed, 11 Dec 2019 09:45:35 GMT | Total Writes: 16
Wed, 11 Dec 2019 09:45:35 GMT | dump complete
# 导出文件
[root@localhost /data]# ll
total 20
-rw-r--r--. 1 root root 18192 Dec 11 17:45 info-ad-map.json
```

## 3、导入数据

``` bash

docker run --net=host --rm -ti -v /data:/tmp taskrabbit/elasticsearch-dump \
   --input=/tmp/info-ad-map.json \
   --output=http://localhost:9200/abcd

# 导入日志
Wed, 11 Dec 2019 09:47:43 GMT | starting dump
Wed, 11 Dec 2019 09:47:43 GMT | got 16 objects from source file (offset: 0)
Wed, 11 Dec 2019 09:47:44 GMT | sent 16 objects to destination elasticsearch, wrote 16
Wed, 11 Dec 2019 09:47:44 GMT | got 0 objects from source file (offset: 16)
Wed, 11 Dec 2019 09:47:44 GMT | Total Writes: 16
Wed, 11 Dec 2019 09:47:44 GMT | dump complete
```

>ps：在使用localhost:9200时需要使用--net=host将网络挂载到容器上
