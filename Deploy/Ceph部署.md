# Ceph (mimic版) 部署

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
| 192.168.100.238 |    管理节点、Mon节点   | 

### 1.2、设置主机名
``` bash
# 192.168.100.236
$ hostnamectl set-hostname ceph-osd1
$ exec bash -l

# 192.168.100.237
$ hostnamectl set-hostname ceph-osd2
$ exec bash -l

# 192.168.100.238
$ hostnamectl set-hostname ceph-mon1
$ exec bash -l
```

### 1.3、host文件
``` bash
$ vim /etc/hosts
192.168.100.236 ceph-osd1
192.168.100.237 ceph-osd2
192.168.100.238 ceph-mon1
```

### 1.4、关闭防火墙、Selinux
``` bash
# 所有主机都执行
# 防火墙
$ systemctl stop firewalld
$ systemctl status firewalld

# selinux
$ setenforce 0
$ vi /etc/selinux/config
SELINUX=disable
```

### 1.5、免密认证
``` bash
# 192.168.100.238
$ ssh-keygen
$ ssh-copy-id  ceph-osd1
$ ssh-copy-id  ceph-osd2
```

### 1.6、repo仓库
为了保证速度，我们使用阿里云的yum源
``` bash
# 所有主机都执行
$ vim /etc/yum.repos.d/ceph.repo
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

## 二、配置服务
### 2.1、安装ceph-deploy
``` bash
# 192.168.100.238
$ yum install ceph-deploy -y
```

### 2.2、生成Monitor的配置文件
Monitor可以为单节点，也可以组成集群来满足高可用，节点个数为奇数。
``` bash
# 192.168.100.238
$ mkdir /opt/ceph-cluster && cd /opt/ceph-cluster 

# 单节点mon
$ ceph-deploy new ceph-mon1
$ ll
total 12
-rw-r--r--. 1 root root  202 Mar  6 01:38 ceph.conf
-rw-r--r--. 1 root root 2975 Mar  6 01:38 ceph-deploy-ceph.log
-rw-------. 1 root root   73 Mar  6 01:38 ceph.mon.keyring

$ cat ceph.conf 
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
$ vim ceph.conf
osd_pool_default_size = 2
```

### 2.4、在所有节点安装ceph
``` bash
$ export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
$ export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

$ ceph-deploy install ceph-mon1 ceph-osd1 ceph-osd2

$ ceph --version
ceph version 13.2.8 (5579a94fafbc1f9cc913a0f5d362953a5d9c3ae0) mimic (stable)
```

### 2.5、传送conf
``` bash
$ mkdir -p /etc/ceph/    # 192.168.100.236
$ mkdir -p /etc/ceph/    # 192.168.100.237
$ mkdir -p /etc/ceph/    # 192.168.100.238

$ ceph-deploy --overwrite-conf config push ceph-mon1 ceph-osd1 ceph-osd2
```

### 2.6、初始化mon节点
``` bash
$ ceph-deploy mon create-initial
# 配置admin key
$ ceph-deploy admin ceph-mon1 ceph-osd1 ceph-osd2

# 查看mon是否添加成功
$ ceph -s
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
$ ceph-deploy osd create --data /dev/sdb ceph-osd1
$ ceph-deploy osd create --data /dev/sdb ceph-osd2

$ ceph -s
[root@ceph-mon1 /opt/ceph-cluster]# ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN
            no active mgr
 
  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: no daemons active
    osd: 2 osds: 2 up, 2 in            # 可以看到有2个OSD了
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0  objects, 0 B
    usage:   0 B used, 0 B / 0 B avail   # 但是关于集群状态信息不显示，这是因为我们需要mgr节点收集信息
    pgs:     
 
```

### 2.8、创建存储池
``` bash
# 创建存储池
$ ceph osd pool create kube pg_num
```

其中：<pg_num> = 128 ,
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
$ ceph osd pool ls
kube
```

### 2.9、加入Mgr节点
``` bash
# 使用ceph health命令查看集群健康，提示没有激活的mgr节点
$ ceph health
HEALTH_WARN no active mgr
```

``` bash
$ ceph-deploy mgr create ceph-mon1 

$ ceph health
HEALTH_WARN Degraded data redundancy: 128 pgs undersized; OSD count 2 < osd_pool_default_size 3

$ ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN
            Degraded data redundancy: 128 pgs undersized
            OSD count 2 < osd_pool_default_size 3
 
  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: ceph-mon1(active)
    osd: 2 osds: 2 up, 2 in
 
  data:
    pools:   1 pools, 128 pgs                      # 存储池等信息已经可以显示了
    objects: 0  objects, 0 B
    usage:   2.0 GiB used, 96 GiB / 98 GiB avail   # 集群状态信息也已经有了
    pgs:     128 active+undersized
    
 ```

