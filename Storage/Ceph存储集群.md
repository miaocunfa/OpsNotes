---
title: "Ceph (mimic版) 部署"
date: "2020-03-05"
categories:
    - "技术"
tags:
    - "Ceph"
    - "分布式存储"
toc: false
original: true
---

## Ceph 概述

Ceph是一个可靠地、自动重均衡、自动恢复的分布式存储系统，根据场景划分可以将Ceph分为三大块，分别是对象存储、块设备存储和文件系统服务。在虚拟化领域里，比较常用到的是Ceph的块设备存储，比如在OpenStack项目里，Ceph的块设备存储可以对接OpenStack的cinder后端存储、Glance的镜像存储和虚拟机的数据存储，比较直观的是Ceph集群可以提供一个raw格式的块存储来作为虚拟机实例的硬盘。

Ceph相比其它存储的优势点在于它不单单是存储，同时还充分利用了存储节点上的计算能力，在存储每一个数据时，都会通过计算得出该数据存储的位置，尽量将数据分布均衡，同时由于Ceph的良好设计，采用了CRUSH算法、HASH环等方法，使得它不存在传统的单点故障的问题，且随着规模的扩大性能并不会受到影响。

### 支持类型

**对象存储**：即radosgw，兼容S3接口。通过rest api上传、下载文件。

**文件系统**：posix接口。可以将ceph集群看做一个共享文件系统挂载到本地。

**块存储**： 即rbd。有 kernel rbd 和 librbd 两种使用方式。支持快照、克隆。相当于一块硬盘挂到本地，用法和用途和硬盘一样。

### 核心组件

Ceph的核心组件包括OSD、Monitor和MDS

**OSD**：主要功能是存储数据、复制数据、平衡数据、恢复数据等，与其它OSD间进行心跳检查等，并将一些变化情况上报给Ceph Monitor。一般情况下一块硬盘对应一个OSD，由OSD来对硬盘存储进行管理，当然一个分区也可以成为一个OSD。当 Ceph 存储集群设定为有2个副本时，至少需要2个 OSD 守护进程，集群才能达到 active+clean 状态（ Ceph 默认有3个副本，但你可以调整副本数）

**Monitor**：主要负责监视Ceph集群，维护Ceph集群的健康状态，同时维护着Ceph集群中的各种Map图，比如OSD Map、Monitor Map、PG Map和CRUSH Map，这些Map统称为Cluster Map，Cluster Map是RADOS的关键数据结构，管理集群中的所有成员、关系、属性等信息以及数据的分发，比如当用户需要存储数据到Ceph集群时，OSD需要先通过Monitor获取最新的Map图，然后根据Map图和object id等计算出数据最终存储的位置。

**MDS**：主要保存的文件系统服务的元数据，但对象存储和块存储设备是不需要使用该服务的

## 一、环境准备

### 1.1、机器规划

|       节点      |   属性   | 
| --------------- | -------  | 
| 192.168.100.236 |    OSD节点   | 
| 192.168.100.237 |    OSD节点   |
| 192.168.100.238 |    管理节点、Mon节点、Mgr节点   | 

### 1.2、设置主机名

``` bash
# 192.168.100.236
➜  hostnamectl set-hostname ceph-osd1
➜  exec bash -l

# 192.168.100.237
➜  hostnamectl set-hostname ceph-osd2
➜  exec bash -l

# 192.168.100.238
➜  hostnamectl set-hostname ceph-mon1
➜  exec bash -l
```

### 1.3、host文件

``` bash
➜  vim /etc/hosts
192.168.100.236 ceph-osd1
192.168.100.237 ceph-osd2
192.168.100.238 ceph-mon1
```

### 1.4、关闭防火墙、Selinux

``` bash
# 所有主机都执行
# 防火墙
➜  systemctl stop firewalld
➜  systemctl status firewalld

# selinux
➜  setenforce 0
➜  vi /etc/selinux/config
SELINUX=disable
```

### 1.5、免密认证

``` bash
# 192.168.100.238
➜  ssh-keygen
➜  ssh-copy-id  ceph-osd1
➜  ssh-copy-id  ceph-osd2
```

### 1.6、repo仓库

为了保证速度，我们使用阿里云的yum源

