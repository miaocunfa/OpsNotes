---
title: "Nginx迁移"
date: "2020-08-15"
categories:
    - "技术"
tags:
    - "Nginx"
    - "迁移"
toc: false
indent: false
original: true
draft: true
---

## 1、目录规划

``` zsh
# html
/usr/share/nginx          -->    /ahdata/nginx/html

# cert
/usr/local/nginx/cert     -->    /ahdata/nginx/cert

# log
/var/log/nginx/           -->    /ahdata/nginx/logs
/usr/local/nginx/logs/    -->    /ahdata/nginx/logs
```

## 2、迁移

``` zsh
➜  mkdir -p /ahdata/nginx/{logs,cert,html}

➜  cp -R /usr/local/nginx/cert/* /ahdata/nginx/cert/
➜  cp -R /usr/share/nginx/* /ahdata/nginx/html/

➜  cp /usr/local/nginx/conf/nginx.conf /etc/nginx/
➜  rm -f /etc/nginx/conf.d/*
➜  cp /usr/local/nginx/conf/conf.d/* /etc/nginx/conf.d/
```

## 3、配置文件修改

``` zsh
➜  vim /etc/nginx/nginx.conf
include /usr/local/nginx/conf/conf.d/*.conf;    -->    include /etc/nginx/conf.d/*.conf;

# /etc/nginx/conf.d/下的所有配置文件
logs    -->    /ahdata/nginx/logs
html    -->    /ahdata/nginx/html
cert    -->    /ahdata/nginx/cert
```
