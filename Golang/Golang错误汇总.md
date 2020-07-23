---
title: "Golang错误汇总"
date: "2020-07-21"
categories:
    - "技术"
tags:
    - "Golang"
    - "错误汇总"
toc: false
indent: false
original: true
---

## 1、GOPATH

### 1.1、错误信息

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
etcdhelper.go:14:2: cannot find package "k8s.io/kubectl/pkg/scheme" in any of:d
    /usr/local/go/src/k8s.io/kubectl/pkg/scheme (from $GOROOT)
    /root/go/src/k8s.io/kubectl/pkg/scheme (from $GOPATH)
```

无法从GOPATH和GOROOT中找到go的package

### 1.2、错误解决

首先配置GOPATH，用于保存go的package

``` zsh
➜  vim /etc/profile
export GOPATH=$HOME/go

➜  source /etc/profile
```

## 2、无法下载packge

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

## 3、gopm - 已弃用

### 3、安装gopm

通过这个命令来安装插件，默认的会存放到GOBIN，如果没有配置%GOBIN%环境变量，那么会默认安装到%GOPATH%下的bin目录，为了我们操作方便，我们把GOBIN加到%PATH%下

``` zsh
# 使用go get前需要将GO111MODULE设置为auto
# 若设置为on, 会将安装包下载至$HOME/go/pkg/mod下
➜  go env -w GO111MODULE=auto

# 安装gopm
➜  go get -u github.com/gpmgo/gopm
➜  ll $HOME/go/bin
total 11092
-rwxr-xr-x. 1 root root 11354924 Jul 21 09:43 gopm
```

### 3.2、gopm使用

国内的 go get 问题的解决，用 gopm get -g 代替 go get

通过`gopm get xxx`，可以将指定的包下载到gopm的本地仓库~/.gopm/repos（建议使用）  
通过`gopm get -g xxx`，可以将指定的包下载到GOPATH下。（建议使用）  
通过`gopm get -l xxx`，可以将指定的包下载到当前所在目录（不常用）  

使用示例

``` zsh
➜  gopm get -g github.com/grafana/loki
[GOPM] 07-21 10:24:19 [ERROR] github.com/grafana/loki: fail to make request: Get "https://gopm.io/api/v1/revision?pkgname=github.com/grafana/loki": dial tcp: lookup gopm.io on 192.168.100.1:53: no such host
```

查看发现因为gomod的出现，gopm已经下线了

![gopm关闭](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/go_err_20200721_01.png)

## 4、working directory is not part of a module

### 4.1、错误信息

``` zsh
➜  go build etcdhelper.go
etcdhelper.go:19:2: cannot find module providing package github.com/openshift/api: working directory is not part of a module
etcdhelper.go:16:2: cannot find module providing package go.etcd.io/etcd/clientv3: working directory is not part of a module
etcdhelper.go:17:2: cannot find module providing package go.etcd.io/etcd/pkg/transport: working directory is not part of a module
etcdhelper.go:13:2: cannot find module providing package k8s.io/apimachinery/pkg/runtime/serializer/json: working directory is not part of a module
etcdhelper.go:14:2: cannot find module providing package k8s.io/kubectl/pkg/scheme: working directory is not part of a module
```

### 4.2、错误解决

使用go.mod编译

``` zsh
# 初始化模块etcdhelper
➜  go mod init etcdhelper
go: creating new go.mod: module etcdhelper

➜  ll
total 16
-rw-r--r--. 1 root root 4988 Jul 16 17:00 etcdhelper.go
-rwxr--r--. 1 root root  706 Jul 16 16:45 etcd_ls.sh
-rw-r--r--. 1 root root   27 Jul 16 20:01 go.mod

# 查看go.mod
➜  cat go.mod
module etcdhelper

go 1.14

# 执行go test
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

# 会根据go test的内容生成go.mod
➜  cat go.mod
module etcdhelper

go 1.14

