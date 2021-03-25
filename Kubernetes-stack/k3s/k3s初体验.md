---
title: "k3s初体验"
date: "2021-03-25"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "k3s"
    - "边缘计算"
toc: false
indent: false
original: true
draft: false
---

## 引言

前一段时间腾讯云特价入手了一台 2c4g 的服务器, 计划用来搞家庭云计算中心节点。  

在家里部署一套k3s, 做边缘计算, 管理家里的智能终端, 为万物互联提供算力。  

中心节点可以提供稳定的调度支持。还可以在上面做一下webhook，镜像打包等自动化操作。 

如果腾讯云好用我还计划再搞一个香港节点, 把我的博客也迁移到k3s上, 全部由这个中心节点提供算力支持。  
这样能做的好处太多了, 首先国外主机内存是真贵啊, 而且网络延时也太高, 腾讯1c2g30M的节点比它还便宜不少, 
能大幅度降低开支, 提升体验。这全都依赖于k3s那40M小小身躯, 可以流畅的运行在512MB内存的主机上。

## 配置

- 系统内核版本：Linux 3.10+ (CentOS 7, Debian 8/9, Ubuntu 14.04+)
- K3S Server端最低内存要求：512 MB
- K3S Agent端内存最低要求：75MB
- 磁盘空间最低要求：200 MB
- 支持的硬件架构：x86_64, ARMv7, ARM64

## 下载

首先下载k3s, k3s只有一个二进制可执行程序, 只有43MB。

``` zsh
➜  wget https://github.com/k3s-io/k3s/releases/download/v1.20.5-rc1%2Bk3s1/k3s -O /usr/local/bin/k3s
➜  chmod +x /usr/local/bin/k3s
```

## 升级内核

由于我们要打通家庭网络与云厂商的网络, 我们需要用到WireGuard, 所以我们需要先升级一下内核。

``` zsh

```

## system Unit 文件

创建 Unit 文件，使用系统服务来管理 k3s

``` zsh
➜  cat > /etc/systemd/system/k3s.service <<EOF
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s \
    server \
    --tls-san <public_ip> \
    --node-ip <public_ip> \
    --node-external-ip <public_ip> \
    --no-deploy servicelb \
    --flannel-backend wireguard \
    --kube-proxy-arg "proxy-mode=ipvs" "masquerade-all=true" \
    --kube-proxy-arg "metrics-bind-address=0.0.0.0"
EOF
```