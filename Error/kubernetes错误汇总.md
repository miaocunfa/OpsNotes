## kubernetes 错误汇总

### 1、增加 master etcd 报错
#### 错误描述
由于创建的k8s集群，其中有一个master节点初始化失败，先删除了这个节点，将他重新添加为主节点，加入集群的时候报错。
``` bash
$ kubectl get nodes
NAME                      STATUS   ROLES    AGE   VERSION
node231                   Ready    master   14h   v1.16.7
node232                   Ready    <none>   14h   v1.16.7
apiserver                 Ready    master   14h   v1.16.7
node225                   Ready    <none>   14h   v1.16.7
node234                   Ready    <none>   14h   v1.16.7
```

#### 错误信息
``` log
$ kubeadm join apiserver.cluster.local:6443 --token 7kbxdh.166ls2phjr8o6o6h     --discovery-token-ca-cert-hash sha256:9cbe70e86b0e441af9da4d48df743150fcd40c86e6878ed899359c6d696e54d1 --control-plane --certificate-key 3052e10797e6d44abc862d67249c4abebb3a71901a4fee397b59508320295832

[check-etcd] Checking that the etcd cluster is healthy
error execution phase check-etcd: etcd cluster is not healthy: failed to dial endpoint https://192.168.100.232:2379 with maintenance client: context deadline exceeded
To see the stack trace of this error execute with --v=5 or higher
```

#### 错误解决
``` bash
# 查找运行中的etcd pod
$ kubectl get pods -n kube-system
# 进入etcd pod内部
$ kubectl exec etcd-apiserver.cluster.local -n kube-system -it -- /bin/sh

# 设置别名使用etcdctl命令时可以不用每次都列出证书文件了
# alias etcdctl='etcdctl --endpoints=https://localhost:2379 --ca-file=/etc/kubernetes/pki/etcd/ca.crt --cert-file=/etc/kubernetes/pki/etcd/server.crt --key-file=/etc/kubernetes/pki/etcd/server.key';

# etcdctl member list
62db8197a2e3eb9: name=apiserver.cluster.local peerURLs=https://192.168.100.236:2380 clientURLs=https://192.168.100.236:2379 isLeader=false
25fad11c030a1194: name=node2 peerURLs=https://192.168.100.232:2380 clientURLs=https://192.168.100.232:2379 isLeader=false                  # 发现232还在成员列表中
ada4976ae76f3d2b: name=node231 peerURLs=https://192.168.100.231:2380 clientURLs=https://192.168.100.231:2379 isLeader=true

# 删除etcd成员232
# etcdctl member remove 25fad11c030a1194
Removed member 25fad11c030a1194 from cluster
```

### 2、quay 镜像拉取
#### 错误信息
``` bash
# 获取pod超时
$ kubectl get pods
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

#### 错误解决
由于quay.io的镜像有某些不可描述的原因无法拉取，所以我们将这个地址换成国内的镜像库即可
将 quay.io/{XXX} 替换为 quay-mirror.qiniu.com/{XXX}
``` bash
# 先使用docker pull尝试拉取镜像
$ docker pull quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest
latest: Pulling from external_storage/rbd-provisioner
256b176beaff: Pull complete 
b4ecb0f03fba: Pull complete 
0ce433cb7726: Pull complete 
Digest: sha256:94fd36b8625141b62ff1addfa914d45f7b39619e55891bad0294263ecd2ce09a
Status: Downloaded newer image for quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest
quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest

# 修改yaml文件
$ vim rbd-provisioner-v16.yaml
spec:
      containers:
      - name: rbd-provisioner
        image: quay-mirror.qiniu.com/external_storage/rbd-provisioner:latest

$ kubectl apply -f rbd-provisioner-v16.yaml
$ kubectl get pods
NAME                               READY   STATUS              RESTARTS   AGE
rbd-provisioner-5b7b9c7b6c-2qn6q   1/1     Running             0          33s
```

### 3、