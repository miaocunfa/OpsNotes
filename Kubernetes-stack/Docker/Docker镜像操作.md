---
title: "Docker镜像操作"
date: "2020-06-12"
categories:
    - "技术"
tags:
    - "Docker"
toc: false
indent: false
original: true
---

## 一、docker老命令

由于docker的发展历史，
docker关于操作image的指令有两种：
一种是下面这些老命令。

### 1.1、Usage

``` zsh
➜  docker -h
Flag shorthand -h has been deprecated, please use --help

Usage:  docker [OPTIONS] COMMAND

Commands:
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  load        Load an image from a tar archive or STDIN
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rmi         Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

Run 'docker COMMAND --help' for more information on a command.
```

``` zsh
➜  docker build     # 通过Dockerfile构建镜像
➜  docker commit    # 通过对正在运行的容器的改变创建镜像
➜  docker history   # 查看镜像历史
➜  docker images    # 列出镜像
➜  docker import    # 导入镜像
➜  docker load      # 导入镜像
➜  docker pull      # 拉取镜像
➜  docker push      # 推送镜像
➜  docker rmi       # 删除镜像
➜  docker save      # 保存镜像
➜  docker search    # 搜索镜像
➜  docker tag       # 打tag标签
```

### 1.2、列出镜像

``` zsh
Usage:  docker images [OPTIONS] [REPOSITORY[:TAG]]

# 列出所有镜像    不加参数
➜  docker images
REPOSITORY                                            TAG                 IMAGE ID            CREATED             SIZE
reg.test.local/library/info-ad-service                0.0.1-SNAPSHOT      41ee9a10fa37        3 days ago          482MB
reg.test.local/library/info-payment-service           0.0.1-SNAPSHOT      7580f87ec4f1        5 days ago          487MB
reg.test.local/library/info-groupon-service           0.0.1-SNAPSHOT      b5353f0c27ca        5 days ago          448MB
reg.test.local/library/info-gateway                   0.0.1-SNAPSHOT      beea9a106b2b        5 days ago          441MB
k8s.gcr.io/kube-proxy                                 v1.16.10            495a36f501e1        3 weeks ago         116MB
k8s.gcr.io/kube-apiserver                             v1.16.10            d925057c2fa5        3 weeks ago         170MB
k8s.gcr.io/kube-controller-manager                    v1.16.10            95b2e4f548f1        3 weeks ago         162MB
k8s.gcr.io/kube-scheduler                             v1.16.10            e81d6df90318        3 weeks ago         93.6MB

# 列出同一仓库下的所有镜像    REPOSITORY/*
➜  docker images k8s.gcr.io/*
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy                v1.16.10            495a36f501e1        3 weeks ago         116MB
k8s.gcr.io/kube-controller-manager   v1.16.10            95b2e4f548f1        3 weeks ago         162MB
k8s.gcr.io/kube-apiserver            v1.16.10            d925057c2fa5        3 weeks ago         170MB
k8s.gcr.io/kube-scheduler            v1.16.10            e81d6df90318        3 weeks ago         93.6MB
k8s.gcr.io/etcd                      3.3.15-0            b2756210eeab        9 months ago        247MB
k8s.gcr.io/coredns                   1.6.2               bf261d157914        10 months ago       44.1MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        2 years ago         742kB

# 列出同一个镜像
➜  docker images calico/node
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
calico/node         v3.13.1             2e5029b93d4a        3 months ago        260MB
calico/node         v3.8.2              11cd78b9e13d        10 months ago       189MB
```

### 1.3、删除镜像

``` zsh
Usage:  docker rmi [OPTIONS] IMAGE [IMAGE...]

# 删除镜像很简单直接指定要删除的镜像即可
➜  docker rmi calico/cni:v3.8.2 calico/kube-controllers:v3.8.2 calico/node:v3.8.2 calico/pod2daemon-flexvol:v3.8.2
```

### 1.4、搜索镜像

``` zsh
Usage:  docker search [OPTIONS] TERM

# 搜索出不同仓库下的busybox镜像
➜  docker search busybox
NAME                      DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
busybox                   Busybox base image.                             1918                [OK]
progrium/busybox                                                          71                                      [OK]
radial/busyboxplus        Full-chain, Internet enabled, busybox made f…   31                                      [OK]
arm32v7/busybox           Busybox base image.                             8
yauritux/busybox-curl     Busybox with CURL                               8
armhf/busybox             Busybox base image.                             6
odise/busybox-curl                                                        4                                       [OK]
```

### 1.5、拉取

#### 1.5.1、Usage

``` zsh
Usage:  docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```

#### 1.5.2、按标签

``` zsh
# 默认标签
# 如果未提供标签，则Docker Engine将使用该:latest标签作为默认标签。此命令将拉出busybox:latest镜像
➜  docker pull busybox
Using default tag: latest
latest: Pulling from library/busybox
76df9210b28c: Pull complete
Digest: sha256:95cf004f559831017cdf4628aaf1bb30133677be8702a8c5f2994629f637a209
Status: Downloaded newer image for busybox:latest
docker.io/library/busybox:latest

# 指定标签
➜  docker pull nginx:1.16.1
1.16.1: Pulling from library/nginx
5546cfc92772: Pull complete
50f62e3cdaf7: Pull complete
Digest: sha256:d20aa6d1cae56fd17cd458f4807e0de462caf2336f0b70b5eeb69fcaaf30dd9c
Status: Downloaded newer image for nginx:1.16.1
docker.io/library/nginx:1.16.1
```

