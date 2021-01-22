---
title: "Kubernetes部署工具Helm之常用操作(一)"
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
draft: false
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
URL                                                   CHART VERSION    APP VERSION    DESCRIPTION
https://hub.helm.sh/charts/t3n/loki                   1.0.0            1.5.0
https://hub.helm.sh/charts/loki/fluent-bit            0.1.4            v1.5.0         Uses fluent-bit Loki go plugin for gathering lo...
https://hub.helm.sh/charts/loki/loki                  0.30.1           v1.5.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/loki/loki-stack            0.38.1           v1.5.0         Loki: like Prometheus, but for logs.
https://hub.helm.sh/charts/loki/promtail              0.23.2           v1.5.0         Responsible for gathering logs and sending them...
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
└── values.yaml    # 修改values.yaml

1 directory, 17 files
```

#### 2.3.2、下拉指定版本

``` zsh
➜  helm pull loki/loki --version 0.29.1
➜  ll loki*

-rw-r--r--. 1 root root  6383 Jul  6 17:41 loki-0.30.1.tgz
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
➜  mv loki*tgz Helm-Chart/

➜  helm pull loki/promtail -d Helm-Chart
➜  cd Helm-Chart/
➜  ll
total 92
-rw-r--r--. 1 root root  5794 Jul  7 09:03 loki-0.29.1.tgz
-rw-r--r--. 1 root root  6383 Jul  6 17:41 loki-0.30.1.tgz
-rw-r--r--. 1 root root  6569 Jul  6 17:53 promtail-0.23.2.tgz
```

### 2.4、helm install

有五种安装Chart的方式

``` log
    1、Chart Reference:              helm install myweb stable/tomcat
    2、Chart 包路径:                  helm install myweb ./tomcat-0.4.1.tgz
    3、Chart 包目录:                  helm install myweb ./tomcat
    4、URL 绝对路径:                  helm install myweb https://kubernetes-charts.storage.googleapis.com/tomcat-0.4.1.tgz
    5、仓库URL 和 Chart Reference:    helm install --repo https://kubernetes-charts.storage.googleapis.com myweb tomcat

    Chart Reference表示为[Repository]/[Chart]，如stable/tomcat，Helm将在本地配置中查找名为stable的Chart仓库，然后在该仓库中查找名为tomcat的Chart。
```

#### 2.4.1、values

安装应用时，如果要覆盖Chart中的值，可以使用`--set`选项并从命令行传递配置。
若要强制`--set`指定的值为字符串，请使用`--set-string`
`--set`和`--set-string`支持重复配置，后面(右边)的值优先级更高。

``` zsh
➜  helm install myweb aliyuncs/tomcat \
  --set service.type=NodePort \
  --set persistence.enabled=false
```

也可以将key=values对配置在文件中，可以通过`-f`或者`--values`指定覆盖的values文件。`-f`或者`--values`支持重复指定，后面(右边)的值优先级更高。

``` zsh
➜  helm install myweb aliyuncs/tomcat -f ./values.yaml
```

如果一个值很大或者占用多行，很难使用`--values`或`--set`，可以使用`--set-file`从文件中读取单个大值。

``` zsh
➜  helm install myweb aliyuncs/tomcat \
  --set-file podAnnotations=./tomcat-annotations.yaml
```

#### 2.4.2、默认安装

安装应用，也就是部署Chart Release实例。缺省安装最新Chart版本。其中myweb为Release名称，–set配置会覆盖Chart的value

``` zsh
# 安装一个tomcat，并设置服务为NodePort类型
➜  helm install myweb stable/tomcat --set service.type=NodePort
NAME: myweb
LAST DEPLOYED: Tue Jul  7 09:36:01 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services myweb-tomcat)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT


# helm Release
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                   STATUS      CHART           APP VERSION
myweb    default      1           2020-07-07 09:36:01.74332018 +0800 CST    deployed    tomcat-0.4.1    7.0

# Kubernetes资源
➜  kubectl get pods
myweb-tomcat-5957c766b4-lxrsb               1/1     Running   0          4m25s

➜  kubectl get rs
myweb-tomcat-5957c766b4               1         1         1       12m

➜  kubectl get deploy
myweb-tomcat               1/1     1            1           10m

➜  kubectl get svc
myweb-tomcat             NodePort    10.96.247.134   <none>        80:30827/TCP                                                                       4m57s



