---
title: "kube-proxy 修改为 ipvs模式"
date: "2021-11-25"
categories:
    - "技术"
tags:
    - "kubernetes"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-11-25 | 初稿 |

## 软件版本

| soft       | Version |
| ---------- | ------- |
| CentOS     | 7.6     |
| Kubernetes | 1.22.3  |

## 1、查看 k8s 使用的模式

``` zsh
➜  kubectl get cm kube-proxy -n kube-system -o yaml | grep mode
    mode: ""
```

## 2、修改内核模块

临时生效

``` zsh
➜  modprobe -- ip_vs
➜  modprobe -- ip_vs_rr
➜  modprobe -- ip_vs_wrr
➜  modprobe -- ip_vs_sh
➜  modprobe -- nf_conntrack_ipv4
```
 
永久生效

``` zsh
➜  cat > /etc/sysconfig/modules/ipvs.modules <<EOF
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
```

## 3、k8s 修改

``` zsh
# 修改 configmap
➜  kubectl edit cm kube-proxy -n kube-system
mode: ipvs

# 删除所有的 kube-proxy, 并重建
➜  kubectl  get pod -n kube-system | grep kube-proxy | awk '{print $1}' | xargs kubectl delete pod -n kube-system
pod "kube-proxy-5kl24" deleted
pod "kube-proxy-qf89q" deleted
pod "kube-proxy-xh4s4" deleted
```

## 4、查看 k8s模式

``` zsh
# 查看重建后 kube-proxy 日志
➜  kubectl logs kube-proxy-dwqgh -n kube-system
I1115 11:57:00.597560       1 node.go:172] Successfully retrieved node IP: 172.31.229.141
I1115 11:57:00.597633       1 server_others.go:140] Detected node IP 172.31.229.141
I1115 11:57:00.631315       1 server_others.go:206] kube-proxy running in dual-stack mode, IPv4-primary
I1115 11:57:00.631372       1 server_others.go:274] Using ipvs Proxier.              # 已经改为 IPVS模式
I1115 11:57:00.631382       1 server_others.go:276] creating dualStackProxier for ipvs.
W1115 11:57:00.631397       1 server_others.go:495] detect-local-mode set to ClusterCIDR, but no IPv6 cluster CIDR defined, , defaulting to no-op detect-local for IPv6
E1115 11:57:00.636106       1 proxier.go:389] can't set sysctl net/ipv4/vs/conn_reuse_mode, kernel version must be at least 4.1
W1115 11:57:00.636328       1 proxier.go:445] IPVS scheduler not specified, use rr by default
E1115 11:57:00.636455       1 proxier.go:389] can't set sysctl net/ipv4/vs/conn_reuse_mode, kernel version must be at least 4.1
W1115 11:57:00.636557       1 proxier.go:445] IPVS scheduler not specified, use rr by default
W1115 11:57:00.636584       1 ipset.go:113] ipset name truncated; [KUBE-6-LOAD-BALANCER-SOURCE-CIDR] -> [KUBE-6-LOAD-BALANCER-SOURCE-CID]
W1115 11:57:00.636600       1 ipset.go:113] ipset name truncated; [KUBE-6-NODE-PORT-LOCAL-SCTP-HASH] -> [KUBE-6-NODE-PORT-LOCAL-SCTP-HAS]
I1115 11:57:00.636834       1 server.go:647] Version: v1.21.6
I1115 11:57:00.639419       1 conntrack.go:100] Set sysctl 'net/netfilter/nf_conntrack_max' to 131072
I1115 11:57:00.639450       1 conntrack.go:52] Setting nf_conntrack_max to 131072
I1115 11:57:00.639838       1 config.go:315] Starting service config controller
I1115 11:57:00.639853       1 shared_informer.go:240] Waiting for caches to sync for service config
I1115 11:57:00.640055       1 config.go:224] Starting endpoint slice config controller
I1115 11:57:00.640069       1 shared_informer.go:240] Waiting for caches to sync for endpoint slice config
W1115 11:57:00.643211       1 warnings.go:70] discovery.k8s.io/v1beta1 EndpointSlice is deprecated in v1.21+, unavailable in v1.25+; use discovery.k8s.io/v1 EndpointSlice
W1115 11:57:00.644516       1 warnings.go:70] discovery.k8s.io/v1beta1 EndpointSlice is deprecated in v1.21+, unavailable in v1.25+; use discovery.k8s.io/v1 EndpointSlice
I1115 11:57:00.740014       1 shared_informer.go:247] Caches are synced for service config
I1115 11:57:00.740131       1 shared_informer.go:247] Caches are synced for endpoint slice config

# 查看 configmap
➜  kubectl get cm kube-proxy -n kube-system -o yaml | grep mode
    mode: ipvs
```
