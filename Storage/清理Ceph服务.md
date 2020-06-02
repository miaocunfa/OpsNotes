---
title: "清理Ceph服务"
date: "2020-06-02"
categories:
    - "技术"
tags:
    - "Ceph"
    - "服务清理"
toc: false
original: true
---

## 一、清理OSD节点

### 1.1、关闭OSD服务

``` zsh
➜  ps -ef|grep ceph
root       27262       1  0 May13 ?        00:45:00 /usr/bin/python2.7 /usr/bin/ceph-crash
root     1673429       2  0 10:58 ?        00:00:00 [ceph-msgr]
root     1673454       2  0 10:58 ?        00:00:00 [ceph-watch-noti]
ceph     2393522       1  1 15:06 ?        00:00:24 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph
ceph     2395750       1  1 15:09 ?        00:00:19 /usr/bin/ceph-osd -f --cluster ceph --id 2 --setuser ceph --setgroup ceph
ceph     2409194       1  1 15:17 ?        00:00:13 /usr/bin/ceph-osd -f --cluster ceph --id 1 --setuser ceph --setgroup ceph
➜  systemctl stop ceph-osd@0
➜  systemctl stop ceph-osd@1
➜  systemctl stop ceph-osd@2
```

### 1.2、清理OSD磁盘

``` zsh
➜  lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   80G  0 disk
├─sda1            8:1    0    1G  0 part /boot
└─sda2            8:2    0   79G  0 part
  ├─centos-root 253:0    0   50G  0 lvm  /
  ├─centos-swap 253:1    0    2G  0 lvm  
  └─centos-home 253:2    0   27G  0 lvm  /home
sdb               8:16   0   32G  0 disk
├─sdb1            8:17   0 10.6G  0 part
│ └─ceph--36df9e22--4787--4c40--8eda--e4c39f4e3da8-osd--block--98ea0cdf--96d1--4b1b--b8b7--b9dc1af28f4d
                253:3    0 10.6G  0 lvm  
├─sdb2            8:18   0 10.6G  0 part
│ └─ceph--d439a7c4--3cf6--44a7--9ad5--2643561c9816-osd--block--64538ad4--8cad--4251--acde--e6e282c163f4
                253:4    0 10.6G  0 lvm  
└─sdb3            8:19   0 10.2G  0 part
  └─ceph--ee3c7dd2--b512--4b20--a2da--cfe92cd22c19-osd--block--8c893829--f506--435c--8ec6--30ba8628ba6c
                253:5    0 10.2G  0 lvm  
sr0              11:0    1 1024M  0 rom  
rbd0            252:0    0    2G  0 disk /var/lib/kubelet/pods/0e7d18fc-9ac5-4fe9-ad92-a3ad2333b608/volumes/kubernetes.io~rbd/pvc-4cb91622-ace3-4
➜  dmsetup ls
ceph--36df9e22--4787--4c40--8eda--e4c39f4e3da8-osd--block--98ea0cdf--96d1--4b1b--b8b7--b9dc1af28f4d (253:3)
ceph--ee3c7dd2--b512--4b20--a2da--cfe92cd22c19-osd--block--8c893829--f506--435c--8ec6--30ba8628ba6c (253:5)
centos-home (253:2)
centos-swap (253:1)
ceph--d439a7c4--3cf6--44a7--9ad5--2643561c9816-osd--block--64538ad4--8cad--4251--acde--e6e282c163f4 (253:4)
centos-root (253:0)
➜  dmsetup remove ceph--36df9e22--4787--4c40--8eda--e4c39f4e3da8-osd--block--98ea0cdf--96d1--4b1b--b8b7--b9dc1af28f4d
➜  dmsetup remove ceph--ee3c7dd2--b512--4b20--a2da--cfe92cd22c19-osd--block--8c893829--f506--435c--8ec6--30ba8628ba6c
➜  dmsetup remove ceph--d439a7c4--3cf6--44a7--9ad5--2643561c9816-osd--block--64538ad4--8cad--4251--acde--e6e282c163f4
➜  dmsetup ls
centos-home (253:2)
centos-swap (253:1)
centos-root (253:0)
➜  lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   80G  0 disk
├─sda1   8:1    0    1G  0 part /boot
└─sda2   8:2    0   79G  0 part
  ├─centos-root
       253:0    0   50G  0 lvm  /
  ├─centos-swap
       253:1    0    2G  0 lvm  
  └─centos-home
       253:2    0   27G  0 lvm  /home
sdb      8:16   0   32G  0 disk
├─sdb1   8:17   0 10.6G  0 part
├─sdb2   8:18   0 10.6G  0 part
└─sdb3   8:19   0 10.2G  0 part
sr0     11:0    1 1024M  0 rom  
rbd0   252:0    0    2G  0 disk /var/lib/kubelet/pods/0e7d18fc-9ac5-4fe9-ad92-a3ad2333b608/volumes/kubernetes.io~rbd/pvc-4cb91622-ace3-404a-8194-
➜  mkfs.xfs -f /dev/sdb
meta-data=/dev/sdb               isize=512    agcount=4, agsize=2097152 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=8388608, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=4096, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
➜  lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   80G  0 disk
├─sda1   8:1    0    1G  0 part /boot
└─sda2   8:2    0   79G  0 part
  ├─centos-root
       253:0    0   50G  0 lvm  /
  ├─centos-swap
       253:1    0    2G  0 lvm  
  └─centos-home
       253:2    0   27G  0 lvm  /home
sdb      8:16   0   32G  0 disk
sr0     11:0    1 1024M  0 rom  
rbd0   252:0    0    2G  0 disk /var/lib/kubelet/pods/0e7d18fc-9ac5-4fe9-ad92-a3ad2333b608/volumes/kubernetes.io~rbd/pvc-4cb91622-ace3-404a-8194-
```

