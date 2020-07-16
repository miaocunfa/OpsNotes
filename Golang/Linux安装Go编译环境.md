---
title: "Linux安装Go编译环境"
date: "2020-07-16"
categories:
    - "技术"
tags:
    - "Golang"
toc: false
indent: false
original: true
---

## 一、下载

打开官网<https://golang.org/dl/>，需翻墙。

``` zsh
➜  wget https://golang.org/dl/go1.14.5.linux-amd64.tar.gz
```

## 二、安装

``` zsh
# 解压
➜  tar -C /usr/local -zxvf go1.14.5.linux-amd64.tar.gz
```

## 三、配置

``` zsh
➜  vim /etc/profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin

➜  source /etc/profile
```

## 四、验证

``` zsh
➜  go version
go version go1.14.5 linux/amd64
```

## 五、错误

### 5.1、GOPATH

``` zsh
➜  go build etcdhelper.go
etcdhelper.go:19:2: cannot find package "github.com/openshift/api" in any of:
    /usr/local/go/src/github.com/openshift/api (from $GOROOT)
    /root/go/src/github.com/openshift/api (from $GOPATH)
etcdhelper.go:16:2: cannot find package "go.etcd.io/etcd/clientv3" in any of:
    /usr/local/go/src/go.etcd.io/etcd/clientv3 (from $GOROOT)
    /root/go/src/go.etcd.io/etcd/clientv3 (from $GOPATH)
etcdhelper.go:17:2: cannot find package "go.etcd.io/etcd/pkg/transport" in any of:
    /usr/local/go/src/go.etcd.io/etcd/pkg/transport (from $GOROOT)
    /root/go/src/go.etcd.io/etcd/pkg/transport (from $GOPATH)
etcdhelper.go:13:2: cannot find package "k8s.io/apimachinery/pkg/runtime/serializer/json" in any of:
    /usr/local/go/src/k8s.io/apimachinery/pkg/runtime/serializer/json (from $GOROOT)
    /root/go/src/k8s.io/apimachinery/pkg/runtime/serializer/json (from $GOPATH)
etcdhelper.go:14:2: cannot find package "k8s.io/kubectl/pkg/scheme" in any of:
    /usr/local/go/src/k8s.io/kubectl/pkg/scheme (from $GOROOT)
    /root/go/src/k8s.io/kubectl/pkg/scheme (from $GOPATH)
```

无法从GOPATH和GOROOT中找到go的package

#### 5.1.1、错误解决

首先配置GOPATH，用于保存go的package

``` zsh
➜  vim /etc/profile
export GOPATH=$HOME/go

➜  source /etc/profile
```

### 5.2、无法下载packge

众所周知，国内网络访问国外资源经常会出现不稳定的情况。 Go 生态系统中有着许多中国 Gopher 们无法获取的模块，比如最著名的 `golang.org/x/...`。并且在中国大陆从 GitHub 获取模块的速度也有点慢。

因此设置 CDN 加速代理就很有必要了，以下是几个速度不错的提供者：

- 官方： 全球 CDN 加速 <https://goproxy.io/>
- 七牛：Goproxy 中国 <https://goproxy.cn>
- 其他：jfrog 维护 <https://gocenter.io>
- 阿里： <https://mirrors.aliyun.com/goproxy/>

在 Linux 或 macOS 上面，需要运行下面命令：

``` zsh
# 启用 Go Modules 功能
➜  go env -w GO111MODULE=on

# 配置 GOPROXY 环境变量，以下三选一

# 1. 官方
➜  go env -w  GOPROXY=https://goproxy.io

# 2. 七牛 CDN
➜  go env -w  GOPROXY=https://goproxy.cn

# 3. 阿里云
➜  go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/
```

### 5.3、working directory is not part of a module

#### 5.3.1、错误信息

``` zsh
➜  go build etcdhelper.go
etcdhelper.go:19:2: cannot find module providing package github.com/openshift/api: working directory is not part of a module
etcdhelper.go:16:2: cannot find module providing package go.etcd.io/etcd/clientv3: working directory is not part of a module
etcdhelper.go:17:2: cannot find module providing package go.etcd.io/etcd/pkg/transport: working directory is not part of a module
etcdhelper.go:13:2: cannot find module providing package k8s.io/apimachinery/pkg/runtime/serializer/json: working directory is not part of a module
etcdhelper.go:14:2: cannot find module providing package k8s.io/kubectl/pkg/scheme: working directory is not part of a module
```

