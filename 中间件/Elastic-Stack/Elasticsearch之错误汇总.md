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
draft: true
--- 

## 更新记录

| 时间       | 内容           |
| ---------- | -------------- |
| 2020-06-09 | 初稿           |
| 2020-08-05 | 增加 es limits |
| 2020-09-30 | 增加 es master |

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

### 2.3、max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

``` zsh
➜  vi /etc/sysctl.conf
vm.max_map_count=262144

➜  sysctl -p
```

### 2.4、节点掉多了，master not discovered

``` zsh
[2020-09-29T16:50:25,320][WARN ][o.e.c.c.ClusterFormationFailureHelper] [es-node-3] master not discovered or elected yet, an election requires at least 2 nodes with ids from [hN_rn9JaRp-PRTnj4mmRYA, u3xjdGA7S0-5AytxnyADrw, rCdsFXdgRbCK1nkKpREnLg], have discovered [{es-node-1}{rCdsFXdgRbCK1nkKpREnLg}{PwdwISkQRDSZB6cclseBjA}{192.168.100.211}{192.168.100.211:9300}, {es-node-2}{hN_rn9JaRp-PRTnj4mmRYA}{wy04Vv9tQaeqghwxY_k5Lw}{192.168.100.212}{192.168.100.212:9300}] which is a quorum; discovery will continue using [192.168.100.211:9300, 192.168.100.212:9300] from hosts providers and [{es-node-3}{u3xjdGA7S0-5AytxnyADrw}{9BvhYJ-IQmOaVEjDCNq75A}{192.168.100.213}{192.168.100.213:9300}] from last-known cluster state; node term 142, last-accepted version 2736 in term 140
[2020-09-29T16:50:35,323][WARN ][o.e.c.c.ClusterFormationFailureHelper] [es-node-3] master not discovered or elected yet, an election requires at least 2 nodes with ids from [hN_rn9JaRp-PRTnj4mmRYA, u3xjdGA7S0-5AytxnyADrw, rCdsFXdgRbCK1nkKpREnLg], have discovered [{es-node-1}{rCdsFXdgRbCK1nkKpREnLg}{PwdwISkQRDSZB6cclseBjA}{192.168.100.211}{192.168.100.211:9300}, {es-node-2}{hN_rn9JaRp-PRTnj4mmRYA}{wy04Vv9tQaeqghwxY_k5Lw}{192.168.100.212}{192.168.100.212:9300}] which is a quorum; discovery will continue using [192.168.100.211:9300, 192.168.100.212:9300] from hosts providers and [{es-node-3}{u3xjdGA7S0-5AytxnyADrw}{9BvhYJ-IQmOaVEjDCNq75A}{192.168.100.213}{192.168.100.213:9300}] from last-known cluster state; node term 142, last-accepted version 2736 in term 140
```

### 2.5、

