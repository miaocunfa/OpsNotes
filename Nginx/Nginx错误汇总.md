---
title: "Nginx错误汇总"
date: "2020-09-01"
categories:
    - "技术"
tags:
    - "Nginx"
    - "错误汇总"
toc: false
indent: false
original: true
draft: true
---

## 1、nginx_upstream_check_module-master

``` log
2020/09/01 17:12:20 [error] 10691#10691: *537 http upstream check module can not find any check server, make sure you've added the check servers, client: 58.56.81.210, server: cms.aihangxunxi.com, request: "GET /status HTTP/1.1", host: "cms.aihangxunxi.com"
```

### 1.1、错误解析

原因是 Nginx_upstream_check_module doesn’t work with nginx > 1.7.6  
相关文章：<https://www.ruby-forum.com/t/nginx-upstream-check-module-doesnt-work-with-nginx-1-7-6/241918>  
也许有其它的办法的，比如这里有说过一些：<https://github.com/yaoweibin/nginx_upstream_check_module/issues/77>  
不过最后在这个网址里看到好像有解决办法了：<http://mailman.nginx.org/pipermail/nginx/2012-September/035375.html>  
文章链接到了github上的一个patch修复链接：<https://github.com/yaoweibin/nginx_upstream_check_module>  
里面包含了对各个nginx版本做的处理比如：check_1.16.1+.patch

### 1.1、错误解决

``` zsh
# 下载 nginx-1.16.1
➜  wget http://nginx.org/download/nginx-1.16.1.tar.gz
➜  tar -zxf nginx-1.16.1.tar.gz

# 打补丁
➜  git clone https://github.com/yaoweibin/nginx_upstream_check_module.git
➜  cd nginx-1.16.1
➜  patch -p1 < /home/miaocunfa/nginx_upstream_check_module/check_1.16.1+.patch
patching file src/http/modules/ngx_http_upstream_hash_module.c
patching file src/http/modules/ngx_http_upstream_ip_hash_module.c
patching file src/http/modules/ngx_http_upstream_least_conn_module.c
patching file src/http/ngx_http_upstream_round_robin.c
patching file src/http/ngx_http_upstream_round_robin.h

# 配置
➜  ./configure --prefix=/usr/local/nginx-1.16.1 \
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

# 编译 && 安装
➜  make
➜  make install
```

> 参考列表：
> 1、[nginx_upstream_check_module-master - 错误描述](http://www.04007.cn/article/696.html)  
> 2、[github - nginx_upstream_check_module](https://github.com/yaoweibin/nginx_upstream_check_module/)  
> 3、[github - nginx_upstream_check_module - issues](https://github.com/yaoweibin/nginx_upstream_check_module/issues/77)  
> 4、[nginx 添加第三方nginx_upstream_check_module 模块实现健康状态检测](https://www.cnblogs.com/dance-walter/p/12212607.html)  
>