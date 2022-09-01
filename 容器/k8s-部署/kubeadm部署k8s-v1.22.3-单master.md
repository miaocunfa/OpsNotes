---
title: "Kubeadm 部署 k8s-v1.22.3 单master"
date: "2021-11-14"
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
| 2021-11-14 | 初稿 |

## 软件版本

| soft       | Version |
| ---------- | ------- |
| CentOS     | 7.6     |
| kubectl    | 1.22.3  |
| kubelet    | 1.22.3  |
| kubeadm    | 1.22.3  |

## 初始化 所有节点

``` zsh
➜  export REGISTRY_MIRROR=https://registry.cn-hangzhou.aliyuncs.com

➜  ./install_kubelet.sh 1.22.3
```

脚本内容

``` zsh
➜  cat install_kubelet
#!/bin/bash

# 在 master 节点和 worker 节点都要执行

# 安装 containerd
# 参考文档如下
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# 卸载旧版本
yum remove -y containerd.io

# 设置 yum repository
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装 containerd
yum install -y containerd.io

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

sed -i "s#k8s.gcr.io#registry.aliyuncs.com/k8sxio#g"  /etc/containerd/config.toml
sed -i '/containerd.runtimes.runc.options/a\ \ \ \ \ \ \ \ \ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml
sed -i "s#https://registry-1.docker.io#${REGISTRY_MIRROR}#g"  /etc/containerd/config.toml


systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd


# 安装 nfs-utils
# 必须先安装 nfs-utils 才能挂载 nfs 网络存储
yum install -y nfs-utils
yum install -y wget

# 关闭 防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭 SeLinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# 关闭 swap
swapoff -a
yes | cp /etc/fstab /etc/fstab_bak
cat /etc/fstab_bak |grep -v swap > /etc/fstab

# 配置K8S的yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 卸载旧版本
yum remove -y kubelet kubeadm kubectl

# 安装kubelet、kubeadm、kubectl
# 将 ${1} 替换为 kubernetes 版本号，例如 1.20.1
yum install -y kubelet-${1} kubeadm-${1} kubectl-${1}

crictl config runtime-endpoint unix:///run/containerd/containerd.sock

# 重启 docker，并启动 kubelet
systemctl daemon-reload
systemctl enable kubelet && systemctl start kubelet

containerd --version
kubelet --version

```

遇到的问题

``` zsh
➜  crictl ps
W1114 18:29:57.482060    8420 util_unix.go:103] Using "/run/containerd/containerd.sock" as endpoint is deprecated, please consider using full url format "unix:///run/containerd/containerd.sock".
W1114 18:29:57.482844    8420 util_unix.go:103] Using "/run/containerd/containerd.sock" as endpoint is deprecated, please consider using full url format "unix:///run/containerd/containerd.sock".
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID
```

解决

``` zsh
➜  crictl config runtime-endpoint unix:///run/containerd/containerd.sock
➜  crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID
```

## 初始化 Master

``` zsh
# 只在 master 节点执行
# 替换 x.x.x.x 为 master 节点的内网IP
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
export MASTER_IP=172.31.229.152
# 替换 apiserver.demo 为 您想要的 dnsName
export APISERVER_NAME=k8s-test
# Kubernetes 容器组所在的网段，该网段安装完成后，由 kubernetes 创建，事先并不存在于您的物理网络中
export POD_SUBNET=10.100.0.0/16
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

➜  ./install_master.sh 1.22.3 /coredns
```

脚本内容

``` zsh
➜ cat install_master.sh
#!/bin/bash

# 只在 master 节点执行

# 脚本出错时终止执行
set -e

if [ ${#POD_SUBNET} -eq 0 ] || [ ${#APISERVER_NAME} -eq 0 ]; then
  echo -e "\033[31;1m请确保您已经设置了环境变量 POD_SUBNET 和 APISERVER_NAME \033[0m"
  echo 当前POD_SUBNET=$POD_SUBNET
  echo 当前APISERVER_NAME=$APISERVER_NAME
  exit 1
fi


# 查看完整配置选项 https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
rm -f ./kubeadm-config.yaml
cat <<EOF > ./kubeadm-config.yaml
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v${1}
imageRepository: registry.aliyuncs.com/k8sxio
controlPlaneEndpoint: "${APISERVER_NAME}:6443"
networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "${POD_SUBNET}"
  dnsDomain: "cluster.local"
dns:
  type: CoreDNS
  imageRepository: swr.cn-east-2.myhuaweicloud.com${2}
  imageTag: 1.8.0

---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

# kubeadm init
# 根据您服务器网速的情况，您需要等候 3 - 10 分钟
echo ""
echo "抓取镜像，请稍候..."
kubeadm config images pull --config=kubeadm-config.yaml
echo ""
echo "初始化 Master 节点"
kubeadm init --config=kubeadm-config.yaml --upload-certs

# 配置 kubectl
rm -rf /root/.kube/
mkdir /root/.kube/
cp -i /etc/kubernetes/admin.conf /root/.kube/config
```

遇到的问题

