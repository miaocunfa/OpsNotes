---
title: "解决elassandra错误"
date: "2020-01-02"
categories:
    - "技术"
tags:
    - "elasticsearch"
    - "Cassandra"
    - "elassandra"
    - "搜索引擎"
    - "错误排查"
toc: true
---

# 解决elassandra错误

## 错误1 - 不能使用root用户启动
```
$ bin/cassandra -e -f
Running Cassandra as root user or group is not recommended - please start Cassandra using a different system user.
If you really want to force running Cassandra as root, use -R command line option.
```

### 解决方案
```
$ useradd elassandra
$ chown -R elassandra:elassandra elassandra-6.2.3.22
```

## 错误2
```
2020-01-02 03:28:05,811 WARN  [main] org.elasticsearch.bootstrap.JNANatives.tryMlockall(JNANatives.java:97) Increase RLIMIT_MEMLOCK, soft limit: 65536, hard limit: 65536
2020-01-02 03:28:05,812 WARN  [main] org.elasticsearch.bootstrap.JNANatives.tryMlockall(JNANatives.java:101) These can be adjusted by modifying /etc/security/limits.conf, for example: 
	# allow user 'elassandra' mlockall
	elassandra soft memlock unlimited
	elassandra hard memlock unlimited
```

### 解决方案
```
$ vi /etc/security/limits.conf
# allow user 'elassandra' mlockall
elassandra soft memlock unlimited
elassandra hard memlock unlimited
```

## 错误3
```
2020-01-02 03:33:00,008 ERROR [main] org.apache.cassandra.service.ElassandraDaemon.main(ElassandraDaemon.java:585) Exception
java.lang.IllegalStateException: path.home is not configured
	at org.elasticsearch.env.Environment.<init>(Environment.java:97)
	at org.elasticsearch.node.InternalSettingsPreparer.prepareEnvironment(InternalSettingsPreparer.java:85)
	at org.elasticsearch.node.InternalSettingsPreparer.prepareEnvironment(InternalSettingsPreparer.java:66)
	at org.elasticsearch.node.Node.<init>(Node.java:246)
	at org.apache.cassandra.service.ElassandraDaemon.activate(ElassandraDaemon.java:181)
	at org.apache.cassandra.service.ElassandraDaemon.main(ElassandraDaemon.java:548)
```

### 解决方案
```
$ vi ~/.bash_profile
export CASSANDRA_HOME=/opt/elassandra-6.2.3.22
export CASSANDRA_CONF=/opt/elassandra-6.2.3.22/conf
$ source ~/.bash_profile
```

> 参考列表  
> 1、https://github.com/strapdata/elassandra/issues/273  
>
