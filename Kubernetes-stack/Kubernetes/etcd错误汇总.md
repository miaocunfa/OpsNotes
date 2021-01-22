---
title: "etcd错误汇总"
date: "2020-07-21"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "etcd"
toc: false
indent: false
original: true
draft: true
---

## 1、etcd2 API - 已弃用

如果要用etcdctl查看etcd服务，需要列出etcd服务使用的证书，为了不每次都输入一大串的证书，所以我们在下面设置了别名。

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

etcd2和etcd3是不兼容的，两者的api参数也不一样，详细请查看 etcdctl -h

``` zsh
# 刚开始使用 etcdctl get 读取有问题，我设置API为3
# export ETCDCTL_API=3

# 发现etcdctl 参数都变了, 刚开始设置的 --ca-file都不认了, 所以别名无法使用了
#
# etcdctl get -h
Error: unknown flag: --ca-file
```
