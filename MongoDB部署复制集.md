# MongoDB 部署复制集

## 一、环境准备

> 官网地址  
> https://www.mongodb.com/download-center/community  
>

### 1.1、安装包准备(V4.2.2)
``` bash
# 下载安装包并解压
$ wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.2.tgz
$ tar -zxvf mongodb-linux-x86_64-rhel70-4.2.2.tgz -C /opt

# 验证版本信息
$ ./mongo --version
MongoDB shell version v4.2.2

# 创建mongodb配置文件目录
$ mkdir -p /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf   
```

## 二、配置服务

### 2.1、rs0 配置文件
``` bash
# 在每个节点都执行
# 创建rs0数据目录
$ mkdir -p /ahdata/mongodb/rs0/
# 配置文件                     
$ cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/conf/rs0.yaml << EOF
replication:
    oplogSizeMB: 2048   
    replSetName: rs0
systemLog:
    destination: file
    path: "/ahdata/mongodb/rs0.log"
    logAppend: true
storage:
    dbPath: "/ahdata/mongodb/rs0/"
    journal:
        enabled: true
    directoryPerDB: true
    #engine: wiredTiger
    wiredTiger:
        engineConfig:
            cacheSizeGB: 2
            directoryForIndexes: true
        collectionConfig:
            blockCompressor: zlib
        indexConfig:
            prefixCompression: true
processManagement:
    fork: true
net:
    bindIp: 0.0.0.0
    port: 27017
EOF
```

## 三、启动服务
### 3.1、启动复制集成员
``` bash
# 在每个节点都执行
$ cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
$ bin/mongod -f conf/rs0.yaml
```

### 3.2、初始化复制集
``` bash
# 连接到其中一台配置服务器
$ bin/mongo

# 启动副本集
rs.initiate( {
   _id : "rs0",
   members: [
      { _id: 0, host: "192.168.100.226:27017" },
      { _id: 1, host: "192.168.100.227:27017" },
      { _id: 2, host: "192.168.100.228:27017","arbiterOnly":true }
   ]
})

# 返回信息
{
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1578883252, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1578883252, 1)
}
```

### 3.3、查看节点状态
``` json
# 在mongo命令行中执行 rs.isMaster(), 查看节点状态
rs0:SECONDARY> rs.isMaster()
{
	"hosts" : [
		"192.168.100.226:27017",
		"192.168.100.227:27017"
	],
	"arbiters" : [
		"192.168.100.228:27017"
	],
	"setName" : "rs0",
	"setVersion" : 1,
	"ismaster" : false,
	"secondary" : true,
	"me" : "192.168.100.226:27017",
	"lastWrite" : {
		"opTime" : {
			"ts" : Timestamp(1578883252, 1),
			"t" : NumberLong(-1)
		},
		"lastWriteDate" : ISODate("2020-01-13T02:40:52Z")
	},
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 100000,
	"localTime" : ISODate("2020-01-13T02:40:59.824Z"),
	"logicalSessionTimeoutMinutes" : 30,
	"connectionId" : 1,
	"minWireVersion" : 0,
	"maxWireVersion" : 8,
	"readOnly" : false,
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1578883252, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1578883252, 1)
}
```
