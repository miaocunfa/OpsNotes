---
title: "清理k8s节点"
date: "2020-06-02"
categories:
    - "技术"
tags:
    - "kubernetes"
    - "服务清理"
toc: false
original: true
---

## 一、清理iptables

``` zsh
➜  iptables -vnL
Chain INPUT (policy ACCEPT 853 packets, 61594 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 605 packets, 491K bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain DOCKER (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain DOCKER-ISOLATION-STAGE-1 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain DOCKER-ISOLATION-STAGE-2 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain DOCKER-USER (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain KUBE-FIREWALL (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain KUBE-FORWARD (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-FORWARD (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-INPUT (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-OUTPUT (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-failsafe-in (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-failsafe-out (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-forward-check (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-forward-endpoint-mark (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-from-endpoint-mark (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-from-hep-forward (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-from-host-endpoint (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-from-wl-dispatch (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-cali3319325d46b (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-cali4cfcee010a6 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-cali678f80d5ec7 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-cali88a6c5ca0ac (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-calia11624d3d63 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-calib7aad6ee58e (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-calie108abc4d09 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-fw-calif176d025020 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-_CVSZITRyIpEmH8AB6H (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-_VsKSQHOAphpwJGZJfN (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-_hNSGmJYNT8uLIzxesP (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-_xdMOVd1dpN-bpVZF1e (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-kns.default (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-kns.kube-system (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pri-ksa.default.default (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-_CVSZITRyIpEmH8AB6H (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-_VsKSQHOAphpwJGZJfN (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-_hNSGmJYNT8uLIzxesP (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-_xdMOVd1dpN-bpVZF1e (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-kns.default (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-kns.kube-system (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-pro-ksa.default.default (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-set-endpoint-mark (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-cali3319325d46b (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-cali4cfcee010a6 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-cali678f80d5ec7 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-cali88a6c5ca0ac (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-calia11624d3d63 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-calib7aad6ee58e (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-calie108abc4d09 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-sm-calif176d025020 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-to-hep-forward (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-to-host-endpoint (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-to-wl-dispatch (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-cali3319325d46b (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-cali4cfcee010a6 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-cali678f80d5ec7 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-cali88a6c5ca0ac (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-calia11624d3d63 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-calib7aad6ee58e (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-calie108abc4d09 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-tw-calif176d025020 (0 references)
 pkts bytes target     prot opt in     out     source               destination         

Chain cali-wl-to-host (0 references)
 pkts bytes target     prot opt in     out     source               destination
➜  iptables -vnL | grep cali | awk '{print $2}' | xargs -i[] iptables -X
➜  iptables -vnL
Chain INPUT (policy ACCEPT 80 packets, 5376 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 55 packets, 46017 bytes)
 pkts bytes target     prot opt in     out     source               destination
```

## 二、清理bridge

``` zsh
➜  ip a
➜  ip link delete
➜  ip a
```
