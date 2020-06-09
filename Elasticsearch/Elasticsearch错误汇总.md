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
 
``` log
➜  ./kibana serve
 error  [05:51:54.559] [warning][stats-collection] [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_search","query":{},"body":"{\"query\":{\"term\":{\"type\":\"config\"}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:51:54.560] [warning][stats-collection] Unable to fetch data from kql collector
 error  [05:51:54.562] [warning][stats-collection] [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_search","query":{"ignore_unavailable":true,"filter_path":"aggregations.types.buckets"},"body":"{\"size\":0,\"query\":{\"terms\":{\"type\":[\"dashboard\",\"visualization\",\"search\",\"index-pattern\",\"graph-workspace\",\"timelion-sheet\"]}},\"aggs\":{\"types\":{\"terms\":{\"field\":\"type\",\"size\":6}}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:51:54.563] [warning][stats-collection] Unable to fetch data from kibana collector
 error  [05:51:54.563] [warning][stats-collection] [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_search","query":{"size":10000,"ignore_unavailable":true,"filter_path":"hits.hits._source.canvas-workpad,-hits.hits._source.canvas-workpad.assets"},"body":"{\"query\":{\"bool\":{\"filter\":{\"term\":{\"type\":\"canvas-workpad\"}}}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:51:54.563] [warning][stats-collection] Unable to fetch data from canvas collector
 error  [05:51:54.564] [warning][stats-collection] [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_search","query":{"size":1000,"ignore_unavailable":true,"filter_path":"hits.hits._id"},"body":"{\"query\":{\"bool\":{\"filter\":{\"term\":{\"index-pattern.type\":\"rollup\"}}}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:51:54.564] [warning][stats-collection] Unable to fetch data from rollups collector
 error  [05:51:54.564] [warning][stats-collection] [no_shard_available_action_exception] No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]] :: {"path":"/.kibana/_doc/config%3A7.1.1","query":{},"statusCode":503,"response":"{\"error\":{\"root_cause\":[{\"type\":\"no_shard_available_action_exception\",\"reason\":\"No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]]\"}],\"type\":\"no_shard_available_action_exception\",\"reason\":\"No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]]\"},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:51:54.565] [warning][stats-collection] Unable to fetch data from kibana_settings collector
  log   [05:51:54.595] [info][license][xpack] Imported license information from Elasticsearch for the [monitoring] cluster: mode: basic | status: active
  log   [05:51:55.100] [warning][browser-driver][reporting] Enabling the Chromium sandbox provides an additional layer of protection.
  log   [05:51:55.102] [warning][reporting] Generating a random key for xpack.reporting.encryptionKey. To prevent pending reports from failing on restart, please set xpack.reporting.encryptionKey in kibana.yml
  log   [05:51:55.120] [info][status][plugin:reporting@7.1.1] Status changed from uninitialized to green - Ready
  log   [05:51:55.175] [error][task_manager] Failed to poll for work: [search_phase_execution_exception] all shards failed :: {"path":"/.kibana_task_manager/_search","query":{"ignore_unavailable":true},"body":"{\"query\":{\"bool\":{\"must\":[{\"term\":{\"type\":\"task\"}},{\"bool\":{\"must\":[{\"terms\":{\"task.taskType\":[\"maps_telemetry\",\"vis_telemetry\"]}},{\"range\":{\"task.attempts\":{\"lte\":3}}},{\"range\":{\"task.runAt\":{\"lte\":\"now\"}}},{\"range\":{\"kibana.apiVersion\":{\"lte\":1}}}]}}]}},\"size\":10,\"sort\":{\"task.runAt\":{\"order\":\"asc\"}},\"seq_no_primary_term\":true}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
  log   [05:51:55.178] [warning][maps] Error scheduling telemetry task, received [cluster_block_exception] blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];
  log   [05:51:55.183] [warning][telemetry] Error scheduling task, received [cluster_block_exception] blocked by: [FORBIDDEN/12/index read-only / allow delete (api)];
  log   [05:51:58.180] [error][task_manager] Failed to poll for work: [search_phase_execution_exception] all shards failed :: {"path":"/.kibana_task_manager/_search","query":{"ignore_unavailable":true},"body":"{\"query\":{\"bool\":{\"must\":[{\"term\":{\"type\":\"task\"}},{\"bool\":{\"must\":[{\"terms\":{\"task.taskType\":[\"maps_telemetry\",\"vis_telemetry\"]}},{\"range\":{\"task.attempts\":{\"lte\":3}}},{\"range\":{\"task.runAt\":{\"lte\":\"now\"}}},{\"range\":{\"kibana.apiVersion\":{\"lte\":1}}}]}}]}},\"size\":10,\"sort\":{\"task.runAt\":{\"order\":\"asc\"}},\"seq_no_primary_term\":true}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
  log   [05:52:01.187] [error][task_manager] Failed to poll for work: [search_phase_execution_exception] all shards failed :: {"path":"/.kibana_task_manager/_search","query":{"ignore_unavailable":true},"body":"{\"query\":{\"bool\":{\"must\":[{\"term\":{\"type\":\"task\"}},{\"bool\":{\"must\":[{\"terms\":{\"task.taskType\":[\"maps_telemetry\",\"vis_telemetry\"]}},{\"range\":{\"task.attempts\":{\"lte\":3}}},{\"range\":{\"task.runAt\":{\"lte\":\"now\"}}},{\"range\":{\"kibana.apiVersion\":{\"lte\":1}}}]}}]}},\"size\":10,\"sort\":{\"task.runAt\":{\"order\":\"asc\"}},\"seq_no_primary_term\":true}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
  log   [05:52:04.191] [error][task_manager] Failed to poll for work: [search_phase_execution_exception] all shards failed :: {"path":"/.kibana_task_manager/_search","query":{"ignore_unavailable":true},"body":"{\"query\":{\"bool\":{\"must\":[{\"term\":{\"type\":\"task\"}},{\"bool\":{\"must\":[{\"terms\":{\"task.taskType\":[\"maps_telemetry\",\"vis_telemetry\"]}},{\"range\":{\"task.attempts\":{\"lte\":3}}},{\"range\":{\"task.runAt\":{\"lte\":\"now\"}}},{\"range\":{\"kibana.apiVersion\":{\"lte\":1}}}]}}]}},\"size\":10,\"sort\":{\"task.runAt\":{\"order\":\"asc\"}},\"seq_no_primary_term\":true}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
 error  [05:52:04.529] [warning][stats-collection] [no_shard_available_action_exception] No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]] :: {"path":"/.kibana/_doc/config%3A7.1.1","query":{},"statusCode":503,"response":"{\"error\":{\"root_cause\":[{\"type\":\"no_shard_available_action_exception\",\"reason\":\"No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]]\"}],\"type\":\"no_shard_available_action_exception\",\"reason\":\"No shard available for [get [.kibana][_doc][config:7.1.1]: routing [null]]\"},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
  log   [05:52:04.530] [warning][stats-collection] Unable to fetch data from kibana_settings collector
  log   [05:52:05.284] [error][status][plugin:spaces@7.1.1] Status changed from yellow to red - all shards failed: [search_phase_execution_exception] all shards failed
  log   [05:52:05.287] [fatal][root] { [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_count","query":{},"body":"{\"query\":{\"bool\":{\"should\":[{\"bool\":{\"must\":[{\"exists\":{\"field\":\"graph-workspace\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.graph-workspace\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"canvas-workpad\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.canvas-workpad\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"index-pattern\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.index-pattern\":\"6.5.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"visualization\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.visualization\":\"7.0.1\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"dashboard\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.dashboard\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"search\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.search\":\"7.0.0\"}}}}]}}]}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
    at respond (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:308:15)
    at checkRespForFailure (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/transport.js:267:7)
    at HttpConnector.<anonymous> (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/src/lib/connectors/http.js:166:7)
    at IncomingMessage.wrapper (/opt/kibana-7.1.1-linux-x86_64/node_modules/elasticsearch/node_modules/lodash/lodash.js:4935:19)
    at IncomingMessage.emit (events.js:194:15)
    at endReadableNT (_stream_readable.js:1103:12)
    at process._tickCallback (internal/process/next_tick.js:63:19)
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

 FATAL  [search_phase_execution_exception] all shards failed :: {"path":"/.kibana/_count","query":{},"body":"{\"query\":{\"bool\":{\"should\":[{\"bool\":{\"must\":[{\"exists\":{\"field\":\"graph-workspace\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.graph-workspace\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"canvas-workpad\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.canvas-workpad\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"index-pattern\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.index-pattern\":\"6.5.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"visualization\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.visualization\":\"7.0.1\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"dashboard\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.dashboard\":\"7.0.0\"}}}}]}},{\"bool\":{\"must\":[{\"exists\":{\"field\":\"search\"}},{\"bool\":{\"must_not\":{\"term\":{\"migrationVersion.search\":\"7.0.0\"}}}}]}}]}}}","statusCode":503,"response":"{\"error\":{\"root_cause\":[],\"type\":\"search_phase_execution_exception\",\"reason\":\"all shards failed\",\"phase\":\"query\",\"grouped\":true,\"failed_shards\":[]},\"status\":503}"}
```
