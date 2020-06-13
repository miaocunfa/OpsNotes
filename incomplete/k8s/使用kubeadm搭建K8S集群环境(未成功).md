## 使用kubeadm搭建k8s集群环境

### 一、设置主机名并做主机间ssh免密

#### 1.1、设置主机名

```bash
# 10.0.0.18
hostnamectl set-hostname master
# 10.0.0.26
hostnamectl set-hostname note01
# 10.0.0.61
hostnamectl set-hostname note02
# 10.0.0.115
hostnamectl set-hostname note03
# 10.0.0.189
hostnamectl set-hostname note04
```

`/etc/hosts` 文件

``` bash
[root@master ~]# cat /etc/hosts
::1	localhost	localhost.localdomain	localhost6	localhost6.localdomain6

127.0.0.1	localhost	localhost.localdomain	localhost4	localhost4.localdomain4
127.0.0.1	localhost	localhost
10.0.0.18       master
10.0.0.26       note01
10.0.0.61       note02
10.0.0.115      note03
10.0.0.189      note04
```

#### 1.2、ssh免密互通
每个节点做`ssh-keygen -t rsa -P ''`
并将每个节点生成的`/root/.ssh/id_rsa.pub`追加至某一节点的`/root/.ssh/authorized_keys`中，
将这个`authorized_keys`文件`scp`至每一个节点，最后`scp /etc/hosts`文件至每一个节点。

### 二、部署k8s准备工作

#### 2.1、关闭iptables和firewall

```bash
systemctl stop firewalld.service     停止firewall服务

systemctl disable firewalld.service  禁止firewall开机自启
```

#### 2.2、时间同步

配置从阿里云ntp服务器同步时间
```bash
vi /etc/chrony.conf
#设置阿里云时间服务器
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp2.aliyun.com iburst
server ntp2.aliyun.com iburst
#允许本地时间向其它主机授时
#allow 10.0.0.0/24
```

启动chrony服务，并检查时间同步状态
``` bash
[root@master ~]# systemctl start chronyd.service
[root@master ~]# chronyc sources -v
210 Number of sources = 2

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^* 120.25.115.20                 2   6    77    64   -755us[ +744us] +/-   21ms
^+ 203.107.6.88                  2   6   177     1   +233us[ +233us] +/-   16ms
[root@master ~]#

```

#### 2.3、所有节点安装docker、kubelet

首先我们配置k8s和docker-ce的yum源

```bash
[root@master ~]# cd /etc/yum.repos.d
[root@master yum.repos.d]# wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
[root@master ~]# cat /etc/yum.repos.d/k8s.repo 
[k8s]
name=k8s repo
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
enabled=1
[root@master ~]#
#我们看到docker库和k8s库是有安装包的
[root@master ~]# yum repolist
repo id                                         repo name                                                                     status
docker-ce-stable/x86_64                            Docker CE Stable - x86_64                                                      56
k8s                                             k8s repo                                                                         406

```

将`docker-ce.repo`和`k8s.repo`文件`scp`至每一个节点
```bash
scp /etc/yum.repos.d/docker-ce.repo root@note01:/etc/yum.repos.d/
scp /etc/yum.repos.d/k8s.repo root@note01:/etc/yum.repos.d/
```

### 三、初始化master节点
#### 3.1、安装程序包
``` bash
yum install docker-ce kubelet kubeadm kubectl
```

#### 3.2、docker

``` bash
# 设置docker开机自启
systemctl enable docker
# 启动docker服务
systemctl start docker
```

``` bash
# 查看参数,iptables能否正常使用桥接功能
cat /proc/sys/net/bridge/bridge-nf-call-iptables
1
cat /proc/sys/net/bridge/bridge-nf-call-ip6tables
1
```

#### 3.3、kubelet
```bash
# 设置为开机自启动
systemctl enable kubelet
```

#### 3.4、kubeadm
初始化k8s集群master节点。

由于某些不可描述原因，无法拉取到所需镜像，有两种办法。一是配置代理，二是先将镜像下载到本地之后重新打标签。

镜像下载脚本
``` bash
[root@master ~]# cat pull.sh
for i in `kubeadm config images list`; do   
	imageName=${i#k8s.gcr.io/}  
	docker pull registry.aliyuncs.com/google_containers/$imageName  	
	docker tag registry.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName  
	docker rmi registry.aliyuncs.com/google_containers/$imageName
done;

[root@master ~]# docker image ls
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-apiserver            v1.16.0             b305571ca60a        2 weeks ago         217MB
k8s.gcr.io/kube-controller-manager   v1.16.0             06a629a7e51c        2 weeks ago         163MB
k8s.gcr.io/kube-proxy                v1.16.0             c21b0c7400f9        2 weeks ago         86.1MB
k8s.gcr.io/kube-scheduler            v1.16.0             301ddc62b80b        2 weeks ago         87.3MB
k8s.gcr.io/etcd                      3.3.15-0            b2756210eeab        4 weeks ago         247MB
k8s.gcr.io/coredns                   1.6.2               bf261d157914        7 weeks ago         44.1MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        21 months ago       742kB
```

初始化master节点
``` bash
[root@master ~]# kubeadm init
W1006 20:39:21.797384   21613 version.go:101] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://dl.k8s.io/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W1006 20:39:21.797445   21613 version.go:102] falling back to the local client version: v1.16.0
[init] Using Kubernetes version: v1.16.0
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.2. Latest validated version: 18.09
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.0.0.18]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master localhost] and IPs [10.0.0.18 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master localhost] and IPs [10.0.0.18 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 21.501580 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.16" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: n3icf8.wpdd3tpwvs7auen7
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.0.18:6443 --token n3icf8.wpdd3tpwvs7auen7 \
    --discovery-token-ca-cert-hash sha256:6838536cb6ba5288ef52de31f5b84fd02f57f087bcb2329d3afd2b8ac6318fae
```

```bash
[root@master ~]# mkdir -p $HOME/.kube
[root@master ~]# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
[root@master ~]# kubectl get nodes
NAME     STATUS     ROLES    AGE     VERSION
master   NotReady   master    5m     v1.16.0
```

### 四、note节点加入k8s集群

#### 4.1、安装软件包

```bash
yum install docker-ce kubelet kubeadm
```

#### 4.2、docker

``` bash
# 设置docker开机自启
systemctl enable docker
# 启动docker服务
systemctl start docker
```

``` bash
# 修改参数保证iptables能正常使用桥接功能
[root@note01 ~]# echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
[root@note01 ~]# echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
```

#### 4.3、kubelet
```bash
# 设置为开机自启动
systemctl enable kubelet
```

#### 4.4、kubeadm
初始化k8s集群 worker节点

```bash
[root@note01 ~]# kubeadm join 10.0.0.18:6443 --token n3icf8.wpdd3tpwvs7auen7 \
>     --discovery-token-ca-cert-hash sha256:6838536cb6ba5288ef52de31f5b84fd02f57f087bcb2329d3afd2b8ac6318fae
[preflight] Running pre-flight checks
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
	[WARNING SystemVerification]: this Docker version is not on the list of validated versions: 19.03.2. Latest validated version: 18.09
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

[root@note01 ~]#
```

```
[root@master ~]# kubectl get nodes
NAME     STATUS     ROLES    AGE     VERSION
master   NotReady   master   45m     v1.16.0
note01   NotReady   <none>   4m15s   v1.16.0
```

五、k8s集群设置

发现k8s集群节点的状态都是NotReady，是因为我们没有部署网络插件，这里我们使用flannel

```
[root@master ~]# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
[root@master ~]#
```





