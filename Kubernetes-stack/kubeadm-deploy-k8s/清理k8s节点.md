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

## 一、清理服务

``` zsh
# master节点先移除node节点
➜  kubectl delete node [Node]

# 列出所有安装的kubernetes服务
➜  yum list installed | grep kube
cri-tools.x86_64                     1.13.0-0                       @kubernetes
kubeadm.x86_64                       1.16.6-0                       @kubernetes
kubectl.x86_64                       1.16.6-0                       @kubernetes
kubelet.x86_64                       1.16.6-0                       @kubernetes
kubernetes-cni.x86_64                0.7.5-0                        @kubernetes

# 卸载所有kubernetes服务
➜  yum list installed | grep kube | awk '{print $1}' | xargs yum remove -y

# 删除kubernetes遗留目录
➜  rm -rf /etc/kubernetes/
➜  rm -rf /usr/bin/kube*
➜  rm -rf /usr/bin/crictl
➜  rm -rf /etc/cni
➜  rm -rf /opt/cni
➜  rm -rf /var/lib/etcd
➜  rm -rf /var/etcd

# 列出所有安装的docker服务
➜  yum list installed | grep docker
containerd.io.x86_64                 1.2.13-3.1.el7                 @docker-ce-stable
docker-ce.x86_64                     3:19.03.8-3.el7                @docker-ce-stable
docker-ce-cli.x86_64                 1:19.03.8-3.el7                @docker-ce-stable

# 卸载所有docker服务
➜  yum list installed | grep docker | awk '{print $1}' | xargs yum remove -y

# 删除docker遗留目录
➜  rm -rf /var/lib/docker
➜  rm -rf /var/run/docker
➜  rm -rf /etc/docker
```

## 二、清理bridge

卸载服务并不能将k8s服务创建的网桥删除，需要我们手工删除

``` zsh
➜  ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 02:39:48:b1:a6:6b brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.225/24 brd 192.168.100.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::e605:58ee:4249:c802/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::7242:85c:d7d5:6e3a/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::16d0:e089:b8e3:3069/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:38:5c:34:97 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
4: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ee:aa:43:04:56:1d brd ff:ff:ff:ff:ff:ff
5: kube-ipvs0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default
    link/ether ca:bb:6c:0e:e1:dd brd ff:ff:ff:ff:ff:ff
    inet 10.98.228.159/32 brd 10.98.228.159 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.96.10.222/32 brd 10.96.10.222 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.97.211.248/32 brd 10.97.211.248 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.97.250.120/32 brd 10.97.250.120 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.104.218.134/32 brd 10.104.218.134 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.96.0.10/32 brd 10.96.0.10 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.97.40.142/32 brd 10.97.40.142 scope global kube-ipvs0
       valid_lft forever preferred_lft forever
    inet 10.96.0.1/32 brd 10.96.0.1 scope global kube-ipvs0
       valid_lft forever preferred_lft forever

# 删除 docker0桥及kube-ipvs0桥
➜  ip link delete kube-ipvs0
➜  ip link delete docker0

# 已删除
➜  ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 02:39:48:b1:a6:6b brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.225/24 brd 192.168.100.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::e605:58ee:4249:c802/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::7242:85c:d7d5:6e3a/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
    inet6 fe80::16d0:e089:b8e3:3069/64 scope link tentative noprefixroute dadfailed
       valid_lft forever preferred_lft forever
4: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether f6:e4:1f:49:75:97 brd ff:ff:ff:ff:ff:ff
```

## 三、清理iptables

同样在iptables中遗留了大量k8s服务创建的链

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

# 删除所有自定义链
➜  iptables -vnL | grep cali | awk '{print $2}' | xargs -i[] iptables -X
➜  iptables -vnL
Chain INPUT (policy ACCEPT 80 packets, 5376 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 55 packets, 46017 bytes)
 pkts bytes target     prot opt in     out     source               destination
```
