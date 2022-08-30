---
title: "Java基础镜像优化"
date: "2022-04-28"
categories:
    - "技术"
tags:
    - "docker"
    - "优化"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容         |
| ---------- | ----------- |
| 2022-04-28 | 初稿        |
| 2022-04-29 | docker exec |

## 软件版本

| soft      | Version  |
| --------- | -------- |
| CentOS    | 7.7      |
| docker-ce | 20.10.10 |
| jdk       | 8u201    |

## 楔子

一直感觉我们公司地基础镜像太大了，而且容器内还没有一些常见的调试命令，比如说 `ip`，`telnet` 之类的。

``` zsh
➜  docker images
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
prod-order                     202204272008        29d305e855a6        24 hours ago        743MB
prod-three                     202204081348        8c53e30cbff6        2 weeks ago         749MB
prod-message                   202204011334        fa2fa9153e6b        3 weeks ago         754MB
prod-craftsman                 202202232012        a3bb3a527829        2 months ago        742MB
prod-square                    202109141927        519a973fbca9        7 months ago        736MB
prod-am                        202109141855        98c3a669a18f        7 months ago        733MB
prod-zuuls                     202109141833        edf219d80b6e        7 months ago        742MB
jdk8                           v1.0                39100325c025        2 years ago         587MB
```

这个 jdk8有587MB，根据这个基础镜像打出来的服务包有 740M+，上传与拉取镜像速度都太慢了。

## 基础镜像

Java 最后一个免费版本是 8u202, 这里选择的是 8u201 稳定版

``` zsh
# 从 DockerHub 拉取 jre-alpine 版本
➜  docker pull openjdk:8u201-jre-alpine3.9

# 使用 docker images 查看镜像只有84.9MB
➜  docker images
openjdk                      8u201-jre-alpine3.9   ce8477c7d086   3 years ago     84.9MB
```

JDK: 8u201 的 Dockerfile文件

``` Dockerfile
ADD file:2e3a37883f56a4a278bec2931fc9f91fb9ebdaa9047540fe8fde419b84a1701b in / 
 CMD ["/bin/sh"]
 ENV LANG=C.UTF-8
/bin/sh -c {echo '#!/bin/sh';echo 'set -e';echo; echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home
 ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
 ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin
 ENV JAVA_VERSION=8u201
 ENV JAVA_ALPINE_VERSION=8.201.08-r1
/bin/sh -c set -x && apk add --no-cache openjdk8-jre="$JAVA_ALPINE_VERSION" && [ "$JAVA_HOME" = "$(docker-java-home)" ]
```

## 优化镜像

先将基础镜像上传至 harbor
修改docker tag

``` Dockerfile
➜  docker tag openjdk:8u201-jre-alpine3.9 172.31.229.139:9999/base/openjdk:8u201-jre-alpine3.9
➜  docker push 172.31.229.139:9999/base/openjdk:8u201-jre-alpine3.9
The push refers to repository [172.31.229.139:9999/base/openjdk]
aae5c057d1b6: Pushed
dee6aef5c2b6: Pushed
a464c54f93a9: Pushed
8u201-jre-alpine3.9: digest: sha256:922d65ba63c3cccb58c0a03e8bdfa86161c60c2aeb33db85d952d99c54f9662b size: 947
```

使用基础镜像打包的 Dockerfile文件

``` Dockerfile
# 1.基础镜像
FROM 172.31.229.139:9999/base/openjdk:8u201-jre-alpine3.9

# 2.指明该镜像的作者和其电子邮件
MAINTAINER Miaocunfa miaocunf@163.com

# 3.在构建镜像时，指定镜像的工作目录，之后的命令都是基于此工作目录，如果不存在，则会创建目录
WORKDIR /opt/enterprise

# 4.一个复制命令，把 jar包复制到镜像中，语法：ADD <src> <dest>, 注意：*.jar使用的是相对路径
ADD *.jar enterprise-customer.jar

# 5.映射端口
EXPOSE 8889

# 6.配置环境变量
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone
ENV LANG C.UTF-8

# 7.容器启动时需要执行的命令
ENTRYPOINT  ["java","-jar","enterprise-customer.jar"]
```

