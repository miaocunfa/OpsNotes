---
title: "迁移原先由RPM包部署的Jenkins服务到Docker服务器"
date: "2022-05-19"
categories:
    - "技术"
tags:
    - "数据迁移"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                 |
| ---------- | ------------------- |
| 2022-05-19 | 初稿                |
| 2022-05-26 | 完善                |

## 软件版本

| soft      | Version     |
| --------- | ----------- |
| CentOS    | 7.7         |
| Jenkins   | 2.234       |

## 楔子



## 原Jenkins服务信息

``` zsh
# 通过查看 systemctl 服务查看 原Jenkins信息
➜  systemctl status jenkins
● jenkins.service - LSB: Jenkins Automation Server
   Loaded: loaded (/etc/rc.d/init.d/jenkins; bad; vendor preset: disabled)
   Active: active (running) since Tue 2021-08-31 14:11:53 CST; 8 months 17 days ago
     Docs: man:systemd-sysv-generator(8)
    Tasks: 199
   Memory: 2.8G
   CGroup: /system.slice/jenkins.service
           ├─27823 java -server -Xmx1024M -Xms1024M -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:-ResizePLAB -XX:+PerfDisableSharedMem -XX:-OmitSt...
           └─30451 /usr/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -Xms256m -Xmx512m -XX:MaxNewSize=256m -XX:MaxPermSize=256m -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins...

May 17 11:41:48 docker-1 sudo[6428]:     root : TTY=unknown ; PWD=/var/lib/jenkins/workspace/Test_H5_Coin_Shop ; USER=root ; COMMAND=/usr/local/node-v12.16.1-linux-x64/bin/npm install
May 17 11:41:57 docker-1 sudo[6483]:     root : TTY=unknown ; PWD=/var/lib/jenkins/workspace/Test_H5_Coin_Shop ; USER=root ; COMMAND=/usr/local/node-v12.16.1-linux-x64/bin/npm run test

# 查看启动文件
➜  /etc/rc.d/init.d/jenkins
JENKINS_CONFIG=/etc/sysconfig/jenkins    # 获得 Jenkins配置文件

# 查看 Jenkins配置文件
➜  cat /etc/sysconfig/jenkins | grep -v ^# | grep -v ^$
JENKINS_HOME="/var/lib/jenkins"
JENKINS_JAVA_CMD=""
JENKINS_USER="root"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Xms256m -Xmx512m -XX:MaxNewSize=256m -XX:MaxPermSize=256m"
JENKINS_PORT="8888"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_HTTP2_PORT=""
JENKINS_HTTP2_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_EXTRA_LIB_FOLDER=""
JENKINS_ARGS=""
```

## 迁移准备

``` zsh
➜  cd /var/lib/jenkins/workspace
➜  du -d 1 -h .
42.1G    .

# 由于 以前使用 Jenkins积攒下 太多信息，需要先清理一波 $JENKINS_HOME/workspace
➜  rm -rf ./*

# 将清理后的整个 $Jenkins_HOME 打为tar包
➜  cd /var/lib
➜  tar -cf test-jenkinsHome_2.234_backup.tar ./jenkins/

# 使用 scp命令 将tar包拷贝到新主机上
➜  scp test-jenkinsHome_2.234_backup.tar root@$HOST:~
  
➜  tar -xf test-jenkinsHome_2.234_backup.tar -C /data/
➜  mv jenkins/ test-jenkins
```

## 修改Jenkins 时区，字符集等

``` Dockerfile
FROM  jenkins/jenkins:2.234-centos7
USER  root

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone
ENV LANG C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

➜  docker build . -t harbor.gjr.net/base/jenkins:2.234-shanghai
```

## 拉起 Jenkins服务

``` zsh
➜  docker run \
  -u root \
  --net=host \
  -d \
  -p 7001:8080 \
  -p 57001:50000 \
  -v /data/test-jenkins:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /script/:/script \
  -v /target/:/target \
  -v /usr/local/maven:/usr/local/maven \
  -v /usr/local/node-v12.16.1-linux-x64:/usr/local/node-v12.16.1-linux-x64 \
  --name test-jenkins \
  harbor.gjr.net/base/jenkins:2.234-shanghai
```

## 问题处理

①在容器内运行 docker命令，容器内还要再运行 docker login才可

``` zsh
➜  docker login harbor.gjr.net
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
➜  docker exec -it test-jenkins /bin/bash
[root@163e4cc2e48c /]# docker push harbor.gjr.net/test-dec/enterprise-customer:10
The push refers to repository [harbor.gjr.net/test-dec/enterprise-customer]
09a5d92d2c13: Preparing 
e4ece6a3b488: Preparing 
a313507ef2e2: Preparing 
aae5c057d1b6: Preparing 
dee6aef5c2b6: Preparing 
a464c54f93a9: Waiting 
unauthorized: unauthorized to access repository: test-dec/enterprise-customer, action: push: unauthorized to access repository: test-dec/enterprise-customer, action: push
[root@163e4cc2e48c /]# docker login harbor.gjr.net
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[root@163e4cc2e48c /]# docker push harbor.gjr.net/test-dec/enterprise-customer:10
The push refers to repository [harbor.gjr.net/test-dec/enterprise-customer]
09a5d92d2c13: Pushed 
e4ece6a3b488: Pushed 
a313507ef2e2: Pushed 
aae5c057d1b6: Pushed 
dee6aef5c2b6: Pushed 
a464c54f93a9: Pushed 
10: digest: sha256:657d3c6ff5883c6505bb77df0f776fea4f1204bedd8f53a8058837f5d309feea size: 1573
[root@163e4cc2e48c /]#
```

②容器内如何与外部主机通信

ssh root@172.31.229.152 'sh -x /script/test-service/enterprise/enterprise_docker_run.sh harbor.gjr.net/test-dec/enterprise-customer:11 enterprise-customer 8889:8889 '
ssh: connect to host 172.31.229.152 port 22: Connection timed out

``` zsh

```

> 参考文章：  
>
> - [Jenkins官网 - lts版本](https://www.jenkins.io/zh/download/lts/)  
> - [Jenkins官网 - Dokcer安装](https://www.jenkins.io/zh/doc/book/installing/#docker)  
> - [Docker Hub - Jenkins-2.234镜像](https://hub.docker.com/r/jenkins/jenkins/tags?page=1&name=234)  
> - [一台服务器安装多个 Jenkins 系统服务运行](https://www.bianchengquan.com/article/380292.html)  
>
