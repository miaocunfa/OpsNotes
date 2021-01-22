---
title: "Elasticsearch 之社区版迁移基础版"
date: "2020-09-28"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "X-pack"
    - "数据迁移"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                 |
| ---------- | -------------------- |
| 2020-09-28 | 初稿                 |
| 2020-09-29 | 迁移规划 && 迁移操作 |

## 版本信息

| Server            | Version |
| ----------------- | ------- |
| elasticsearch-oss | 7.1.1   |
| elasticsearch     | 7.1.1   |

![es版本介绍](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/es_subscriptions_20200930_01.png)

## 迁移规划

由于es-oss版无法使用X-pack安全套件，所以我们计划将原 oss版迁移至基础版。

data目录: /ahdata/elasticsearch/data     -->  不变
原oss-bin目录: /usr/local/elasticsearch  -->  规划基础版目录: /opt/elasticsearch

查看oss版安装的插件列表：
elasticsearch-plugin list
analysis-hanlp
analysis-ik

插件目录：
/usr/local/elasticsearch/elasticsearch-analysis-hanlp-7.1.1.zip
/usr/local/elasticsearch/elasticsearch-analysis-ik-7.1.1.zip

## 迁移

在 es集群 各节点依次执行如下操作。

``` zsh
# 上传基础版 && 停掉oss版
scp elasticsearch-7.1.1-linux-x86_64.tar.gz n211:/opt
ps -ef|grep elastic
kill 6484

# 解压基础版
cd /opt
tar -zxf elasticsearch-7.1.1-linux-x86_64.tar.gz

# 插件安装
cd /opt/elasticsearch-7.1.1/bin
./elasticsearch-plugin install file:///usr/local/elasticsearch/elasticsearch-analysis-hanlp-7.1.1.zip
./elasticsearch-plugin install file:///usr/local/elasticsearch/elasticsearch-analysis-ik-7.1.1.zip

# 配置文件
cp /usr/local/elasticsearch/config/elasticsearch.yml /opt/elasticsearch-7.1.1/config
cp /usr/local/elasticsearch/config/analysis-hanlp/hanlp-remote.xml /opt/elasticsearch-7.1.1/config/analysis-hanlp

# 修改文件权限
cd /opt
chown -R elasticsearch:elasticsearch ./elasticsearch-7.1.1

# 启动
su - elasticsearch
cd /opt/elasticsearch-7.1.1/bin
./elasticsearch -d
```

> 参考文档：  
> 1、[es官网 - 关于各版本功能介绍](https://www.elastic.co/cn/subscriptions)  
>