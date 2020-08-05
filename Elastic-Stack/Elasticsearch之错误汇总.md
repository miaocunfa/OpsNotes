---
title: "Elasticsearch错误汇总"
date: "2020-06-09"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "错误汇总"
toc: false
indent: false
original: true
--- 

## 更新记录

| 时间       | 内容           |
| ---------- | -------------- |
| 2020-06-09 | 初稿           |
| 2020-08-05 | 增加 es limits |

## 一、kibana

### 1.1、启动报错

``` log
➜  ./kibana serve
  status: 503,
  displayName: 'ServiceUnavailable',
  message:
   'all shards failed: [search_phase_execution_exception] all shards failed',
  path: '/.kibana/_count',
  query: {},
  body:
   { error:
      { root_cause: [],
        type: 'search_phase_execution_exception',
        reason: 'all shards failed',
        phase: 'query',
        grouped: true,
        failed_shards: [] },
     status: 503 },
  statusCode: 503,
  response:
   '{"error":{"root_cause":[],"type":"search_phase_execution_exception","reason":"all shards failed","phase":"query","grouped":true,"failed_shards":[]},"status":503}',
  toString: [Function],
  toJSON: [Function],
  isBoom: true,
  isServer: true,
  data: null,
  output:
   { statusCode: 503,
     payload:
      { message:
         'all shards failed: [search_phase_execution_exception] all shards failed',
        statusCode: 503,
        error: 'Service Unavailable' },
     headers: {} },
  reformat: [Function],
  [Symbol(SavedObjectsClientErrorCode)]: 'SavedObjectsClient/esUnavailable' }
```

## 二、elasticsearch

### 2.1、文件描述符限制

``` log
max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
```

错误解决

``` zsh
# 每个进程最大同时打开文件数太小，可通过下面2个命令查看当前数量
➜  ulimit -Hn
➜  ulimit -Sn

# 修改限制文件即可
➜  vim /etc/security/limits.conf
*               soft    nofile          65536
*               hard    nofile          65536
```

### 2.2、最大线程限制

``` log
max number of threads [3818] for user [es] is too low, increase to at least [4096]
```

错误解决

``` zsh
# 最大线程个数太低, 可通过下面2个命令查看当前数量
➜  ulimit -Hu
➜  ulimit -Su

# 修改限制文件即可
➜  vim /etc/security/limits.conf
*               soft    nproc           4096
*               hard    nproc           4096
```

### 4.3、max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

``` zsh
➜  vi /etc/sysctl.conf
vm.max_map_count=262144

➜  sysctl -p
```

> 参考链接：  
> 1、[elasticsearch启动常见错误](https://www.cnblogs.com/zhi-leaf/p/8484337.html)  
>