# 访问tomcat，或可访问svc地址
➜  kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services myweb-tomcat
30827
➜  kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}"
192.168.100.236
➜  curl 192.168.100.236:30827/sample/index.html
<html>
<head>
<title>Sample "Hello, World" Application</title>
</head>
<body bgcolor=white>

<table border="0">
<tr>
<td>
<img src="images/tomcat.gif">
</td>
<td>
<h1>Sample "Hello, World" Application</h1>
<p>This is the home page for a sample application used to illustrate the
source directory organization of a web application utilizing the principles
outlined in the Application Developer's Guide.
</td>
</tr>
</table>

<p>To prove that they work, you can execute either of the following links:
<ul>
<li>To a <a href="hello.jsp">JSP page</a>.
<li>To a <a href="hello">servlet</a>.
</ul>

</body>
</html>
```

#### 2.4.3、指定版本

``` zsh
➜  helm install myweb-605 aliyuncs/tomcat --version 6.0.5
```

#### 2.4.4、指定名称空间

``` zsh
➜  kubectl create namespace helm-test

➜  helm install myweb-ns aliyuncs/tomcat -n helm-test

➜  helm list -n helm-test
NAME        NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb-ns    helm-test    1           2020-07-07 10:51:49.809646948 +0800 CST    deployed    tomcat-6.2.3    9.0.31
```

#### 2.4.5、--dry-run

通过`--dry-run`模拟安装应用，会输出每个模板生成的yaml内容，可查看将要部署的渲染后的yaml，检视这些输出，判断是否与预期相符。

``` zsh
➜  helm install myweb-dr aliyuncs/tomcat \
>   --dry-run \
>   --set service.type=NodePort
NAME: myweb-dr
LAST DEPLOYED: Tue Jul  7 13:20:20 2020
NAMESPACE: default
STATUS: pending-install
REVISION: 1
TEST SUITE: None
HOOKS:
MANIFEST:
---
# Source: tomcat/templates/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: myweb-dr-tomcat
  labels:
    app: tomcat
    chart: tomcat-6.2.3
    release: myweb-dr
    heritage: Helm
type: Opaque
data:
  tomcat-password: "RklGQTBvN0RWYQ=="
---
# Source: tomcat/templates/pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: myweb-dr-tomcat
  labels:
    app: tomcat
    chart: tomcat-6.2.3
    release: myweb-dr
    heritage: Helm
  annotations:
    volume.alpha.kubernetes.io/storage-class: default
spec:
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: "8Gi"
---
# Source: tomcat/templates/svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-dr-tomcat
  labels:
    app: tomcat
    chart: tomcat-6.2.3
    release: myweb-dr
    heritage: Helm
spec:
  type: NodePort
  externalTrafficPolicy: "Cluster"
  ports:
    - name: http
      port: 80
      targetPort: http
  selector:
    app: tomcat
    release: myweb-dr
---
# Source: tomcat/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myweb-dr-tomcat
  labels:
    app: tomcat
    chart: tomcat-6.2.3
    release: myweb-dr
    heritage: Helm
spec:
  strategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: tomcat
      release: myweb-dr
  template:
    metadata:
      labels:
        app: tomcat
        chart: tomcat-6.2.3
        release: myweb-dr
        heritage: Helm
    spec:
      securityContext:
        fsGroup: 1001
        runAsUser: 1001
      containers:
        - name: tomcat
          image: docker.io/bitnami/tomcat:9.0.31-debian-10-r0
          imagePullPolicy: "IfNotPresent"
          env:
            - name: TOMCAT_USERNAME
              value: "user"
            - name: TOMCAT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: myweb-dr-tomcat
                  key: tomcat-password
            - name: TOMCAT_ALLOW_REMOTE_MANAGEMENT
              value: "0"
          ports:
            - name: http
              containerPort: 8080
          livenessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 120
            timeoutSeconds: 5
            failureThreshold: 6
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 30
            timeoutSeconds: 3
            periodSeconds: 51
          resources:
            limits: {}
            requests:
              cpu: 300m
              memory: 512Mi
          volumeMounts:
            - name: data
              mountPath: /bitnami/tomcat
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: myweb-dr-tomcat

NOTES:
** Please be patient while the chart is being deployed **

1. Get the Tomcat URL by running:

  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services myweb-dr-tomcat)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo http://$NODE_IP:$NODE_PORT/

