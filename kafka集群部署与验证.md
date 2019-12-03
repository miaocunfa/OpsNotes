# kafka集群部署与验证

## 一、官网下载kafka
``` bash
wget https://www.apache.org/dyn/closer.cgi?path=/kafka/2.3.0/kafka_2.12-2.3.0.tgz
```

## 二、zookeeper
### 2.1、配置zookeeper
``` conf
tar -zxvf kafka_2.12-2.3.0.tgz
cd /opt/kafka_2.12-2.3.0/config

[miaocunfa@db1 config]$ cat zookeeper.properties | grep -v ^# | grep -v ^$

# tickTime：心跳基本时间单位，毫秒级，ZK基本上所有的时间都是这个时间的整数倍。
# initLimit：tickTime的个数，表示在leader选举结束后，followers与leader同步需要的时间，如果followers比较多或者说leader的数据灰常多时，同步时间相应可能会增加，那么这个值也需要相应增加。当然，这个值也是follower和observer在开始同步leader的数据时的最大等待时间(setSoTimeout)
# syncLimit：tickTime的个数，这时间容易和上面的时间混淆，它也表示follower和observer与leader交互时的最大等待时间，只不过是在与leader同步完毕之后，进入正常请求转发或ping等消息交互时的超时时间。
tickTime=2000
initLimit=10
syncLimit=5

# 内存数据库快照存放地址，如果没有指定事务日志存放地址(dataLogDir)，默认也是存放在这个路径下，建议两个地址分开存放到不同的设备上。
dataDir=/ahdata/kafka-tmp/zookeeper

# 配置ZK监听客户端连接的端口
clientPort=2181

# 默认值是10，一个客户端能够连接到同一个服务器上的最大连接数，根据IP来区分。如果设置为0，表示没有任何限制。设置该值一方面是为了防止DoS攻击。
maxClientCnxns=0

# server.serverid=host:tickpot:electionport
# server：固定写法
# serverid：每个服务器的指定ID（必须处于1-255之间，必须每一台机器不能重复）
# host：主机名
# tickpot：心跳通信端口
# electionport：选举端口
server.1=172.19.26.3:2888:3888
server.2=172.19.26.6:2888:3888
server.3=172.19.26.4:2888:3888
```

### 2.2 各节点分别创建server-id
``` bash
# myid文件创建在dataDir目录下
# myid内容与配置文件中的serverid一致
echo 1 > /ahdata/kafka-tmp/zookeeper/myid
echo 2 > /ahdata/kafka-tmp/zookeeper/myid
echo 2 > /ahdata/kafka-tmp/zookeeper/myid
```

### 2.3、启动zookeeper
``` bash
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
/opt/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
```

### 2.4、验证zookeeper状态
``` bash
[root@db1 config]# echo stat | nc 172.19.26.3 2181 | grep Mode
Mode: follower
[root@db1 config]# echo stat | nc 172.19.26.4 2181 | grep Mode
Mode: follower
[root@db1 config]# echo stat | nc 172.19.26.6 2181 | grep Mode
Mode: leader
```

## 三、kafka
### 3.1、配置kafka
``` conf
# 当前机器在集群中的唯一标识，和zookeeper的myid性质一样
broker.id=1

listeners=PLAINTEXT://172.19.26.3:9092
advertised.listeners=PLAINTEXT://172.19.26.3:9092

# broker 处理消息的最大线程数，一般情况下不需要去修改
num.network.threads=3

# broker处理磁盘IO 的线程数 ，数值应该大于你的硬盘数
num.io.threads=8

# 发送缓冲区buffer大小，数据不是一下子就发送的，先回存储到缓冲区了到达一定的大小后在发送，能提高性能
socket.send.buffer.bytes=102400

# kafka接收缓冲区大小，当数据到达一定大小后在序列化到磁盘
socket.receive.buffer.bytes=102400

# 这个参数是向kafka请求消息或者向kafka发送消息的请请求的最大数，这个值不能超过java的堆栈大小
socket.request.max.bytes=104857600

# 如果配置多个目录，新创建的topic他把消息持久化的地方是，当前以逗号分割的目录中，那个分区数最少就放那一个
log.dirs=/ahdata/kafka-tmp/kafka-logs

# 分区数，一个topic 3个分区
num.partitions=3

# 每个数据目录用来日志恢复的线程数目
num.recovery.threads.per.data.dir=1

# 集群高可用参数，建议使用大于1的值来确保可用性，比如3。
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=3

# 默认消息的最大持久化时间，168小时，7天
log.retention.hours=168

#这个参数是：因为kafka的消息是以追加的形式落地到文件，当超过这个值的时候，kafka会新起一个文件
log.segment.bytes=1073741824

# 每隔300000毫秒去检查上面配置的log失效时间
log.retention.check.interval.ms=300000

# zookeeper的连接端口
zookeeper.connect=172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181

# zookeeper的连接超时时间
zookeeper.connection.timeout.ms=6000

# 客户端消费者重新选举的延时时间，默认0
group.initial.rebalance.delay.ms=0

# 允许删除topic
delete.topic.enable=true
```

