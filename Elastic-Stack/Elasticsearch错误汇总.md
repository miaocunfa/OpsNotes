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
 
## kibana启动报错

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

## elasticsearch清空数据目录

```

```