``` bash
# 所有主机都执行
➜  vim /etc/yum.repos.d/ceph.repo
[Ceph]
name=Ceph packages for $basearch
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/x86_64/
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/noarch/
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://mirrors.aliyun.com/ceph/rpm-luminous/el7/SRPMS/
enabled=1
gpgcheck=0
type=rpm-md
gpgkey=https://mirrors.aliyun.com/ceph/keys/release.asc
priority=1
```

### 1.7、磁盘准备

在每一个OSD节点上，准备一块50G的裸盘，为了使用ceph的分布式特性，这里我们将磁盘分为5分区，使每个分区激活为一个OSD

``` bash
➜  parted -s /dev/sdb mklabel gpt
➜  parted -s /dev/sdb mkpart primary 0% 20%
➜  parted -s /dev/sdb mkpart primary 21% 40%
➜  parted -s /dev/sdb mkpart primary 41% 60%
➜  parted -s /dev/sdb mkpart primary 61% 80%
➜  parted -s /dev/sdb mkpart primary 81% 100%
```

## 二、配置服务

### 2.1、安装ceph-deploy

``` bash
# 192.168.100.238
➜  yum install ceph-deploy -y
```

### 2.2、生成Monitor的配置文件

Monitor可以为单节点，也可以组成集群来满足高可用，节点个数为奇数。

``` bash
# 192.168.100.238
➜  mkdir /opt/ceph-cluster && cd /opt/ceph-cluster 

# 单节点mon
➜  ceph-deploy new ceph-mon1
➜  ll
total 12
-rw-r--r--. 1 root root  202 Mar  6 01:38 ceph.conf
-rw-r--r--. 1 root root 2975 Mar  6 01:38 ceph-deploy-ceph.log
-rw-------. 1 root root   73 Mar  6 01:38 ceph.mon.keyring

➜  cat ceph.conf 
[global]
fsid = 243f3ae6-326a-4af6-9adb-6538defbacb7
mon_initial_members = ceph-mon1
# mon节点为192.168.100.238
mon_host = 192.168.100.238
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
```

### 2.3、修改副本数

在ceph.conf文件末行添加配置
将副本数修改为2(默认为3)，这样只需要两个osd也能达到active+clean状态

``` bash
➜  vim ceph.conf
osd_pool_default_size = 2
```

### 2.4、在所有节点安装ceph

``` bash
# 先将ceph repo地址导出，会避免连接超时的问题
➜  export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
➜  export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

➜  ceph-deploy install ceph-mon1 ceph-osd1 ceph-osd2

➜  ceph --version
ceph version 13.2.8 (5579a94fafbc1f9cc913a0f5d362953a5d9c3ae0) mimic (stable)
```

### 2.5、传送conf

``` bash
➜  mkdir -p /etc/ceph/    # 192.168.100.236
➜  mkdir -p /etc/ceph/    # 192.168.100.237
➜  mkdir -p /etc/ceph/    # 192.168.100.238

# 将配置文件传送到每一个ceph节点
➜  ceph-deploy --overwrite-conf config push ceph-mon1 ceph-osd1 ceph-osd2
```

### 2.6、初始化mon节点

``` bash
➜  ceph-deploy mon create-initial
# 配置admin key
➜  ceph-deploy admin ceph-mon1 ceph-osd1 ceph-osd2

# 查看mon是否添加成功
➜  ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum ceph-mon1     # 成功启动1个MON节点
    mgr: no daemons active
    osd: 0 osds: 0 up, 0 in

  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   0 B used, 0 B / 0 B avail
    pgs:
```

### 2.7、加入OSD节点

``` bash
➜  ceph-deploy osd create --data /dev/sdb1 ceph-osd1
➜  ceph-deploy osd create --data /dev/sdb2 ceph-osd1
➜  ceph-deploy osd create --data /dev/sdb3 ceph-osd1
➜  ceph-deploy osd create --data /dev/sdb4 ceph-osd1
➜  ceph-deploy osd create --data /dev/sdb5 ceph-osd1
➜  ceph-deploy osd create --data /dev/sdb1 ceph-osd2
➜  ceph-deploy osd create --data /dev/sdb2 ceph-osd2
➜  ceph-deploy osd create --data /dev/sdb3 ceph-osd2
➜  ceph-deploy osd create --data /dev/sdb4 ceph-osd2
➜  ceph-deploy osd create --data /dev/sdb5 ceph-osd2

➜  ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN
            Reduced data availability: 128 pgs inactive, 128 pgs stale
            Degraded data redundancy: 128 pgs undersized
            too few PGs per OSD (12 < min 30)

  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: ceph-mon1(active)
    osd: 10 osds: 10 up, 10 in

  data:
    pools:   1 pools, 128 pgs
    objects: 0  objects, 0 B
    usage:   10 GiB used, 80 GiB / 90 GiB avail
    pgs:     100.000% pgs not active
             128 stale+undersized+remapped+peered
```

