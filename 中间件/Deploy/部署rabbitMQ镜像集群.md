---
title: "部署rabbitMQ镜像集群"
date: "2020-03-25"
categories:
    - "技术"
tags:
    - "消息队列"
    - "rabbit MQ"
    - "haproxy"
toc: false
original: true
draft: false
---

## 更新信息

| 时间       | 内容         |
| ---------- | ------------ |
| 2020-03-25 | 初稿         |
| 2020-08-05 | 文档结构优化 |
| 2020-08-12 | 增加插件列表 |

## 版本信息

``` info
    rabbit MQ: 3.8.2
    Erlang: 官方建议最低21.3 推荐22.x
            这里用的是22.2.8
```

## 一、环境准备

### 1.1、主机规划

| 主机            | 节点     |
| --------------- | -------- |
| 192.168.100.217 | 磁盘节点 |
| 192.168.100.218 | 内存节点 |
| 192.168.100.219 | 磁盘节点 |

``` log
内存节点：
    内存节点将所有的队列、交换机、绑定、用户、权限和 vhost 的元数据定义存储在内存中，好处是可以使得像交换机和队列声明等操作更加的快速。例外情况是：持久的 queue 的内容将被保存到磁盘。

磁盘节点：
    将元数据存储在磁盘中，单节点系统只允许磁盘类型的节点，防止重启 RabbitMQ 的时候，丢失系统的配置信息。

注意点：
    1、内存节点由于不进行磁盘读写，它的性能比磁盘节点高。
    2、集群中可以存在多个磁盘节点，磁盘节点越多整个集群可用性越好，但是集群整体性能不会线性增加，需要权衡考虑。
    3、RabbitMQ 要求在集群中至少有一个磁盘节点，所有其他节点可以是内存节点，当节点加入或者离开集群时，必须要将该变更通知到至少一个磁盘节点。如果集群中唯一的一个磁盘节点崩溃的话，集群仍然可以保持运行，但是无法进行其他操作（增删改查），直到节点恢复。
    4、设置两个磁盘节点，至少有一个是可用的，可以保存元数据的更改。
```

### 1.2、下载离线包

