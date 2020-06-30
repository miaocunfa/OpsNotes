---
title: "Kubernetes之亲和性"
date: "2020-06-30"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "亲和性"
toc: false
indent: false
original: true
---

## 一、节点亲和性

## 二、pod亲和性

## 三、pod反亲和性

### 3.1、软反亲和性

改造yaml

``` zsh
➜  cat info-ad-service_deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: info-ad-service
  labels:
    serviceName: info-ad-service       # 设置label
spec:
  selector:
    matchLabels:
      serviceName: info-ad-service
  replicas: 2                          # 首先设置两个副本, 观察pod的调用情况
  template:
    metadata:
      labels:
        serviceName: info-ad-service
    spec:
      containers:
      - name: info-ad-service
        image: reg.test.local/library/info-ad-service:0.0.2
      imagePullSecrets:
      - name: registry-secret
      affinity:                                                  # 亲和性
        podAntiAffinity:                                         # pod反亲和性
          preferredDuringSchedulingIgnoredDuringExecution:       # 软亲和性
          - weight: 100                                          # 可以设置多个匹配规则, 这是权重
            podAffinityTerm:
              topologyKey: kubernetes.io/hostname
              labelSelector:
                matchExpressions:
                - key: serviceName          # 根据label名serviceName
                  operator: In              # In 是否在values中
                  values:
                  - info-ad-service         # serviceName in ['info-ad-service', ]

➜  kubectl delete -f info-ad-service_deploy.yaml
➜  kubectl apply -f info-ad-service_deploy.yaml

# 查看pod的标签
➜  kubectl get pods --show-labels
info-ad-service-5f5598dc7f-bpw6b            1/1     Running             0          22s    pod-template-hash=5f5598dc7f,serviceName=info-ad-service
info-ad-service-5f5598dc7f-fhh5v            0/1     ContainerCreating   0          21s    pod-template-hash=5f5598dc7f,serviceName=info-ad-service

# 我们查看这两个pod调度到什么节点了
➜  kubectl get pods
info-ad-service-5f5598dc7f-bpw6b            1/1     Running       0          13m    10.100.239.29     node231   <none>           <none>
info-ad-service-5f5598dc7f-fhh5v            1/1     Running       0          13m    10.100.159.209    node232   <none>           <none>

# 首先查看节点资源
➜  kubectl top nodes
NAME                      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
apiserver.cluster.local   396m         9%     1975Mi          53%
node231                   255m         6%     2292Mi          29%    # 节点231内存资源比较充足
node232                   477m         11%    6106Mi          79%

➜  vim info-ad-service_deploy.yaml
replicas: 4    # 将副本数量扩展为4

➜  kubectl apply -f info-ad-service_deploy.yaml

➜  kubectl get pods
info-ad-service-5f5598dc7f-bpw6b            1/1     Running       0          15m    10.100.239.29     node231   <none>           <none>
info-ad-service-5f5598dc7f-dtbn4            1/1     Running       0          41s    10.100.239.37     node231   <none>           <none>    # 我们可以看到新增的这两个pod
info-ad-service-5f5598dc7f-fhh5v            1/1     Running       0          15m    10.100.159.209    node232   <none>           <none>
info-ad-service-5f5598dc7f-xjxjp            1/1     Running       0          42s    10.100.239.36     node231   <none>           <none>    # 都被调度到内存资源比较充足的231节点了
```

所以软反亲和性, 是在条件满足的情况下尽量去实现, 当条件不满足的时候也能调度

### 3.2、硬亲和性
