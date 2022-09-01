---
title: "K8s环境下 Harbor的 Secret问题解决"
date: "2022-05-10"
categories:
    - "技术"
tags:
    - "harbor"
    - "kubernetes"
    - "容器化"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-05-10 | 初稿 |

## 问题

首先发现 deployment 无法拉取镜像

``` zsh
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  58s                default-scheduler  Successfully assigned default/enterprise-customer-6545b78b47-ngwdz to test-k8s-node01
  Warning  Failed     43s                kubelet            Failed to pull image "172.31.229.139:9999/test-dec/enterprise-customer:5": rpc error: code = Unknown desc = failed to pull and unpack image "172.31.229.139:9999/test-dec/enterprise-customer:5": failed to resolve reference "172.31.229.139:9999/test-dec/enterprise-customer:5": unexpected status code [manifests 5]: 401 Unauthorized
  Warning  Failed     43s                kubelet            Error: ErrImagePull
  Normal   BackOff    42s                kubelet            Back-off pulling image "172.31.229.139:9999/test-dec/enterprise-customer:5"
  Warning  Failed     42s                kubelet            Error: ImagePullBackOff
  Normal   Pulling    29s (x2 over 58s)  kubelet            Pulling image "172.31.229.139:9999/test-dec/enterprise-customer:5"
```

## 解决

以为是 secret 有问题，查看 secret 名字为 test-registry-secret

``` zsh
➜  kubectl get secrets test-registry-secret
NAME                   TYPE                             DATA   AGE
test-registry-secret   kubernetes.io/dockerconfigjson   1      123d
```

找到 secret 的创建脚本，发现密码能对上，接着又找其他的问题，找的头都大了。

``` zsh
➜  kubectl create secret docker-registry test-registry-secret \
  --docker-server=http://172.31.229.139:9999/ \
  --docker-username=admin \
  --docker-password=gjr@@#$$Test@@ \
  --docker-email=i@miaocf.com
```

最后将 secret 获取出 yaml来，base64 解密了一下

``` zsh
➜  kubectl get secrets test-registry-secret -o yaml
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwOi8vMTcyLjMxLjIyOS4xMzk6OTk5OS8iOnsidXNlcm5hbWUiOiJhZG1pbiIsInBhc3N3b3JkIjoiZ2pyQEAjMzgxNFRlc3RAQCIsImVtYWlsIjoiaUBtaWFvY2YuY29tIiwiYXV0aCI6IllXUnRhVzQ2WjJweVFFQWpNemd4TkZSbGMzUkFRQT09In19fQ==
kind: Secret
metadata:
  creationTimestamp: "2022-01-07T07:10:52Z"
  name: test-registry-secret
  namespace: default
  resourceVersion: "817597"
  uid: 8c880c4e-8160-4589-a7c5-f8c407e750f9
type: kubernetes.io/dockerconfigjson
```

发现密码根本就对不上, emmm...

``` zsh
{"auths":{"http://172.31.229.139:9999/":{"username":"admin","password":"gjr@@#3814Test@@","email":"i@miaocf.com","auth":"YWRtaW46Z2pyQEAjMzgxNFRlc3RAQA=="}}}
```

重新创建 Secret

``` zsh
➜  kubectl delete secret test-registry-secret

➜  kubectl create secret docker-registry harbor-test-secret \
  --docker-server=http://172.31.229.139:9999/ \
  --docker-username=admin \
  --docker-password=gjr@@#$$Test@@
```

修改 yaml中的 secret，重新拉起镜像

``` zsh
➜  vim enterprise-customer.yaml
       imagePullSecrets:
         - name: harbor-test-secret

➜  kubectl apply -f .
```

> 参考文章：  
>
> - [在线base64编码、解码](https://base64.us/)  
> - [k8s 配置 Secret 集成Harbor](https://zhuanlan.zhihu.com/p/506616957)  
>