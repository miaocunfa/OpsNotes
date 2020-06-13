---
title: "Elasticsearch 介绍与概念"
date: "2019-12-27"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "搜索引擎"
    - "概述"
toc: true
---

# Elasticsearch 介绍与概念

## 一、介绍
### 分布式搜索引擎  
Elasticsearch（ES）是一个基于Lucene构建的开源、分布式、RESTful接口的全文搜索引擎。Elasticsearch还是一个分布式文档数据库，其中每个字段均可被索引，而且每个字段的数据均可被搜索，ES能够横向扩展至数以百计的服务器存储以及处理PB级的数据。可以在极短的时间内存储、搜索和分析大量的数据。

### 大数据近实时分析引擎  
除了搜索，结合 Kibana、Logstash、Beats，Elastic Stack 还被广泛运用在大数据近实时分析领域，包括日志分析、指标监控、信息安全等多个领域。它可以帮助你探索海量结构化、非结构化数据，按需创建可视化报表，对监控数据设置报警阈值。甚至通过使用机器学习技术，自动标识异常状况。

### 产品特性
- 高性能，和 T+1 说不
- 容易使用 / 容易扩展

## 二、Lucene
Lucene是一套用于全文检索和搜索的开放源码程序库，由Apache软件基金会支持和提供。Lucene提供了一个简单却强大的应用程序接口，能够做全文索引和搜索，在Java开发环境里Lucene是一个成熟的免费开放源代码工具；就其本身而论，Lucene是现在并且是这几年，最受欢迎的免费Java信息检索程序库。

### 2.1、特点
基于Java语言开发的搜索引擎库类  
创建于1999年，2005年成为Apache顶级开源项目  
Lucene具有高性能、易扩展的优点  

### 2.2、Lucene的局限性：  
- 只能基于Java语言开发  
- 类库的接口学习曲线陡峭  
- 原生不支持水平扩展  


## 三、基本概念：文档
索引、文档：开发人员视角，是一个逻辑概念  
节点、分片：运维人员视角，是一个物理概念  

### 文档
Elasticsearch是面向文档的，文档是所有可搜索数据的最小单位
```
例如
- 日志文件中的日志项
- 一本电影的具体信息/一张唱片的详细信息
- MP3播放器里的一首歌/一篇PDF文档中的具体内容
```
文档会被序列化成JSON格式，保存在Elasticsearch中  
```
JSON对象由字段组成，
每个字段都有对应的字段类型(字符串/数值/布尔/日期/二进制/范围类型)
```
每个文档都有一个Unique ID  
    你可以自己指定ID
    或者通过Elasticsearch自动生成

JSON文档
一篇文档包含了一些列的字段。类似数据库表中的一条记录
JSON文档，格式灵活，不需要预先定义格式
    字段的类型可以指定或者通过 Elasticsearch 自动推算
    支持数组 / 支持嵌套

```
# CSV file
movieId,title,genres
1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy

# JSON 文档
{
    "year": 1995,
    "@version": "1",
    "genre": [
        "Adventure","Animation",
        "Children","Comedy","Fantasy"],
    ]
    "id": "1",
    "title": "Toy Story"
}
```

#### 元数据  
用于标注文档的相关信息
```
_index    文档所属的索引名
_type     文档所属的类型名
_id       文档唯一 ID
_source   文档的原始Json数据
_all      整合所有字段内容到该字段，从7.0开始已被废弃
_version  文档的版本信息
_score    相关性打分
```

## 四、基本概念：索引

Index - 索引是文档的容器，是一类文档的结合
    Index 体现了逻辑空间的概念：每个索引都有自己的Mapping定义，用户定义包含的文档的字段名和字段类型
    Shard 体现了物理空间的概念：索引中的数据分散在Shard上
索引的 Mapping 与 Setting
    Maping  定义文档字段的类型
    Setting 定义不同的数据分布

索引的不同语意
    名词：一个 Elasticsearch 集群中，可以创建很多个不同的索引
    动词：保存一个文档到Elasticsearch的过程也叫索引(indexing)
        ES中，创建一个倒排索引的过程
    名词：一个B树索引，一个倒排索引

Type
1、在7.0之前，一个Index可以设置多个Types
2、6.0开始，Type已经被 Deprecated。
   7.0开始，一个索引只能创建一个Type - "_doc"
3、传统关系型数据库和 Elasticsearch 的区别
    Elasticsearch - Schemaless 
    相关性/高性能全文检索

    RDMS          
    对数据的事务性要求特别高/Join

抽象和类比
| RDBMS  | Elasticsearch |
| :----  | :------------ |
| Table  | Index(Type)   |
| Row    | Doucment      |
| Column | Field         |
| SChema | Mapping       |
| SQL    | DSL           |

## 五、Rest API - 很容易被各种语言调用
为了方便其他语言的整合，elasticsearch创始人在早期就提供了Restful的API给其他程序调用，

图 
client application --> http request  --> rest api ES
                      <-- http response <--

