# Sealos安装Kubernetes v1.16.0 HA集群

> github项目链接
> https://github.com/fanux/sealos

## 初始化master节点与worker节点

初始化脚本 init.sh
``` shell
#!/bin/bash

# 在 master 节点和 worker 节点都要执行

# 安装 docker
# 参考文档如下
# https://docs.docker.com/install/linux/docker-ce/centos/ 
# https://docs.docker.com/install/linux/linux-postinstall/

# 卸载旧版本
yum remove -y docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine

# 设置 yum repository
yum install -y yum-utils \
device-mapper-persistent-data \
lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装并启动 docker
yum install -y docker-ce-18.09.7 docker-ce-cli-18.09.7 containerd.io
systemctl enable docker
systemctl start docker

# 安装 nfs-utils
# 必须先安装 nfs-utils 才能挂载 nfs 网络存储
yum install -y nfs-utils

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

# 修改 /etc/sysctl.conf
# 如果有配置，则修改
sed -i "s#^net.ipv4.ip_forward.*#net.ipv4.ip_forward=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-ip6tables.*#net.bridge.bridge-nf-call-ip6tables=1#g"  /etc/sysctl.conf
sed -i "s#^net.bridge.bridge-nf-call-iptables.*#net.bridge.bridge-nf-call-iptables=1#g"  /etc/sysctl.conf
# 可能没有，追加
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
# 执行命令以应用
sysctl -p

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
yum install -y kubelet-1.16.0 kubeadm-1.16.0 kubectl-1.16.0

# 修改docker Cgroup Driver为systemd
# # 将/usr/lib/systemd/system/docker.service文件中的这一行 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
# # 修改为 ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
# 如果不修改，在添加 worker 节点时可能会碰到如下错误
# [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". 
# Please follow the guide at https://kubernetes.io/docs/setup/cri/
sed -i "s#^ExecStart=/usr/bin/dockerd.*#ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd#g" /usr/lib/systemd/system/docker.service

# 设置 docker 镜像，提高 docker 镜像下载速度和稳定性
# 如果您访问 https://hub.docker.io 速度非常稳定，亦可以跳过这个步骤
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io

# 重启 docker，并启动 kubelet
systemctl daemon-reload
systemctl restart docker
systemctl enable kubelet && systemctl start kubelet

docker version
```

## Sealos
``` bash
# 下载sealos
wget https://github.com/fanux/sealos/releases/download/v2.0.7/sealos
# 加执行权限，并将sealos移至/usr/bin下
chmod +x sealos && mv sealos /usr/bin
```

### sealos选项
```
--master   master服务器地址列表
--node     node服务器地址列表
--user     服务器ssh用户名
--passwd   服务器ssh用户密码
--pkg-url  离线包位置，可以放在本地目录，也可以放在一个http服务器上，sealos会wget到安装目标机
--version  kubernetes版本
```

## 初始化k8s HA集群
``` bash
sealos init --passwd YOUR_SERVER_PASSWD  
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
``` bash
[root@master01 ~]# kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
master01   Ready    master   11h   v1.16.0
master02   Ready    master   11h   v1.16.0
master03   Ready    master   11h   v1.16.0
node01     Ready    <none>   11h   v1.16.0
```

``` bash
# 获取service
[root@master01 ~]# kubectl get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17h

# 通过查看 ipvs 规则，我们可以看到发送至 10.96.0.1 的请求都被负载至所有master节点。
[root@master01 ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  10.96.0.1:443 rr
  -> 172.31.194.114:6443          Masq    1      3          0         
  -> 172.31.194.115:6443          Masq    1      2          0         
  -> 172.31.194.116:6443          Masq    1      0          0         
```