2. Login with the following credentials

  echo Username: user
  echo Password: $(kubectl get secret --namespace default myweb-dr-tomcat -o jsonpath="{.data.tomcat-password}" | base64 --decode)
```

#### 2.4.6、--wait

通过设置`--wait`参数，将等待所有Pod、PVC和Service以及Deployment、StatefulSet和ReplicaSet的最小Pod数都处于就绪状态后，然后才将Release标记为deployed状态，然后install命令行返回成功。等待`--timeout`时间，`--timeout`缺省时间为5m0s。

``` zsh
# 等待超时过程中
# helm 安装命令会处于等待中
➜  helm install myweb-time aliyuncs/tomcat \
  --wait \
  --set service.type=NodePort

# 获取 K8S 资源, Pending状态
➜  kubectl get pods
myweb-time-tomcat-7676cb74c7-59564          0/1     Pending   0          44s

# helm list不展示这个Release, 需要加-a选项, Release处于pending-install状态
➜  helm list -a
myweb-time    default      1           2020-07-07 13:25:24.577131774 +0800 CST    pending-install    tomcat-6.2.3    9.0.31


# 等待5分钟超时以后
# helm 安装命令返回错误
➜  helm install myweb-time aliyuncs/tomcat --wait --set service.type=NodePort
Error: timed out waiting for the condition

# 命令行返回 1
➜  echo $?
1

# 获取 K8S 资源
➜  kubectl get pods
myweb-time-tomcat-7676cb74c7-59564          0/1     Pending   0          5m13s

# 这次执行helm list直接就列出来了, 状态为failed
➜  helm list
myweb-time    default      1           2020-07-07 13:25:24.577131774 +0800 CST    failed      tomcat-6.2.3    9.0.31
```

设置`--timeout`参数，缺省为5m0s。如果超过`--timeout`还没有就绪，Release状态将被标记为failed，命令行返回值为1，但并不会回退提交给Kubernetes的资源，所以安装不一定失败。如下载镜像时间过长，Release的状态被置为failed，但Kubernetes仍在会继续下载镜像，所以安装最终会成功，但Release不会被重置为deployed。没有找到修改Release状态的命令。

``` zsh
➜  helm install myweb-time-1m aliyuncs/tomcat \
  --wait --timeout 1m \
  --set service.type=NodePort
```

#### 2.4.7、 --atomic

设置`--atomic`参数，如果安装失败，会自动清除Chart，相当于如果状态为failed时会回退所有操作，保持安装的原子性。当设置`--atomic`参数时，`--wait`参数会自动配置。

``` zsh
➜  helm install myweb-atomic aliyuncs/tomcat \
  --atomic --timeout 1m \
  --set service.type=NodePort

➜  kubectl get pods
myweb-atomic-tomcat-565799cd49-8qrvx        0/1     Pending   0          3s

➜  helm list -a
myweb-atomic     default      1           2020-07-07 13:43:05.862598049 +0800 CST    pending-install    tomcat-6.2.3    9.0.31

➜  helm install myweb-atomic aliyuncs/tomcat \
>   --atomic --timeout 1m \
>   --set service.type=NodePort
Error: release myweb-atomic failed, and has been uninstalled due to atomic being set: timed out waiting for the condition

➜  kubectl describe pods myweb-atomic-tomcat-565799cd49-8qrvx
Error from server (NotFound): pods "myweb-atomic-tomcat-565799cd49-8qrvx" not found
```

### 2.5、helm list

``` zsh
# 列出default命名空间的Release列表，只显示状态为deployed或failed的Release
➜  helm list
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed    tomcat-6.0.5    9.0.27
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# 列出某一命名空间的Release列表
➜  helm list -n helm-test
NAME        NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb-ns    helm-test    1           2020-07-07 10:51:49.809646948 +0800 CST    deployed    tomcat-6.2.3    9.0.31

# 列出所有命名空间的Release列表
➜  helm list --all-namespaces
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed    tomcat-6.0.5    9.0.27
myweb-ns         helm-test    1           2020-07-07 10:51:49.809646948 +0800 CST    deployed    tomcat-6.2.3    9.0.31
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# 列出所有的Release列表，不止包括状态为deployed或failed的Release
➜  helm ls -a
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS         CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed       tomcat-0.4.1    7.0
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed       tomcat-6.0.5    9.0.27
myweb-keep       default      1           2020-07-07 13:53:25.69436677 +0800 CST     uninstalled    tomcat-0.4.1    7.0
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed         tomcat-6.2.3    9.0.31

