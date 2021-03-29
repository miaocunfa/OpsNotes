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

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-25 | 初稿 |
| 2021-03-26 | 内核 |

## 软件版本

| soft      | Version       |
| --------- | ------------- |
| Debian    | 10.2          |
| kernel    | 5.10.0        |
| WireGuard | v1.0.20210223 |
| k3s       | v1.20.5       |

## 引言

前一段时间腾讯云特价入手了一台 2c4g 的服务器, 计划用来搞家庭云计算中心节点。  

在家里部署一套k3s, 做边缘计算, 管理家里的智能终端, 为万物互联提供算力。  

中心节点可以提供稳定的调度支持。还可以在上面做一下webhook，镜像打包等自动化操作。 

如果腾讯云好用我还计划再搞一个香港节点, 把我的博客也迁移到k3s上, 全部由这个中心节点提供算力支持。  
这样能做的好处太多了, 首先国外主机内存是真贵啊, 而且网络延时也太高, 腾讯1c2g30M的节点比它还便宜不少, 
能大幅度降低开支, 提升体验。这全都依赖于k3s那40M小小身躯, 可以流畅的运行在512MB内存的主机上。

## k3s 最低配置

- 系统内核版本：Linux 3.10+ (CentOS 7, Debian 8/9, Ubuntu 14.04+)
- K3S Server端最低内存要求：512 MB
- K3S Agent端内存最低要求：75MB
- 磁盘空间最低要求：200 MB
- 支持的硬件架构：x86_64, ARMv7, ARM64

## 下载 k3s

首先下载k3s, k3s只有一个二进制可执行程序, 只有43MB。

``` zsh
➜  wget https://github.com/k3s-io/k3s/releases/download/v1.20.5-rc1%2Bk3s1/k3s -O /usr/local/bin/k3s
➜  chmod +x /usr/local/bin/k3s
```

## 安装 WireGuard

由于要使用 WireGuard, WireGuard 的安装和使用条件非常苛刻，对内核版本要求极高，不仅如此，在不同的系统中，内核，内核源码包，内核头文件必须存在且这三者版本要一致。

Red Hat、CentOS、Fedora 等系统的内核，内核源码包，内核头文件包名分别为 kernel、kernel-devel、kernel-headers。

Debian、Ubuntu 等系统的内核，内核源码包，内核头文件包名分别为 linux-image、linux-headers。

如果这三者任一条件不满足的话，则不管是从代码编译安装还是从 repository 直接安装，也只是安装了 wireguard-tools 而已。而 WireGuard 真正工作的部分，是 wireguard-dkms，也就是动态内核模块支持(DKMS)，是它将 WireGuard 编译到系统内核中。

当然，目前 WireGuard 已经被合并到 Linux 5.6 内核中了，如果你的内核版本 >= 5.6，就可以用上原生的 WireGuard 了，只需要安装 wireguard-tools 即可。例如，对于 Ubuntu 20.04 来说，它的内核版本是 5.4，虽然小于 5.6，但经过我的测试发现它已经将 WireGuard 合并到了内核中，我们只需要安装 wireguard-tools 即可：

[内核升级](https://github.com/miaocunfa/OpsNotes/blob/master/Linux/Debian-10.2%E5%8D%87%E7%BA%A7%E5%86%85%E6%A0%B8.md) 请看此篇

``` zsh
# 内核升级完后 安装wireguard
➜  apt install wireguard
```

## Master 节点

### system Unit 文件

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
    --tls-san 121.4.165.232 \
    --node-ip 121.4.165.232 \
    --node-external-ip 121.4.165.232 \
    --no-deploy servicelb \
    --flannel-backend wireguard \
    --kube-proxy-arg "proxy-mode=ipvs" "masquerade-all=true" \
    --kube-proxy-arg "metrics-bind-address=0.0.0.0"
EOF

➜  touch /etc/systemd/system/k3s.service.env
```

### 启动 && 自启

``` zsh
➜  systemctl enable k3s --now
```

### 查看集群状态

``` zsh
➜  cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
➜  k3s kubectl get node
NAME              STATUS   ROLES                  AGE   VERSION
vm-12-11-debian   Ready    control-plane,master   26m   v1.20.5-rc1+k3s1
```

## Node 节点

### system Unit 文件

部署好 master节点后，就可以加入 node节点了。

``` zsh
cat > /etc/systemd/system/k3s-agent.service <<EOF
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=exec
EnvironmentFile=/etc/systemd/system/k3s-agent.service.env
KillMode=process
Delegate=yes
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s agent \
    --node-external-ip <public_ip> \
    --node-ip <public_ip> \
    --kube-proxy-arg "proxy-mode=ipvs" "masquerade-all=true" \
    --kube-proxy-arg "metrics-bind-address=0.0.0.0"
EOF
```

### 环境变量文件

在 `/etc/systemd/system/k3s-agent.service.env` 中需要加入两个环境变量

**K3S_URL** : API Server 的 URL，一般格式为：https://<master_ip>:6443。其中 <master_ip> 是控制节点的公网 IP。  
**K3S_TOKEN** : 加入集群所需的 token，可以在控制节点上查看 `/var/lib/rancher/k3s/server/node-token` 文件。

### 启动 k3s-agent 并设置开启自启

``` zsh
➜  systemctl enable k3s-agent --now
```

> 参考文档：  
> [1] [跨云厂商部署 k3s 集群](https://fuckcloudnative.io/posts/deploy-k3s-cross-public-cloud/)  
> [2] [K3S的一些基础使用配置](https://sspai.com/post/59081)  
>