### 2.8、创建存储池

``` bash
# 创建存储池
➜  ceph osd pool create kube pg_num
```

其中：<pg_num> = 128,  
关于创建存储池  
确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
　　*少于 5 个 OSD 时可把 pg_num 设置为 128  
　　*OSD 数量在 5 到 10 个时，可把 pg_num 设置为 512  
　　*OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
　　*OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算 pg_num 取值  
　　*自己计算 pg_num 取值时可借助 pgcalc 工具  
随着 OSD 数量的增加，正确的 pg_num 取值变得更加重要，因为它显著地影响着集群的行为、以及出错时的数据持久性（即灾难性事件导致数据丢失的概率）。

``` bash
# 查看存储池
➜  ceph osd pool ls
kube
```

### 2.9、加入Mgr节点

``` bash
# 使用ceph health命令查看集群健康，提示没有激活的mgr节点
➜  ceph health
HEALTH_WARN no active mgr
```

``` bash
➜  ceph-deploy mgr create ceph-mon1

➜  ceph health
HEALTH_WARN Degraded data redundancy: 128 pgs undersized; OSD count 2 < osd_pool_default_size 3

➜  ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN                            # 集群状态已经处于warn状态，需要进行处理
            Degraded data redundancy: 128 pgs undersized
            OSD count 2 < osd_pool_default_size 3

  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: ceph-mon1(active)
    osd: 2 osds: 2 up, 2 in

  data:
    pools:   1 pools, 128 pgs                      # 存储池等信息
    objects: 0  objects, 0 B
    usage:   2.0 GiB used, 96 GiB / 98 GiB avail   # 集群状态信息
    pgs:     128 active+undersized
 ```

## 三、高阶使用

### 3.1、删除osd

``` bash
# 查看osd树
➜  ceph osd tree
ID CLASS WEIGHT  TYPE NAME          STATUS REWEIGHT PRI-AFF
-1       0.09579 root default
-3       0.04790     host ceph-osd1
 0   hdd 0.04790         osd.0          up  1.00000 1.00000
-5       0.04790     host ceph-osd2
 1   hdd 0.04790         osd.1          up  1.00000 1.00000

# 将osd移出集群
➜  ceph osd out 0
marked out osd.0. 
➜  ceph osd out 1
marked out osd.1. 

# 再次查看osd树
➜  ceph osd tree
ID CLASS WEIGHT  TYPE NAME          STATUS REWEIGHT PRI-AFF
-1       0.09579 root default
-3       0.04790     host ceph-osd1
 0   hdd 0.04790         osd.0          up        0 1.00000      #发现权重变为0了
-5       0.04790     host ceph-osd2
 1   hdd 0.04790         osd.1          up        0 1.00000

# 在ceph-osd1节点停止osd0
➜  systemctl stop ceph-osd@0
# 在ceph-osd2节点停止osd1
➜  systemctl stop ceph-osd@1

# 将osd从crush map中移除
➜  ceph osd crush remove osd.0
removed item id 0 name 'osd.0' from crush map
➜  ceph osd crush remove osd.1
removed item id 1 name 'osd.1' from crush map
➜  ceph osd tree
ID CLASS WEIGHT TYPE NAME          STATUS REWEIGHT PRI-AFF
-1            0 root default
-3            0     host ceph-osd1
-5            0     host ceph-osd2
 0            0 osd.0                down        0 1.00000
 1            0 osd.1                down        0 1.00000

# 最后删除osd
➜  ceph auth del osd.0
updated
➜  ceph osd rm 0
removed osd.0
➜  ceph auth del osd.1
updated
➜  ceph osd rm 1
removed osd.1

# 查看osd树，已经没有这个osd了
➜  ceph osd tree
ID CLASS WEIGHT TYPE NAME          STATUS REWEIGHT PRI-AFF
-1            0 root default
-3            0     host ceph-osd1
-5            0     host ceph-osd2

# 最后使用磁盘的清理命令，将块设备还原为裸盘
➜  ceph-disk zap /dev/sdb
```