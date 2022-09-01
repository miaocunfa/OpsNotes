---
title: "同一台服务器部署多个Jenkins服务"
date: "2022-05-26"
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
| 2022-05-26 | 初稿                |
| 2022-05-27 | 稳定性改造           |

## 软件版本

| soft      | Version     |
| --------- | ----------- |
| CentOS    | 7.7         |
| Jenkins1  | 2.234       |
| Jenkins2  | 2.241       |

## 楔子

最近观察公司服务器，部署测试 Jenkins服务的服务器因为部署了太多服务 处于一个负载极高的情况，而且每次Jenkins服务 一发布，就影响了那台服务器上的其它服务。  
而生产 Jenkins服务由于 不经常发布部署任务，也没有部署其它服务，基本上没有负载，就想把这台服务器也利用起来，让一台服务器同时跑 测试和生产的 Jenkins服务。
期间也测试过用 docker服务 去同时跑 测试、生产两个Jenkins服务，但由于挂载路径过多，不是特别实用，失去容器的意义了。所以现在改为物理部署两个版本的Jenkins。

## 迁移测试Jenkins

由于测试 以及生产的 Jenkins处于不同版本，这种情况也是需要把 Jenkins程序 分开处理的。

通过 `sh -x /etc/rc.d/init.d/jenkins start` 获取到的 Jenkins启动命令

``` zsh
# 启动命令
/usr/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -Xms256m -Xmx512m -XX:MaxNewSize=256m -XX:MaxPermSize=256m -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=7001 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
```

观察启动命令，只需要将 war文件、以及JenkinsHome下的内容 发送到生产服务器上即可。

``` zsh
# 先在生产主机，做一些准备工作
# 处理 Test Jenkins 目录
➜  mkdir -p /data/test-jenkins/{bin,logs,warcache,home}

#-------------------------------------------------

# Host: Test
# Jenkins war
➜  cd /usr/lib/jenkins/
➜  scp jenkins.war root@192.168.189.182:/data/test-jenkins/bin/jenkins-2.234.war

#-------------------------------------------------

# Host: Test
# JenkinsHome
➜  cd /var/lib/jenkins/workspace
➜  rm -rf ./*

# 将清理后的整个 $Jenkins_HOME 打为tar包
➜  cd /var/lib
➜  tar -cf test-jenkinsHome_2.234_backup.tar ./jenkins/

# 使用 scp命令 将tar包拷贝到新主机上
➜  scp test-jenkinsHome_2.234_backup.tar root@192.168.189.182:/data/test-jenkins

# Host: 生产
➜  cd /data/test-jenkins
➜  tar -xf test-jenkinsHome_2.234_backup.tar
➜  mv jenkins home
```

测试 Jenkins 启动命令

``` zsh
➜  /usr/bin/java \
-Dcom.sun.akuma.Daemon=daemonized \
-Djava.awt.headless=true \
-Xms256m \
-Xmx512m \
-XX:MaxNewSize=256m \
-XX:MaxPermSize=256m \
-DJENKINS_HOME=/data/test-jenkins/home \
-jar /data/test-jenkins/bin/jenkins-2.234.war \
--logfile=/data/test-jenkins/logs/jenkins.log \
--webroot=/data/test-jenkins/warcache \
--daemon \
--httpPort=7001 \
--debug=5 \
--handlerCountMax=100 \
--handlerCountMaxIdle=20 &
```

## 生产Jenkins

为了统一管理Jenkins服务，我们将生产Jenkins 的目录层级也进行一下处理

``` zsh
# 处理 Prod Jenkins 目录
➜  mkdir -p /data/prod-jenkins/{bin,logs,warcache,home}

# Prod Jenkins war
➜  cp /usr/lib/jenkins/jenkins.war /data/prod-jenkins/bin/jenkins-2.241.war

# JenkinsHome
➜  cd /var/lib/jenkins/workspace
➜  rm -rf ./*

➜  cd /var/lib
➜  cp -R jenkins/* /data/prod-jenkins/home
```

## 稳定性改造

经过我们测试使用发现 `java -jar` 启动的 Jenkins 服务时常被杀后台，所以决定还是以 系统服务systemctl 方式启动

①测试 Jenkins

进行启动文件改造

``` zsh
# 配置文件
➜  mkdir -p /data/test-jenkins/config
➜  cp /etc/sysconfig/jenkins /data/test-jenkins/config

# 修改配置文件
➜ vim /data/test-jenkins/config/jenkins
JENKINS_HOME="/data/test-jenkins/home"
JENKINS_PORT="7001"

# systemctl 服务文件
➜  cp /etc/rc.d/init.d/jenkins /etc/rc.d/init.d/test-jenkins

# 修改 test-jenkins 服务
➜  vim /etc/rc.d/init.d/test-jenkins
JENKINS_WAR="/data/test-jenkins/bin/jenkins-2.234.war"
JENKINS_CONFIG=/data/test-jenkins/config/jenkins

JENKINS_PID_FILE="/data/test-jenkins/logs/jenkins.pid"
JENKINS_LOCKFILE="/data/test-jenkins/logs/jenkins.lock"

PARAMS="--logfile=/data/test-jenkins/logs/jenkins.log --webroot=/data/test-jenkins/warcache --daemon"
```

