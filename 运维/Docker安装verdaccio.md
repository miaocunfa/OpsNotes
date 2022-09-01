---
title: "Docker 安装 verdaccio"
date: "2022-07-05"
categories:
    - "技术"
tags:
    - "Docker"
    - "verdaccio"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容           |
| ---------- | ------------- |
| 2022-07-05 | 初稿           |

## 准备工作

``` zsh
➜  mkdir -p /data/verdaccio/{storage,conf,plugins}
➜  chown -R 10001:65533 /data/verdaccio/storage

➜  vi /data/verdaccio/conf/config.yaml
# 素有包的保存路径
storage: /verdaccio/storage/data
# 插件的保存路径
plugins: /verdaccio/plugins
 
# 通过web访问
web:
  title: Verdaccio
 
# 账号密码文件，初始不存在
auth:
  htpasswd:
    file: /verdaccio/storage/htpasswd
    # max_users：1000
    # 默认1000，允许用户注册数量。为-1时，不能通过 npm adduser 注册，此时可以直接修改 file 文件添加用户。
 
# 本地不存在时，读取仓库的地址
uplinks:
  npmjs:
    url: https://registry.npmjs.org
 
# 对包的访问操作权限，可以匹配某个具体项目，也可以通配
# access 访问下载；publish 发布；unpublish 取消发布；
# proxy 对应着uplinks名称，本地不存在，去unplinks里取
 
# $all 表示所有人都可以执行该操作
# $authenticated 已注册账户可操作
# $anonymous 匿名用户可操作
# 还可以明确指定 htpasswd 用户表中的用户，可以配置一个或多个。
packages:
  '@*/*':
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs
 
  '**':
    access: $all
    publish: $authenticated
    unpublish: $authenticated
    proxy: npmjs
 
# 服务器相关
sever:
  keepAliveTimeout: 60
 
middlewares:
  audit:
    enabled: true
 
# 日志设定
logs: { type: stdout, format: pretty, level: http }
```

## 启动服务

``` zsh
➜  docker run -d --name verdaccio -p 4873:4873 -v /data/verdaccio/storage:/verdaccio/storage -v /data/verdaccio/conf:/verdaccio/conf -v /data/verdaccio/plugins:/verdaccio/plugins verdaccio/verdaccio
```

> 参考文档:  
>
> - [Docker 安装verdaccio](https://blog.csdn.net/qq_27615455/article/details/124551047)
>
