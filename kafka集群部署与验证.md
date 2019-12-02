# kafka集群部署与验证

## 一、官网下载kafka
``` bash
wget https://www.apache.org/dyn/closer.cgi?path=/kafka/2.3.0/kafka_2.12-2.3.0.tgz
```

## 二、zookeeper
### 2.1、配置zookeeper
``` bash
tar -zxvf kafka_2.12-2.3.0.tgz
cd /opt/kafka_2.12-2.3.0/config
[miaocunfa@db1 config]$ cat zookeeper.properties | grep -v ^# | grep -v ^$
dataDir=/ahdata/kafka-tmp/zookeeper
clientPort=2181
maxClientCnxns=0
tickTime=2000
initLimit=10
syncLimit=5
server.1=172.19.26.3:2888:3888
server.2=172.19.26.6:2888:3888
server.3=172.19.26.4:2888:3888
```

### 2.2、启动zookeeper
``` bash
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
```

### 2.3、检查zookeeper状态
``` bash
[root@db1 config]# echo stat | nc 172.19.26.3 2181 | grep Mode
Mode: follower
[root@db1 config]# echo stat | nc 172.19.26.4 2181 | grep Mode
Mode: follower
[root@db1 config]# echo stat | nc 172.19.26.6 2181 | grep Mode
Mode: leader
[root@db1 config]# echo stat | nc 172.19.26.3 2181
Zookeeper version: 3.4.14-4c25d480e66aadd371de8bd2fd8da255ac140bcf, built on 03/06/2019 16:18 GMT
Clients:
 /172.19.26.3:55016[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/0/0
Received: 2
Sent: 1
Connections: 1
Outstanding: 0
Zxid: 0x0
Mode: follower
Node count: 4
[root@db1 config]#
```

## 三、kafka
### 3.1、配置kafka
```
```

### 3.2、启动kafka
```
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
```

### 3.3、
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.3 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.4 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.6 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2

[miaocunfa@db1 kafka_2.12-2.3.0]$ bin/kafka-topics.sh --create --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --replication-factor 2 --partitions 3 --topic demo_topics
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic demo_topics.
[miaocunfa@db1 kafka_2.12-2.3.0]$ /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --list --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181
demo_topics
[miaocunfa@db1 kafka_2.12-2.3.0]$ /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --describe --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181
Topic:demo_topics	PartitionCount:3	ReplicationFactor:2	Configs:
	Topic: demo_topics	Partition: 0	Leader: 1	Replicas: 1,2	Isr: 1,2
	Topic: demo_topics	Partition: 1	Leader: 2	Replicas: 2,1	Isr: 2,1
	Topic: demo_topics	Partition: 2	Leader: 1	Replicas: 1,2	Isr: 1,2
[miaocunfa@db1 kafka_2.12-2.3.0]$

```
[miaocunfa@db1 kafka_2.12-2.3.0]$ /opt/kafka_2.12-2.3.0/bin/kafka-console-producer.sh --broker-list 172.19.26.3:9092,172.19.26.4:9092,172.19.26.6:9092 --topic demo_topics
>Hello Kafka!      
>

[root@db1 kafka_2.12-2.3.0]# /opt/kafka_2.12-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server=172.19.26.3:9092,172.19.26.4:9092,172.19.26.6:9092 --topic demo_topics --from-beginning
Hello Kafka!
```

java -cp KafkaOffsetMonitor-assembly-0.2.1.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb --zk 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --port 2188  --refresh 5.seconds --retain 1.days

[root@db1 kafkaMonitor]# /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --list --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181
__consumer_offsets
ad-label-topic
demo_topics
info-ad-topic
info-ad-update-topic
info-callback
info-favorite-topic
info-follow-topic
info-history
info-history-topic
info-order
info-update-ad-topic


java -cp KafkaOffsetMonitor-assembly-0.2.0.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb --zk 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --refresh 5.minutes --retain 1.day

echo '@WSX#EDC' | passwd --stdin miaocunfa
