---
title: "Jenkins 错误处理"
date: "2022-07-29"
categories:
    - "技术"
tags:
    - "错误处理"
    - "Jenkins"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                 |
| ---------- | ------------------- |
| 2022-07-29 | 初稿                |

## JDK版本问题

``` zsh
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=256m; support was removed in 8.0
Jul 19, 2022 5:11:49 PM executable.Main verifyJavaVersion
SEVERE: Running with Java class version 52, which is older than the Minimum required version 55. See https://jenkins.io/redirect/java-support/
java.lang.UnsupportedClassVersionError: 52.0
        at executable.Main.verifyJavaVersion(Main.java:145)
        at executable.Main.main(Main.java:109)

Jenkins requires Java versions [17, 11] but you are running with Java 1.8 from /usr/local/jdk1.8.0_151/jre
java.lang.UnsupportedClassVersionError: 52.0
        at executable.Main.verifyJavaVersion(Main.java:145)
        at executable.Main.main(Main.java:109)
```

下载 openjdk11

``` zsh
➜  cd /usr/local
➜  wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
➜  tar -xf openjdk-11.0.2_linux-x64_bin.tar.gz

➜  cd jdk-11.0.2/bin
➜  ./java -version
openjdk version "11.0.2" 2019-01-15
OpenJDK Runtime Environment 18.9 (build 11.0.2+9)
OpenJDK 64-Bit Server VM 18.9 (build 11.0.2+9, mixed mode)
```

## Out of Memory

``` zsh
➜  tail -f -n 300 /var/log/messages
Jul 28 16:08:07 production-jenkins01 kernel: Out of memory: Kill process 3487 (java) score 306 or sacrifice child
Jul 28 16:08:07 production-jenkins01 kernel: Killed process 3487 (java) total-vm:6063552kB, anon-rss:2524792kB, file-rss:0kB, shmem-rss:0kB
Jul 28 16:08:07 production-jenkins01 test-jenkins-v360: bash: line 1:  3487 Killed                  /usr/local/jdk-11.0.2/bin/java -Djava.awt.headless=true -server -Xms1024m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m -DJENKINS_HOME=/data/test-jenkins-v360/home -jar /data/test-jenkins-v360/bin/jenkins-2.360.war --logfile=/data/test-jenkins-v360/logs/jenkins.log --webroot=/data/test-jenkins-v360/warcache --daemon --httpPort=7008 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20
```

修改配置文件

``` zsh
# 增加内存限制
vim /data/test-jenkins-v360/config/jenkins
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -server -Xms1024m -Xmx2048m -XX:PermSize=256m -XX:MaxPermSize=512m"
```