### 5.3.2、错误解决

``` zsh
➜  go mod init etcdhelper
go: creating new go.mod: module etcdhelper
➜  ll
total 16
-rw-r--r--. 1 root root 4988 Jul 16 17:00 etcdhelper.go
-rwxr--r--. 1 root root  706 Jul 16 16:45 etcd_ls.sh
-rw-r--r--. 1 root root   27 Jul 16 20:01 go.mod
➜  cat go.mod
module etcdhelper

go 1.14
➜  go test
go: finding module for package go.etcd.io/etcd/clientv3
go: finding module for package k8s.io/kubectl/pkg/scheme
go: finding module for package go.etcd.io/etcd/pkg/transport
go: finding module for package k8s.io/apimachinery/pkg/runtime/serializer/json
go: finding module for package github.com/openshift/api
go: downloading k8s.io/kubectl v0.18.6
go: downloading github.com/openshift/api v0.0.0-20200714125145-93040c6967eb
go: downloading k8s.io/apimachinery v0.18.6
go: found github.com/openshift/api in github.com/openshift/api v0.0.0-20200714125145-93040c6967eb
go: found go.etcd.io/etcd/clientv3 in go.etcd.io/etcd v3.3.22+incompatible
go: found k8s.io/apimachinery/pkg/runtime/serializer/json in k8s.io/apimachinery v0.18.6
go: found k8s.io/kubectl/pkg/scheme in k8s.io/kubectl v0.18.6
go: downloading github.com/modern-go/reflect2 v1.0.1
go: downloading sigs.k8s.io/yaml v1.2.0
go: downloading k8s.io/api v0.18.6
go: downloading k8s.io/client-go v0.18.6
go: downloading gopkg.in/inf.v0 v0.9.1
go: downloading github.com/google/gofuzz v1.1.0
go: downloading github.com/coreos/etcd v3.3.10+incompatible
go: finding module for package go.uber.org/zap
go: downloading google.golang.org/grpc v1.19.0
go: downloading github.com/golang/protobuf v1.3.2
go: downloading sigs.k8s.io/structured-merge-diff/v3 v3.0.0
go: finding module for package github.com/coreos/etcd/clientv3/balancer/picker
go: downloading github.com/json-iterator/go v1.1.8
go: finding module for package github.com/coreos/etcd/clientv3/balancer
go: finding module for package github.com/coreos/etcd/clientv3/credentials
go: downloading github.com/coreos/go-semver v0.2.0
go: downloading google.golang.org/genproto v0.0.0-20190418145605-e7d98fc518a7
go: downloading gopkg.in/yaml.v2 v2.2.8
go: downloading golang.org/x/net v0.0.0-20191209160850-c0dbc17a3553
go: downloading github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd
go: finding module for package github.com/coreos/pkg/capnslog
go: finding module for package github.com/coreos/etcd/clientv3/balancer/resolver/endpoint
go: downloading k8s.io/klog v1.0.0
go: downloading golang.org/x/sys v0.0.0-20191022100944-742c48ecaeb7
go: downloading golang.org/x/text v0.3.2
go: found github.com/coreos/etcd/clientv3/balancer in github.com/coreos/etcd v3.3.22+incompatible
go: found github.com/coreos/pkg/capnslog in github.com/coreos/pkg v0.0.0-20180928190104-399ea9e2e55f
go: found go.uber.org/zap in go.uber.org/zap v1.15.0
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"

➜  go test
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"
➜  go build etcdhelper.go
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"
```

> 参考链接：  
> 1、<https://www.cnblogs.com/qf-dd/p/10594882.html>  
> 2、[Go 技巧分享：Go 国内加速镜像](https://learnku.com/go/wikis/38122)  
> 3、[go modules初探及踩坑（GO11包管理工具）](https://studygolang.com/articles/19236)