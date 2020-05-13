---
title: "Ceph对象存储"
date: "2020-05-13"
categories:
    - "技术"
tags:
    - "Ceph"
    - "对象存储"
    - "分布式存储"
toc: false
original: true
---

## 一、ceph存储集群
``` bash
# 编辑hosts文件
vim /etc/hosts
192.168.100.234    node234
192.168.100.238    ceph-mon

# 192.168.100.238 ceph-deploy
➜  yum install ceph-deploy -y
➜  hostnamectl set-hostname ceph-mon

# repo地址
➜  export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
➜  export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

# 创建ceph-deploy目录
➜  mkdir /opt/ceph-cluster && cd /opt/ceph-cluster 
➜  ceph-deploy new ceph-mon

# 修改ceph配置文件
➜  vim ceph.conf 
[global]
fsid = 6ab7b319-0028-4032-9706-796962f06217
mon_initial_members = ceph-mon
mon_host = 192.168.100.238
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

osd_pool_default_size = 2

# 安装ceph
➜  ceph-deploy install ceph-mon node234
➜  ceph --version

# 创建Mon、Mgr节点
➜  ceph-deploy mon create-initial
➜  ceph-deploy admin ceph-mon
➜  ceph-deploy mgr create ceph-mon
➜  ceph -s

# 推送配置文件
➜  ceph-deploy --overwrite-conf config push ceph-mon node234

# 准备磁盘
➜  parted -s /dev/sdb mklabel gpt
➜  parted -s /dev/sdb mkpart primary 0% 33%
➜  parted -s /dev/sdb mkpart primary 34% 67%
➜  parted -s /dev/sdb mkpart primary 68% 100%
➜  partprobe
➜  chown -R ceph:ceph /dev/sdb1
➜  chown -R ceph:ceph /dev/sdb2
➜  chown -R ceph:ceph /dev/sdb3

# 添加OSD
➜  ceph-deploy osd create node234 --data /dev/sdb1
➜  ceph-deploy osd create node234 --data /dev/sdb2
➜  ceph-deploy osd create node234 --data /dev/sdb3
```