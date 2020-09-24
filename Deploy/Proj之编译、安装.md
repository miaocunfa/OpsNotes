---
title: "Proj之编译、安装"
date: "2020-09-22"
categories:
    - "技术"
tags:
    - "boost"
toc: false
original: true
---

## 版本信息

| Server        | Version |
| ------------- | ------- |
| CentOS        | 7.6     |
| sqlite3       | 3.33    |
| libtiff-devel | 4.0.3   |
| libcurl-devel | 7.29.0  |
| Proj          | 7.1.0   |

## 前置安装

Proj 需要安装sqlite3、libtiff、libcurl-devel等

``` zsh
安装 sqlite3 >= 3.11
➜  yum install -y libtiff libtiff-devel.x86_64
➜  yum install -y libcurl-devel.x86_64
```

## Proj 下载 && 安装

[Proj官网](https://proj.org/)  

``` zsh
# 下载源码
➜  wget https://download.osgeo.org/proj/proj-7.1.0.tar.gz
```

安装说明查看源代码主目录下的INSTALL文件  

``` zsh
# 使用最简单的安装方式
# 解压
➜  tar zxf proj-7.1.0.tar.gz
➜  cd proj-7.1.0

# 编译 && 安装
➜  ./configure && make && make install
```

## 错误汇总

### 1、sqlite3 未安装

``` zsh
➜  ./configure
checking for SQLITE3... configure: error: Package requirements (sqlite3 >= 3.11) were not met:

No package 'sqlite3' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables SQLITE3_CFLAGS
and SQLITE3_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

错误解决

``` zsh
➜  wget https://www.sqlite.org/2020/sqlite-autoconf-3330000.tar.gz
➜  tar -zxf sqlite-autoconf-3330000.tar.gz

# sqlite3 就使用最简单的编译三部曲安装。
➜  cd sqlite-autoconf-3330000
➜  ./configure && make && make install

# 环境变量
➜  find / -name "pkgconfig" -print
/usr/lib64/pkgconfig
/usr/share/pkgconfig
/usr/local/lib/pkgconfig
/usr/local/lib64/pkgconfig

# 可以设置PKG_CONFIG_PATH
# 或者设置 SQLITE3_CFLAGS SQLITE3_LIBS
➜  export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:/usr/share/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH
```

### 2、libtiff-4 未安装

``` zsh
➜  ./configure
checking for TIFF... configure: error: Package requirements (libtiff-4) were not met:

No package 'libtiff-4' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables TIFF_CFLAGS
and TIFF_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

错误解决

``` zsh
➜  yum install -y libtiff libtiff-devel.x86_64
```

### 3、curl-config 未安装

``` zsh
checking for curl-config... not-found
configure: error: curl not found. If wanting to do a build without curl support (and thus without built-in networking capability), explictly disable it with --without-curl
```

错误解决

``` zsh
➜  yum install -y libcurl-devel.x86_64
```

> 参考链接：  
> 1、[SQLite下载中心](https://www.sqlite.org/download.html)  
> 2、[PKG_CONFIG_PATH错误提示解决办法](https://blog.csdn.net/ubuntulover/article/details/6978305)  
> 3、[Proj - 官方安装手册](https://proj.org/install.html)  
>