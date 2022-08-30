---
title: "Ceph错误汇总"
date: "2020-05-14"
categories:
    - "技术"
tags:
    - "Ceph"
    - "错误汇总"
toc: false
original: true
draft: true
---

## Ceph错误汇总

### 1、执行ceph-deploy报错

#### 1.1、错误信息

``` zsh
➜  ceph-deploy
Traceback (most recent call last):
  File "/usr/bin/ceph-deploy", line 18, in <module>
    from ceph_deploy.cli import main
  File "/usr/lib/python2.7/site-packages/ceph_deploy/cli.py", line 1, in <module>
    import pkg_resources
ImportError: No module named pkg_resources
```

#### 1.2、解决办法

``` zsh
➜  yum install python-setuptools -y
```

### 2、安装ceph连接超时

#### 2.1、错误信息

``` log
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

#### 2.2、解决方法

``` zsh
➜  export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
➜  export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

➜  ceph-deploy install ceph-mon1 ceph-osd1 ceph-osd2
```

### 3、ceph -s 执行失败

#### 3.1、错误信息

``` zsh
➜  ceph -s
2020-03-06 03:41:43.104 7f5aedc74700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2020-03-06 03:41:43.104 7f5aedc74700 -1 monclient: ERROR: missing keyring, cannot use cephx for authentication
```

#### 3.2、解决方法

``` zsh
➜  cd /opt/ceph-cluster

# 添加admin key至/etc/ceph
➜  ceph-deploy admin ceph-mon1 ceph-osd1 ceph-osd2
或
➜  cp ceph.client.admin.keyring /etc/ceph
```

### 4、硬盘无法格式化

#### 4.1、错误信息

``` zsh
# 磁盘无法进行格式化
➜  mkfs.xfs /dev/sdb
mkfs.xfs: cannot open /dev/sdb: Device or resource busy
```

#### 4.2、错误解决

``` zsh
# 查看磁盘状态
➜  lsblk
NAME                                                                                                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                                                                                                     8:0    0   80G  0 disk
├─sda1                                                                                                  8:1    0    1G  0 part /boot
└─sda2                                                                                                  8:2    0   79G  0 part
  ├─centos-root                                                                                       253:0    0   50G  0 lvm  /
  ├─centos-swap                                                                                       253:1    0    2G  0 lvm  
  └─centos-home                                                                                       253:2    0   27G  0 lvm  /home
sdb                                                                                                     8:16   0   50G  0 disk
└─ceph--f5aefc82--f489--4a94--abcd--87934fcbb457-osd--block--41ba649f--f99e--40f6--b2f9--afda1251c0ad 253:3    0   49G  0 lvm      # 发现ceph的一些服务占用着磁盘
sr0

# 列出占用
➜  dmsetup ls
ceph--f5aefc82--f489--4a94--abcd--87934fcbb457-osd--block--41ba649f--f99e--40f6--b2f9--afda1251c0ad (253:3)
centos-home (253:2)
centos-swap (253:1)
centos-root (253:0)

# 移除占用
➜  dmsetup remove ceph--f5aefc82--f489--4a94--abcd--87934fcbb457-osd--block--41ba649f--f99e--40f6--b2f9--afda1251c0ad

# 查看状态
➜  lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   80G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   79G  0 part
  ├─centos-root 253:0    0   50G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  
  └─centos-home 253:2    0   27G  0 lvm  /home
sdb               8:16   0   50G  0 disk
sr0              11:0    1 1024M  0 rom

# 格式化硬盘
➜  mkfs.xfs -f /dev/sdb
meta-data=/dev/sdb               isize=512    agcount=4, agsize=3276800 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=13107200, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=6400, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

### 5、too few PGs per OSD

#### 5.1、错误信息

``` zsh
➜  ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN
            Reduced data availability: 128 pgs inactive, 128 pgs stale
            Degraded data redundancy: 128 pgs undersized
            too few PGs per OSD (12 < min 30)
```

#### 5.2、关于创建存储池  

确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
　　*少于 5 个 OSD 时可把 pg_num 设置为 128  
　　*OSD 数量在 5 到 10 个时，可把 pg_num 设置为 512  
　　*OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
　　*OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算 pg_num 取值  
　　*自己计算 pg_num 取值时可借助 pgcalc 工具  
随着 OSD 数量的增加，正确的 pg_num 取值变得更加重要，因为它显著地影响着集群的行为、以及出错时的数据持久性（即灾难性事件导致数据丢失的概率）。

#### 5.3、解决办法

