---
title: "Sealos部署 k8s-v1.16.0 HA集群"
date: "2020-06-03"
categories:
    - "技术"
tags:
    - "Kubernetes"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容     |
| ---------- | -------- |
| 2020-06-03 | 初稿     |
| 2022-09-01 | 文档整理 |

## 软件版本

| soft       | Version |
| ---------- | ------- |
| CentOS     | 7.6     |
| sealos     | 2.0.7   |
| kubernetes | 1.16.0  |

## Sealos 安装

``` zsh
# 下载 sealos
➜  wget https://github.com/fanux/sealos/releases/download/v2.0.7/sealos
# 加执行权限，并将 sealos 移至/usr/bin下
➜  chmod +x sealos && mv sealos /usr/bin
```

### sealos 选项

``` zsh
--master   master服务器地址列表
--node     node服务器地址列表
--user     服务器ssh用户名
--passwd   服务器ssh用户密码
--pkg-url  离线包位置，可以放在本地目录，也可以放在一个http服务器上，sealos会wget到安装目标机
--version  kubernetes版本
```

## 初始化 k8s-HA 集群

``` zsh
➜  sealos init --passwd [YOUR_SERVER_PASSWD]
  --master 172.31.194.114  --master 172.31.194.116  --master 172.31.194.115 \
  --node 172.31.194.117 \
  --pkg-url https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz  \ 
  --version v1.16.0
```

执行完成后shell最后一行输出如下说明集群部署成功

``` log
2019-11-07 17:30:20 [INFO] [github.com/fanux/sealos/install/print.go:25] sealos install success.
```

我们来获取一下节点的状态

``` zsh
➜  kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
master01   Ready    master   11h   v1.16.0
master02   Ready    master   11h   v1.16.0
master03   Ready    master   11h   v1.16.0
node01     Ready    <none>   11h   v1.16.0
```

查看 master负载

``` zsh
# 获取 service
➜  kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

# 通过查看 ipvs 规则，我们可以看到发送至 10.96.0.1 的请求都被负载至所有master节点。
➜  ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.96.0.1:443 rr
  -> 172.31.194.114:6443          Masq    1      3          0         
  -> 172.31.194.115:6443          Masq    1      2          0         
  -> 172.31.194.116:6443          Masq    1      0          0         
```

> 参考文章：
>
> - [github 地址](https://github.com/fanux/sealos)
>