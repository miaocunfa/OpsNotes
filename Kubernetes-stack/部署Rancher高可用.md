---
title: "部署Rancher高可用"
date: "2020-07-10"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "Rancher"
toc: false
indent: false
original: true
---

## 1、环境

| Service Name | Version |
| ------------ | ------- |
| Helm         | v3.2.4  |
| Rancher      | 2.4.5   |
| CentOS       | 7.6     |
| Kubernetes   | 1.16.10 |

## 2、Helm 准备

``` zsh
# 添加 helm repo
➜  helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

# repo 列表
➜  helm repo list
NAME              URL
loki              https://grafana.github.io/loki/charts
stable            https://kubernetes-charts.storage.googleapis.com
aliyuncs          https://apphub.aliyuncs.com
bitnami           https://charts.bitnami.com/bitnami
rancher-stable    https://releases.rancher.com/server-charts/stable

# 搜索 Rancher
➜  helm search repo rancher
NAME                      CHART VERSION    APP VERSION    DESCRIPTION
rancher-stable/rancher    2.4.5            v2.4.5         Install Rancher Server to manage Kubernetes clu...
```

## 3、K8S 资源准备

``` zsh
# 创建名称空间
➜  kubectl create namespace cattle-system
```

## 4、SSL 选项

有三种关于证书来源的推荐选项，证书将用来在 Rancher Server 中终止 TLS：

- Rancher 生成的自签名证书： 在这种情况下，您需要在集群中安装 `cert-manager`。 Rancher 利用 `cert-manager`签发并维护证书。Rancher 将生成自己的 CA 证书，并使用该 CA 签署证书。然后，`cert-manager`负责管理该证书。
- Let's Encrypt： Let's Encrypt 选项也需要使用 `cert-manager`。但是，在这种情况下，`cert-manager`与特殊的 Issuer 结合使用，`cert-manager`将执行获取 Let's Encrypt 发行的证书所需的所有操作（包括申请和验证）。此配置使用 HTTP 验证（HTTP-01），因此负载均衡器必须具有可以从公网访问的公共 DNS 记录。
- 使用您自己的证书： 此选项使您可以使用自己的权威 CA 颁发的证书或自签名 CA 证书。 Rancher 将使用该证书来保护 WebSocket 和 HTTPS 流量。在这种情况下，您必须上传名称分别为 `tls.crt` 和 `tls.key` 的 PEM 格式的证书以及相关的密钥。如果使用私有 CA，则还必须上传该证书。这是由于您的节点可能不信任此私有 CA。 Rancher 将获取该 CA 证书，并从中生成一个校验和，各种 Rancher 组件将使用该校验和来验证其与 Rancher 的连接。

| 设置                     | Chart 选项                     | 描述                                                  | 是否需要 cert-manager |
| ------------------------ | ------------------------------ | ----------------------------------------------------- | --------------------- |
| Rancher 生成的自签名证书 | ingress.tls.source=rancher     | 使用 Rancher 生成的 CA 签发的自签名证书此项为默认选项 | 是                    |
| Let’s Encrypt            | ingress.tls.source=letsEncrypt | 使用Let's Encrypt颁发的证书                           | 是                    |
| 您已有的证书             | ingress.tls.source=secret      | 使用您的自己的证书（Kubernetes 密文）                 | 否                    |

## 5、安装 Rancher

使用 `ingress.tls.source=secret` 方式安装

在此选项中，将使用您自己的证书来创建 Kubernetes 密文，以供 Rancher 使用。

### 5.1、添加TLS密文

当您运行此命令时，hostname选项必须与服务器证书中的Common Name或Subject Alternative Names条目匹配，否则 Ingress 控制器将无法正确配置。
尽管技术上仅需要Subject Alternative Names中有一个条目，但是拥有一个匹配的 Common Name 可以最大程度的提高与旧版浏览器/应用程序的兼容性。

如果您使用的是私有 CA，Rancher 需要您提供 CA 证书的副本，用来校验 Rancher Agent 与 Server 的连接。
拷贝 CA 证书到名为 `cacerts.pem` 的文件，使用 kubectl 命令在 cattle-system 命名空间中创建名为 `tls-ca` 的密文。

``` zsh
➜  cp /etc/kubernetes/pki/ca.crt /root/iKubernetes/Helm-Chart/rancher/cacerts.pem

➜  kubectl -n cattle-system create secret generic tls-ca \
      --from-file=/root/iKubernetes/Helm-Chart/rancher/cacerts.pem
```

### 5.2、安装

- 设置 `hostname`。
- 将 `ingress.tls.source` 选项设置为 `secret`。
- 如果您在安装 alpha 版本，需要把 `--devel` 选项添加到下面到 Helm 命令中。
- 如果您使用的是私有 CA 证书，请在命令中增加 `--set privateCA=true`

``` zsh
➜  helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set ingress.tls.source=secret \
  --set privateCA=true
```

## 6、验证 Rancher

``` zsh
# 查看升级状态
➜  kubectl -n cattle-system rollout status deploy/rancher
Waiting for deployment "rancher" rollout to finish: 0 of 3 updated replicas are available...

# 查看 deployment 的状态
➜  kubectl -n cattle-system get deploy rancher
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
rancher   0/3     3            0           80s

# 获取pods
➜  kubectl get pods -n cattle-system
NAME                      READY   STATUS              RESTARTS   AGE
rancher-8b6574f7f-857qn   0/1     ContainerCreating   0          107s
rancher-8b6574f7f-zgvwk   0/1     ContainerCreating   0          107s
rancher-8b6574f7f-zj2xc   0/1     ContainerCreating   0          107s

# 镜像还没拉完
➜  kubectl describe pods -n cattle-system rancher-8b6574f7f-857qn
Events:
  Type    Reason     Age        From               Message
  ----    ------     ----       ----               -------
  Normal  Scheduled  <unknown>  default-scheduler  Successfully assigned cattle-system/rancher-8b6574f7f-857qn to node237
  Normal  Pulling    2m8s       kubelet, node237   Pulling image "rancher/rancher:v2.4.5"
```

## 7、关于镜像问题

镜像下载太费劲了

``` zsh
➜  docker pull rancher/rancher:v2.4.5
➜  docker tag rancher/rancher:v2.4.5 reg.test.local/library/rancher:v2.4.5
➜  docker push reg.test.local/library/rancher:v2.4.5

# 使用 helm 时命令
➜  helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.my.org \
  --set ingress.tls.source=secret \
  --set privateCA=true \
  --set rancherImage=reg.test.local/library/rancher:v2.4.5
```

> 参考链接:  
> 1、<https://rancher2.docs.rancher.cn/docs/installation/k8s-install/helm-rancher/_index>  
> 2、<https://rancher2.docs.rancher.cn/docs/installation/options/tls-secrets/_index/>  
>