### 3.2、启动kafka
``` bash
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
/opt/kafka_2.12-2.3.0/bin/kafka-server-start.sh -daemon config/server.properties
```

### 3.3、验证kafka状态
``` bash
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.3 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.4 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2
[root@db1 kafka_2.12-2.3.0]# echo dump | nc 172.19.26.6 2181 | grep broker
	/brokers/ids/1
	/brokers/ids/2
```

## 四、验证集群
### 4.1、topic
``` bash
# 创建一个topic
[miaocunfa@db1 kafka_2.12-2.3.0]$ bin/kafka-topics.sh --create --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --replication-factor 2 --partitions 3 --topic demo_topics
WARNING: Due to limitations in metric names, topics with a period ('.') or underscore ('_') could collide. To avoid issues it is best to use either, but not both.
Created topic demo_topics.

# 列出所有topic
[miaocunfa@db1 kafka_2.12-2.3.0]$ /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --list --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181
demo_topics

# 查看topic详细情况
[miaocunfa@db1 config]$ /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --describe --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --topic demo_topics
Topic:demo_topics	PartitionCount:3	ReplicationFactor:2	Configs:
	Topic: demo_topics	Partition: 0	Leader: 2	Replicas: 1,2	Isr: 2,1
	Topic: demo_topics	Partition: 1	Leader: 2	Replicas: 2,1	Isr: 2,1
	Topic: demo_topics	Partition: 2	Leader: 2	Replicas: 1,2	Isr: 2,1
```

### 4.2、生产消费验证

ps. 1) 若producer 和 consumer 两个窗口同时打开，在producer输入信息，consumer会立即消费信息并打印在终端  
    2）新开一个终端，去消费同一个topic，刚刚已经消费过的消息还会被新终端继续消费。也就是说，消息被消费过后不会立即被删除。　

#### 4.2.1、生产者发送消息
``` bash
[miaocunfa@db1 kafka_2.12-2.3.0]$ /opt/kafka_2.12-2.3.0/bin/kafka-console-producer.sh --broker-list 172.19.26.3:9092,172.19.26.4:9092,172.19.26.6:9092 --topic demo_topics
>Hello Kafka!      
>
```

#### 4.2.2、消费者接收消息
``` bash
# 启动一个新终端创建一个消费者接收消息。
[root@db1 kafka_2.12-2.3.0]# /opt/kafka_2.12-2.3.0/bin/kafka-console-consumer.sh --bootstrap-server=172.19.26.3:9092,172.19.26.4:9092,172.19.26.6:9092 --topic demo_topics --from-beginning
Hello Kafka!
```

### 4.3、删除测试topic
``` bash
# 配置文件中delete.topic.enable=true才可删除topic
[miaocunfa@db1 config]$ /opt/kafka_2.12-2.3.0/bin/kafka-topics.sh --delete --zookeeper 172.19.26.3:2181,172.19.26.4:2181,172.19.26.6:2181 --topic demo_topics
Topic demo_topics is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```

> 参考：  
> 1.https://www.cnblogs.com/qingyunzong/p/8619184.html  
> 2.https://www.cnblogs.com/qingyunzong/p/9005062.html#_label3_5  
> 3.https://www.cnblogs.com/cici20166/p/9426417.html  
> 4.https://www.orchome.com/805
