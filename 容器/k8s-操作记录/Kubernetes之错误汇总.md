---
title: "kubernetes错误汇总"
date: "2020-03-17"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "错误汇总"
toc: false
original: true
draft: false
---

## 1、增加 master etcd 报错

### 1.1、错误描述

由于创建的k8s集群，其中有一个master节点初始化失败，先删除了这个节点，将他重新添加为主节点，加入集群的时候报错。

``` zsh
➜  kubectl get nodes
NAME                      STATUS   ROLES    AGE   VERSION
node231                   Ready    master   14h   v1.16.7
node232                   Ready    <none>   14h   v1.16.7
apiserver                 Ready    master   14h   v1.16.7
node225                   Ready    <none>   14h   v1.16.7
node234                   Ready    <none>   14h   v1.16.7
```

### 1.2、错误信息

``` log
➜  kubeadm join apiserver.cluster.local:6443 --token 7kbxdh.166ls2phjr8o6o6h     --discovery-token-ca-cert-hash sha256:9cbe70e86b0e441af9da4d48df743150fcd40c86e6878ed899359c6d696e54d1 --control-plane --certificate-key 3052e10797e6d44abc862d67249c4abebb3a71901a4fee397b59508320295832

[check-etcd] Checking that the etcd cluster is healthy
error execution phase check-etcd: etcd cluster is not healthy: failed to dial endpoint https://192.168.100.232:2379 with maintenance client: context deadline exceeded
To see the stack trace of this error execute with --v=5 or higher
```

### 1.3、错误解决

``` zsh
# 查找运行中的etcd pod
➜  kubectl get pods -n kube-system
# 进入etcd pod内部
➜  kubectl exec etcd-apiserver.cluster.local -n kube-system -it -- /bin/sh

# 设置别名使用etcdctl命令时可以不用每次都列出证书文件了
➜  alias etcdctl='etcdctl --endpoints=https://localhost:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key';

➜  etcdctl member list
62db8197a2e3eb9: name=apiserver.cluster.local peerURLs=https://192.168.100.236:2380 clientURLs=https://192.168.100.236:2379 isLeader=false
25fad11c030a1194: name=node2 peerURLs=https://192.168.100.232:2380 clientURLs=https://192.168.100.232:2379 isLeader=false                  # 发现232还在成员列表中
ada4976ae76f3d2b: name=node231 peerURLs=https://192.168.100.231:2380 clientURLs=https://192.168.100.231:2379 isLeader=true

# 删除etcd成员232
➜  etcdctl member remove 25fad11c030a1194
Removed member 25fad11c030a1194 from cluster
```

## 2、quay 镜像拉取

### 2.1、错误信息

``` zsh
# 获取pod超时
➜  kubectl get pods
NAME                               READY   STATUS             RESTARTS   AGE
rbd-provisioner-75b85f85bd-c6xnb   0/1     ImagePullBackOff   0          23m

Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  <unknown>            default-scheduler  Successfully assigned default/rbd-provisioner-75b85f85bd-c6xnb to node225
  Warning  Failed     14m                  kubelet, node225   Failed to pull image "quay.io/external_storage/rbd-provisioner:latest": rpc error: code = Unknown desc = dial tcp: lookup d3uo42mtx6z2cr.cloudfront.net on 192.168.100.1:53: read udp 192.168.100.225:50342->192.168.100.1:53: i/o timeout
  Warning  Failed     11m                  kubelet, node225   Failed to pull image "quay.io/external_storage/rbd-provisioner:latest": rpc error: code = Unknown desc = dial tcp: lookup d3uo42mtx6z2cr.cloudfront.net on 192.168.100.1:53: read udp 192.168.100.225:52712->192.168.100.1:53: i/o timeout
  Warning  Failed     8m19s                kubelet, node225   Failed to pull image "quay.io/external_storage/rbd-provisioner:latest": rpc error: code = Unknown desc = dial tcp: lookup d3uo42mtx6z2cr.cloudfront.net on 192.168.100.1:53: read udp 192.168.100.225:37164->192.168.100.1:53: i/o timeout
  Normal   Pulling    7m32s (x4 over 23m)  kubelet, node225   Pulling image "quay.io/external_storage/rbd-provisioner:latest"
  Warning  Failed     4m36s                kubelet, node225   Failed to pull image "quay.io/external_storage/rbd-provisioner:latest": rpc error: code = Unknown desc = dial tcp: lookup d3uo42mtx6z2cr.cloudfront.net on 192.168.100.1:53: read udp 192.168.100.225:39043->192.168.100.1:53: i/o timeout
  Warning  Failed     4m36s (x4 over 14m)  kubelet, node225   Error: ErrImagePull
  Normal   BackOff    3m55s (x8 over 14m)  kubelet, node225   Back-off pulling image "quay.io/external_storage/rbd-provisioner:latest"
  Warning  Failed     3m55s (x8 over 14m)  kubelet, node225   Error: ImagePullBackOff
```

