---
title: "nginx编译模块"
date: "2020-08-15"
categories:
    - "技术"
tags:
    - "Nginx"
    - "编译"
toc: false
indent: false
original: true
---

## 初稿

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-04 | 初稿 |

## 1、查看原编译参数

原nginx版本太低，1.8.0，需要升级nginx版本。

``` zsh
➜  nginx -V
nginx version: nginx/1.8.0
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module --add-module=../nginx_upstream_check_module-master
```

## 2、更新编译参数

将原有参数带到新版

``` zsh
# 准备编译环境
➜  yum -y install gcc gcc-c++ automake pcre pcre-devel zlib zlib-devel openssl openssl-devel
# 下载最新的 Stable版
➜  wget http://nginx.org/download/nginx-1.18.0.tar.gz
# 准备第三方模块
➜  cp -R /home/wangshuxian/nginx_upstream_check_module-master /home/miaocunfa/

➜  cd nginx-1.18.0
➜  ./configure --prefix=/usr/local/nginx-1.18.0 \
--with-pcre \
--with-debug \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_stub_status_module \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_slice_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--add-module=/home/miaocunfa/nginx_upstream_check_module-master

# temp
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \

# 核心模块 或 需要安装依赖
--with-sha1 \
--with-md5 \
--with-http_log_module \
--with-http_headers_module \
--with-http_rewrite_module \
--with-http_referer_module \
--with-http_access_module \
--with-http_proxy_module \
--with-http_fastcgi_module \
--with-http_upstream_module \
--with-stream_core_module \
--with-stream_proxy_module \
--with-http_core_module \
--with-http_xslt_module \

➜  make
➜  make install
```

## 3、模块介绍

``` zsh

```

> 参考链接：
> 1、[](https://www.cnblogs.com/fangfei9258/p/9453709.html)  
>