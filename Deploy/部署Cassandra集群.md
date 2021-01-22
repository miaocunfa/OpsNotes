---
title: "部署 Cassandra 集群"
date: "2019-12-09"
categories:
    - "技术"
tags:
    - "Cassandra"
    - "NoSQL"
    - "数据库"
toc: false
original: true
draft: false
---

## 一、环境准备

### 1.1、下载二进制源码包

``` zsh
wget http://apache.mirrors.hoobly.com/cassandra/3.11.5/apache-cassandra-3.11.5-bin.tar.gz
```

### 1.2、节点准备

``` zsh
# 准备三台节点
192.168.100.226
192.168.100.227
192.168.100.228

# ansible配置
# 因为是测试环境，这里就直接配置密码，不去麻烦的配置免密验证了。
[root@master ~]# cat /etc/ansible/hosts
[casd]
192.168.100.226 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.227 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.228 ansible_ssh_user='root' ansible_ssh_pass='test123'
```

### 1.3、创建 Cassandra 用户

``` bash
# 创建用户
ansible casd -m user -a "name=cassandra state=present"

# 修改密码
ansible casd -m shell -a "echo cassandra | passwd --stdin cassandra"

# 将cassandra二进制包拷贝到部署节点上。
ansible casd -m copy -a "src=apache-cassandra-3.11.5.tar.gz dest=/home/cassandra/apache-cassandra-3.11.5.tar.gz"

# 解压源码包
ansible casd -m shell -a "cd /home/cassandra/; tar -zxvf apache-cassandra-3.11.5.tar.gz"
```

### 1.4、Java 环境准备

``` bash
# 拷贝jdk至部署节点
ansible casd -m copy -a "src=java-1.8.0-amazon-corretto-devel-1.8.0_212.b04-2.x86_64.rpm dest=/root"

# 安装jdk
ansible casd -m shell -a "yum install -y java-1.8.0-amazon-corretto-devel-1.8.0_212.b04-2.x86_64.rpm"

# 验证jdk
``` bash
[root@localhost ~]# java -version
openjdk version "1.8.0_212"
OpenJDK Runtime Environment Corretto-8.212.04.2 (build 1.8.0_212-b04)
OpenJDK 64-Bit Server VM Corretto-8.212.04.2 (build 25.212-b04, mixed mode)
```

### 1.5、配置用户环境变量

``` bash
# 切换用户
[root@localhost ~]# su - cassandra 
Last login: Fri Dec  6 04:27:53 EST 2019 on pts/1

# 配置环境变量
[cassandra@localhost ~]$ vi .bash_profile
export CASSANDRA_HOME=/home/cassandra/apache-cassandra-3.11.5
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto
export PATH=$JAVA_HOME/bin:$CASSANDRA_HOME/bin:$PATH

# 加载环境变量
[cassandra@localhost ~]$ source .bash_profile
```

## 二、部署 Cassandra

### 2.1、配置文件

修改配置文件 `/home/cassandra/apache-cassandra-3.11.5/conf/cassandra.yaml`

``` yaml
cluster_name: 'test'
data_file_directories:
    - /home/cassandra/apache-cassandra-3.11.5/data
commitlog_directory: /home/cassandra/apache-cassandra-3.11.5/data/commitlog
saved_caches_directory: /home/cassandra/apache-cassandra-3.11.5/data/saved_caches
seed_provider:
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          - seeds: "192.168.100.226"  # 因子
listen_address: 192.168.100.226       # 监听地址，不可以为127.0.0.1
start_rpc: true
rpc_address: 192.168.100.226          # rpc监听地址，不可以为127.0.0.1
```

### 2.2、各节点

各节点的 `listen_address` 和 `rpc_address` 需要按节点配置，且不能使用 `localhost`，因子 `seeds` 配置为第一个启动的节点。

``` zsh
First Node
--------------
seeds: "192.168.100.226"
listen_address: 192.168.100.226
rpc_address: 192.168.100.226

Second Node
---------------
seeds: "192.168.100.226"
listen_address: 192.168.100.227
rpc_address: 192.168.100.227

Third Node
---------------
seeds: "192.168.100.226"
listen_address: 192.168.100.228
rpc_address: 192.168.100.228
```

## 三、启动 Cassandra 服务

### 3.1、启动服务

``` bash
# 先启动226, 使用-f选项启动在前台
/home/cassandra/apache-cassandra-3.11.5/bin/cassandra

# 再启动其余的节点
/home/cassandra/apache-cassandra-3.11.5/bin/cassandra
/home/cassandra/apache-cassandra-3.11.5/bin/cassandra
```

### 3.验证服务

使用 `nodetool status` 验证服务

``` bash
[cassandra@localhost ~]$/home/cassandra/apache-cassandra-3.11.5/bin/nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address          Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.100.226  302.76 KiB  256          69.2%             723cb923-d19c-4dea-8124-c4503dab4d75  rack1
UN  192.168.100.227  295.05 KiB  256          66.3%             5bbeeb09-9bf4-4e45-a7a1-168e4f87186f  rack1
UN  192.168.100.228  239.96 KiB  256          64.5%             78677dd0-797e-45b0-a34a-23842927af35  rack1
```