``` zsh
➜ ./install_master.sh 1.22.3

抓取镜像，请稍候...
failed to pull image "registry.aliyuncs.com/k8sxio/kube-apiserver:v1.22.3": output: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
, error: exit status 1
To see the stack trace of this error execute with --v=5 or higher
```

问题解决

``` zsh
# 所有节点都执行
➜ yum install docker-ce -y
➜ systemctl start docker
```

kubelet 状态不对

``` zsh
[kubelet-check] It seems like the kubelet isn't running or healthy.
[kubelet-check] The HTTP call equal to 'curl -sSL http://localhost:10248/healthz' failed with error: Get "http://localhost:10248/healthz": dial tcp 127.0.0.1:10248: connect: connection refused.

        Unfortunately, an error has occurred:
                timed out waiting for the condition

        This error is likely caused by:
                - The kubelet is not running
                - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

        If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands:
                - 'systemctl status kubelet'
                - 'journalctl -xeu kubelet'

        Additionally, a control plane component may have crashed or exited when started by the container runtime.
        To troubleshoot, list all containers using your preferred container runtimes CLI.

        Here is one example how you may list all Kubernetes containers running in docker:
                - 'docker ps -a | grep kube | grep -v pause'
                Once you have found the failing container, you can inspect its logs with:
                - 'docker logs CONTAINERID'

error execution phase wait-control-plane: couldn't initialize a Kubernetes cluster
To see the stack trace of this error execute with --v=5 or higher
```

``` log
Nov 14 20:25:01 docker-node04 kubelet: E1114 20:25:01.138826   17299 server.go:294] "Failed to run kubelet" err="failed to run Kubelet: misconfiguration: kubelet cgroup driver: \"systemd\" is different from docker cgroup driver: \"cgroupfs\""
```

问题解决

修改 daemon.json 加入 `native.cgroupdriver=systemd`

``` zsh
# 所有节点
➜ vim /etc/docker/daemon.json
{
    "insecure-registries": [
        "172.31.229.139:9999","192.168.189.182:9999"
    ],
    "registry-mirrors" :[
        "https://docker.mirrors.ustc.edu.cn"
    ],
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ]
}

➜ systemctl restart docker
➜ systemctl restart kubelet
```

重新执行初始化脚本

``` zsh
You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join k8s-test:6443 --token ltss96.5te4xx610vri8kss \
        --discovery-token-ca-cert-hash sha256:0101735c6dd14a6540ff87ff8c64a27d8627305d98b99742ad3c444168cc3d7f \
        --control-plane --certificate-key a5e2d009782104df7671df1a11b68c20cd8bef9d081e2092b8ae4063749ae696

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

➜ kubeadm join k8s-test:6443 --token ltss96.5te4xx610vri8kss \
        --discovery-token-ca-cert-hash sha256:0101735c6dd14a6540ff87ff8c64a27d8627305d98b99742ad3c444168cc3d7f
```

``` zsh
➜ kubectl get nodes
NAME            STATUS     ROLES                  AGE    VERSION
docker-node04   NotReady   control-plane,master   103s   v1.22.3

➜ kubectl get pods -n kube-system
NAME                                    READY   STATUS    RESTARTS   AGE
coredns-7d75679df-hx5sc                 0/1     Pending   0          2m8s
coredns-7d75679df-rkk7m                 0/1     Pending   0          2m8s
etcd-docker-node04                      1/1     Running   1          2m23s
kube-apiserver-docker-node04            1/1     Running   1          2m22s
kube-controller-manager-docker-node04   1/1     Running   1          2m23s
kube-proxy-tntr9                        1/1     Running   0          2m8s
kube-scheduler-docker-node04            1/1     Running   1          2m23s
```

``` zsh
➜ export POD_SUBNET=10.100.0.0/16
➜ kubectl apply -f https://kuboard.cn/install-script/v1.21.x/calico-operator.yaml

➜ wget https://kuboard.cn/install-script/flannel/flannel-v0.14.0.yaml
➜ sed -i "s#10.244.0.0/16#${POD_SUBNET}#" flannel-v0.14.0.yaml
➜ kubectl apply -f ./flannel-v0.14.0.yaml
```

## Node 节点加入

``` zsh
# 只在 worker 节点执行
# 替换 x.x.x.x 为 master 节点的内网 IP
➜ export MASTER_IP=172.31.229.152
# 替换 apiserver.demo 为初始化 master 节点时所使用的 APISERVER_NAME
➜ export APISERVER_NAME=k8s-test
➜ echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

# 替换为 master 节点上 kubeadm token create 命令的输出
➜ kubeadm join k8s-test:6443 --token ltss96.5te4xx610vri8kss \
        --discovery-token-ca-cert-hash sha256:0101735c6dd14a6540ff87ff8c64a27d8627305d98b99742ad3c444168cc3d7f
```

https://blog.51cto.com/hexiaoshuai/2664271
https://blog.csdn.net/yuxuan89814/article/details/118220640
https://www.cnblogs.com/hellxz/p/kubelet-cgroup-driver-different-from-docker.html
