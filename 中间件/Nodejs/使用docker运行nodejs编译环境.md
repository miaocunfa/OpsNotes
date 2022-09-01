---
title: "使用docker运行nodejs编译环境"
date: "2022-06-07"
categories:
    - "技术"
tags:
    - "nodejs"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-06-07 | 初稿 |

## docker 环境

``` Dockerfile
# 1.基础镜像
FROM node:14.19.3

# 2.指明该镜像的作者和其电子邮件
MAINTAINER Miaocunfa miaocunf@163.com

# 3.在构建镜像时，指定镜像的工作目录，之后的命令都是基于此工作目录，如果不存在，则会创建目录
WORKDIR /opt/nodejs

# 4.一个复制命令，把 jar包复制到镜像中，语法：ADD <src> <dest>, 注意：*.jar使用的是相对路径
ADD app.js app.js

# 5.映射端口
EXPOSE 80

# 6.容器启动时需要执行的命令
ENTRYPOINT  ["node","app.js"]
```

docker build . -t node-helloworld:14.19.3

docker exec -it node14 "cd /data/test-jenkins/home/workspace/H5_gjr-engineering-manage; yarn; yarn test"
