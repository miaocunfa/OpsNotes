bin/elasticsearch-plugin list
bin/elsaticsearch-plugin install analysis-icu

api接口
http://localhost:9200/_cat/plugins

多实例的elasticsearch

bin/elasticsearch -E node.name=node1 -E cluster.name=testes -E path.data=node1_data -d
bin/elasticsearch -E node.name=node2 -E cluster.name=testes -E path.data=node2_data -d
bin/elasticsearch -E node.name=node3 -E cluster.name=testes -E path.data=node3_data -d

api接口
http://localhost:9200/_cat/nodes

kibana
http://localhost:5601

工具：Dev Tools
get /_cat/nodes

bin/kibana-plugin install plugin_location
bin/kibana-plugin list
bin/kibana remove

cerebro es监控

grouplens 测试数据 movielens

索引，文档 开发
节点，分片 运维

文档
es是面向文档的，文档是所有可搜索数据的最小单位
文档会被序列化成json格式，
每个文档有一个uid，可以自动生成也可以指定。

元数据，用于标注文档的相关信息。

索引
一类文档的集合

优缺点，
全文检索 es
事务性要求高 关系性数据库

分布式系统
高可用
服务可用性 允许有节点停止服务
数据可用性 部分节点丢失，不会丢失数据
可扩展
将数据分布到所有节点上

分布式架构，

分片
primary shard 用于解决水平扩展，一个分片是一个运行的lucene实例
              主分片数在索引创建时指定，后续不允许修改，除非 Reindex
replica shard 副本用于解决数据高可用的问题

对于生产环境中分片的设定，需要提前做好容量规划
主分片数需要在索引创建的时候预先设定，无法在事后做修改，
分片数设置过小，
分片数设置过大。

es集群状态三种颜色：
green
yellow
red