``` zsh
[2021-10-20T15:46:31,211][DEBUG][o.e.a.a.i.c.TransportCreateIndexAction] [node-2] no known master node, scheduling a retry
[2021-10-20T15:46:36,724][INFO ][o.e.c.c.JoinHelper       ] [node-2] failed to join {master}{CRkxVk4ATJ6ted3qxnxz8w}{yPIsZn-qRTWWAPMsaDACrw}{192.168.189.166}{192.168.189.166:9300}{ml.machine_memory=16656801792, ml.max_open_jobs=20, xpack.installed=true} with JoinRequest{sourceNode={node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20}, optionalJoin=Optional[Join{term=266, lastAcceptedTerm=264, lastAcceptedVersion=218293, sourceNode={node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20}, targetNode={master}{CRkxVk4ATJ6ted3qxnxz8w}{yPIsZn-qRTWWAPMsaDACrw}{192.168.189.166}{192.168.189.166:9300}{ml.machine_memory=16656801792, ml.max_open_jobs=20, xpack.installed=true}}]}
org.elasticsearch.transport.RemoteTransportException: [master][192.168.189.166:9300][internal:cluster/coordination/join]
Caused by: org.elasticsearch.cluster.coordination.FailedToCommitClusterStateException: publication failed
        at org.elasticsearch.cluster.coordination.Coordinator$CoordinatorPublication$3.onFailure(Coordinator.java:1353) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ListenableFuture$1.run(ListenableFuture.java:101) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.EsExecutors$DirectExecutorService.execute(EsExecutors.java:193) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ListenableFuture.notifyListener(ListenableFuture.java:92) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ListenableFuture.addListener(ListenableFuture.java:54) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.coordination.Coordinator$CoordinatorPublication.onCompletion(Coordinator.java:1293) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.coordination.Publication.onPossibleCompletion(Publication.java:124) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.coordination.Publication.cancel(Publication.java:88) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.coordination.Coordinator$CoordinatorPublication$2.run(Coordinator.java:1260) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ThreadContext$ContextPreservingRunnable.run(ThreadContext.java:688) ~[elasticsearch-7.2.0.jar:7.2.0]
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) ~[?:1.8.0_151]
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) ~[?:1.8.0_151]
        at java.lang.Thread.run(Thread.java:748) [?:1.8.0_151]
Caused by: org.elasticsearch.ElasticsearchException: publication cancelled before committing: timed out after 30s
        at org.elasticsearch.cluster.coordination.Publication.cancel(Publication.java:85) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.coordination.Coordinator$CoordinatorPublication$2.run(Coordinator.java:1260) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ThreadContext$ContextPreservingRunnable.run(ThreadContext.java:688) ~[elasticsearch-7.2.0.jar:7.2.0]
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) ~[?:1.8.0_151]
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) ~[?:1.8.0_151]
        at java.lang.Thread.run(Thread.java:748) ~[?:1.8.0_151]
[2021-10-20T15:46:41,431][INFO ][o.e.c.s.MasterService    ] [node-2] elected-as-master ([2] nodes joined)[{master}{CRkxVk4ATJ6ted3qxnxz8w}{yPIsZn-qRTWWAPMsaDACrw}{192.168.189.166}{192.168.189.166:9300}{ml.machine_memory=16656801792, ml.max_open_jobs=20, xpack.installed=true} elect leader, {node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20} elect leader, _BECOME_MASTER_TASK_, _FINISH_ELECTION_], term: 268, version: 218296, reason: master node changed {previous [], current [{node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20}]}
[2021-10-20T15:46:41,828][INFO ][o.e.c.c.JoinHelper       ] [node-2] failed to join {master}{CRkxVk4ATJ6ted3qxnxz8w}{yPIsZn-qRTWWAPMsaDACrw}{192.168.189.166}{192.168.189.166:9300}{ml.machine_memory=16656801792, ml.max_open_jobs=20, xpack.installed=true} with JoinRequest{sourceNode={node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20}, optionalJoin=Optional[Join{term=267, lastAcceptedTerm=266, lastAcceptedVersion=218295, sourceNode={node-2}{6l844bT5R46ExfAiT0tpdQ}{v4VjPbJMS7KX29LzgaHsKw}{192.168.189.168}{192.168.189.168:9300}{ml.machine_memory=33566531584, xpack.installed=true, ml.max_open_jobs=20}, targetNode={master}{CRkxVk4ATJ6ted3qxnxz8w}{yPIsZn-qRTWWAPMsaDACrw}{192.168.189.166}{192.168.189.166:9300}{ml.machine_memory=16656801792, ml.max_open_jobs=20, xpack.installed=true}}]}
org.elasticsearch.transport.RemoteTransportException: [master][192.168.189.166:9300][internal:cluster/coordination/join]
Caused by: org.elasticsearch.cluster.coordination.FailedToCommitClusterStateException: node is no longer master for term 267 while handling publication
        at org.elasticsearch.cluster.coordination.Coordinator.publish(Coordinator.java:1012) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.service.MasterService.publish(MasterService.java:252) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.service.MasterService.runTasks(MasterService.java:238) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.service.MasterService$Batcher.run(MasterService.java:142) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.service.TaskBatcher.runIfNotProcessed(TaskBatcher.java:150) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.cluster.service.TaskBatcher$BatchedTask.run(TaskBatcher.java:188) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.ThreadContext$ContextPreservingRunnable.run(ThreadContext.java:688) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.PrioritizedEsThreadPoolExecutor$TieBreakingPrioritizedRunnable.runAndClean(PrioritizedEsThreadPoolExecutor.java:252) ~[elasticsearch-7.2.0.jar:7.2.0]
        at org.elasticsearch.common.util.concurrent.PrioritizedEsThreadPoolExecutor$TieBreakingPrioritizedRunnable.run(PrioritizedEsThreadPoolExecutor.java:215) ~[elasticsearch-7.2.0.jar:7.2.0]
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) ~[?:1.8.0_151]
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) ~[?:1.8.0_151]
        at java.lang.Thread.run(Thread.java:748) [?:1.8.0_151]
[2021-10-20T15:46:42,109][DEBUG][o.e.a.a.i.c.TransportCreateIndexAction] [node-2] no known master node, scheduling a retry
```

``` zsh
curl 192.168.189.166:9200/_cat/health
{"error":{"root_cause":[{"type":"master_not_discovered_exception","reason":null}],"type":"master_not_discovered_exception","reason":null},"status":503}
```

> 参考链接：  
> 1、[elasticsearch启动常见错误](https://www.cnblogs.com/zhi-leaf/p/8484337.html)  
>