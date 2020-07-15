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

### 2.1、进入etcd

``` zsh
# 获取etcd pod
➜  kubectl get pods -n kube-system
NAME                                              READY   STATUS        RESTARTS   AGE
etcd-apiserver.cluster.local                      1/1     Running       9          40d

# exec进入etcd内
➜  kubectl exec -n kube-system etcd-apiserver.cluster.local -it -- /bin/sh

# find / -name 'etcd' -print
/etc/kubernetes/pki/etcd   # 证书目录
/usr/local/bin/etcd        # 二进制程序
/var/lib/etcd              # 数据目录

# 查看etcdctl使用说明
# etcdctl -h
NAME:
   etcdctl - A simple command line client for etcd.

WARNING:
   Environment variable ETCDCTL_API is not set; defaults to etcdctl v2.
   Set environment variable ETCDCTL_API=3 to use v3 API or ETCDCTL_API=2 to use v2 API.

USAGE:
   etcdctl [global options] command [command options] [arguments...]

VERSION:
   3.3.15

COMMANDS:
     backup          backup an etcd directory
     cluster-health  check the health of the etcd cluster
     mk              make a new key with a given value
     mkdir           make a new directory
     rm              remove a key or a directory
     rmdir           removes the key if it is an empty directory or a key-value pair
     get             retrieve the value of a key
     ls              retrieve a directory
     set             set the value of a key
     setdir          create a new directory or update an existing directory TTL
     update          update an existing key with a given value
     updatedir       update an existing directory
     watch           watch a key for changes
     exec-watch      watch a key for changes and exec an executable
     member          member add, remove and list subcommands
     user            user add, grant and revoke subcommands
     role            role add, grant and revoke subcommands
     auth            overall auth controls
     help, h         Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --debug                          output cURL commands which can be used to reproduce the request
   --no-sync                        don't synchronize cluster information before sending request
   --output simple, -o simple       output response in the given format (simple, `extended` or `json`) (default: "simple")
   --discovery-srv value, -D value  domain name to query for SRV records describing cluster endpoints
   --insecure-discovery             accept insecure SRV records describing cluster endpoints
   --peers value, -C value          DEPRECATED - "--endpoints" should be used instead
   --endpoint value                 DEPRECATED - "--endpoints" should be used instead
   --endpoints value                a comma-delimited list of machine addresses in the cluster (default: "http://127.0.0.1:2379,http://127.0.0.1:4001")
   --cert-file value                identify HTTPS client using this SSL certificate file
   --key-file value                 identify HTTPS client using this SSL key file
   --ca-file value                  verify certificates of HTTPS-enabled servers using this CA bundle
   --username value, -u value       provide username[:password] and prompt if password is not supplied.
   --timeout value                  connection timeout per request (default: 2s)
   --total-timeout value            timeout for the command execution (except watch) (default: 5s)
   --help, -h                       show help
   --version, -v                    print the version
```

### 2.2、etcdctl

#### etcd2 API - 已弃用

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

#### etcd3 API

从kubernetes 1.6开始，etcd集群使用version 3

``` zsh
# 我们重新进入etcd容器
➜  kubectl exec -n kube-system etcd-apiserver.cluster.local -it -- /bin/sh

# 设置API版本为3
# export ETCDCTL_API=3

# etcdctl -h
NAME:
    etcdctl - A simple command line client for etcd3.

USAGE:
    etcdctl

VERSION:
    3.3.15

API VERSION:
    3.3                # 这多了一个API版本, 下面的API也多了很多内容。


COMMANDS:
    get            Gets the key or a range of keys
    put            Puts the given key into the store
    del            Removes the specified key or range of keys [key, range_end)
    txn            Txn processes all the requests in one transaction
    compaction        Compacts the event history in etcd
    alarm disarm        Disarms all alarms
    alarm list        Lists all alarms
    defrag            Defragments the storage of the etcd members with given endpoints
    endpoint health        Checks the healthiness of endpoints specified in `--endpoints` flag
    endpoint status        Prints out the status of endpoints specified in `--endpoints` flag
    endpoint hashkv        Prints the KV history hash for each endpoint in --endpoints
    move-leader        Transfers leadership to another etcd cluster member.
    watch            Watches events stream on keys or prefixes
    version            Prints the version of etcdctl
    lease grant        Creates leases
    lease revoke        Revokes leases
    lease timetolive    Get lease information
    lease list        List all active leases
    lease keep-alive    Keeps leases alive (renew)
    member add        Adds a member into the cluster
    member remove        Removes a member from the cluster
    member update        Updates a member in the cluster
    member list        Lists all members in the cluster
    snapshot save        Stores an etcd node backend snapshot to a given file
    snapshot restore    Restores an etcd member snapshot to an etcd directory
    snapshot status        Gets backend snapshot status of a given file
    make-mirror        Makes a mirror at the destination etcd cluster
    migrate            Migrates keys in a v2 store to a mvcc store
    lock            Acquires a named lock
    elect            Observes and participates in leader election
    auth enable        Enables authentication
    auth disable        Disables authentication
    user add        Adds a new user
    user delete        Deletes a user
    user get        Gets detailed information of a user
    user list        Lists all users
    user passwd        Changes password of user
    user grant-role        Grants a role to a user
    user revoke-role    Revokes a role from a user
    role add        Adds a new role
    role delete        Deletes a role
    role get        Gets detailed information of a role
    role list        Lists all roles
    role grant-permission    Grants a key to a role
    role revoke-permission    Revokes a key from a role
    check perf        Check the performance of the etcd cluster
    help            Help about any command

OPTIONS:
      --cacert=""                verify certificates of TLS-enabled secure servers using this CA bundle
      --cert=""                    identify secure client using this TLS certificate file
      --command-timeout=5s            timeout for short running command (excluding dial timeout)
      --debug[=false]                enable client-side debug logging
      --dial-timeout=2s                dial timeout for client connections
  -d, --discovery-srv=""            domain name to query for SRV records describing cluster endpoints
      --endpoints=[127.0.0.1:2379]        gRPC endpoints
      --hex[=false]                print byte strings as hex encoded strings
      --insecure-discovery[=true]        accept insecure SRV records describing cluster endpoints
      --insecure-skip-tls-verify[=false]    skip server certificate verification
      --insecure-transport[=true]        disable transport security for client connections
      --keepalive-time=2s            keepalive time for client connections
      --keepalive-timeout=6s            keepalive timeout for client connections
      --key=""                    identify secure client using this TLS key file
      --user=""                    username[:password] for authentication (prompt if password is not supplied)
  -w, --write-out="simple"            set the output format (fields, json, protobuf, simple, table)

# API3 也还是需要指定证书的
# etcdctl endpoint health
{"level":"warn","ts":"2020-07-15T07:29:46.745Z","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://client-add26c5f-438e-4d44-8cb8-e276588cccae/127.0.0.1:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest connection error: connection closed"}
127.0.0.1:2379 is unhealthy: failed to commit proposal: context deadline exceeded
Error: unhealthy cluster

# 指定证书获取endpoint的状态
# etcdctl --endpoints=https://localhost:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key  endpoint health
https://localhost:2379 is healthy: successfully committed proposal: took = 2.706905334s

# 可以声明etcdctl的环境变量
# export ETCDCTL_DIAL_TIMEOUT=3s
# export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
# export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
# export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
# export ETCD_ENDPOINTS=https://localhost:2379

# etcdctl endpoint health
127.0.0.1:2379 is healthy: successfully committed proposal: took = 827.031484ms
```

