---
title: "使用 kubeadm 升级 k8s 集群"
date: "2022-08-26"
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
| 2022-08-26 | 初稿 |

## 软件版本

| soft    | Version           |
| ------- | ----------------- |
| CentOS  | 7.6               |
| kubectl | 1.22.5 --> 1.24.4 |
| kubelet | 1.22.5 --> 1.24.4 |
| kubeadm | 1.22.5 --> 1.24.4 |

## 一、升级 master节点至 v1.23

kubeadm 升级时, 不能跳过次要版本,  
不能从 1.22 --> 1.24 这样升级,  
需要先从 1.22 --> 1.23,  
再从 1.23 --> 1.24

①先查看 kubeadm 有哪些可用的版本

``` zsh
➜  yum list --showduplicates kubeadm
kubeadm.x86_64                                                                                      1.22.5-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.22.6-0                                                                                        kubernetes 
...
kubeadm.x86_64                                                                                      1.22.11-0                                                                                       kubernetes 
kubeadm.x86_64                                                                                      1.22.12-0                                                                                       kubernetes 
kubeadm.x86_64                                                                                      1.22.13-0                                                                                       kubernetes 
...
kubeadm.x86_64                                                                                      1.23.7-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.23.8-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.23.9-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.23.10-0                                                                                       kubernetes 
...
kubeadm.x86_64                                                                                      1.24.3-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.24.4-0                                                                                        kubernetes 
kubeadm.x86_64                                                                                      1.25.0-0                                                                                        kubernetes
```

②升级 kubeadm版本

``` zsh
# 安装 1.23.10
➜  yum install -y kubeadm-1.23.10-0

# 验证 kubeadm 版本
➜  kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.10", GitCommit:"7e54d50d3012cf3389e43b096ba35300f36e0817", GitTreeState:"clean", BuildDate:"2022-08-17T18:31:47Z", GoVersion:"go1.17.13", Compiler:"gc", Platform:"linux/amd64"}

# 验证升级计划
➜  kubeadm upgrade plan
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.22.5
[upgrade/versions] kubeadm version: v1.23.10
I0826 14:36:20.855806   10546 version.go:255] remote version is much newer: v1.25.0; falling back to: stable-1.23
[upgrade/versions] Target version: v1.23.10
[upgrade/versions] Latest version in the v1.22 series: v1.22.13

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     2 x v1.22.5   v1.22.13

Upgrade to the latest version in the v1.22 series:

COMPONENT                 CURRENT   TARGET
kube-apiserver            v1.22.5   v1.22.13
kube-controller-manager   v1.22.5   v1.22.13
kube-scheduler            v1.22.5   v1.22.13
kube-proxy                v1.22.5   v1.22.13
CoreDNS                   1.8.0     v1.8.6
etcd                      3.5.0-0   3.5.1-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.22.13

_____________________________________________________________________

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     2 x v1.22.5   v1.23.10

Upgrade to the latest stable version:

COMPONENT                 CURRENT   TARGET
kube-apiserver            v1.22.5   v1.23.10
kube-controller-manager   v1.22.5   v1.23.10
kube-scheduler            v1.22.5   v1.23.10
kube-proxy                v1.22.5   v1.23.10
CoreDNS                   1.8.0     v1.8.6
etcd                      3.5.0-0   3.5.1-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.23.10

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________

```

③升级 Master 节点

``` zsh
➜  kubeadm upgrade apply 1.23.10
[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.23.10". Enjoy!
```

④升级 kubelet、kubectl

``` zsh
# 安装 kubelet、kubectl 新版本
➜  yum install -y kubelet-1.23.10-0 kubectl-1.23.10-0

# 执行如下命令, 以重启 kubelet
➜  systemctl daemon-reload
➜  systemctl restart kubelet

# 可以 查看节点状态, master 已升级完毕
➜  kubectl get nodes
NAME              STATUS   ROLES                  AGE    VERSION
test-k8s-master   Ready    control-plane,master   237d   v1.23.10
test-k8s-node01   Ready    <none>                 107d   v1.22.5
```

## 升级 worker节点至 v1.23

①升级 kubeadm

``` zsh
➜  yum install -y kubeadm-1.23.10-0
```

②排空节点

``` zsh
# 将节点标记为 不可调度的 并驱逐节点上所有的 Pod
➜  kubectl drain test-k8s-node01  --ignore-daemonsets
```

③升级 Worker 节点

``` zsh
➜  kubeadm upgrade node
```

④升级 kubelet、kubectl

``` zsh
➜  yum install -y kubelet-1.23.10-0 kubectl-1.23.10-0

# 执行如下命令, 以重启 kubelet
➜  systemctl daemon-reload
➜  systemctl restart kubelet

# 可以 查看节点状态, worker 已升级完毕
➜  kubectl get nodes
NAME              STATUS                     ROLES                  AGE    VERSION
test-k8s-master   Ready                      control-plane,master   237d   v1.23.10
test-k8s-node01   Ready,SchedulingDisabled   <none>                 107d   v1.23.10
```

⑤恢复调度

``` zsh
➜  kubectl uncordon test-k8s-node01

➜  kubectl get nodes
NAME              STATUS   ROLES                  AGE    VERSION
test-k8s-master   Ready    control-plane,master   237d   v1.23.10
test-k8s-node01   Ready    <none>                 107d   v1.23.10
```

至此, k8s集群从 1.22 --> 1.23 版本升级已经完成, 要升级到 1.24 只要重复上面过程即可

## kubeadm 工作过程

在第一个 master 节点上，kubeadm upgrade apply 执行了如下操作：
检查集群是否处于可升级的状态：
API Server 可以调用
所有的节点处于 Ready 装填
master 节点处于 healthy 状态
检验是否可以从当前版本升级到目标版本
确保 master 节点所需要的镜像可以被抓取到节点上
升级 master 节点的组件，（如果碰到问题，则回滚）
应用新的 kube-dns 和 kube-proxy 的 manifests 文件，并确保需要的 RBAC 规则被创建
如果证书在 180 天内将要过期，则为 API Server 创建新的证书文件，并备份旧的文件

在其他 master 节点上，kubeadm upgrade node 执行了如下操作：
从集群中抓取 kubeadm 的配置信息 ClusterConfiguration
备份 kube-apiserver 的证书
升级 master 节点上静态组件的 manifest 信息
升级 master 节点上 kubelet 的配置信息

在所有的 worker 节点上，kubeadm upgrade node 执行了如下操作：
从集群中抓取 kubeadm 的配置信息 ClusterConfiguration
升级 worker 节点上 kubelet 的配置信息

> 参考文章：
>
> - [K8S从1.15.x(1.16.x)升级到 1.16.x](https://kuboard.cn/install/upgrade-k8s/1.15.x-1.16.x.html)
> - [升级kubeadm集群](kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade)
>