# 要想在helm list列出已卸载的版本, 需要在卸载的时候使用--keep-history选项, 下面会介绍
➜  helm list --uninstalled
NAME          NAMESPACE    REVISION    UPDATED                                   STATUS         CHART           APP VERSION
myweb-keep    default      1           2020-07-07 13:53:25.69436677 +0800 CST    uninstalled    tomcat-0.4.1    7.0

# 只列出Release名称
➜  helm list -q
myweb
myweb-605
myweb-time-1m

# 按时间顺序
➜  helm ls -d
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed    tomcat-6.0.5    9.0.27
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# 按时间反序
➜  helm ls -d -r
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed    tomcat-6.0.5    9.0.27
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
```

### 2.6、helm uninstall

#### 2.6.1、直接卸载

直接卸载后是没有这个Release状态的

``` zsh
# 列出所有Release
➜  helm ls
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-605        default      1           2020-07-07 10:48:55.063624358 +0800 CST    deployed    tomcat-6.0.5    9.0.27
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# helm 卸载
helm uninstall myweb-605
release "myweb-605" uninstalled

# helm list
➜  helm ls
NAME             NAMESPACE    REVISION    UPDATED                                   STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST    deployed    tomcat-0.4.1    7.0
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST    failed      tomcat-6.2.3    9.0.31

# 列出已经卸载的Release
➜  helm ls --uninstalled
NAME          NAMESPACE    REVISION    UPDATED                                   STATUS         CHART           APP VERSION
```

#### 2.6.2、--keep-history

``` zsh
# 安装一个tomcat
➜  helm install myweb-keep stable/tomcat --set service.type=NodePort

# helm list
➜  helm ls
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-keep       default      1           2020-07-07 13:53:25.69436677 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# 卸载使用--keep-history选项
➜  helm uninstall myweb-keep --keep-history
release "myweb-keep" uninstalled

# helm list
➜  helm ls
NAME             NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb            default      1           2020-07-07 09:36:01.74332018 +0800 CST     deployed    tomcat-0.4.1    7.0
myweb-time-1m    default      1           2020-07-07 13:38:40.40151403 +0800 CST     failed      tomcat-6.2.3    9.0.31

# 列出已经卸载的Release
➜  helm ls --uninstalled
NAME          NAMESPACE    REVISION    UPDATED                                   STATUS         CHART           APP VERSION
myweb-keep    default      1           2020-07-07 13:53:25.69436677 +0800 CST    uninstalled    tomcat-0.4.1    7.0
```

### 2.7、helm upgrade

升级Release到一个新的Chart版本；或者同一Chart版本，但更改values

``` zsh
# --install 选项的意思是, 如果Release存在就升级, 如果不存在就安装
➜  helm upgrade --install grafana stable/grafana -n loki-stack
Release "grafana" does not exist. Installing it now.    # Release不存在, 所以进行安装
NAME: grafana
LAST DEPLOYED: Tue Jul  7 17:51:36 2020
NAMESPACE: loki-stack
STATUS: deployed
REVISION: 1    # REVISION为1

➜  kubectl get svc -n loki-stack
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
grafana         ClusterIP   10.96.158.184   <none>        80/TCP     6m22s    # Service类型为ClusterIP
loki            ClusterIP   10.96.115.99    <none>        3100/TCP   21m
loki-headless   ClusterIP   None            <none>        3100/TCP   21m

# 升级版本, Release名字不变, 修改service.type为NodePort
➜  helm upgrade --install grafana stable/grafana -n loki-stack --set service.type=NodePort
Release "grafana" has been upgraded. Happy Helming!
NAME: grafana
LAST DEPLOYED: Tue Jul  7 18:08:25 2020
NAMESPACE: loki-stack
STATUS: deployed
REVISION: 2    # REVISION为2

# 成功修改service类型为NodePort
➜  kubectl get svc -n loki-stack
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
grafana         NodePort    10.96.158.184   <none>        80:31067/TCP   20m
loki            ClusterIP   10.96.115.99    <none>        3100/TCP       35m
loki-headless   ClusterIP   None            <none>        3100/TCP       35m