### 2.3、成员列表

``` zsh
# etcdctl member list
287efa333fece95a, started, apiserver.cluster.local, https://192.168.100.236:2380, https://192.168.100.236:2379
```

### 2.4、Kubernetes资源

#### 2.4.1、etcdctl get

``` zsh
# etcdctl get --help
NAME:
    get - Gets the key or a range of keys

USAGE:
    etcdctl get [options] <key> [range_end]

OPTIONS:
      --consistency="l"            Linearizable(l) or Serializable(s)
      --from-key[=false]        Get keys that are greater than or equal to the given key using byte compare
      --keys-only[=false]        Get only the keys
      --limit=0                Maximum number of results
      --order=""            Order of results; ASCEND or DESCEND (ASCEND by default)
      --prefix[=false]            Get keys with matching prefix
      --print-value-only[=false]    Only write values when using the "simple" output format
      --rev=0                Specify the kv revision
      --sort-by=""            Sort target; CREATE, KEY, MODIFY, VALUE, or VERSION
```

#### 2.4.2、获取所有key

``` zsh
# etcdctl get --prefix --keys-only /
/registry/services/endpoints/default/info-nearby-service
/registry/services/endpoints/default/info-news-service
/registry/services/endpoints/default/info-payment-service
/registry/services/endpoints/default/info-scheduler-service
/registry/services/endpoints/default/info-store-service
/registry/services/endpoints/default/info-uc-service
/registry/services/endpoints/default/kubernetes
/registry/services/endpoints/default/myweb-tomcat
/registry/services/endpoints/helm-test/myweb-ns-tomcat
/registry/services/endpoints/kube-system/kube-controller-manager
/registry/services/endpoints/kube-system/kube-dns
/registry/services/endpoints/kube-system/kube-scheduler
/registry/services/endpoints/kube-system/metrics-server
/registry/services/endpoints/kube-system/prometheus-node-exporter
/registry/services/endpoints/loki-stack/grafana
/registry/services/endpoints/loki-stack/loki
/registry/services/endpoints/loki-stack/loki-headless
/registry/services/specs/cattle-system/rancher
/registry/services/specs/default/consul
/registry/services/specs/default/info-ad-service
...
/registry/services/specs/default/info-store-service
/registry/services/specs/default/info-uc-service
/registry/services/specs/default/kubernetes
/registry/services/specs/default/myweb-tomcat
/registry/services/specs/helm-test/myweb-ns-tomcat
/registry/services/specs/kube-system/kube-dns
/registry/services/specs/kube-system/metrics-server
/registry/services/specs/kube-system/prometheus-node-exporter
/registry/services/specs/loki-stack/grafana
/registry/services/specs/loki-stack/loki
/registry/services/specs/loki-stack/loki-headless
/registry/statefulsets/default/consul
/registry/statefulsets/loki-stack/loki
/registry/storageclasses/dynamic-ceph-rbd
```

#### 2.4.3、获取

``` zsh
etcdctl --prefix --keys-only=false get /registry/statefulsets/loki-stack/loki
```

> 参考链接：  
> 1、[unable to retrive registry from etcd-3.0.4](https://github.com/kubernetes/kubernetes/issues/44175)  
> 2、<https://www.jianshu.com/p/dbb0623a541d>  
> 3、[etcd官网](https://etcd.io/)  
> 4、<https://github.com/etcd-io/etcd/blob/master/Documentation/dev-guide/interacting_v3.md>  
> 5、[etcd3如何设置环境变量](https://blog.csdn.net/qq_21816375/article/details/85013393)  
> 6、[如何读取Kubernetes存储在etcd上的数据](https://zhuanlan.zhihu.com/p/94685947)  
>