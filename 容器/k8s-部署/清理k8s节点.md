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
draft: false
---

## 一、清理服务

``` zsh
# master节点先移除node节点
➜  kubectl delete node [Node]

# node节点
# 使用kubeadm reset重置节点
➜  kubeadm reset

# 卸载
➜  ip a
7: tunl0@NONE: <NOARP,UP,LOWER_UP> mtu 1440 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
    inet 100.93.228.128/32 brd 100.93.228.128 scope global tunl0
       valid_lft forever preferred_lft forever
➜  modprobe -r ipip  && lsmod

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
➜  rm -rf /etc/cni
➜  rm -rf /opt/cni
➜  rm -rf /etc/systemd/system/kubelet.service*

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
➜  rm -rf /opt/containerd

# Master节点要删除config文件
➜  rm -rf $HOME/.kube/
```

## 二、清理bridge

卸载服务并不能将k8s服务创建的网桥删除，需要我们手工删除

``` zsh
➜  ip a
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:38:5c:34:97 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
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
```

## 三、清理iptables

同样在iptables中遗留了大量k8s服务创建的链

``` zsh
# 清空iptables规则
➜  iptables -F

➜  iptables -vnL
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
......

# 删除所有自定义链
➜  iptables -vnL | grep cali | awk '{print $2}' | xargs -i[] iptables -X
```

## 四、清理脚本

由于一步步执行太繁杂，我将上述过程整理为脚本，一键清理。

``` sh
➜  vim clean_k8s_node.sh
yum list installed | grep kube | awk '{print $1}' | xargs yum remove -y

# 删除kubernetes遗留目录
rm -rf /etc/kubernetes/
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /etc/systemd/system/kubelet.service*

# 卸载所有docker服务
yum list installed | grep docker | awk '{print $1}' | xargs yum remove -y

# 删除docker遗留目录
rm -rf /var/lib/docker
rm -rf /var/run/docker
rm -rf /etc/docker
rm -rf /opt/containerd

# 删除 docker0桥及kube-ipvs0桥
ip link delete kube-ipvs0
ip link delete docker0

# 删除所有自定义链
iptables -vnL | grep cali | awk '{print $2}' | xargs -i[] iptables -X

➜  chmod u+x clean_k8s_node.sh
➜  ./clean_k8s_node.sh
```
