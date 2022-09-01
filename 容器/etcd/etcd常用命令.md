---
title: "etcd 常用命令"
date: "2022-09-01"
categories:
    - "技术"
tags:
    - "etcd"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-09-01 | 初稿 |

## 1、使用etcdctl查看etcd服务 && 并设置别名

如果要用 etcdctl 查看etcd服务，需要列出 etcd服务使用的证书，为了不每次都输入一大串的证书，所以我们在下面设置了别名。

``` zsh
# 不指定证书连接拒绝
➜  etcdctl cluster-health
client: etcd cluster is unavailable or misconfigured; error #0: EOF
; error #1: dial tcp 127.0.0.1:4001: connect: connection refused

# 指定证书, 查看 etcd服务
➜  cd /etc/kubernetes/pki/etcd
➜  ls
ca.crt    ca.key    healthcheck-client.crt    healthcheck-client.key    peer.crt  peer.key  server.crt    server.key
➜  etcdctl --endpoints=https://localhost:2379 \
    --ca-file=/etc/kubernetes/pki/etcd/ca.crt \
    --cert-file=/etc/kubernetes/pki/etcd/server.crt \
    --key-file=/etc/kubernetes/pki/etcd/server.key \
    cluster-health
287efa333fece95a: name=apiserver.cluster.local peerURLs=https://192.168.100.236:2380 clientURLs=https://192.168.100.236:2379 isLeader=true
```

设置别名

``` zsh
# 设置别名 && 也可以写入 /etc/profile 永久生效
➜  alias etcdctl='etcdctl --endpoints=https://localhost:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key';

# 使用别名, 这样就省了每次指定一大堆证书了
➜  etcdctl cluster-health
member 287efa333fece95a is healthy: got healthy result from https://192.168.100.236:2379
cluster is healthy
```