[官网安装手册](https://www.rabbitmq.com/install-generic-unix.html)

```  zsh
rabbit MQ：二进制版
➜  wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.8.2/rabbitmq-server-generic-unix-3.8.2.tar.xz

Erlang: 无依赖版 -- 该软件包剥离了一些Erlang模块和依赖项，这些对运行RabbitMQ而言不是必需的。
➜  wget https://github.com/rabbitmq/erlang-rpm/releases/download/v22.2.8/erlang-22.2.8-1.el7.x86_64.rpm
```

### 1.3、安装离线包

``` zsh
# 安装erlang
➜  yum install -y yum install erlang-22.2.8-1.el7.x86_64.rpm

# 解压rabbitmq
➜  xz -d rabbitmq-server-generic-unix-3.8.2.tar.xz
➜  tar -xvf rabbitmq-server-generic-unix-3.8.2.tar -C /opt
```

### 1.4、hosts文件

``` zsh
192.168.100.217    MQ1
192.168.100.218    MQ2
192.168.100.219    MQ3
```

### 1.5、配置文件

我们要自己在$Home/etc/rabbitmq中创建rabbitmq-env.conf, 详细信息请参阅 [官方配置说明](https://www.rabbitmq.com/configure.html)

``` zsh
# 创建持久化目录
➜  mkdir -p /ahdata/rabbitmq/store
➜  mkdir -p /ahdata/rabbitmq/logs

# 创建配置文件
➜  vim /opt/rabbitmq_server-3.8.2/etc/rabbitmq/rabbitmq-env.conf
# 指定节点的名字，默认rabbit@${hostname}
NODENAME=rabbit@MQ1
# 指定端口，默认5672
NODE_PORT=5672
# 配置持久目录
MNESIA_BASE=/ahdata/rabbitmq/store
# 配置日志目录 默认文件名字：${NODENAME}.log 可以用配置修改
LOG_BASE=/ahdata/rabbitmq/logs
```

## 二、启用服务

### 2.1、常用命令

``` zsh
➜  sbin/rabbitmq-server                          # 启动server
➜  sbin/rabbitmq-server -detached                # 后台启动server
➜  sbin/rabbitmqctl status                       # 查看节点状态
➜  sbin/rabbitmqctl shutdown                     # 停止运行的节点
➜  sbin/rabbitmqctl stop_app
➜  sbin/rabbitmqctl start_app
➜  sbin/rabbitmqctl cluster_status               # 查看集群状态
➜  sbin/rabbitmqctl set_cluster_name rabbit@MQ1  # 修改集群名称
➜  sbin/rabbitmqctl join_cluster <cluster_name>  # 加入集群
➜  sbin/rabbitmqctl change_cluster_node_type --node <node_name> [ disk | ram ]  # 修改节点类型
```

### 2.2、启动rabbit

``` zsh
➜  cd /opt/rabbitmq_server-3.8.2/
➜  sbin/rabbitmq-server -detached

# 查看节点状态
➜  sbin/rabbitmqctl status
```

### 2.3、erlang.cookie

Erlang 节点间通过认证 Erlang cookie 的方式允许互相通信。因为 rabbitmqctl 使用 Erlang OTP 通信机制来和 Rabbit 节点通信，运行 rabbitmqctl 的机器和所要连接的 Rabbit 节点必须使用相同的 Erlang cookie 。否则你会得到一个错误。

``` zsh
➜  cat /root/.erlang.cookie
IJPCAHDPWVYSDERZDUPG

# 保持cookie一致
➜  scp /root/.erlang.cookie n218:/root/.erlang.cookie
➜  scp /root/.erlang.cookie n219:/root/.erlang.cookie
```

现在三台机器上具有相同的 Erlang cookie 了。下面开始组建集群。

## 三、集群

### 3.1、基础概念

RabbitMQ 集群分为两种:

- 普通集群
- 镜像集群(普通集群的升级)

普通集群：

``` info
以两个节点（rabbit01、rabbit02）为例来进行说明。
rabbit01和rabbit02两个节点仅有相同的元数据，即队列的结构，但消息实体只存在于其中一个节点rabbit01（或者rabbit02）中。当消息进入rabbit01节点的Queue后，consumer从rabbit02节点消费时，RabbitMQ会临时在rabbit01、rabbit02间进行消息传输，把A中的消息实体取出并经过B发送给consumer。所以consumer应尽量连接每一个节点，从中取消息。即对于同一个逻辑队列，要在多个节点建立物理Queue。否则无论consumer连rabbit01或rabbit02，出口总在rabbit01，会产生瓶颈。当rabbit01节点故障后，rabbit02节点无法取到rabbit01节点中还未消费的消息实体。如果做了消息持久化，那么得等rabbit01节点恢复，然后才可被消费；如果没有持久化的话，就会产生消息丢失的现象。
```

镜像集群：

``` info
在普通集群的基础上，把需要的队列做成镜像队列，消息实体会主动在镜像节点间同步，而不是在客户端取数据时临时拉取，也就是说多少节点消息就会备份多少份。该模式带来的副作用也很明显，除了降低系统性能外，如果镜像队列数量过多，加之大量的消息进入，集群内部的网络带宽将会被这种同步通讯大大消耗掉。所以在对可靠性要求较高的场合中适用。由于镜像队列之间消息自动同步，且内部有选举master机制，即使master节点宕机也不会影响整个集群的使用，达到去中心化的目的，从而有效的防止消息丢失及服务不可用等问题。
```

### 3.2、普通集群

#### 3.2.1、集群名

将集群名修改为rabbit@MQ1

``` zsh
# 修改集群名
➜  sbin/rabbitmqctl set_cluster_name rabbit@MQ1
Setting cluster name to rabbit@MQ1 ...

# 查看集群状态
➜  sbin/rabbitmqctl cluster_status  
Cluster status of node rabbit@MQ1 ...
Basics

Cluster name: rabbit@MQ1

Disk Nodes

rabbit@MQ1

Running Nodes

rabbit@MQ1
```

#### 3.2.2、加入集群

在218、219节点上执行

``` zsh
➜  sbin/rabbitmqctl stop_app
➜  sbin/rabbitmqctl join_cluster rabbit@MQ1
➜  sbin/rabbitmqctl start_app
```

#### 3.2.3、修改节点类型

查看集群状态

``` zsh
➜  sbin/rabbitmqctl cluster_status
Cluster status of node rabbit@MQ1 ...
Basics

Cluster name: rabbit@MQ1

Disk Nodes    # 磁盘节点

rabbit@MQ1    # 我们看到所有的节点都是disk类型与我们预设的架构不符
rabbit@MQ2    # 我们需要修改一下这个架构
rabbit@MQ3

Running Nodes

rabbit@MQ1
rabbit@MQ2
rabbit@MQ3
```

更改218节点为内存节点

``` zsh
# 停止节点
➜  sbin/rabbitmqctl stop_app
# 与集群通讯，从集群中删除节点
➜  sbin/rabbitmqctl reset
# 以RAM模式重新加入集群
➜  sbin/rabbitmqctl join_cluster rabbit@MQ1 --ram
# 启动节点
➜  sbin/rabbitmqctl start_app

➜  sbin/rabbitmqctl cluster_status
Cluster status of node rabbit@MQ1 ...
Basics

Cluster name: rabbit@MQ1

Disk Nodes

rabbit@MQ1
rabbit@MQ3

RAM Nodes

rabbit@MQ2

Running Nodes

rabbit@MQ1
rabbit@MQ2
rabbit@MQ3
```

节点单机状态时，reset 命令将清空节点的状态，并将其恢复到空白状态。当节点是集群的一部分时，该命令也会和集群中的磁盘节点通信，告诉他们该节点正在离开集群。

这很重要，不然，集群会认为该节点出了故障，并期望其最终能够恢复回来，在该节点回来之前，集群禁止新的节点加入。

### 3.3、镜像集群(HA)

上面我们已经成功部署了一个普通集群，普通集群并不是高可用的，下面基于普通集群升级为镜像集群
[官方HA方案](https://www.rabbitmq.com/ha.html)

``` zsh
➜  sbin/rabbitmqctl set_policy <name> [-p <vhost>] <pattern> <definition> [--apply-to <apply-to>]
    name: 策略名称
    vhost: 指定vhost, 默认值 /
    pattern: 通过正则表达式匹配哪些需要镜像, ^为所有
    definition:
        ha-mode: 指明镜像队列的模式，有效值为 all/exactly/nodes
            all     表示在集群所有的节点上进行镜像，无需设置ha-params
            exactly 表示在指定个数的节点上进行镜像，节点的个数由ha-params指定
            nodes   表示在指定的节点上进行镜像，节点名称通过ha-params指定
        ha-params: ha-mode 模式需要用到的参数
        ha-sync-mode: 镜像队列中消息的同步方式，有效值为automatic，manually
    apply-to: 策略作用对象。可选值3个，默认all
        exchanges 表示镜像 exchange (并不知道意义所在)
        queues    表示镜像 queue
        all       表示镜像 exchange和queue

➜  sbin/rabbitmqctl set_policy ahy "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
```

| ha-mode | ha-params | 功能                                                                                                                                                                |
| ------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| all     | 空        | 镜像队列将会在整个集群中复制。当一个新的节点加入后，也会在这 个节点上复制一份。                                                                                     |
| exactly | count     | 镜像队列将会在集群上复制 count 份。如果集群数量少于 count 时候，队列会复制到所有节点上。如果大于 Count 集群，有一个节点 crash 后，新进入节点也不会做新的镜像。      |
| nodes   | node name | 镜像队列会在 node name 中复制。如果这个名称不是集群中的一个，这不会触发错误。如果在这个 node list 中没有一个节点在线，那么这个 queue 会被声明在 client 连接的节点。 |

## 四、WEB管理

### 4.1、启用WEB管理插件

``` zsh
# 启动web管理插件
➜  sbin/rabbitmq-plugins enable rabbitmq_management

# 启用插件列表
➜  sbin/rabbitmq-plugins list
Listing plugins with pattern ".*" ...
 Configured: E = explicitly enabled; e = implicitly enabled
 | Status: * = running on rabbit@ty-db1
 |/
[  ] rabbitmq_amqp1_0                  3.8.2
[  ] rabbitmq_auth_backend_cache       3.8.2
[  ] rabbitmq_auth_backend_http        3.8.2
[  ] rabbitmq_auth_backend_ldap        3.8.2
[  ] rabbitmq_auth_backend_oauth2      3.8.2
[  ] rabbitmq_auth_mechanism_ssl       3.8.2
[  ] rabbitmq_consistent_hash_exchange 3.8.2
[  ] rabbitmq_event_exchange           3.8.2
[  ] rabbitmq_federation               3.8.2
[  ] rabbitmq_federation_management    3.8.2
[  ] rabbitmq_jms_topic_exchange       3.8.2
[E*] rabbitmq_management               3.8.2    # E 显式启用
[e*] rabbitmq_management_agent         3.8.2    # e 隐式启用

# 增加用户 && 设置用户角色
➜  sbin/rabbitmqctl add_user ahy ahy                  # 执行一遍
➜  sbin/rabbitmqctl set_user_tags ahy administrator   # 执行一遍
```

### 4.2、访问管理界面

``` zsh
➜  ss -tnlp | grep 5672
LISTEN     0      128          *:25672                    *:*                   users:(("beam.smp",pid=3593,fd=77))
LISTEN     0      128          *:15672                    *:*                   users:(("beam.smp",pid=3593,fd=93))
LISTEN     0      128         :::5672                    :::*                   users:(("beam.smp",pid=3593,fd=92))
```

打开浏览器访问<http://nodeip:15672>, 使用上面创建的用户登录即可

## 五、负载均衡

我们这里用haproxy做负载均衡

### 5.1、增加VIP

``` zsh
➜  ip addr add 192.168.100.242/24 dev eth0:mq

➜  ip a
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 5a:fd:bf:c3:43:ec brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.217/24 brd 192.168.100.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.100.242/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
```

### 5.2、配置文件

``` zsh
➜  vim /opt/rabbitmq_server-3.8.2/etc/haproxy.cnf
global
    log     127.0.0.1  local0 info
    log     127.0.0.1  local1 notice
    daemon
    maxconn 4096

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    retries 3
    option  abortonclose
    maxconn 4096
    timeout connect  5000ms
    timeout client  3000ms
    timeout server  3000ms
    balance roundrobin

listen private_monitoring
    bind    192.168.100.242:8100
    mode    http
    option  httplog
    stats   refresh  5s
    stats   uri  /stats
    stats   realm   Haproxy
    stats   auth  admin:admin

listen rabbitmq_cluster
    bind    192.168.100.242:8101
    mode    tcp
    option  tcplog
    balance roundrobin
    server  MQ1  192.168.100.217:5672  check  inter  5000  rise  2  fall  3
    server  MQ2  192.168.100.218:5672  check  inter  5000  rise  2  fall  3
    server  MQ3  192.168.100.219:5672  check  inter  5000  rise  2  fall  3

listen rabbitmq_admin
    bind    192.168.100.242:8102
    server  MQ1  192.168.100.217:15672
    server  MQ2  192.168.100.218:15672
    server  MQ3  192.168.100.219:15672
```

### 5.3、启动haproxy

``` zsh
➜  haproxy -f /opt/rabbitmq_server-3.8.2/etc/haproxy.cnf
```

> 参考链接:  
> 1、[官方二进制手册](https://www.rabbitmq.com/install-generic-unix.html)  
> 2、[官方集群手册](https://www.rabbitmq.com/clustering.html)  
> 3、<https://www.jianshu.com/p/97fbf9c82872>  
> 4、<https://my.oschina.net/genghz/blog/1840262>  
> 5、<https://www.jianshu.com/p/d55fcee12918>  
> 6、<https://www.jianshu.com/p/7cf2ad01c422>  
> 7、<https://blog.csdn.net/yujin2010good/article/details/73614507>  
> 8、<http://www.haproxy.org/>  
> 9、<https://blog.csdn.net/winy_lm/article/details/81128181>  
> 10、<https://www.cnblogs.com/knowledgesea/p/6535766.html>
>