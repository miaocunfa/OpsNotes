---
title: "Kubernetes之etcd操作"
date: "2020-07-15"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "etcd"
toc: false
indent: false
original: true
---

## 环境

| Server  | Version |
| ------- | ------- |
| etcdctl | 3.3.15  |
| API     | 3.3     |

## 一、概述

etcd 是一个响应快、分布式、一致的 key-value 存储

## 二、操作

### 2.1、进入etcd容器

``` zsh
# 获取etcd pod
➜  kubectl get pods -n kube-system
NAME                                              READY   STATUS        RESTARTS   AGE
etcd-apiserver.cluster.local                      1/1     Running       9          40d

# exec进入etcd内
➜  kubectl exec -n kube-system etcd-apiserver.cluster.local -it -- /bin/sh

# 容器内etcd的目录结构
# find / -name 'etcd' -print
/etc/kubernetes/pki/etcd   # 证书目录
/usr/local/bin/etcd        # 二进制程序
/var/lib/etcd              # 数据目录
```

### 2.2、etcdctl

#### etcd3 API

从kubernetes 1.6开始，etcd集群使用version 3

``` zsh
# 下载etcdctl, 以在etcd容器外访问etcd接口
# https://github.com/etcd-io/etcd/releases
➜  cp etcdctl /usr/local/bin/

# 设置API版本为3
# 必须先指定API的版本才能使用 --cert等参数指定证书, api2的参数与3不一致。
➜  export ETCDCTL_API=3

# 指定证书获取 endpoint的状态
➜  etcdctl --endpoints=https://localhost:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key  endpoint health
https://localhost:2379 is healthy: successfully committed proposal: took = 2.706905334s

# 可以声明 etcdctl的环境变量
➜  vim /etc/profile
# etcd
export ETCDCTL_API=3
export ETCDCTL_DIAL_TIMEOUT=3s;
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt;
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt;
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key;
export ETCD_ENDPOINTS=https://localhost:2379
➜  source /etc/profile

# 可以不用指定证书了
➜  etcdctl endpoint health
127.0.0.1:2379 is healthy: successfully committed proposal: took = 827.031484ms
```

### 2.3、Kubernetes资源

#### 2.3.1、etcdctl ls脚本

v3版本的数据存储没有目录层级关系了，而是采用平展（flat)模式，换句话说/a与/a/b并没有嵌套关系，而只是key的名称差别而已，这个和AWS S3以及OpenStack Swift对象存储一样，没有目录的概念，但是key名称支持/字符，从而实现看起来像目录的伪目录，但是存储结构上不存在层级关系。

也就是说etcdctl无法使用类似v2的ls命令。但是我还是习惯使用v2版本的etcdctl ls查看etcdctl存储的内容，于是写了个性能不怎么好但是可以用的shell脚本etcd_ls.sh:

``` zsh
➜  vim etcd_ls.sh
#!/bin/bash
PREFIX=${1:-/}
ORIG_PREFIX=${PREFIX}

LAST_CHAR=${PREFIX:${#PREFIX}-1:1}
if [[ $LAST_CHAR != '/' ]];
then
    # Append  '/' at the end if not exist
    PREFIX="$PREFIX/"
fi

for ITEM in $(etcdctl get "$PREFIX" --prefix=true --keys-only | grep "$PREFIX");
do
    PREFIX_LEN=${#PREFIX}
    CONTENT=${ITEM:$PREFIX_LEN}
    POS=$(expr index "$CONTENT" '/')

    if [[ $POS -le 0 ]];
    then
        # No '/', it's not dir, get whole str
        POS=${#CONTENT}
    fi

    CONTENT=${CONTENT:0:$POS}
    LAST_CHAR=${CONTENT:${#CONTENT}-1:1}

    if [[ $LAST_CHAR == '/' ]];
    then
        CONTENT=${CONTENT:0:-1}
    fi

    echo ${PREFIX}${CONTENT}

done | sort | uniq
```

#### 2.4.2、获取所有key

由于Kubernetes的所有数据都以/registry为前缀，因此首先查看/registry