#### 1.5.3、按摘要

使用名称和标签是使用镜像的便捷方法。使用标签时，您可以docker pull再次拉取镜像以确保您具有该镜像的最新版本。例如，`docker pull nginx:1.18.0`提取最新版本的 nginx 1.18.0 镜像。

在某些情况下，您不希望将镜像更新为较新的版本，而是希望使用镜像的固定版本。Docker使您能够按其摘要提取映像 。当按摘要提取镜像时，您可以确切指定要提取的镜像版本。这样，您可以将镜像"固定"到该版本，并确保所使用的镜像始终相同。

要了解镜像摘要，请先拉取镜像。让我们从 Docker Hub 中获取 nginx 1.18.0 的最新镜像：

``` zsh
➜  docker pull nginx:1.18.0
1.18.0: Pulling from library/nginx
8559a31e96f4: Pull complete
9a38be3aab21: Pull complete
522e5edd83fa: Pull complete
2ccf5a90baa6: Pull complete
Digest: sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
Status: Downloaded newer image for nginx:1.18.0
docker.io/library/nginx:1.18.0
```

拉取完成后，Docker将打出镜像的摘要。在上面的示例中，镜像的摘要为：

``` zsh
Digest: sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
```

当推送到仓库时，Docker也会打出镜像的摘要。如果您想固定到刚推送的镜像版本，这可能会很有用。

按摘要拉取镜像时，请运行以下命令

``` zsh
➜  docker pull nginx@sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c: Pulling from library/nginx
Digest: sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
Status: Image is up to date for nginx@sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
docker.io/library/nginx@sha256:159aedcc6acb8147c524ec2d11f02112bc21f9e8eb33e328fb7c04b05fc44e1c
```

### 1.6、推送

要推送的镜像的名称必须跟要推送到的仓库一致

``` zsh
Usage:  docker push [OPTIONS] NAME[:TAG]

# 例如我们要推送k8s镜像
➜  docker images k8s.gcr.io/*
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy                v1.16.10            495a36f501e1        3 weeks ago         116MB
k8s.gcr.io/kube-apiserver            v1.16.10            d925057c2fa5        3 weeks ago         170MB
k8s.gcr.io/kube-controller-manager   v1.16.10            95b2e4f548f1        3 weeks ago         162MB
k8s.gcr.io/kube-scheduler            v1.16.10            e81d6df90318        3 weeks ago         93.6MB
k8s.gcr.io/etcd                      3.3.15-0            b2756210eeab        9 months ago        247MB
k8s.gcr.io/coredns                   1.6.2               bf261d157914        10 months ago       44.1MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        2 years ago         742kB

# 先修改tag
➜  kubeadm config images list
I0615 18:19:23.043038 2946627 version.go:251] remote version is much newer: v1.18.3; falling back to: stable-1.16
k8s.gcr.io/kube-apiserver:v1.16.10
k8s.gcr.io/kube-controller-manager:v1.16.10
k8s.gcr.io/kube-scheduler:v1.16.10
k8s.gcr.io/kube-proxy:v1.16.10
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.3.15-0
k8s.gcr.io/coredns:1.6.2

# 脚本批量修改tag并推送
➜  vim batch_tag_push.sh
for i in `kubeadm config images list`
do
    imageName=${i#k8s.gcr.io/}  
    docker tag  k8s.gcr.io/$imageName reg.test.local/google_containers/$imageName
    docker push reg.test.local/google_containers/$imageName
done
```

### 1.7、历史

``` zsh
Usage:  docker history [OPTIONS] IMAGE

# 查看镜像历史
➜  docker history
```

### 1.8、构建

``` zsh
Usage:  docker build [OPTIONS] PATH | URL | -

# 通过Dockerfile构建镜像
➜  docker build
```

### 1.9、提交

``` zsh
Usage:  docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

# 通过对正在运行的容器的改变创建镜像
➜  docker commit  
```

## 二、docker image

docker发展到后来把命令进行整理了，使用下面这种子命令进行管理。

``` zsh
➜  docker image --help

Usage:  docker image COMMAND

Manage images

Commands:
  build       Build an image from a Dockerfile
  history     Show the history of an image
  import      Import the contents from a tarball to create a filesystem image
  inspect     Display detailed information on one or more images
  load        Load an image from a tar archive or STDIN
  ls          List images
  prune       Remove unused images
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rm          Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

Run 'docker image COMMAND --help' for more information on a command.
```

``` zsh
➜  docker image build      # 根据Dockfile构建镜像
➜  docker image history    # 查看镜像历史
➜  docker image import     # 导入镜像
➜  docker image inspect    # 查看镜像详细信息
➜  docker image load       # 导入镜像
➜  docker image ls         # 列出镜像
➜  docker image prune      # 删除未使用镜像
➜  docker image pull       # 拉取镜像
➜  docker image push       # 推送镜像
➜  docker image rm         # 删除镜像
➜  docker image save       # 导出镜像
➜  docker image tag        # 给镜像打tag
```

> 参考列表：
> 1、<https://docs.docker.com/engine/reference/commandline/pull/>  
>