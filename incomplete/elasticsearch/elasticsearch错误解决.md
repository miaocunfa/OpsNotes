# 解决elasticsearch错误

## 错误
```
[3] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65535]
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
[3]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```

## 错误1
``` log
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65535]
```

### 解决办法
``` bash
$ vi /etc/security/limits.conf
es  soft  nofile  65536
es  hard  nofile  65536
```

## 错误2
``` log
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

### 解决方法
``` bash
$ echo "vm.max_map_count=262144" > /etc/sysctl.conf
$ sysctl -p
vm.max_map_count = 262144
```

## 错误3

``` log
[3]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```

### 解决方法

``` bash
discovery.seed_hosts: ["192.168.100.217"]
cluster.initial_master_nodes: ["mytest-1"]
```

## 错误4

```
集群nfs
{
	"error": {
		"root_cause": [{
			"type": "repository_verification_exception",
			"reason": "[ah_backup] [[cib4J3-9S-Gu-HxzElx1KQ, 'RemoteTransportException[[node-1][172.19.26.3:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-1}{cib4J3-9S-Gu-HxzElx1KQ}{rcOvdo8VQ4eVJEqDRVwExQ}{172.19.26.3}{172.19.26.3:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];'], [tdlv8aquS_qiKOi7S1ODbg, 'RemoteTransportException[[node-3][172.19.26.4:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-3}{tdlv8aquS_qiKOi7S1ODbg}{MSLA7qUeTJWoQ0Qr90E-ug}{172.19.26.4}{172.19.26.4:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];']]"
		}],
		"type": "repository_verification_exception",
		"reason": "[ah_backup] [[cib4J3-9S-Gu-HxzElx1KQ, 'RemoteTransportException[[node-1][172.19.26.3:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-1}{cib4J3-9S-Gu-HxzElx1KQ}{rcOvdo8VQ4eVJEqDRVwExQ}{172.19.26.3}{172.19.26.3:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];'], [tdlv8aquS_qiKOi7S1ODbg, 'RemoteTransportException[[node-3][172.19.26.4:9300][internal:admin/repository/verify]]; nested: RepositoryVerificationException[[ah_backup] a file written by master to the store [/ahdata/elasticsearch-repository/ah_backup] cannot be accessed on the node [{node-3}{tdlv8aquS_qiKOi7S1ODbg}{MSLA7qUeTJWoQ0Qr90E-ug}{172.19.26.4}{172.19.26.4:9300}]. This might indicate that the store [/ahdata/elasticsearch-repository/ah_backup] is not shared between this node and the master node or that permissions on the store don't allow reading files written by the master node];']]"
	},
	"status": 500
}
```

### 解决方案

这是使用es快照时出现的错误，es集群创建快照repo，repo路径必须是共享存储。