### 2.2、错误解决

由于quay.io的镜像有某些不可描述的原因无法拉取，所以我们将这个地址换成国内的镜像库即可
将 quay.io/{XXX} 替换为 quay-mirror.qiniu.com/{XXX}

``` zsh
# 先使用docker pull尝试拉取镜像
➜  docker pull quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest
latest: Pulling from external_storage/rbd-provisioner
256b176beaff: Pull complete 
b4ecb0f03fba: Pull complete 
0ce433cb7726: Pull complete 
Digest: sha256:94fd36b8625141b62ff1addfa914d45f7b39619e55891bad0294263ecd2ce09a
Status: Downloaded newer image for quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest
quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest

# 修改yaml文件
➜  vim rbd-provisioner-v16.yaml
spec:
      containers:
      - name: rbd-provisioner
        image: quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest

➜  kubectl apply -f rbd-provisioner-v16.yaml
➜  kubectl get pods
NAME                               READY   STATUS              RESTARTS   AGE
rbd-provisioner-5b7b9c7b6c-2qn6q   1/1     Running             0          33s
```

## 3、Statefulset 挂载Ceph 失败

### 3.1、错误信息

``` zsh
➜  kubectl get pods
NAME                               READY   STATUS              RESTARTS   AGE
consul-0                           0/1     ContainerCreating   0          15h

Events:
  Type     Reason       Age                  From             Message
  ----     ------       ----                 ----             -------
  Warning  FailedMount  46m (x304 over 15h)  kubelet, mongo1  Unable to attach or mount volumes: unmounted volumes=[consul-ceph-pvc], unattached volumes=[consul-ceph-pvc default-token-8wntp]: timed out waiting for the condition
  Warning  FailedMount  12m (x83 over 14h)   kubelet, mongo1  Unable to attach or mount volumes: unmounted volumes=[consul-ceph-pvc], unattached volumes=[default-token-8wntp consul-ceph-pvc]: timed out waiting for the condition
  Warning  FailedMount  56s (x455 over 15h)  kubelet, mongo1  MountVolume.WaitForAttach failed for volume "pvc-025063c5-3a6e-4e34-a950-f72dee2f8b9b" : fail to check rbd image status with: (executable file not found in $PATH), rbd output: ()
```

### 3.2、错误解决

node节点未安装ceph-common

ansible配置

``` zsh
➜  cat /etc/ansible/hosts
[k8s-master]
192.168.100.231 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.232 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.236 ansible_ssh_user='root' ansible_ssh_pass='test123'

[k8s-node]
192.168.100.225 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.226 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.227 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.228 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.234 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.237 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.238 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.239 ansible_ssh_user='root' ansible_ssh_pass='test123'
```

拷贝ceph.repo至每一个节点

``` zsh
➜  ansible k8s-node -m copy -a "src=/etc/yum.repos.d/ceph.repo dest=/etc/yum.repos.d/ceph.repo"
```

安装ceph-common

