---
title: "Kubernetes之滚动升级"
date: "2020-06-29"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "rollout"
    - "滚动升级"
toc: false
indent: false
original: true
draft: false
---

## 一、滚动前

``` zsh
➜  cat info-ad-service_deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: info-ad-service
  labels:
    name: info-ad-service
spec:
  selector:
    matchLabels:
      name: info-ad-service
  replicas: 1
  template:
    metadata:
      labels:
        name: info-ad-service
    spec:
      containers:
      - name: info-ad-service                                           # 容器名称
        image: reg.test.local/library/info-ad-service:0.0.1-SNAPSHOT    # 镜像tag
      imagePullSecrets:
      - name: registry-secret

# 由于只有一个副本无法展现滚动效果, 先扩容为3个副本
➜  kubectl scale --replicas=3 deployment/info-ad-service
deployment.apps/info-ad-service scaled

➜  kubectl get pods
info-ad-service-79fc9796df-6kjkv            1/1     Running   0          36m
info-ad-service-79fc9796df-thwhl            1/1     Running   0          75s
info-ad-service-79fc9796df-zd6rt            1/1     Running   0          75s
```

## 二、滚动中

### 2.1、使用命令进行滚动升级

``` zsh
# 使用 kubectl set image 进行滚动升级
Usage:
  kubectl set image (-f FILENAME | TYPE NAME) CONTAINER_NAME_1=CONTAINER_IMAGE_1 ... CONTAINER_NAME_N=CONTAINER_IMAGE_N [options]

# --record 可以将命令详细的记录下来, 方便回滚
➜  kubectl set image deploy/info-ad-service info-ad-service=reg.test.local/library/info-ad-service:0.0.2 --record
deployment.apps/info-ad-service image updated

# watch pods资源
➜  kubectl get pods -w
info-ad-service-79fc9796df-6kjkv            1/1     Running   0          40m
info-ad-service-79fc9796df-thwhl            1/1     Running   0          5m43s
info-ad-service-79fc9796df-zd6rt            1/1     Running   0          5m43s

# 滚动升级过程中 pod的变化
info-ad-service-5bf7f4c8dc-vf2dk            0/1     Pending   0          0s
info-ad-service-5bf7f4c8dc-vf2dk            0/1     Pending   0          1s
info-ad-service-5bf7f4c8dc-vf2dk            0/1     ContainerCreating   0          2s
info-ad-service-5bf7f4c8dc-vf2dk            0/1     ContainerCreating   0          15s
info-ad-service-5bf7f4c8dc-vf2dk            1/1     Running             0          49s    # 我们发现滚动升级过程是首先创建一个pod, 待这个新版本的pod Running后
info-ad-service-79fc9796df-thwhl            1/1     Terminating         0          10m    # 删除一个旧的pod
info-ad-service-5bf7f4c8dc-jhg2z            0/1     Pending             0          1s
info-ad-service-5bf7f4c8dc-jhg2z            0/1     Pending             0          1s
info-ad-service-5bf7f4c8dc-jhg2z            0/1     ContainerCreating   0          3s
info-ad-service-5bf7f4c8dc-jhg2z            0/1     ContainerCreating   0          30s
info-ad-service-79fc9796df-thwhl            0/1     Terminating         0          11m
info-ad-service-5bf7f4c8dc-jhg2z            1/1     Running             0          66s    # 又成功 Running 一个pod
info-ad-service-79fc9796df-thwhl            0/1     Terminating         0          11m
info-ad-service-79fc9796df-thwhl            0/1     Terminating         0          11m
info-ad-service-79fc9796df-zd6rt            1/1     Terminating         0          11m    # 删除一个 pod, 这个速率我们可以通过属性控制
info-ad-service-5bf7f4c8dc-vz8bx            0/1     Pending             0          4s
info-ad-service-5bf7f4c8dc-vz8bx            0/1     Pending             0          6s
info-ad-service-5bf7f4c8dc-vz8bx            0/1     ContainerCreating   0          8s
info-ad-service-5bf7f4c8dc-vz8bx            0/1     ContainerCreating   0          19s
info-ad-service-79fc9796df-zd6rt            0/1     Terminating         0          12m
info-ad-service-79fc9796df-zd6rt            0/1     Terminating         0          12m
info-ad-service-79fc9796df-zd6rt            0/1     Terminating         0          12m
info-ad-service-5bf7f4c8dc-vz8bx            1/1     Running             0          48s
info-ad-service-79fc9796df-6kjkv            1/1     Terminating         0          47m
info-ad-service-79fc9796df-6kjkv            0/1     Terminating         0          47m
info-ad-service-79fc9796df-6kjkv            0/1     Terminating         0          47m
info-ad-service-79fc9796df-6kjkv            0/1     Terminating         0          47m

# 滚动过程中 可以使用rollout status查看滚动升级的状态，执行效果类似于watch命令
➜  kubectl rollout status deploy/info-ad-service
Waiting for deployment "info-ad-service" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "info-ad-service" rollout to finish: 1 old replicas are pending termination...
deployment "info-ad-service" successfully rolled out

# 滚动升级完成后, 我们可以查看这个deployment的版本
➜  kubectl rollout history deployment/info-ad-service
deployment.apps/info-ad-service
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deploy/info-ad-service info-ad-service=reg.test.local/library/info-ad-service:0.0.2 --record=true    # 当时使用--record记录下来的命令
```

### 2.2、使用yaml文件进行滚动升级

``` zsh
# 使用python脚本自动生成所有的yaml文件
➜  cd /root/iKubernetes/info
➜  python3 Auto_Create_K8S_YAML.py

请输入要生成的tag: 0.0.2

0.0.2/info-gateway_svc.yaml: Success!
0.0.2/info-gateway_deploy.yaml: Success!
0.0.2/info-admin_svc.yaml: Success!
0.0.2/info-admin_deploy.yaml: Success!
...

# 滚动升级所有的deployment
➜  cd 0.0.2/
➜  kubectl apply -f . --record

# 验证升级后的版本
➜  kubectl rollout history deployment info-admin
deployment.apps/info-admin
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl apply --filename=. --record=true
➜  kubectl rollout history deployment info-payment-service
deployment.apps/info-payment-service
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl apply --filename=. --record=true
```

## 三、回滚

### 3.1、回滚Usage

``` zsh
Usage:
  kubectl rollout undo (TYPE NAME | TYPE/NAME) [flags] [options]

Options:
      --to-revision=0: The revision to rollback to. Default to 0 (last revision).
```

### 3.2、开始回滚

``` zsh
➜  kubectl rollout undo deploy/info-ad-service
deployment.apps/info-ad-service rolled back

➜  kubectl rollout status deploy/info-ad-service
Waiting for deployment "info-ad-service" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "info-ad-service" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "info-ad-service" rollout to finish: 1 old replicas are pending termination...
deployment "info-ad-service" successfully rolled out
```
