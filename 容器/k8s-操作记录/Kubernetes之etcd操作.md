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
original: false
draft: false
---

## 更新记录

| 时间       | 内容           |
| ---------- | -------------- |
| 2020-07-15 | 初稿           |
| 2020-07-21 | 编译etcdhelper |
| 2020-07-23 | 完成图床的替换 |

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

## 三、Kubernetes资源

### 3.1、etcdctl ls脚本

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

### 3.2、获取所有key

由于Kubernetes的所有数据都以/registry为前缀，因此首先查看/registry

![/registry列表](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/etcd_20200723_01.png)

我们发现除了minions、range等大多数资源都可以通过etcdctl get xxx获取，组织格式为/registry/{resource_name}/{namespace}/{resource_instance}，而minions其实就是node信息，Kubernetes之前节点叫minion，应该还没有改过来，因此还是使用的/registry/minions

### 3.3、获取key值

![获取key值](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/etcd_20200723_02.png)

如上为什么需要使用strings命令，那是因为除了/registry/apiregistration.k8s.io是直接存储JSON格式的，其他资源默认都不是使用JSON格式直接存储，而是通过protobuf格式存储，当然这么做的原因是为了性能，除非手动配置--storage-media-type=application/json，参考: [etcdctl v3: k8s changes its internal format to proto, and the etcdctl result is unreadable.](https://github.com/kubernetes/kubernetes/issues/44670)

直接查看会乱码

![乱码](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/etcd_20200723_03.png)

## 四、etcdhelper

使用proto提高了性能，但也导致有时排查问题时不方便直接使用etcdctl读取内容，可幸的是openshift项目已经开发了一个强大的辅助工具 [etcdhelper](https://github.com/openshift/origin/tree/master/tools/etcdhelper) 可以读取etcd内容并解码proto。

### 4.1、编译etcdhelper

``` zsh
# 源代码url
# https://github.com/openshift/origin/blob/master/tools/etcdhelper/etcdhelper.go

# 编译
# 使用gomod编译etcdhelper
➜  go mod init etcdhelper
go: creating new go.mod: module etcdhelper
➜  go test
➜  cat go.mod
module etcdhelper

go 1.14

require (
    github.com/coreos/etcd v3.3.22+incompatible // indirect
    github.com/coreos/pkg v0.0.0-20180928190104-399ea9e2e55f // indirect
    github.com/openshift/api v0.0.0-20200714125145-93040c6967eb
    go.etcd.io/etcd v3.3.22+incompatible
    go.uber.org/zap v1.15.0 // indirect
    k8s.io/apimachinery v0.18.6
    k8s.io/kubectl v0.18.6
)

# 正常情况下，go test之后就可以进行编译了，报错了需要先解决错误。
➜  go build etcdhelper.go
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"
# 这个问题主要看这个 [issues](https://github.com/etcd-io/etcd/issues/11345)
# 先将 go-systemd 下载到本地
➜  mkdir -p $GOPATH/src/github.com/coreos/go-systemd/
➜  git clone https://github.com/coreos/go-systemd.git $GOPATH/src/github.com/coreos/go-systemd/
➜  cd $myproject
# 修改 go.mod，将依赖改为本地包
➜  vim go.mod
replace (
  github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 latest
)

# 再执行go test
➜  go test
# 执行编译，并生成可执行文件etcdhelper
➜  go build etcdhelper.go
➜  ll
total 46668
-rwxr-xr-x. 1 root root 47737965 Jul 20 15:59 etcdhelper
-rw-r--r--. 1 root root     4988 Jul 16 17:00 etcdhelper.go
-rwxr--r--. 1 root root      706 Jul 16 16:45 etcd_ls.sh
-rw-r--r--. 1 root root      515 Jul 20 15:54 go.mod
-rw-r--r--. 1 root root    32493 Jul 20 15:54 go.sum
```

### 4.2、使用etcdhelper

``` zsh
# 将etcdhelper 加入PATH
➜  mv etcdhelper $HOME/go/bin

# Usage
➜  ./etcdhelper  -h
Usage of ./etcdhelper:
  -cacert string
        Server TLS CA certificate.
  -cert string
        TLS client certificate.
  -endpoint string
        etcd endpoint. (default "https://127.0.0.1:2379")
  -key string
        TLS client key.

# 设置别名
➜  alias etcdhelper='etcdhelper -cacert /etc/kubernetes/pki/etcd/ca.crt \
                             -key /etc/kubernetes/pki/etcd/server.key \
                             -cert /etc/kubernetes/pki/etcd/server.crt'
```

获取key值，现在可以看到存储在etcd中JSON格式的数据了

![etcdhelper](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/etcd_20200723_04.png)

> 参考链接：  
> 1、[unable to retrive registry from etcd-3.0.4](https://github.com/kubernetes/kubernetes/issues/44175)  
> 2、<https://www.jianshu.com/p/dbb0623a541d>  
> 3、[etcd官网](https://etcd.io/)  
> 4、<https://github.com/etcd-io/etcd/blob/master/Documentation/dev-guide/interacting_v3.md>  
> 5、[etcd3如何设置环境变量](https://blog.csdn.net/qq_21816375/article/details/85013393)  
> 6、[如何读取Kubernetes存储在etcd上的数据](https://zhuanlan.zhihu.com/p/94685947)  
>