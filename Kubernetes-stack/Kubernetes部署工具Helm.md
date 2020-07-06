---
title: "Kubernetes部署工具Helm"
date: "2020-07-06"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "Helm"
toc: false
indent: false
original: true
---

## 一、Helm安装

在[Helm Realese](https://github.com/helm/helm/releases)页面下载二进制文件，这里下载的v3.2.4版本，解压后将可执行文件helm拷贝到/usr/local/bin目录下即可，这样Helm客户端就在这台机器上安装完成了。

``` zsh
➜  wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
➜  tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
linux-amd64/
linux-amd64/helm
linux-amd64/README.md
linux-amd64/LICENSE
➜  cp linux-amd64/helm /usr/local/bin
```

## 二、常用命令

### 2.1、helm repo

#### 2.1.1、helm repo add

增加仓库，以下命令为增加helm官方stable仓库，命令中stable为仓库名称，链接为仓库的Chart清单文件地址。当增加仓库时，Helm会将仓库的Chart清单文件下载到本地并存放到Kubernetes中，以后helm search、install和pull等操作都通过仓库名称到Kubernetes中查找该仓库相关的Chart包。可以注意到官方的stable仓库的地址和Helm Hub地址是不同的，两者是独立存在的，stable仓库只是众多公共仓库之一，但是是Helm官方提供的。

``` zsh
➜  helm repo add stable https://kubernetes-charts.storage.googleapis.com
```

以下为几个常用的仓库的添加命令

``` zsh
➜  helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com
➜  helm repo add bitnami https://charts.bitnami.com/bitnami
➜  helm repo add aliyuncs https://apphub.aliyuncs.com
➜  helm repo add kong https://charts.konghq.com
```

#### 2.1.2、helm repo list

``` zsh
helm repo list
NAME    URL
loki    https://grafana.github.io/loki/charts
stable  https://kubernetes-charts.storage.googleapis.com
```

Helm v3 取消了 v2 的 local repo，Helm v3 本地增加的仓库列表存放在 /root/.config/helm/repositories.yaml

``` zsh
➜  cat /root/.config/helm/repositories.yaml
apiVersion: ""
generated: "0001-01-01T00:00:00Z"
repositories:
- caFile: ""
  certFile: ""
  insecure_skip_tls_verify: false
  keyFile: ""
  name: loki
  password: ""
  url: https://grafana.github.io/loki/charts
  username: ""
- caFile: ""
  certFile: ""
  insecure_skip_tls_verify: false
  keyFile: ""
  name: stable
  password: ""
  url: https://kubernetes-charts.storage.googleapis.com
  username: ""
```

仓库的Chart清单应该是存储在Kubernetes的etcd中，但在/root/.cache/helm/repository存储了备份。下载的Chart包也缓存在该目录下。

``` zsh
➜  ls -rtl /root/.cache/helm/repository
total 112
-rw-r--r--. 1 root root 98768 Jul  6 14:45 loki-index.yaml
-rw-r--r--. 1 root root    36 Jul  6 14:45 loki-charts.txt
-rw-r--r--. 1 root root  6383 Jul  6 15:24 loki-0.30.1.tgz
```

### 2.2、helm search

查询Chart包，查询命令分为helm search hub和helm search repo。

+ helm search hub，只从Helm Hub中查找Chart，这些Chart来自于注册到Helm Hub中的各个仓库。

+ helm search repo，从所有加到本地的仓库中查找应用，这些仓库加到本地时Chart清单文件已被存放到Kubernetes中，所以查找应用时无需联网。

#### 2.2.1、helm search hub

``` zsh
➜  helm search hub loki
URL         CHART VERSION    APP VERSION    DESCRIPTION
https://hub.helm.sh/charts/t3n/loki     1.0.0            1.5.0
https://hub.helm.sh/charts/loki/fluent-bit            0.1.4            v1.5.0         Uses fluent-bit Loki go plugin for gathering lo...
https://hub.helm.sh/charts/loki/loki    0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/loki/loki-stack            0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/loki/promtail0.23.2           v1.5.0         Responsible for gathering logs and sending them...
https://hub.helm.sh/charts/banzaicloud-stable/n...    2.5.0            2.5.0          A Demo application for the logging-operator
https://hub.helm.sh/charts/banzaicloud-stable/loki    0.17.4           v1.3.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/choerodon/loki             0.29.0           v1.5.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/choerodon/promtail         0.23.0           v1.5.0         Responsible for gathering logs and sending them...
```

#### 2.2.2、helm search repo

``` zsh
➜  helm search repo loki
NAME CHART VERSION    APP VERSION    DESCRIPTION
loki/loki          0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/fluent-bit    0.1.4            v1.5.0         Uses fluent-bit Loki go plugin for gathering lo...
loki/promtail      0.23.2           v1.5.0         Responsible for gathering logs and sending them...
```

##### 查找特定版本

``` zsh
➜  helm search repo loki --version '0.30.1'
NAME         CHART VERSION    APP VERSION    DESCRIPTION
loki/loki    0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
```

##### 查询所有chart版本

``` zsh
➜  helm search repo loki --versions
NAME CHART VERSION    APP VERSION    DESCRIPTION
loki/loki          0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.30.0           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.29.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.29.0           v1.5.0         Loki: like Prometheus, but for logs.
...
loki/loki          0.7.2            0.0.1          Loki: like Prometheus, but for logs.
loki/loki          0.7.1            0.0.1          Loki: like Prometheus, but for logs.
loki/loki          0.7.0            0.0.1          Loki: like Prometheus, but for logs.
loki/loki          0.6.0            0.0.1          Loki: like Prometheus, but for logs.
loki/loki          0.5.0            0.0.1          Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.0           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.37.4           v1.5.0         Loki: like Prometheus, but for logs.
...
loki/loki-stack    0.31.2           v1.3.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.31.1           v1.3.0         Loki: like Prometheus, but for logs.
...
loki/fluent-bit    0.0.4            v0.0.1         Uses fluent-bit Loki go plugin for gathering lo...
loki/fluent-bit    0.0.3            v0.0.1         Uses fluent-bit Loki go plugin for gathering lo...
loki/fluent-bit    0.0.2            v0.0.1         Uses fluent-bit Loki go plugin for gathering lo...
loki/fluent-bit    0.0.1            v0.0.1         Uses fluent-bit Loki go plugin for gathering lo...
loki/promtail      0.23.2           v1.5.0         Responsible for gathering logs and sending them...
loki/promtail      0.23.1           v1.5.0         Responsible for gathering logs and sending them...
loki/promtail      0.23.0           v1.5.0         Responsible for gathering logs and sending them...
loki/promtail      0.22.2           v1.4.1         Responsible for gathering logs and sending them...
...
loki/promtail      0.6.1            0.0.1          Responsible for gathering logs and sending them...
loki/promtail      0.6.0            0.0.1          Responsible for gathering logs and sending them...
```

##### 按范围查找

``` zsh
➜  helm search repo loki --version '>=0.20.0' --versions
NAME               CHART VERSION    APP VERSION    DESCRIPTION
loki/loki          0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.30.0           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.29.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki          0.29.0           v1.5.0         Loki: like Prometheus, but for logs.
...
loki/loki          0.20.0           v1.1.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.0           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.37.4           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.37.3           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.37.2           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.37.1           v1.5.0         Loki: like Prometheus, but for logs.
...
loki/loki-stack    0.24.0           v1.2.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.23.0           v1.2.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.22.0           v1.1.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.21.0           v1.0.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.20.0           v1.0.0         Loki: like Prometheus, but for logs.
loki/promtail      0.23.2           v1.5.0         Responsible for gathering logs and sending them...
loki/promtail      0.23.1           v1.5.0         Responsible for gathering logs and sending them...
loki/promtail      0.23.0           v1.5.0         Responsible for gathering logs and sending them...
...
loki/promtail      0.20.0           v1.4.0         Responsible for gathering logs and sending them...
```

### 2.3、helm pull

#### 2.3.1、默认下载

将Chart包下载到本地，缺省下载的是最新的Chart版本，并且是tgz包。

``` zsh
# 搜索loki版本
➜  helm search repo loki
NAME               CHART VERSION    APP VERSION    DESCRIPTION
loki/loki          0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/loki-stack    0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
loki/fluent-bit    0.1.4            v1.5.0         Uses fluent-bit Loki go plugin for gathering lo...
loki/promtail      0.23.2           v1.5.0         Responsible for gathering logs and sending them...

# 下载最新版
➜  helm pull loki/loki

# 默认下到当前路径
➜  ll
-rw-r--r--.  1 root root      6383 Jul  6 17:41 loki-0.30.1.tgz

# 解压Chart
➜  tar -zxvf loki-0.30.1.tgz

# Chart目录结构
➜  tree loki
loki
├── Chart.yaml
├── README.md
├── templates
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── networkpolicy.yaml
│   ├── NOTES.txt
│   ├── pdb.yaml
│   ├── podsecuritypolicy.yaml
│   ├── rolebinding.yaml
│   ├── role.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── service-headless.yaml
│   ├── servicemonitor.yaml
│   ├── service.yaml
│   └── statefulset.yaml
└── values.yaml

1 directory, 17 files
```

#### 2.3.2、下拉指定版本

``` zsh
➜  helm pull loki/loki --version 0.30.0
➜  ll loki*
-rw-r--r--. 1 root root  6364 Jul  6 17:45 loki-0.30.0.tgz
-rw-r--r--. 1 root root  6383 Jul  6 17:41 loki-0.30.1.tgz
-rw-r--r--. 1 root root 60953 Jul  6 17:36 loki-stack-0.38.1.tgz
```

#### 2.3.3、下拉Chart包后直接解压为目录，而不是tgz包

``` zsh
➜  helm pull loki/promtail --untar
➜  ll
drwxr-xr-x.  3 root root        96 Jul  6 17:46 promtail
```

#### 2.3.4、直接从URL下拉Chart包

``` zsh
➜  helm pull https://kubernetes-charts.storage.googleapis.com/coredns-1.1.3.tgz
ll
-rw-r--r--.  1 root root      5825 Jul  6 17:48 coredns-1.1.3.tgz
```

#### 2.3.5、下载Chart包到指定路径

``` zsh
➜  mkdir Helm-Chart
➜  mv loki*tgz Helm-Chart/; mv coredns-1.1.3.tgz Helm-Chart/

➜  helm pull loki/promtail -d Helm-Chart
➜  cd Helm-Chart/
➜  ll
total 92
-rw-r--r--. 1 root root  5825 Jul  6 17:48 coredns-1.1.3.tgz
-rw-r--r--. 1 root root  6364 Jul  6 17:45 loki-0.30.0.tgz
-rw-r--r--. 1 root root  6383 Jul  6 17:41 loki-0.30.1.tgz
-rw-r--r--. 1 root root 60953 Jul  6 17:36 loki-stack-0.38.1.tgz
-rw-r--r--. 1 root root  6569 Jul  6 17:53 promtail-0.23.2.tgz
```

### 2.4、helm install

> 参考链接:  
> 1、<https://blog.csdn.net/twingao/article/details/104282223>  
> 2、<https://www.qikqiak.com/post/use-loki-monitor-alert/>
>