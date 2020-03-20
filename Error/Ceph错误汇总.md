## Ceph错误汇总
### 1、执行ceph-deploy报错
#### 错误信息
``` bash
$ ceph-deploy
Traceback (most recent call last):
  File "/usr/bin/ceph-deploy", line 18, in <module>
    from ceph_deploy.cli import main
  File "/usr/lib/python2.7/site-packages/ceph_deploy/cli.py", line 1, in <module>
    import pkg_resources
ImportError: No module named pkg_resources
```

#### 解决办法
``` bash
yum install python-setuptools -y
```

### 2、安装ceph连接超时
#### 错误信息
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

#### 解决方法
``` bash
$ export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
$ export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

$ ceph-deploy install ceph-mon1 ceph-osd1 ceph-osd2
```

### 3、ceph -s 执行失败
#### 错误信息
``` bash
$ ceph -s
2020-03-06 03:41:43.104 7f5aedc74700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
2020-03-06 03:41:43.104 7f5aedc74700 -1 monclient: ERROR: missing keyring, cannot use cephx for authentication
```

#### 解决方法
``` bash
$ cd /opt/ceph-cluster

# 添加admin key至/etc/ceph
$ ceph-deploy admin ceph-mon1 ceph-osd1 ceph-osd2
或
$ cp ceph.client.admin.keyring /etc/ceph 
```

### 4、硬盘无法格式化
#### 错误信息
``` bash
# 磁盘无法进行格式化
$ mkfs.xfs /dev/sdb
mkfs.xfs: cannot open /dev/sdb: Device or resource busy
```

#### 错误解决
``` bash
# 查看磁盘状态
$ lsblk
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
$ dmsetup ls
ceph--f5aefc82--f489--4a94--abcd--87934fcbb457-osd--block--41ba649f--f99e--40f6--b2f9--afda1251c0ad	(253:3)
centos-home	(253:2)
centos-swap	(253:1)
centos-root	(253:0)

# 移除占用
$ dmsetup remove ceph--f5aefc82--f489--4a94--abcd--87934fcbb457-osd--block--41ba649f--f99e--40f6--b2f9--afda1251c0ad

# 查看状态
$ lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   80G  0 disk 
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   79G  0 part 
  ├─centos-root 253:0    0   50G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  
  └─centos-home 253:2    0   27G  0 lvm  /home
sdb               8:16   0   50G  0 disk 
sr0              11:0    1 1024M  0 rom 
```

### 5、too few PGs per OSD
#### 错误信息
``` bash
$ ceph -s
  cluster:
    id:     243f3ae6-326a-4af6-9adb-6538defbacb7
    health: HEALTH_WARN
            Reduced data availability: 128 pgs inactive, 128 pgs stale
            Degraded data redundancy: 128 pgs undersized
            too few PGs per OSD (12 < min 30)
```

#### 关于创建存储池  
确定 pg_num 取值是强制性的，因为不能自动计算。下面是几个常用的值：  
　　*少于 5 个 OSD 时可把 pg_num 设置为 128  
　　*OSD 数量在 5 到 10 个时，可把 pg_num 设置为 512  
　　*OSD 数量在 10 到 50 个时，可把 pg_num 设置为 4096  
　　*OSD 数量大于 50 时，你得理解权衡方法、以及如何自己计算 pg_num 取值  
　　*自己计算 pg_num 取值时可借助 pgcalc 工具  
随着 OSD 数量的增加，正确的 pg_num 取值变得更加重要，因为它显著地影响着集群的行为、以及出错时的数据持久性（即灾难性事件导致数据丢失的概率）。

#### 解决办法
``` bash
# 删除pool重建
$ ceph osd pool delete kube kube --yes-i-really-really-mean-it
Error EPERM: pool deletion is disabled; you must first set the mon_allow_pool_delete config option to true before you can destroy a pool

#根据提示需要将mon_allow_pool_delete的value设置为true
$ vim /opt/ceph-cluster/ceph.conf
mon_allow_pool_delete = true

# 传送配置文件
$ ceph-deploy --overwrite-conf config push ceph-mon1 ceph-osd1 ceph-osd2

# 列出所有ceph服务
$ systemctl list-units --type=service | grep ceph
ceph-crash.service                 loaded active running Ceph crash dump collector
ceph-mgr@ceph-mon1.service         loaded active running Ceph cluster manager daemon
ceph-mon@ceph-mon1.service         loaded active running Ceph cluster monitor daemon

# 重启服务ceph服务
$ systemctl restart ceph-mgr@ceph-mon1.service
$ systemctl restart ceph-mon@ceph-mon1.service

# 删除kube存储池
$ ceph osd pool delete kube kube --yes-i-really-really-mean-it
pool 'kube' removed

# 重新创建kube存储池
$ ceph osd pool create kube 512
pool 'kube' created
$ ceph  -s
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
#### 错误信息
``` bash
$ ceph health
HEALTH_WARN application not enabled on 1 pool(s)
```

#### 错误解决
``` bash
$ ceph health detail
HEALTH_WARN application not enabled on 1 pool(s)
POOL_APP_NOT_ENABLED application not enabled on 1 pool(s)
    application not enabled on pool 'kube'
    use 'ceph osd pool application enable <pool-name> <app-name>', where <app-name> is 'cephfs', 'rbd', 'rgw', or freeform for custom applications.
$ ceph osd pool application enable kube rbd
enabled application 'rbd' on pool 'kube'
$ ceph health
HEALTH_OK
```

### 7、安装ceph-common报错
#### 错误信息
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

#### 错误解决
``` bash
# 安装epel仓库
$ ansible k8s-node -m copy -a "src=/etc/yum.repos.d/aliyun.repo dest=/etc/yum.repos.d/aliyun.repo"

# 安装ceph-common
$ ansible k8s-node -m shell -a "yum install -y ceph-common"
```