``` zsh
➜  ansible k8s-node -m shell -a "yum install -y ceph-common"
➜  ansible k8s-master -m shell -a "yum install -y ceph-common"
```

验证问题

``` zsh
➜  kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          16h
consul-1                           1/1     Running   0          9m54s
consul-2                           1/1     Running   0          <invalid>
```

## 4、age invalid

### 4.1、错误信息

发现pod的age不对，显示invalid

``` zsh
➜  kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          16h
consul-1                           1/1     Running   0          10m
consul-2                           1/1     Running   0          <invalid>
```

### 4.2、错误解决

``` bash
# apiserver 的时间
➜  date
Wed Mar 18 10:34:01 CST 2020

# node 的时间
➜  date
Tue Mar 17 22:34:01 EDT 2020

# 发现问题是时间不同步
# 同步所有主机时间
➜  ansible all -m shell -a "ntpdate ntp1.aliyun.com"

# 验证
➜  kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          17h
consul-1                           1/1     Running   0          30m
consul-2                           1/1     Running   0          18s
```

## 5、Harbor私服的http

### 5.1、错误信息

``` zsh
➜  kubectl describe pods consul-0
  Normal   BackOff                 17s (x3 over 43s)  kubelet, node231         Back-off pulling image "reg.test.local/library/consul:1.7"
  Warning  Failed                  17s (x3 over 43s)  kubelet, node231         Error: ImagePullBackOff
  Normal   Pulling                 3s (x3 over 44s)   kubelet, node231         Pulling image "reg.test.local/library/consul:1.7"
  Warning  Failed                  3s (x3 over 44s)   kubelet, node231         Failed to pull image "reg.test.local/library/consul:1.7": rpc error: code = Unknown desc = Error response from daemon: Get https://reg.test.local/v2/: x509: certificate signed by unknown authority
  Warning  Failed                  3s (x3 over 44s)   kubelet, node231         Error: ErrImagePull
```

### 5.2、错误分析

reg.test.local为测试环境Harbor  
没有启用https  

### 5.3、错误解决

``` zsh
# 修改所有docker主机
➜  vim /etc/docker/daemon.json
"insecure-registries": ["http://reg.test.local"]

➜  systemctl restart docker
```

## 6、Harbor私服需要docker login

### 6.1、错误信息

``` zsh
kubectl get pods -w
NAME                               READY   STATUS              RESTARTS   AGE
consul-0                           0/1     ContainerCreating   0          8s
consul-0                           0/1     ContainerCreating   0          19s
consul-0                           0/1     ErrImagePull        0          20s
consul-0                           0/1     ImagePullBackOff    0          21s

➜  kubectl describe pods consul-0
  Normal   Pulling                 17s (x2 over 30s)  kubelet, node232         Pulling image "reg.test.local/library/consul:1.7"
  Warning  Failed                  17s (x2 over 30s)  kubelet, node232         Failed to pull image "reg.test.local/library/consul:1.7": rpc error: code = Unknown desc = Error response from daemon: pull access denied for reg.test.local/library/consul, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
  Warning  Failed                  17s (x2 over 30s)  kubelet, node232         Error: ErrImagePull
  Normal   BackOff                 5s (x3 over 30s)   kubelet, node232         Back-off pulling image "reg.test.local/library/consul:1.7"
  Warning  Failed                  5s (x3 over 30s)   kubelet, node232         Error: ImagePullBackOff
```

### 6.2、错误解析

docker主机需要docker login

### 6.3、错误解决