require (
    github.com/coreos/etcd v3.3.22+incompatible // indirect
    github.com/coreos/pkg v0.0.0-20180928190104-399ea9e2e55f // indirect
    github.com/openshift/api v0.0.0-20200714125145-93040c6967eb
    go.etcd.io/etcd v3.3.22+incompatible
    go.uber.org/zap v1.15.0 // indirect
    k8s.io/apimachinery v0.18.6
    k8s.io/kubectl v0.18.6
)

# 再执行go test发现还有错误
➜  go test
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"

# 正常情况下，若无错误就可以进行编译了
➜  go build etcdhelper.go
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"
```

## 5、cannot find module providing package github.com/coreos/go-systemd/journal

### 5.1、错误信息

``` zsh
➜  go test
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"

➜  go build etcdhelper.go
go: finding module for package github.com/coreos/go-systemd/journal
/root/go/pkg/mod/github.com/coreos/etcd@v3.3.22+incompatible/pkg/logutil/zap_journal.go:29:2: no matching versions for query "latest"
```

### 5.2、错误解决

这个问题主要看这个 [issues](https://github.com/etcd-io/etcd/issues/11345)

``` zsh
# 先将go-systemd下载到本地
➜  mkdir -p $GOPATH/src/github.com/coreos/go-systemd/
➜  git clone https://github.com/coreos/go-systemd.git $GOPATH/src/github.com/coreos/go-systemd/
➜  cd $myproject

# 修改go.mod，将依赖改为本地包
➜  vim go.mod
replace (
  github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 latest
)

# 再执行go test
➜  go test
go: downloading github.com/coreos/go-systemd/v22 v22.1.0
go: found github.com/coreos/go-systemd/journal in github.com/coreos/go-systemd v0.0.0-00010101000000-000000000000
# runtime/cgo
exec: "gcc": executable file not found in $PATH
➜  cat go.mod
module etcdhelper

go 1.14

require (
    github.com/coreos/etcd v3.3.22+incompatible // indirect
    github.com/coreos/go-systemd v0.0.0-00010101000000-000000000000 // indirect
    github.com/coreos/pkg v0.0.0-20180928190104-399ea9e2e55f // indirect
    github.com/openshift/api v0.0.0-20200714125145-93040c6967eb
    go.etcd.io/etcd v3.3.22+incompatible
    go.uber.org/zap v1.15.0 // indirect
    k8s.io/apimachinery v0.18.6
    k8s.io/kubectl v0.18.6
)

replace github.com/coreos/go-systemd => github.com/coreos/go-systemd/v22 v22.1.0    # 新添加的replace被替换为这句话了

# 执行编译，并生成可执行文件etcdhelper
➜  go build etcdhelper.go
➜  ll
total 46668
-rwxr-xr-x. 1 root root 47737965 Jul 20 15:59 etcdhelper
-rw-r--r--. 1 root root     4988 Jul 16 17:00 etcdhelper.go
-rwxr--r--. 1 root root      706 Jul 16 16:45 etcd_ls.sh
-rw-r--r--. 1 root root      515 Jul 20 15:54 go.mod
-rw-r--r--. 1 root root    32493 Jul 20 15:54 go.sum
```

## 6、go get - return 128

### 6.1、错误信息

``` zsh
➜  go get github.com/grafana/loki
# cd .; git clone -- https://github.com/grafana/loki /root/go/src/github.com/grafana/loki
error: RPC failed; result=18, HTTP code = 200
fatal: The remote end hung up unexpectedly
fatal: early EOF
fatal: index-pack failed
package github.com/grafana/loki: exit status 128
```

### 6.2、解决方法

``` zsh
➜  mkdir -p /root/go/src/github.com/grafana/loki
➜  git clone -- https://github.com/grafana/loki /root/go/src/github.com/grafana/loki
```

> 参考链接：  
> 1、[go modules初探及踩坑（GO11包管理工具）](https://studygolang.com/articles/19236)  
> 2、[Go 技巧分享：Go 国内加速镜像](https://learnku.com/go/wikis/38122)  
> 3、[cannot find module providing package github.com/coreos/go-systemd/journal](https://github.com/etcd-io/etcd/issues/11345)  
>