# 查看helm版本
➜  helm history grafana -n loki-stack
REVISION    UPDATED                     STATUS        CHART            APP VERSION    DESCRIPTION
1           Tue Jul  7 17:51:36 2020    superseded    grafana-5.3.4    7.0.3          Install complete
2           Tue Jul  7 18:08:25 2020    deployed      grafana-5.3.4    7.0.3          Upgrade complete
```

### 2.8、helm status

显示Release的状态

``` zsh
➜  helm status grafana -n loki-stack
NAME: grafana
LAST DEPLOYED: Tue Jul  7 18:08:25 2020
NAMESPACE: loki-stack
STATUS: deployed
REVISION: 2
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace loki-stack grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.loki-stack.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
export NODE_PORT=$(kubectl get --namespace loki-stack -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
     export NODE_IP=$(kubectl get nodes --namespace loki-stack -o jsonpath="{.items[0].status.addresses[0].address}")
     echo http://$NODE_IP:$NODE_PORT


3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################
```

显示Release的某个修订版本的状态

``` zsh
➜  helm status grafana -n loki-stack --revision 1
NAME: grafana
LAST DEPLOYED: Tue Jul  7 17:51:36 2020
NAMESPACE: loki-stack
STATUS: superseded
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace loki-stack grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.loki-stack.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:

     export POD_NAME=$(kubectl get pods --namespace loki-stack -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace loki-stack port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin
#################################################################################
######   WARNING: Persistence is disabled!!! You will lose your data when   #####
######            the Grafana pod is terminated.                            #####
#################################################################################
```

### 2.9、helm history

``` zsh
# 安装myweb
➜  helm install myweb stable/tomcat

# 查看helm Release列表
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      1           2020-07-07 19:59:00.668979152 +0800 CST    deployed    tomcat-0.4.1    7.0

# 删除myweb
➜  helm uninstall myweb --keep-history
release "myweb" uninstalled

# helm list不会显示卸载了但保留历史的Release
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION

# -a会显示卸载了但保留历史的Release  注意修订REVISION为1
➜  helm list -a
NAME          NAMESPACE    REVISION    UPDATED                                    STATUS         CHART              APP VERSION
myweb         default      1           2020-07-07 19:59:00.668979152 +0800 CST    uninstalled    tomcat-0.4.1       7.0

# 重新安装myweb
# 因为保留了这个Release, 所以直接install会报错
➜  helm install myweb stable/tomcat
Error: cannot re-use a name that is still in use
# 使用 --replace选项
➜  helm install myweb stable/tomcat --replace
NAME: myweb
LAST DEPLOYED: Tue Jul  7 20:03:23 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2    # REVISION修订为2

# helm list只显示生效的Release  
# 注意修订REVISION为2
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      2           2020-07-07 20:03:23.647690834 +0800 CST    deployed    tomcat-0.4.1    7.0

# 使用helm history展示Release的历史版本
➜  helm history myweb
REVISION    UPDATED                     STATUS        CHART           APP VERSION    DESCRIPTION
1           Tue Jul  7 19:59:00 2020    superseded    tomcat-0.4.1    7.0            superseded by new release
2           Tue Jul  7 20:03:23 2020    deployed      tomcat-0.4.1    7.0            Install complete
```

### 2.10、helm rollback

#### 2.10.1、升级

``` zsh
# 使用myweb这个Release
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      2           2020-07-07 20:03:23.647690834 +0800 CST    deployed    tomcat-0.4.1    7.0

➜  kubectl get pods
myweb-tomcat-5957c766b4-qdgmf               1/1     Running   0          7m22s

# myweb现在的service类型为LoadBalancer
➜  kubectl get svc
myweb-tomcat             LoadBalancer   10.96.147.119   <pending>     80:31148/TCP                                                                       6m41s


# 升级版本
# service类型为NodePort
➜  helm upgrade myweb stable/tomcat --set service.type=NodePort

# REVISION修订为3
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      3           2020-07-07 20:14:20.112163954 +0800 CST    deployed    tomcat-0.4.1    7.0

➜  kubectl get pods
myweb-tomcat-5957c766b4-qdgmf               1/1     Running   0          11m

# service类型已修改为NodePort
➜  kubectl get svc
myweb-tomcat             NodePort    10.96.147.119   <none>        80:31148/TCP                                                                       11m

# 查看helm Release历史
➜  helm history myweb
REVISION    UPDATED                     STATUS        CHART           APP VERSION    DESCRIPTION
1           Tue Jul  7 19:59:00 2020    superseded    tomcat-0.4.1    7.0            superseded by new release
2           Tue Jul  7 20:03:23 2020    superseded    tomcat-0.4.1    7.0            Install complete
3           Tue Jul  7 20:14:20 2020    deployed      tomcat-0.4.1    7.0            Upgrade complete
```

#### 2.10.2、默认回滚

``` zsh
# 回滚
# 回滚Release，没有指定修订版本，则回滚到上一个修订版本。
➜  helm rollback myweb
Rollback was a success! Happy Helming!

# helm Release列表REVISION修订为4
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      4           2020-07-08 09:06:06.639584596 +0800 CST    deployed    tomcat-0.4.1    7.0

# 可以看出回滚是按照Release重新安装，会生成新的修订版本。
➜  helm history myweb
REVISION    UPDATED                     STATUS        CHART           APP VERSION    DESCRIPTION
1           Tue Jul  7 19:59:00 2020    superseded    tomcat-0.4.1    7.0            superseded by new release
2           Tue Jul  7 20:03:23 2020    superseded    tomcat-0.4.1    7.0            Install complete
3           Tue Jul  7 20:14:20 2020    superseded    tomcat-0.4.1    7.0            Upgrade complete
4           Wed Jul  8 09:06:06 2020    deployed      tomcat-0.4.1    7.0            Rollback to 2

# 看Service，类型为LoadBalancer,确实回滚到前一个修订版本。
➜  kubectl get svc
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                            AGE
myweb-tomcat             LoadBalancer   10.96.147.119   <pending>     80:31148/TCP                                                                       13h
```

#### 2.10.3、回滚到指定版本

``` zsh
# REVISION3 是service 为NodePort的版本, 咱们指定回退到这个版本
➜  helm rollback myweb 3
Rollback was a success! Happy Helming!

# helm Release列表REVISION修订为5
➜  helm list
NAME     NAMESPACE    REVISION    UPDATED                                    STATUS      CHART           APP VERSION
myweb    default      5           2020-07-08 09:10:37.633028452 +0800 CST    deployed    tomcat-0.4.1    7.0

# 查看myweb的helm Release历史
➜  helm history myweb
REVISION    UPDATED                     STATUS        CHART           APP VERSION    DESCRIPTION
1           Tue Jul  7 19:59:00 2020    superseded    tomcat-0.4.1    7.0            superseded by new release
2           Tue Jul  7 20:03:23 2020    superseded    tomcat-0.4.1    7.0            Install complete
3           Tue Jul  7 20:14:20 2020    superseded    tomcat-0.4.1    7.0            Upgrade complete
4           Wed Jul  8 09:06:06 2020    superseded    tomcat-0.4.1    7.0            Rollback to 2
5           Wed Jul  8 09:10:37 2020    deployed      tomcat-0.4.1    7.0            Rollback to 3

# 查看service, 类型为NodePort, 确实回退到REVISION3了
➜  kubectl get svc
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                            AGE
myweb-tomcat             NodePort    10.96.147.119   <none>        80:31148/TCP                                                                       13h
```

#### 2.10.4、模拟回滚操作

``` zsh
# 模拟回滚是否成功
➜  helm rollback myweb --dry-run
Rollback was a success! Happy Helming!

# 版本并没有发生变化
➜  helm history myweb
REVISION    UPDATED                     STATUS        CHART           APP VERSION    DESCRIPTION
1           Tue Jul  7 19:59:00 2020    superseded    tomcat-0.4.1    7.0            superseded by new release
2           Tue Jul  7 20:03:23 2020    superseded    tomcat-0.4.1    7.0            Install complete
3           Tue Jul  7 20:14:20 2020    superseded    tomcat-0.4.1    7.0            Upgrade complete
4           Wed Jul  8 09:06:06 2020    superseded    tomcat-0.4.1    7.0            Rollback to 2
5           Wed Jul  8 09:10:37 2020    deployed      tomcat-0.4.1    7.0            Rollback to 3
```

> 参考链接:  
> 1、<https://blog.csdn.net/twingao/article/details/104282223>  
> 2、<https://www.qikqiak.com/post/use-loki-monitor-alert/>
>