``` zsh
# 删除pool重建
➜  ceph osd pool delete kube kube --yes-i-really-really-mean-it
Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool

#根据提示需要将mon_allow_pool_delete的value设置为true
➜  vim /opt/ceph-cluster/ceph.conf
mon_allow_pool_delete = true

# 传送配置文件
➜  ceph-deploy --overwrite-conf config push ceph-mon1 ceph-osd1 ceph-osd2

# 列出所有ceph服务
➜  systemctl list-units --type=service | grep ceph
ceph-crash.service                 loaded active running Ceph crash dump collector
ceph-mgr@ceph-mon1.service         loaded active running Ceph cluster manager daemon
ceph-mon@ceph-mon1.service         loaded active running Ceph cluster monitor daemon

# 重启服务ceph服务
➜  systemctl restart ceph-mgr@ceph-mon1.service
➜  systemctl restart ceph-mon@ceph-mon1.service

# 删除kube存储池
➜  ceph osd pool delete kube kube --yes-i-really-really-mean-it
pool 'kube' removed

# 重新创建kube存储池
➜  ceph osd pool create kube 512
pool 'kube' created
➜  ceph  -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_OK               # 集群状态ok

  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: ceph-mon1(active)
    osd: 10 osds: 10 up, 10 in

  data:
    pools:   1 pools, 512 pgs
    objects: 0  objects, 0 B
    usage:   10 GiB used, 80 GiB / 90 GiB avail
    pgs:     100.000% pgs unknown
             512 unknown
```

### 6、application not enabled on 1 pool

#### 6.1、错误信息

``` zsh
➜  ceph health
HEALTH_WARN application not enabled on 1 pool(s)
```

#### 6.2、错误解决

``` zsh
➜  ceph health detail
HEALTH_WARN application not enabled on 1 pool(s)
POOL_APP_NOT_ENABLED application not enabled on 1 pool(s)
    application not enabled on pool 'kube'
    use 'ceph osd pool application enable <pool-name> <app-name>', where <app-name> is 'cephfs', 'rbd', 'rgw', or freeform for custom applications.
➜  ceph osd pool application enable kube rbd
enabled application 'rbd' on pool 'kube'
➜  ceph health
HEALTH_OK
```

### 7、安装ceph-common报错

#### 7.1、错误信息

``` log
--> Finished Dependency Resolution
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: libleveldb.so.1()(64bit)
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: liboath.so.0(LIBOATH_1.10.0)(64bit)
Error: Package: 2:librbd1-13.2.8-0.el7.x86_64 (ceph)
           Requires: liblttng-ust.so.0()(64bit)
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: libbabeltrace-ctf.so.1()(64bit)
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: libbabeltrace.so.1()(64bit)
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: liboath.so.0(LIBOATH_1.2.0)(64bit)
Error: Package: 2:librgw2-13.2.8-0.el7.x86_64 (ceph)
           Requires: liboath.so.0()(64bit)
Error: Package: 2:librados2-13.2.8-0.el7.x86_64 (ceph)
           Requires: liblttng-ust.so.0()(64bit)
Error: Package: 2:librgw2-13.2.8-0.el7.x86_64 (ceph)
           Requires: liblttng-ust.so.0()(64bit)
Error: Package: 2:ceph-common-13.2.8-0.el7.x86_64 (ceph)
           Requires: liboath.so.0()(64bit)
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

#### 7.2、错误解决

``` zsh
# 安装epel仓库
➜  ansible k8s-node -m copy -a "src=/etc/yum.repos.d/aliyun.repo dest=/etc/yum.repos.d/aliyun.repo"

# 安装ceph-common
➜  ansible k8s-node -m shell -a "yum install -y ceph-common"
```

### 8、修复down掉的ceph osd

#### 8.1、错误信息

``` zsh
➜  ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_ERR
            2/99 objects unfound (2.020%)
            Reduced data availability: 1 pg inactive, 1 pg peering, 1 pg stale
            Possible data damage: 2 pgs recovery_unfound
            Degraded data redundancy: 4/198 objects degraded (2.020%), 2 pgs degraded
            16 slow ops, oldest one blocked for 47468 sec, daemons [osd.4,osd.8] have slow ops.
            mon ceph-mon1 is low on available space

  services:
    mon: 1 daemons, quorum ceph-mon1
    mgr: ceph-mon1(active)
    osd: 10 osds: 7 up, 7 in      # 10个OSD，有三个不在集群内，已经down掉了。

  data:
    pools:   1 pools, 512 pgs
    objects: 99  objects, 140 MiB
    usage:   7.5 GiB used, 56 GiB / 63 GiB avail
    pgs:     0.195% pgs not active
             4/198 objects degraded (2.020%)
             2/99 objects unfound (2.020%)
             509 active+clean
             2   active+recovery_unfound+degraded
             1   stale+peering

  io:
    client:   28 KiB/s wr, 0 op/s rd, 2 op/s wr