通过 systemctl 启动

``` zsh
# 重载配置文件 & 启动 test-jenkins 服务
➜  systemctl daemon-reload
➜  systemctl start test-jenkins

# 查看 test-jenkins 服务状态
➜  systemctl status test-jenkins
● test-jenkins.service - LSB: Jenkins Automation Server
   Loaded: loaded (/etc/rc.d/init.d/test-jenkins; bad; vendor preset: disabled)
   Active: active (running) since Fri 2022-05-27 11:33:45 CST; 24s ago
     Docs: man:systemd-sysv-generator(8)
   CGroup: /system.slice/test-jenkins.service
           └─16919 /usr/local/jdk1.8.0_151/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/data/test-jenkins/home -jar /data/test-jenkins/bin/jenkins-2.234.war --logfil...

May 27 11:33:44 production-jenkins01 systemd[1]: Starting LSB: Jenkins Automation Server...
May 27 11:33:44 production-jenkins01 runuser[16899]: pam_unix(runuser:session): session opened for user root by (uid=0)
May 27 11:33:45 production-jenkins01 runuser[16899]: pam_unix(runuser:session): session closed for user root
May 27 11:33:45 production-jenkins01 test-jenkins[16894]: Starting Jenkins [  OK  ]
May 27 11:33:45 production-jenkins01 systemd[1]: Started LSB: Jenkins Automation Server.
```

②生产 Jenkins

由于生产 Jenkins 也调整了目录层级，这个系统服务 也需要重新调整

``` zsh
# 配置文件
➜  mkdir -p /data/prod-jenkins/config
➜  cp /etc/sysconfig/jenkins /data/prod-jenkins/config

# 修改配置文件
➜ vim /data/prod-jenkins/config/jenkins
JENKINS_HOME="/data/prod-jenkins/home"

# systemctl 服务文件
➜  mv /etc/rc.d/init.d/jenkins /etc/rc.d/init.d/prod-jenkins

# 修改 prod-jenkins 服务
➜  vim /etc/rc.d/init.d/prod-jenkins
JENKINS_WAR="/data/prod-jenkins/bin/jenkins-2.241.war"
JENKINS_CONFIG=/data/prod-jenkins/config/jenkins

JENKINS_PID_FILE="/data/prod-jenkins/logs/jenkins.pid"
JENKINS_LOCKFILE="/data/prod-jenkins/logs/jenkins.lock"

PARAMS="--logfile=/data/prod-jenkins/logs/jenkins.log --webroot=/data/prod-jenkins/warcache --daemon"
```

通过 systemctl 启动

``` zsh
# 重载配置文件 & 启动 prod-jenkins 服务
➜  systemctl daemon-reload
➜  systemctl start prod-jenkins

# 查看 prod-jenkins 服务状态
➜  systemctl status prod-jenkins
systemctl status prod-jenkins
● prod-jenkins.service - LSB: Jenkins Automation Server
   Loaded: loaded (/etc/rc.d/init.d/prod-jenkins; bad; vendor preset: disabled)
   Active: active (running) since Fri 2022-05-27 14:28:16 CST; 6s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 13156 ExecStart=/etc/rc.d/init.d/prod-jenkins start (code=exited, status=0/SUCCESS)
    Tasks: 48
   Memory: 457.1M
   CGroup: /system.slice/prod-jenkins.service
           └─13181 /usr/local/jdk1.8.0_151/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/data/prod-jenkins/home -jar /data/prod-jenkins/bin/jenkins-2.241.war --logfil...

May 27 14:28:15 production-jenkins01 systemd[1]: Starting LSB: Jenkins Automation Server...
May 27 14:28:15 production-jenkins01 runuser[13161]: pam_unix(runuser:session): session opened for user root by (uid=0)
May 27 14:28:16 production-jenkins01 runuser[13161]: pam_unix(runuser:session): session closed for user root
May 27 14:28:16 production-jenkins01 prod-jenkins[13156]: Starting Jenkins [  OK  ]
May 27 14:28:16 production-jenkins01 systemd[1]: Started LSB: Jenkins Automation Server.
```

> 参考文章：  
>
> - [一台服务器安装多个 Jenkins 系统服务运行](https://www.bianchengquan.com/article/380292.html)  
> - [jenkins修改同时构建Job个数](https://www.likecs.com/show-305668792.html)  
> - [在同一台Windows机器上安装多个Jenkins实例导致问题](https://zgserver.com/windowsjenkins-3.html)  
>
