---
title: "Kubernetes使用Ceph共享存储"
date: "2020-03-11"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "分布式存储"
    - "StorageClass"
toc: false
original: true
---

## 一、环境准备

### 1.1、Ceph版本
ceph mimic(13.2.8)
``` bash
$ ceph version
ceph version 13.2.8 (5579a94fafbc1f9cc913a0f5d362953a5d9c3ae0) mimic (stable)
```

### 1.2、存储池
``` bash
$ ceph osd pool ls
kube
```

### 1.3、秘钥
``` bash
# 生成k8s专用账号秘钥
$ ceph auth get-or-create client.k8s mon 'allow r' osd 'allow rwx pool=kube' -o ceph.client.k8s.keyring
$ cat ceph.client.k8s.keyring
[client.k8s]
	key = AQCNVmheCOVAFRAA9Vc36VQumqpeWbgY9dEjNw==

$ ceph auth get-key client.k8s | base64
QVFDTlZtaGVDT1ZBRlJBQTlWYzM2VlF1bXFwZVdiZ1k5ZEVqTnc9PQ==
```

## 二、K8S准备

### 2.1、安装rbd驱动
``` yaml
$ cat >rbd-provisioner.yaml << EOF
kind: ClusterRole 
apiVersion: rbac.authorization.k8s.io/v1 
metadata: 
  name: rbd-provisioner 
rules: 
  - apiGroups: [""] 
    resources: ["persistentvolumes"] 
    verbs: ["get", "list", "watch", "create", "delete"] 
  - apiGroups: [""] 
    resources: ["persistentvolumeclaims"] 
    verbs: ["get", "list", "watch", "update"] 
  - apiGroups: ["storage.k8s.io"] 
    resources: ["storageclasses"] 
    verbs: ["get", "list", "watch"] 
  - apiGroups: [""] 
    resources: ["events"] 
    verbs: ["create", "update", "patch"] 
  - apiGroups: [""] 
    resources: ["services"] 
    resourceNames: ["kube-dns","coredns"] 
    verbs: ["list", "get"] 
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "create", "delete"]  
--- 
kind: ClusterRoleBinding 
apiVersion: rbac.authorization.k8s.io/v1 
metadata: 
  name: rbd-provisioner 
subjects: 
  - kind: ServiceAccount 
    name: rbd-provisioner 
    namespace: default 
roleRef: 
  kind: ClusterRole 
  name: rbd-provisioner 
  apiGroup: rbac.authorization.k8s.io 
--- 
apiVersion: rbac.authorization.k8s.io/v1 
kind: Role 
metadata: 
  name: rbd-provisioner 
rules: 
- apiGroups: [""] 
  resources: ["secrets"] 
  verbs: ["get"] 
- apiGroups: [""] 
  resources: ["endpoints"] 
  verbs: ["get", "list", "watch", "create", "update", "patch"] 
--- 
apiVersion: rbac.authorization.k8s.io/v1 
kind: RoleBinding 
metadata: 
  name: rbd-provisioner 
roleRef: 
  apiGroup: rbac.authorization.k8s.io 
  kind: Role 
  name: rbd-provisioner 
subjects: 
  - kind: ServiceAccount 
    name: rbd-provisioner 
    namespace: default 
--- 
apiVersion: extensions/v1beta1 
kind: Deployment 
metadata: 
  name: rbd-provisioner 
spec: 
  replicas: 1 
  strategy: 
    type: Recreate 
  template: 
    metadata: 
      labels: 
        app: rbd-provisioner 
    spec: 
      containers: 
      - name: rbd-provisioner 
        image: quay.mirrors.ustc.edu.cn/external_storage/rbd-provisioner:latest
        env: 
        - name: PROVISIONER_NAME 
          value: ceph.com/rbd 
      serviceAccount: rbd-provisioner 
--- 
apiVersion: v1 
kind: ServiceAccount 
metadata: 
  name: rbd-provisioner
EOF

$ kubectl apply -f rbd-provisioner.yaml
```

### 2.2、为kubelet提供rbd命令
创建pod时，kubelet需要使用rbd命令去检测和挂载pv对应的ceph image，所以要在所有的worker节点安装ceph客户端ceph-common-13.2.8。
``` bash
$ yum install -y ceph-common-13.2.8
```

## 三、K8S使用

### 3.1、secret

创建 admin secret
``` bash
# 在ceph Mon节点获取admin key
$ ceph auth get-key client.admin

$ export CEPH_ADMIN_SECRET='AQCzDGJeEcGGLhAAut/m7RPgV7ZYlLHGhO8sfw=='
$ kubectl create secret generic ceph-secret --type="kubernetes.io/rbd" --from-literal=key=$CEPH_ADMIN_SECRET --namespace=kube-system
```

在default命名空间创建secret
``` bash
# 在ceph Mon节点获取user key
$ ceph auth get-key client.k8s

$ export CEPH_KUBE_SECRET='AQCNVmheCOVAFRAA9Vc36VQumqpeWbgY9dEjNw=='
$ kubectl create secret generic ceph-user-secret --type="kubernetes.io/rbd" --from-literal=key=$CEPH_KUBE_SECRET --namespace=default
```

查看secret
``` bash
$ kubectl get secret ceph-user-secret -o yaml
$ kubectl get secret ceph-secret -n kube-system -o yaml
```

### 3.2、StorageClass

配置 StorageClass
``` yaml
# 如果使用kubeadm创建的集群 provisioner 使用如下方式
# provisioner: ceph.com/rbd

$ cat >storageclass-ceph-rdb.yaml << EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: dynamic-ceph-rdb
provisioner: ceph.com/rbd
# provisioner: kubernetes.io/rbd
parameters:
  monitors: 192.168.100.238:6789
  adminId: admin
  adminSecretName: ceph-secret
  adminSecretNamespace: kube-system
  pool: kube
  userId: k8s
  userSecretName: ceph-user-secret
  fsType: xfs
  imageFormat: "2"
  imageFeatures: "layering"
EOF

$ kubectl apply -f storageclass-ceph-rdb.yaml
```

### 3.3、PVC

创建pvc测试
``` yaml
$ cat >ceph-rdb-pvc-test.yaml<<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ceph-rdb-claim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: dynamic-ceph-rdb
  resources:
    requests:
      storage: 2Gi
EOF

$ kubectl apply -f ceph-rdb-pvc-test.yaml

# 查看
$ kubectl get pvc
$ kubectl get pv
```

### 3.4、创建 nginx pod 挂载测试
``` yaml
cat >nginx-pod.yaml<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod1
  labels:
    name: nginx-pod1
spec:
  containers:
  - name: nginx-pod1
    image: nginx:alpine
    ports:
    - name: web
      containerPort: 80
    volumeMounts:
    - name: ceph-rdb
      mountPath: /usr/share/nginx/html    # 将主页挂载至ceph
  volumes:
  - name: ceph-rdb
    persistentVolumeClaim:
      claimName: ceph-rdb-claim
EOF

$ kubectl apply -f nginx-pod.yaml

# 查看pod
$ kubectl get pods -o wide
 
# 修改主页内容
$ kubectl exec -ti nginx-pod1 -- /bin/sh -c 'echo Hello World from Ceph RBD!!! > /usr/share/nginx/html/index.html'
 
# 访问测试
$ POD_IP=$(kubectl get pods -o wide | grep nginx-pod1 | awk '{print $6}')
$ curl http://$POD_IP

# 清理
$ kubectl delete -f nginx-pod.yaml
$ kubectl delete -f ceph-rdb-pvc-test.yaml
```