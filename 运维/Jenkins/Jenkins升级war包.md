---
title: "Jenkins 升级 war包"
date: "2022-07-19"
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
| 2022-07-19 | 初稿                |
| 2022-07-21 | 版本修改为2.360 && 准备数据部分修改 |
| 2022-07-28 | 内存溢出 && 版本修改为 2.346.2-lts|
| 2022-07-29 | 移除 错误处理 |

## 软件版本

| soft      | Version     |
| --------- | ----------- |
| CentOS    | 7.7         |
| Jenkins  | 2.234 --> 2.346.2-lts |

## 楔子

由于在用的Jenkins版本太低，导致很多插件已经无法升级，所以对Jenkins版本进行升级

## 环境准备

新版程序准备，从Jenkins官网下载war包

``` zsh
➜  wget --no-check-certificate https://get.jenkins.io/war-stable/2.346.2/jenkins.war

# 创建目录
➜  mkdir -p /data/test-jenkins-v346/{bin,logs,warcache,home,config}
➜  mv jenkins.war /data/test-jenkins-v346/bin/jenkins-2.346.2-lts.war
```

## 运行

``` zsh
➜  /usr/local/jdk1.8.0_151/bin/java \
    -Dcom.sun.akuma.Daemon=daemonized \
    -Djava.awt.headless=true \
    -Xms512m \
    -Xmx1024m \
    -DJENKINS_HOME=/data/test-jenkins-v346/home \
    -jar /data/test-jenkins-v346/bin/jenkins-2.346.2-lts.war \
    --logfile=/data/test-jenkins-v346/logs/jenkins.log \
    --webroot=/data/test-jenkins-v346/warcache \
    --daemon \
    --httpPort=7008 \
    --debug=5 \
    --handlerCountMax=100 \
    --handlerCountMaxIdle=20 &

➜  ps -ef|grep jenkins
➜  kill $Jenkins_PID
```

## 数据迁移

``` zsh
➜  cd /data/
➜  cp -R test-jenkins/home/jobs/* test-jenkins-v346/home/jobs/
➜  cp -R test-jenkins/home/users/* test-jenkins-v346/home/users/
➜  cp -R test-jenkins/home/plugins test-jenkins-v346/home/plugins/
➜  cp test-jenkins/home/config.xml test-jenkins-v346/home/
```

然后重启Jenkins服务即可

## systemd

``` zsh
➜  cp test-jenkins/config/jenkins test-jenkins-v346/config
```

> 参考文章：  
>
> - [Jenkins 下载中心](https://jenkins.io/download/)  
> - [下载 Jenkins War包](https://get.jenkins.io/war/)  
> - [下载 Jdk](https://jdk.java.net/archive/)  
> - [Jenkins之迁移](https://blog.csdn.net/weixin_38556197/article/details/121134641)  
