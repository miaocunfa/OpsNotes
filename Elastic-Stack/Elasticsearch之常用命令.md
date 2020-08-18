---
title: "Elasticsearch之常用命令"
date: "2020-08-04"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "常用命令"
toc: false
original: true
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-04 | 初稿 |

## 一、删除索引

``` zsh
# 批量删除
➜  curl -XDELETE localhost:9200/prod-restored-0724-*

# 删除指定索引
➜  curl -XDELETE 192.168.100.211:9200/user-growth
```

## 二、查看索引

``` zsh
➜  curl localhost:9200/_cat/indices
green open infos               0_SC39C-S2KQzYNy7Dwk9A 3 1    814    8   1.1mb 606.7kb
green open info_scenic_spot    LjX93QWVT8SJ25-fjJHmdA 1 1 101853 1218  66.9mb  31.7mb
green open info-ad             2aJvWdxrQqWpfP406Rx4VA 1 1   1399   38   5.8mb   2.8mb
green open info_group_purchase ApRy87XARDy3zflHY4wQAg 1 1     48    0 103.7kb  45.8kb
green open info-history        4pzwiXiESdSLqQ92PEkVtQ 1 1  24769    7  52.2mb  26.1mb
green open info-favorite       cBnOEYNbSzadPVs0A5ofDQ 1 1     53    1 319.2kb 159.6kb
green open info-history-label  kISE1TlCQFWTx9j5CN6PVA 1 1      0    0    566b    283b
green open info-ad-exchange    gnDNX_-wQPyrbCBqPcetqA 1 1      3    0 156.7kb  78.3kb
green open user-growth         QkEJ9dJHQ9GLwm-D7yb2Mg 1 1     18    0  85.9kb  42.9kb
green open info-follow         -v9DIPlXQ4mOEulEnno3mg 1 1     23    0 117.2kb  58.6kb
green open ad-label            QenCfL7xS12pSq8k8LcnUA 1 1      0    0    566b    283b

➜  curl -s -XDELETE localhost:9200/infos | jq .
{
  "acknowledged":true
}

➜  curl localhost:9200/_cat/indices
green open info_scenic_spot    LjX93QWVT8SJ25-fjJHmdA 1 1 101853 1218  66.9mb  31.7mb
green open info-ad             2aJvWdxrQqWpfP406Rx4VA 1 1   1399   38   5.8mb   2.8mb
green open info_group_purchase ApRy87XARDy3zflHY4wQAg 1 1     48    0 103.7kb  45.8kb
green open info-history        4pzwiXiESdSLqQ92PEkVtQ 1 1  24770    7  52.2mb  26.1mb
green open info-favorite       cBnOEYNbSzadPVs0A5ofDQ 1 1     53    1 319.2kb 159.6kb
green open info-history-label  kISE1TlCQFWTx9j5CN6PVA 1 1      0    0    566b    283b
green open info-ad-exchange    gnDNX_-wQPyrbCBqPcetqA 1 1      3    0 156.7kb  78.3kb
green open user-growth         QkEJ9dJHQ9GLwm-D7yb2Mg 1 1     18    0  85.9kb  42.9kb
green open info-follow         -v9DIPlXQ4mOEulEnno3mg 1 1     23    0 117.2kb  58.6kb
green open ad-label            QenCfL7xS12pSq8k8LcnUA 1 1      0    0    566b    283b
```