## 三、错误
### 3.1、执行ceph-deploy报错
``` bash
[root@ceph-mon1 /opt/ceph-cluster]# ceph-deploy
Traceback (most recent call last):
  File "/usr/bin/ceph-deploy", line 18, in <module>
    from ceph_deploy.cli import main
  File "/usr/lib/python2.7/site-packages/ceph_deploy/cli.py", line 1, in <module>
    import pkg_resources
ImportError: No module named pkg_resources
```

解决办法
``` bash
yum install python-setuptools -y
```

### 3.2、安装ceph连接超时
```
[node1][DEBUG ] Downloading packages:
[node1][WARNIN] No data was received after 300 seconds, disconnecting...
[node1][INFO  ] Running command: ceph --version
[node1][ERROR ] Traceback (most recent call last):
[node1][ERROR ]   File "/usr/lib/python2.7/site-packages/ceph_deploy/lib/vendor/remoto/process.py", line 119, in run
[node1][ERROR ]     reporting(conn, result, timeout)
[node1][ERROR ]   File "/usr/lib/python2.7/site-packages/ceph_deploy/lib/vendor/remoto/log.py", line 13, in reporting
[node1][ERROR ]     received = result.receive(timeout)
[node1][ERROR ]   File "/usr/lib/python2.7/site-packages/ceph_deploy/lib/vendor/remoto/lib/vendor/execnet/gateway_base.py", line 704, in receive
[node1][ERROR ]     raise self._getremoteerror() or EOFError()
[node1][ERROR ] RemoteError: Traceback (most recent call last):
[node1][ERROR ]   File "<string>", line 1036, in executetask
[node1][ERROR ]   File "<remote exec>", line 12, in _remote_run
[node1][ERROR ]   File "/usr/lib64/python2.7/subprocess.py", line 711, in __init__
[node1][ERROR ]     errread, errwrite)
[node1][ERROR ]   File "/usr/lib64/python2.7/subprocess.py", line 1327, in _execute_child
[node1][ERROR ]     raise child_exception
[node1][ERROR ] OSError: [Errno 2] No such file or directory
[node1][ERROR ] 
[node1][ERROR ] 
[ceph_deploy][ERROR ] RuntimeError: Failed to execute command: ceph --version
```

解决方法
``` bash
$ export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
$ export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

$ ceph-deploy install ceph-mon1 ceph-osd1 ceph-osd2
```

### 3.3、ceph -s 执行失败
``` bash
$ ceph -s
2020-03-06 03:41:43.104 7f5aedc74700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2020-03-06 03:41:43.104 7f5aedc74700 -1 monclient: ERROR: missing keyring, cannot use cephx for authentication
```

解决方法
``` bash
$ cd /opt/ceph-cluster

# 添加admin key至/etc/ceph
$ ceph-deploy admin ceph-mon1 ceph-osd1 ceph-osd2
或
$ cp ceph.client.admin.keyring /etc/ceph 
```

### 3.4、
```
$ ceph-deploy osd create --data /dev/sdb ceph-osd2
[ceph-osd2][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy.osd][ERROR ] Failed to execute command: /usr/sbin/ceph-volume --cluster ceph lvm create --bluestore --data /dev/sdb
[ceph_deploy][ERROR ] GenericError: Failed to create 1 OSDs
```

解决错误
需要将挂载到文件系统磁盘卸载掉
```
[root@ceph-osd2 /etc/yum.repos.d]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   80G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   79G  0 part 
  ├─centos-root 253:0    0   50G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  
  └─centos-home 253:2    0   27G  0 lvm  /home
sdb               8:16   0   50G  0 disk /var/local/osd2
sr0              11:0    1 1024M  0 rom  

[root@ceph-osd2 /etc/yum.repos.d]# umount /var/local/osd2

[root@ceph-osd2 /etc/yum.repos.d]# lsblk
NAME                                                                                                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                                                                                                     8:0    0   80G  0 disk 
├─sda1                                                                                                  8:1    0    1G  0 part /boot
└─sda2                                                                                                  8:2    0   79G  0 part 
  ├─centos-root                                                                                       253:0    0   50G  0 lvm  /
  ├─centos-swap                                                                                       253:1    0    2G  0 lvm  
  └─centos-home                                                                                       253:2    0   27G  0 lvm  /home
sdb                                                                                                     8:16   0   50G  0 disk 
└─ceph--8d5d82e2--2f98--48a2--bda1--cb64aea5d328-osd--block--cc35252f--5531--4ad1--9c38--9e52086cde86 253:3    0   49G  0 lvm  
sr0                                                                                                    11:0    1 1024M  0 rom  
[root@ceph-osd2 /etc/yum.repos.d]#
```