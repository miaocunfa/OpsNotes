---
title: "注册Systemd服务"
date: "2020-07-28"
categories:
    - "技术"
tags:
    - "Systemd"
toc: false
indent: false
original: true
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-07-28 | 初稿 |

## 示例

``` shell
[Unit]
# 定义描述
Description=The Apache HTTP Server
# 指定了在systemd在执行完那些target之后再启动该服务
After=network.target remote-fs.target nss-lookup.target

[Service]
# 定义Service 的运行type，一般是forking，就是后台运行
Type=notify
Environment=LANG=C
# 以下定义systemctl start |stop |reload *.service  的每个执行方法，具体命令#需要写绝对路径
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
# 创建私有的内存临时空间
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 案列

``` shell
➜  vim /usr/lib/systemd/system/seata@.service
[Unit]
Description=The Seata Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/seata/bin/seata-server.sh -n %i 2>&1 > /opt/seata/logs/seata-%i.log'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

启用 Service

``` zsh
➜  systemctl daemon-reload
➜  systemctl start seata@3
➜  systemctl status seata@3
● seata@3.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-07-29 08:43:43 CST; 1s ago
 Main PID: 17960 (sh)
   CGroup: /system.slice/system-seata.slice/seata@3.service
           ├─17960 /bin/sh -c /opt/seata/bin/seata-server.sh -n 3 2>&1 > /opt/seata/logs/seata-3.log
           └─17961 /usr/bin/java -server -Xmx2048m -Xms2048m -Xmn1024m -Xss512k -XX:SurvivorRatio=10 -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=1024m -XX:-O...

Jul 29 08:43:43 node225 systemd[1]: Started The Seata Server.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN No appenders could be found for logger (org.apache.http.client.protocol.RequestAddCookies).
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN Please initialize the log4j system properly.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
➜  cd /opt/seata/logs/
➜  ll
total 32
-rw-r--r-- 1 root root 28037 Jul 29 08:46 seata-3.log
-rw-r--r-- 1 root root   986 Jul 29 08:44 seata_gc.log
```

> 参考链接：  
> 1、[Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)  
> 2、[systemctl服务编写，及日志控制](https://blog.csdn.net/jeccisnd/article/details/103166554/)  
> 3、[linux kill信号列表](https://www.cnblogs.com/the-tops/p/5604537.html)  
>