``` zsh
# 在所有docker主机执行docker login
➜  docker login reg.test.local
Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# 已经可以直接使用docker pull镜像了
➜  docker pull reg.test.local/library/consul:1.7
1.7: Pulling from library/consul
9123ac7c32f7: Pull complete
f3e53a83f220: Pull complete
b64aa8d4cc8e: Pull complete
82481eff66f7: Pull complete
79aba2a452b6: Pull complete
fe81d1cfdb25: Pull complete
Digest: sha256:2f03c533527fdf8b579647f093eb7fe88fc7f2038794cfbe20347b02eef68e1e
Status: Downloaded newer image for reg.test.local/library/consul:1.7
reg.test.local/library/consul:1.7

# 但是k8s节点暂时还无法拉取镜像
# 需要创建名为registry-secret的docker-registry
➜  kubectl create secret docker-registry registry-secret --namespace=default \
--docker-server=reg.test.local \
--docker-username=admin \
--docker-password=Harbor123

# 查看imagePullSecrets属性
➜  kubectl explain deploy.spec.template.spec.imagePullSecrets
KIND:     Deployment
VERSION:  apps/v1

RESOURCE: imagePullSecrets <[]Object>

DESCRIPTION:
     ImagePullSecrets is an optional list of references to secrets in the same
     namespace to use for pulling any of the images used by this PodSpec. If
     specified, these secrets will be passed to individual puller
     implementations for them to use. For example, in the case of docker, only
     DockerConfig type secrets are honored. More info:
     https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod

     LocalObjectReference contains enough information to let you locate the
     referenced object inside the same namespace.

FIELDS:
   name	<string>
     Name of the referent. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names

# 修改deployment yaml
➜  vim consul-statefulset-v16.yaml
imagePullSecrets:
  - name: registry-secret

➜  kubectl delete -f consul-statefulset-v16.yaml
➜  kubectl apply -f consul-statefulset-v16.yaml
statefulset.apps/consul configured
➜  kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          4m53s
consul-1                           1/1     Running   0          4m44s
consul-2                           0/1     Pending   0          4m10s
```

## 7、pod反亲和性

### 7.1、错误信息

``` zsh
➜  ubectl get nodes
NAME                      STATUS   ROLES    AGE    VERSION
apiserver.cluster.local   Ready    master   4d3h   v1.16.10
node231                   Ready    <none>   4d2h   v1.16.10
node232                   Ready    <none>   4d2h   v1.16.10
➜  kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          3m46s
consul-1                           1/1     Running   0          3m37s
consul-2                           0/1     Pending   0          3m3s
➜  kubectl describe pods consul-2
Events:
  Type     Reason            Age        From               Message
  ----     ------            ----       ----               -------
  Warning  FailedScheduling  <unknown>  default-scheduler  pod has unbound immediate PersistentVolumeClaims (repeated 2 times)
  Warning  FailedScheduling  <unknown>  default-scheduler  pod has unbound immediate PersistentVolumeClaims (repeated 2 times)
  Warning  FailedScheduling  <unknown>  default-scheduler  0/3 nodes are available: 1 node(s) had taints that the pod didn't tolerate, 2 node(s) didn't match pod affinity/anti-affinity, 2 node(s) didn't satisfy existing pods anti-affinity rules.
➜  cat consul-statefulset-v16.yaml
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - consul
              topologyKey: kubernetes.io/hostname
```

### 7.2、错误分析

由于只有两个node，违反了yaml中配置的反亲和性规则

### 7.3、错误解决

``` zsh
➜  vim consul-statefulset-v16.yaml

:set nu

 28       affinity:
 29         podAntiAffinity:
 30           requiredDuringSchedulingIgnoredDuringExecution:
 31             - labelSelector:
 32                 matchExpressions:
 33                   - key: app
 34                     operator: In
 35                     values:
 36                       - consul
 37               topologyKey: kubernetes.io/

:28,37s@^@#@

 28 #      affinity:
 29 #        podAntiAffinity:
 30 #          requiredDuringSchedulingIgnoredDuringExecution:
 31 #            - labelSelector:
 32 #                matchExpressions:
 33 #                  - key: app
 34 #                    operator: In
 35 #                    values:
 36 #                      - consul
 37 #              topologyKey: kubernetes.io/hostname

➜   kubectl delete -f consul-statefulset-v16.yaml
➜   kubectl apply -f consul-statefulset-v16.yaml

➜   kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
consul-0                           1/1     Running   0          55s
consul-1                           1/1     Running   0          46s
consul-2                           1/1     Running   0          24s
```
