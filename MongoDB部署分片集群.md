# MongoDB 部署分片集群

## 一、环境准备

> 官网地址  
> https://www.mongodb.com/download-center/community  
>

安装包准备(V4.2.2)
``` bash
# 下载安装包并解压
$ wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.2.tgz
$ tar -zxvf mongodb-linux-x86_64-rhel70-4.2.2.tgz -C /opt

# 验证版本信息
$ cd /opt/mongodb-linux-x86_64-rhel70-4.2.2
$ ./mongo --version
MongoDB shell version v4.2.2
git version: a0bbbff6ada159e19298d37946ac8dc4b497eadf
OpenSSL version: OpenSSL 1.0.1e-fips 11 Feb 2013
allocator: tcmalloc
modules: none
build environment:
    distmod: rhel70
    distarch: x86_64
    target_arch: x86_64
```

## 二、部署

### 2.1、机器规划

| 192.168.100.226 | 192.168.100.227 | 192.168.100.228 | 端口 |
| --------------- | --------------- | --------------- | ---- |
| config servers | config servers | config servers | 20000 |
| mongos | mongos | mongos | 21000 |
| shard1 | shard1 | shard1 | 27001 |
| shard2 | shard2 | shard2 | 27002 |

### 2.2、配置文件

#### 2.1、config server
``` bash
# 每个节点都执行

$ mkdir -p /opt/mongodb-linux-x86_64-rhel70-4.2.2/config
$ mkdir -p /ahdata/mongodb/config/
$ cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/config/config.conf << EOF
configsvr=true
port=20000
dbpath=/ahdata/mongodb/config/
logpath=/ahata/mongodb/config.log
logappend=true
fork=true
EOF
```

#### 2.2、mongos
``` bash
# 每个节点都执行

$ mkdir -p /ahdata/mongodb/mongos
$ cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/config/mongos.conf <<EOF 
configdb=server1:20000,server2:20000,server3:20000
port=21000
chunkSize=100
logpath=/ahdata/mongodb/mongos.log
logappend=true
fork=true
EOF
```

#### 2.3、shard1
``` bash
# 每个节点都执行

$ mkdir -p /ahdata/mongodb/shard1
$ cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/config/shard1.conf <<EOF 
shardsvr=true
replSet=shard1
port=27001
dbpath=/ahdata/mongodb/shard1
oplogSize=2048
logpath=/ahdata/mongodb/shard1.log
logappend=true
fork=true
#rest=true
#nojournal=true
EOF
```

#### 2.4、shard2
``` bash
# 每个节点都执行

$ mkdir -p /ahdata/mongodb/shard2
$ cat > /opt/mongodb-linux-x86_64-rhel70-4.2.2/config/shard2.conf <<EOF 
shardsvr=true
replSet=shard2
port=27002
dbpath=/ahdata/mongodb/shard2
oplogSize=2048
logpath=/ahdata/mongodb/shard2.log
logappend=true
fork=true
#rest=true
#nojournal=true
EOF
```

## 三、启动服务
``` bash
# 每个节点都执行

$ cd /opt/mongodb-linux-x86_64-rhel70-4.2.2/
$ bin/mongod --config config/config.conf
$ bin/mongod --config config/shard1.conf
$ bin/mongod --config config/shard2.conf
$ bin/mongos --config config/mongos.conf
```

## 四、配置分片


## 五、解决报错

### 5.1
```
$ bin/mongod --config config/shard1.conf
about to fork child process, waiting until server is ready for connections.
forked process: 31132
ERROR: child process failed, exited with error number 2
To see additional information in this output, start without the "--fork" option.

# 禁用选项
#nojournal=true
```

### 5.2
```
$ bin/mongod --config config/shard1.conf
Error parsing INI config file: unrecognised option 'rest'
try './mongod --help' for more information

# 禁用选项
#rest=true
```

### 5.3
```
$ bin/mongod --config config/config.conf
about to fork child process, waiting until server is ready for connections.
forked process: 31619
ERROR: child process failed, exited with error number 1
To see additional information in this output, start without the "--fork" option.


```

