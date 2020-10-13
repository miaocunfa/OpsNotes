---
title: "Elasticsearch之索引只读解决"
date: "2020-06-09"
categories:
    - "技术"
tags:
    - "elasticsearch"
toc: false
indent: false
original: true
--- 

> 一旦在存储超过95％的磁盘中的节点上分配了一个或多个分片的任何索引，该索引将被强制进入只读模式

在确保你剩余的磁盘空间足够存储你的数据，可以进行如下操作

``` json
curl -s -X PUT "localhost:9200/infos/settings" -h "" '
{
    "index": {
        "blocks": {
            "read_only_allow_delete": "false"
        }
    }
}
'
```

> 参考文档：
> 1、[es 报错： index read-only / allow delete (api) 索引只读的解决方案](https://blog.csdn.net/Coder_Lotus/article/details/99679603)  
>