### 1.3、移除ceph服务

``` zsh
➜  yum list installed | grep ceph
Repodata is over 2 weeks old. Install yum-cron? Or run: yum makecache fast
ceph.x86_64                          2:13.2.10-0.el7                @ceph
ceph-base.x86_64                     2:13.2.10-0.el7                @ceph
ceph-common.x86_64                   2:13.2.10-0.el7                @ceph
ceph-mds.x86_64                      2:13.2.10-0.el7                @ceph
ceph-mgr.x86_64                      2:13.2.10-0.el7                @ceph
ceph-mon.x86_64                      2:13.2.10-0.el7                @ceph
ceph-osd.x86_64                      2:13.2.10-0.el7                @ceph
ceph-radosgw.x86_64                  2:13.2.10-0.el7                @ceph
ceph-selinux.x86_64                  2:13.2.10-0.el7                @ceph
libcephfs2.x86_64                    2:13.2.10-0.el7                @ceph
librados2.x86_64                     2:13.2.10-0.el7                @ceph
libradosstriper1.x86_64              2:13.2.10-0.el7                @ceph
librbd1.x86_64                       2:13.2.10-0.el7                @ceph
librgw2.x86_64                       2:13.2.10-0.el7                @ceph
python-ceph-argparse.x86_64          2:13.2.10-0.el7                @ceph
python-cephfs.x86_64                 2:13.2.10-0.el7                @ceph
python-rados.x86_64                  2:13.2.10-0.el7                @ceph
python-rbd.x86_64                    2:13.2.10-0.el7                @ceph
python-rgw.x86_64                    2:13.2.10-0.el7                @ceph
➜  yum list installed | grep ceph | awk '{print $1}' | xargs yum remove -y
Removed:
  ceph.x86_64 2:13.2.10-0.el7                   ceph-base.x86_64 2:13.2.10-0.el7             ceph-common.x86_64 2:13.2.10-0.el7
  ceph-mds.x86_64 2:13.2.10-0.el7               ceph-mgr.x86_64 2:13.2.10-0.el7              ceph-mon.x86_64 2:13.2.10-0.el7
  ceph-osd.x86_64 2:13.2.10-0.el7               ceph-radosgw.x86_64 2:13.2.10-0.el7          ceph-selinux.x86_64 2:13.2.10-0.el7
  libcephfs2.x86_64 2:13.2.10-0.el7             librados2.x86_64 2:13.2.10-0.el7             libradosstriper1.x86_64 2:13.2.10-0.el7
  librbd1.x86_64 2:13.2.10-0.el7                librgw2.x86_64 2:13.2.10-0.el7               python-ceph-argparse.x86_64 2:13.2.10-0.el7
  python-cephfs.x86_64 2:13.2.10-0.el7          python-rados.x86_64 2:13.2.10-0.el7          python-rbd.x86_64 2:13.2.10-0.el7
  python-rgw.x86_64 2:13.2.10-0.el7

Complete!
➜  ll /var/lib/ceph/
total 228
drwxr-x---    2 ceph ceph     26 Apr 24 01:07 bootstrap-osd
drwxr-x--- 2287 ceph ceph 188416 Jun  2 15:57 crash
drwxr-x---    5 ceph ceph     48 May 13 20:05 osd
➜  rm -rf /var/lib/ceph/
rm: cannot remove ‘/var/lib/ceph/osd/ceph-0’: Device or resource busy
rm: cannot remove ‘/var/lib/ceph/osd/ceph-1’: Device or resource busy
rm: cannot remove ‘/var/lib/ceph/osd/ceph-2’: Device or resource busy
➜  umount /var/lib/ceph/osd/*
➜  rm -rf /var/lib/ceph/
➜  rm -rf /var/run/ceph/
➜  rm -rf /etc/ceph
```

## 二、清理Mon节点

### 2.1、停止服务

``` zsh
➜  ps -ef|grep ceph
root        3388       1  0 Jun01 ?        00:00:00 /usr/bin/python2.7 /usr/bin/ceph-crash
ceph        3769       1  0 Jun01 ?        00:05:29 /usr/bin/ceph-mon -f --cluster ceph --id ceph-mon --setuser ceph --setgroup ceph
ceph        3771       1  0 Jun01 ?        00:04:57 /usr/bin/ceph-mgr -f --cluster ceph --id ceph-mon --setuser ceph --setgroup ceph
root     1099844       1  0 17:33 ?        00:00:00 /usr/bin/radosgw -f --cluster ceph --name client.rgw.ceph-mon --setuser ceph --setgroup ceph
root     1101724 1028850  0 17:37 pts/0    00:00:00 grep --color=auto ceph
➜  systemctl stop ceph-mgr@ceph-mon1.service
➜  systemctl stop ceph-mon@ceph-mon1.service
➜  systemctl stop ceph-radosgw@rgw.ceph-mon.service
```

### 2.2、卸载服务

``` zsh
➜  yum list installed | grep ceph
➜  yum list installed | grep ceph | awk '{print $1}' | xargs yum remove -y

➜  rm -rf /var/lib/ceph
➜  rm -rf /var/run/ceph
➜  rm -rf /etc/ceph
```
