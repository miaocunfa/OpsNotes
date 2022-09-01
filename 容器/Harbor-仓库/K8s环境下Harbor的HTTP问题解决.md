---
title: "K8s环境下 Harbor的 HTTP问题解决"
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

``` zsh
# k8s pods 无法拉取镜像
➜  kubectl describe pods enterprise-customer-6d575894f6-z5pwz
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  73s                default-scheduler  Successfully assigned default/enterprise-customer-6d575894f6-z5pwz to test-k8s-node01
  Normal   Pulling    51s (x2 over 73s)  kubelet            Pulling image "172.31.229.139:9999/test-dec/enterprise-customer:5"
  Warning  Failed     13s (x2 over 65s)  kubelet            Failed to pull image "172.31.229.139:9999/test-dec/enterprise-customer:5": rpc error: code = Unknown desc = failed to pull and unpack image "172.31.229.139:9999/test-dec/enterprise-customer:5": failed to resolve reference "172.31.229.139:9999/test-dec/enterprise-customer:5": unexpected status code [manifests 5]: 401 Unauthorized
  Warning  Failed     13s (x2 over 65s)  kubelet            Error: ErrImagePull
  Normal   BackOff    2s (x2 over 65s)   kubelet            Back-off pulling image "172.31.229.139:9999/test-dec/enterprise-customer:5"
  Warning  Failed     2s (x2 over 65s)   kubelet            Error: ImagePullBackOff

# 在 node节点 也无法通过 crictl拉取镜像
➜  crictl pull 172.31.229.139:9999/test-dec/enterprise-customer:5
FATA[0000] pulling image: rpc error: code = Unknown desc = failed to pull and unpack image "172.31.229.139:9999/test-dec/enterprise-customer:5": failed to resolve reference "172.31.229.139:9999/test-dec/enterprise-customer:5": unexpected status code [manifests 5]: 401 Unauthorized
```

## 解决

先在 node节点配置 /etc/containerd/config.toml文件, 并重启 containerd服务

``` zsh
➜  vim /etc/containerd/config.toml
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry.cn-hangzhou.aliyuncs.com"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."172.31.229.139:9999"]
          endpoint = ["http://172.31.229.139:9999"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."172.31.229.139:9999".tls]
          insecure_skip_verify = true
        [plugins."io.containerd.grpc.v1.cri".registry.configs."172.31.229.139:9999".auth]
          username = "admin"
          password = "gjr@@#$$Test@@"

➜  systemctl restart containerd
```

## 重新

在 node节点拉取镜像，已经成功拉取镜像到本地

``` zsh
➜  crictl pull 172.31.229.139:9999/test-dec/enterprise-customer:5
Image is up to date for sha256:cf006fa4486a1e2589fb859fa54ab42033d2170e2be954eac1cb4847f1a3c654

➜  crictl images
IMAGE                                                                          TAG                 IMAGE ID            SIZE
172.31.229.139:9999/test-dec/enterprise-customer                               5                   cf006fa4486a1       157MB
```

在 k8s删除配置文件，重新尝试拉取镜像

``` zsh
➜  kubectl delete -f .
➜  kubectl apply -f .
➜  kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
enterprise-customer-646b6fc476-gz5lp    1/1     Running   0          4m15s
enterprise-equipment-6c4cd56976-9c29h   1/1     Running   0          4m15s
enterprise-gateway-6bb8797788-gcp99     1/1     Running   0          4m15s
enterprise-mall-7749894886-s59ds        1/1     Running   0          4m15s
enterprise-message-84cbc7cf5f-sww2r     1/1     Running   0          4m15s
enterprise-user-f45b45c9-dbld7          1/1     Running   0          4m15s
enterprise-work-d7fddc8d5-ghkbx         1/1     Running   0          4m15s
```

> 参考文章：  
>
> - [github - containerd配置](https://github.com/containerd/containerd/blob/main/docs/cri/registry.md)  
> - [Kubernetes with containerd : http: server gave HTTP response to HTTPS client](https://stackoverflow.com/questions/65724285/kubernetes-with-containerd-http-server-gave-http-response-to-https-client)  
>