``` zsh
➜  ./etcd_ls.sh /registry
/registry/apiextensions.k8s.io
/registry/apiregistration.k8s.io
/registry/clusterrolebindings
/registry/clusterroles
/registry/configmaps
/registry/controllerrevisions
/registry/crd.projectcalico.org
/registry/daemonsets
/registry/deployments
/registry/events
/registry/ingress
/registry/leases
/registry/limitranges
/registry/management.cattle.io
/registry/masterleases
/registry/minions
/registry/namespaces
/registry/persistentvolumeclaims
/registry/persistentvolumes
/registry/pods
/registry/podsecuritypolicy
/registry/priorityclasses
/registry/project.cattle.io
/registry/ranges
/registry/replicasets
/registry/rolebindings
/registry/roles
/registry/secrets
/registry/serviceaccounts
/registry/services
/registry/statefulsets
/registry/storageclasses
```

我们发现除了minions、range等大多数资源都可以通过etcdctl get xxx获取，组织格式为/registry/{resource_name}/{namespace}/{resource_instance}，而minions其实就是node信息，Kubernetes之前节点叫minion，应该还没有改过来，因此还是使用的/registry/minions

#### 2.4.3、获取key值

``` zsh
# range对应Service网段以及NodePort端口范围
➜  ./etcd_ls.sh /registry/ranges/servicenodeports | strings
/registry/ranges/servicenodeports
RangeAllocation
30000-32767

➜  ./etcd_ls.sh /registry/ranges/serviceips | strings
/registry/ranges/serviceips
RangeAllocation
10.96.0.0/16
```

如上为什么需要使用strings命令，那是因为除了/registry/apiregistration.k8s.io是直接存储JSON格式的，其他资源默认都不是使用JSON格式直接存储，而是通过protobuf格式存储，当然这么做的原因是为了性能，除非手动配置--storage-media-type=application/json，参考: [etcdctl v3: k8s changes its internal format to proto, and the etcdctl result is unreadable.](https://github.com/kubernetes/kubernetes/issues/44670)

!img[]()

使用proto提高了性能，但也导致有时排查问题时不方便直接使用etcdctl读取内容，可幸的是openshift项目已经开发了一个强大的辅助工具 [etcdhelper](https://github.com/openshift/origin/tree/master/tools/etcdhelper) 可以读取etcd内容并解码proto。

``` zsh
# https://github.com/openshift/origin/blob/master/tools/etcdhelper/etcdhelper.go

# 编译

```

## 三、问题

### 3.1、etcd2 API - 已弃用

~~如果要用etcdctl查看etcd服务，需要列出etcd服务使用的证书，为了不每次都输入一大串的证书，所以我们在下面设置了别名。~~

``` zsh
# 不指定证书连接拒绝
# etcdctl cluster-health
client: etcd cluster is unavailable or misconfigured; error #0: EOF
; error #1: dial tcp 127.0.0.1:4001: connect: connection refused

# 指定证书
# cd /etc/kubernetes/pki/etcd
# ls
ca.crt    ca.key    healthcheck-client.crt    healthcheck-client.key    peer.crt  peer.key  server.crt    server.key
# etcdctl --endpoints=https://localhost:2379 \
    --ca-file=/etc/kubernetes/pki/etcd/ca.crt \
    --cert-file=/etc/kubernetes/pki/etcd/server.crt \
    --key-file=/etc/kubernetes/pki/etcd/server.key \
    cluster-health
287efa333fece95a: name=apiserver.cluster.local peerURLs=https://192.168.100.236:2380 clientURLs=https://192.168.100.236:2379 isLeader=true

# 设置别名
# alias etcdctl='etcdctl --endpoints=https://localhost:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key';

# 使用别名
# etcdctl cluster-health
member 287efa333fece95a is healthy: got healthy result from https://192.168.100.236:2379
cluster is healthy
```

~~etcd2和etcd3是不兼容的，两者的api参数也不一样，详细请查看 etcdctl -h~~

``` zsh
# 刚开始使用 etcdctl get 读取有问题，我设置API为3
# export ETCDCTL_API=3

# 发现etcdctl 参数都变了, 刚开始设置的 --ca-file都不认了, 所以别名无法使用了
#
# etcdctl get -h
Error: unknown flag: --ca-file
```

> 参考链接：  
> 1、[unable to retrive registry from etcd-3.0.4](https://github.com/kubernetes/kubernetes/issues/44175)  
> 2、<https://www.jianshu.com/p/dbb0623a541d>  
> 3、[etcd官网](https://etcd.io/)  
> 4、<https://github.com/etcd-io/etcd/blob/master/Documentation/dev-guide/interacting_v3.md>  
> 5、[etcd3如何设置环境变量](https://blog.csdn.net/qq_21816375/article/details/85013393)  
> 6、[如何读取Kubernetes存储在etcd上的数据](https://zhuanlan.zhihu.com/p/94685947)  
>