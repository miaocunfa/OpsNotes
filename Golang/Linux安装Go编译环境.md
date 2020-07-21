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

## 一、下载安装包

打开官网<https://golang.org/dl/>，需翻墙。

``` zsh
➜  wget https://golang.org/dl/go1.14.5.linux-amd64.tar.gz
```

## 二、部署Go

``` zsh
# 解压至/usr/local下
➜  tar -C /usr/local -zxvf go1.14.5.linux-amd64.tar.gz
```

## 三、配置环境变量

``` zsh
# 修改配置文件
➜  vim /etc/profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GOBIN=$HOME/go/bin
export PATH=$PATH:$GOROOT/bin:$GOBIN

# 加载环境变量
➜  source /etc/profile

# 使用go env查看go的环境变量
➜  go env
GO111MODULE="on"
GOARCH="amd64"
GOBIN="/root/go/bin"
GOCACHE="/root/.cache/go-build"
GOENV="/root/.config/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOINSECURE=""
GONOPROXY=""
GONOSUMDB=""
GOOS="linux"
GOPATH="/root/go"
GOPRIVATE=""
GOPROXY="https://goproxy.io"
GOROOT="/usr/local/go"
...
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build238216350=/tmp/go-build -gno-record-gcc-switches"
```

## 四、验证Go版本

``` zsh
➜  go version
go version go1.14.5 linux/amd64
```

> 参考链接：  
> 1、<https://www.cnblogs.com/qf-dd/p/10594882.html>  
> 2、[gopm解决golang国内无法go get获取第三方包的问题](https://blog.csdn.net/weixin_36162966/article/details/90605065)
>