➜  ceph osd tree
ID CLASS WEIGHT  TYPE NAME          STATUS REWEIGHT PRI-AFF
-1       0.08789 root default
-3       0.04395     host ceph-osd1
 0   hdd 0.00879         osd.0          up  1.00000 1.00000
 1   hdd 0.00879         osd.1          up  1.00000 1.00000
 2   hdd 0.00879         osd.2        down        0 1.00000
 3   hdd 0.00879         osd.3        down        0 1.00000
 4   hdd 0.00879         osd.4          up  1.00000 1.00000
-5       0.04395     host ceph-osd2
 5   hdd 0.00879         osd.5          up  1.00000 1.00000
 6   hdd 0.00879         osd.6          up  1.00000 1.00000
 7   hdd 0.00879         osd.7          up  1.00000 1.00000
 8   hdd 0.00879         osd.8          up  1.00000 1.00000
 9   hdd 0.00879         osd.9        down        0 1.00000
```

#### 8.2、错误分析

``` log
  状态说明：
    集群内(in)
    集群外(out)
    活着且在运行(up)
    挂了且不再运行(down)

  说明：
    如果OSD活着，它也可以是 in或者 out 集群。如果它以前是 in 但最近 out 了， Ceph 会把其归置组迁移到其他OSD 。
    如果OSD out 了， CRUSH 就不会再分配归置组给它。如果它挂了（ down ）其状态也应该是 out 。
    如果OSD 状态为 down 且 in ，必定有问题，而且集群处于非健康状态。
```

#### 8.3、错误解决

``` zsh
# 先拉起所有osd
# ceph-osd1
➜  systemctl start ceph-osd@2
➜  systemctl start ceph-osd@3

# ceph-osd2
➜  systemctl start ceph-osd@9

➜  ceph-volume lvm activate --all

# 从Ceph版本13.0.0开始，ceph-disk已弃用
# 从搜索引擎搜索到以下激活osd的操作均已失效
# 1、ceph-deploy osd activate  ceph-osd1:/dev/sdb1 ceph-osd1:/dev/sdb2 ceph-osd1:/dev/sdb3 ceph-osd1:/dev/sdb4 ceph-osd1:/dev/sdb5 ceph-osd2:/dev/sdb1 ceph-osd2:/dev/sdb2 ceph-osd2:/dev/sdb3 ceph-osd2:/dev/sdb4 ceph-osd2:/dev/sdb5
# 2、ceph-disk activate-all
```

### 9、磁盘无法加入

#### 9.1、错误信息

``` log
➜  ceph-deploy osd create --data /dev/sdb1 ceph-osd
[ceph-osd][WARNIN] Running command: /bin/ceph-authtool --gen-print-key
[ceph-osd][WARNIN] Running command: /bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 08864eab-9a28-47ce-8ab7-829f6624d8c7
[ceph-osd][WARNIN]  stderr: [errno 1] error connecting to the cluster
[ceph-osd][WARNIN] -->  RuntimeError: Unable to create a new OSD id
[ceph-osd][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy.osd][ERROR ] Failed to execute command: /usr/sbin/ceph-volume --cluster ceph lvm create --bluestore --data /dev/sdb1
[ceph_deploy][ERROR ] GenericError: Failed to create 1 OSDs
```

#### 9.2、错误解决

``` zsh

```

### 10、对象存储删除pool

#### 10.1、错误信息

``` zsh
# 删除错误
➜  rados rmpool .rgw.root
WARNING:
  This will PERMANENTLY DESTROY an entire pool of objects with no way back.
  To confirm, pass the pool to remove twice, followed by     # 由于删除是非常危险的操作，请确认两遍名字
  --yes-i-really-really-mean-it                              # 并且增加确认选项，表明我真的想这样做

# 确认选项增加后报错
➜  rados rmpool .rgw.root .rgw.root --yes-i-really-really-mean-it
pool .rgw.root could not be removed
Check your monitor configuration - `mon allow pool delete` is set to false by default, change it to true to allow deletion of pools          # 需要在ceph配置文件，ceph-mon的配置中加入允许
error 1: (1) Operation not permitted
```

#### 10.2、解决错误

``` zsh
# 修改ceph.conf
➜  vim /opt/ceph-cluster/ceph.conf
mon_allow_pool_delete = true

