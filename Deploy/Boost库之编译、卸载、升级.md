---
title: "Boost库之编译、卸载、升级"
date: "2020-09-21"
categories:
    - "技术"
tags:
    - "boost"
toc: false
original: true
draft: false
---

## 一、下载

[Boost官网](https://www.boost.org/)地址

``` zsh
➜  wget https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz
```

## 二、编译

``` zsh
➜  tar -zxf boost_1_74_0.tar.gz
➜  cd boost_1_74_0
➜  ./bootstrap.sh --with-libraries=all --with-toolset=gcc
```

## 三、安装

``` zsh
➜  ./b2 install
```

## 四、卸载

安装多个boost可能会引起冲突，将所有版本全部卸载，重新安装。

``` zsh
➜  yum info boost
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
Installed Packages
Name        : boost
Arch        : x86_64
Version     : 1.53.0

➜  yum remove boost

➜  rm -rf /usr/local/lib/cmake/{B,b}oost*-1.74.0
➜  rm -rf /usr/local/include/*boost*
➜  rm -f /usr/local/lib/libboost*
```

> 参考链接：  
> 1、[boost的编译、安装](https://www.cnblogs.com/smallredness/p/9245127.html)  
> 2、[卸载boost安装另一个版本](https://www.thinbug.com/q/8430332)  
>