使用 Dockerfile构建镜像

``` zsh
# 构建镜像 test
➜  docker build . -t test

# 查看镜像大小
➜  docker images
REPOSITORY                    TAG                   IMAGE ID       CREATED         SIZE
test                          latest                81051569a467   6 seconds ago   197MB
```

构建的镜像 从740MB+ 减到了197MB，镜像体积缩减了70%

``` zsh
# 运行服务包
➜  docker run -d -p 7001:8889 --name=test test
69550466fbfe9be24e2eb14df18358f87fd37653f5bc4b6178b655d8e43bd6ba

# 查看容器运行状态
➜  docker ps
CONTAINER ID   IMAGE           COMMAND                  CREATED         STATUS                  PORTS                                       NAMES
69550466fbfe   test            "java -jar enterpris…"   4 seconds ago   Up 3 seconds            0.0.0.0:7001->8889/tcp, :::7001->8889/tcp   test

# 进入容器内部
➜  docker exec -it test sh
# 进程
/opt/enterprise # ps aux
PID   USER     TIME  COMMAND
    1 root      0:39 java -jar enterprise-customer.jar
   29 root      0:00 sh
   45 root      0:00 ps aux
# 进入日志路径
/opt/enterprise # cd /log/enterprise-customer-service
/log/enterprise-customer-service # ls
enterprise-customer-service.log
# 查看日志
/ # tail -f enterprise-customer-service.log
2022-04-28 21:29:56.817  INFO 1 --- [main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8889 (http) with context path ''
2022-04-28 21:29:56.823  INFO 1 --- [main] com.alibaba.nacos.client.naming          : [BEAT] adding beat: {"cluster":"DEFAULT","ip":"172.17.0.5","metadata":{"preserved.register.source":"SPRING_CLOUD"},"period":5000,"port":8889,"scheduled":false,"serviceName":"DEFAULT_GROUP@@enterprise-customer-service","stopped":false,"weight":1.0} to beat map.
2022-04-28 21:29:57.101  INFO 1 --- [main] com.alibaba.nacos.client.naming          : [REGISTER-SERVICE] public registering service DEFAULT_GROUP@@enterprise-customer-service with instance: {"clusterName":"DEFAULT","enabled":true,"ephemeral":true,"healthy":true,"instanceHeartBeatInterval":5000,"instanceHeartBeatTimeOut":15000,"ip":"172.17.0.5","ipDeleteTimeout":30000,"metadata":{"preserved.register.source":"SPRING_CLOUD"},"port":8889,"weight":1.0}
2022-04-28 21:29:57.124  INFO 1 --- [main] c.a.c.n.registry.NacosServiceRegistry    : nacos registry, DEFAULT_GROUP enterprise-customer-service 172.17.0.5:8889 register finished
2022-04-28 21:29:58.648  INFO 1 --- [main] com.gjr.enterprise.CustomerApplication   : Started CustomerApplication in 18.54 seconds (JVM running for 19.652)
```

> 参考文章：  
>
> - [Java JDK8/JAVA8以及后版本收费后还能用吗](https://www.csdn.net/tags/MtTaMg0sODgwMDg0LWJsb2cO0O0O.html)  
> - [DockerHub - 搜索openjdk下jre-alpine版本](https://hub.docker.com/_/openjdk?tab=tags&page=1&name=jre-alpine)
> - [DockerHub - openjdk:8u201-jre-alpine3.9](https://hub.docker.com/layers/openjdk/library/openjdk/8u201-jre-alpine3.9/images/sha256-ce8477c7d086dce9f49ffb44383ee84dcf14a8f826525e83a36eed4f2fc47025?context=explore)
> - [alpine docker exec: "/bin/bash": stat /bin/bash: no such file or directory 解决方案](https://blog.csdn.net/weixin_41282397/article/details/81450866)
>