# 推送配置文件
➜  ceph-deploy --overwrite-conf config push ceph-mon node234

# 重启服务
➜  systemctl restart ceph-mon@ceph-mon

# 删除pool
➜  rados rmpool .rgw.root .rgw.root --yes-i-really-really-mean-it
successfully deleted pool .rgw.root
```

### 11、对象存储创建pool -- pg数量不足

#### 11.1、错误信息

``` zsh
➜  cat ceph-rgw-pool.sh
#!/bin/bash

PG_NUM=128
PGP_NUM=128
SIZE=3

pool='.rgw
.rgw.root
.rgw.control
.rgw.gc
.rgw.buckets
.rgw.buckets.index
.rgw.buckets.extra
.log
.intent-log
.usage
.users
.users.email
.users.swift
.users.uid'

for i in $(echo $pool)
do
    ceph osd pool create $i $PG_NUM

    sleep 1

    ceph osd pool set $i size    $SIZE
    ceph osd pool set $i pgp_num $PGP_NUM
done

➜  ./ceph-rgw-pool.sh
pool '.rgw' created
set pool 6 size to 3
set pool 6 pgp_num to 128
pool '.rgw.root' created
Error ERANGE: pool id 7 pg_num 128 size 3 would mean 816 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
set pool 7 pgp_num to 128
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.rgw.control'
Error ENOENT: unrecognized pool '.rgw.control'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.rgw.gc'
Error ENOENT: unrecognized pool '.rgw.gc'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.rgw.buckets'
Error ENOENT: unrecognized pool '.rgw.buckets'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.rgw.buckets.index'
Error ENOENT: unrecognized pool '.rgw.buckets.index'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.rgw.buckets.extra'
Error ENOENT: unrecognized pool '.rgw.buckets.extra'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.log'
Error ENOENT: unrecognized pool '.log'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.intent-log'
Error ENOENT: unrecognized pool '.intent-log'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.usage'
Error ENOENT: unrecognized pool '.usage'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.users'
Error ENOENT: unrecognized pool '.users'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.users.email'
Error ENOENT: unrecognized pool '.users.email'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.users.swift'
Error ENOENT: unrecognized pool '.users.swift'
Error ERANGE:  pg_num 128 size 2 would mean 944 total pgs, which exceeds max 750 (mon_max_pg_per_osd 250 * num_in_osds 3)
Error ENOENT: unrecognized pool '.users.uid'
Error ENOENT: unrecognized pool '.users.uid'
```

#### 11.2、错误分析

报错原因：每个osd最多只支持250个pg，有3个osd，总共有750pg。现在新建了14个池，每个池占用的pg数为(750 / 14).
         pool size 设置为3，我们有3个副本，pg_num = (250 * 3 / 14 / 3)

处理办法：1、删除之前的池，然后修改脚本把pg数目设置小一点，再创建对象池。
         2、为了以后的使用我们每个池创建10个pg

#### 11.3、错误解决

``` zsh
# 列出已经创建的pool
➜  rados lspools
default.rgw.control
default.rgw.meta
default.rgw.log
.rgw
.rgw.root

# 删除已经创建的pool
➜  rados rmpool .rgw.root .rgw.root --yes-i-really-really-mean-it
➜  rados rmpool .rgw .rgw --yes-i-really-really-mean-it

# 修改脚本 pg大小
➜  vim ceph-rgw-pool.sh
PG_NUM=10
PGP_NUM=10
SIZE=3

# 重新创建pool
➜  ./ceph-rgw-pool.sh

# 列出pool
➜  rados lspools
default.rgw.control
default.rgw.meta
default.rgw.log
.rgw
.rgw.root
.rgw.control
.rgw.gc
.rgw.buckets
.rgw.buckets.index
.rgw.buckets.extra
.log
.intent-log
.usage
.users
.users.email
.users.swift
.users.uid
```

### 12、对象存储API -- s3cmd 创建 bucket

#### 12.1、错误信息

``` zsh
➜  s3cmd mb s3://first-bucket
ERROR: S3 error: 400 (InvalidLocationConstraint): The specified location-constraint is not valid
```

#### 12.2、错误解决

``` zsh
➜  vim /root/.s3cfg
bucket_location = ZH    # 把ZH改成US

# 创建bucket
➜  s3cmd mb s3://first-bucket
Bucket 's3://first-bucket/' created

# 列出bucket
➜  s3cmd ls
2020-05-14 07:14  s3://first-bucket
```