基本API
indices
    创建 Index
        PUT Movies
    查看所有 Index
        _cat/indices

```
查看索引相关信息
GET kibana_sample_data_ecommerce

查看索引的文档总数
GET kibana_sample_data_ecommerce/_count

# _cat indices API
查看indices
GET /_cat/indices/kibana*?v&s=index

查看状态为绿的索引
GET /_cat/indices?v&health=green

按照文档个数排序
GET /_cat/indices?v&s=docs.count:desc

查看具体的字段
GET /_cat/indices/kibana*?pri&v&h=health,index,pri,rep,docs.count,mt

How much memory is used per index?
GET /_cat/indices?v&h=i,tm&s=tm:desc
```

## 基本概念：节点、集群、分片及副本
分布式系统的可用性与扩展性
高可用性
    服务可用性 允许有节点停止服务
    数据可用性 部分节点丢失，不会丢失数据
可扩展性
    请求量提升/数据的不断增长(将数据分布到所有节点上)

分布式特性
Elasticsearch 的分布式架构的好处
    存储的水平扩容
    提高系统的可用性，部分节点停止服务，整个集群的服务不受影响
Elasticsearch 的分布式架构
    不同的集群通过不同的名字来区分，默认名字"elasticsearch"
    通过配置文件修改，或者在命令行中 -E cluster.name=geektime 进行设定
    一个集群可以有一个或者多个节点

节点
节点是一个Elasticsearch的实例
    本质上就是一个Java进程
    一台机器上可以运行多个Elasticsearch进程，但是生产环境一般建议一台机器上只运行一个Elasticsearch实例
每一个节点都有名字，通过配置文件配置，或者启动时候 -E node.name=node1指定
每一个节点在启动之后，会分配一个UID，保存在data目录下

Master-eligible nodes 和 Master Node
每个节点启动后，默认就是一个 Master eligible节点
    可以设置 node.master: false禁止
Master-eligible节点可以参加选主流程，成为Master节点
当第一个节点启动时候，它会将自己选举成Master节点
每个节点上都保存了集群的状态，只有Master节点才能修改集群的状态
    集群状态（Cluster State），维护了一个急群中，必要的信息
        所有的节点信息
        所有的索引和其相关的Mapping与Setting信息
        分片的路由信息
    任意节点都能修改信息会导致数据的不一致性

Data Node & Coordinating Node
Data Node
    可以保存数据的节点，叫做 Data Node。负责保存分片数据。在数据扩展上起到了至关重要的作用
Coordinating Node
    负责接收Client的请求，将请求分发到合适的节点，最终把结果汇集到一起
    每个节点默认都起到了Coordinating Node的职责

其他节点类型
Hot & Warm Node
    不同硬件配置的Data Node，用来实现 Hot & Warm架构，降低集群部署的成本
Machine Learning Node
    负责跑机器学习的Job，用来做异常检测
Tribe Node （将被废弃）
    （5.3开始使用Cross Cluster Search) Tribe Node 连接到不同的 Elasticsearch集群，
    并且支持将这些集群当成一个单独的集群处理

配置节点类型
开发环境中一个节点可以承担多种角色
生产环境中应该设置单一的角色的节点（dedicated node）
| 节点类型 | 配置参数 | 默认值 |
| :------ | :------- | :----- |
| master eligible | node.master | true |
| data            | node.data   | true |
| ingest          | node.ingest | true |
| coordinating only | 无        |每个节点默认都是 coordinating 节点。设置其他类型全部为false|
| machine learning | node.ml    | true（需 enable x-pack |

分片（Primary Shard & Replica Shard）
主分片，用以解决数据水平扩展的问题。通过主分片，可以将数据分布到集群内的所有节点之上
    一个分片是一个运行 Lucene 的实例
    主分片数在索引创建时指定，后续不允许修改，除非 Reindex
副本，用以解决数据高可用的问题。分片是主分片的拷贝
    副本分片数，可以动态调整
    增加副本数，还可以在一定程度上提高服务的可用性（读取的吞吐）

分片的设定
对于生产环境中分片的设定，需要提前做好容量规划
    分片数设置过小
        导致后续无法增加节点实现水平扩展
        单个分片的数据量太大，导致数据重新分配耗时，
    分片数设置过大，7.0开始，默认主分片设置成1，解决了over-sharding的问题
        影响搜索结果的相关性打分，影响统计结果的准确性
        单个节点上过多的分片，会导致资源浪费，同时也会影响性能

查看集群的健康程度
    Green - 主分片与副本都正常分配
    Yellow - 主分片全部正常分配，有副本分片未能正常分配
    Red - 有主分片未能分配
        例如，当服务器的磁盘容量超过85%时，去创建了一个新的索引

Demo
查看一个集群的健康状态
http://localhost:9200/_cluster/health

CAT API
http://localhost:9200/_cat/nodes
http://localhost:9200/_cat/shards
查看索引和分片

设置分片数

Kibana + Cerebro界面介绍