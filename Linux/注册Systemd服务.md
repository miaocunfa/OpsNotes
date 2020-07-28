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
# 定义描述
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
#StandardOutput=file:/opt/seata/logs/seata-%i.log

[Install]
WantedBy=multi-user.target
```

``` zsh
cd /usr/lib/systemd/system
systemctl daemon-reload
systemctl enable seata@1
systemctl start seata@1
systemctl status seata@1
● seata@1.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-07-28 20:05:01 CST; 3s ago
 Main PID: 24638 (java)
   CGroup: /system.slice/system-seata.slice/seata@1.service
           └─24638 /usr/bin/java -server -Xmx2048m -Xms2048m -Xmn1024m -Xss512k -XX:SurvivorRatio=10 -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=1024m -XX:-O...

Jul 28 20:05:01 n223 seata-server.sh[24638]: 20:05:01,694 |-INFO in c.q.l.core.rolling.helper.TimeBasedArchiveRemover - Removed  0 Bytes of files
Jul 28 20:05:01 n223 seata-server.sh[24638]: 20:05:01,695 |-INFO in ch.qos.logback.classic.joran.JoranConfigurator@64bf3bbf - Registering current configuration as safe fallback point
Jul 28 20:05:01 n223 seata-server.sh[24638]: 2020-07-28 20:05:01.819  INFO --- [           main] io.seata.config.FileConfiguration        : The configuration file used is registry.conf
Jul 28 20:05:01 n223 seata-server.sh[24638]: 2020-07-28 20:05:01.850  INFO --- [           main] io.seata.config.FileConfiguration        : The configuration file used is file.conf
Jul 28 20:05:02 n223 seata-server.sh[24638]: 2020-07-28 20:05:02.283  INFO --- [           main] i.s.core.rpc.netty.NettyServerBootstrap  : Server started, listen port: 8091
Jul 28 20:05:02 n223 seata-server.sh[24638]: log4j:WARN No appenders could be found for logger (org.apache.http.client.protocol.RequestAddCookies).
Jul 28 20:05:02 n223 seata-server.sh[24638]: log4j:WARN Please initialize the log4j system properly.
Jul 28 20:05:02 n223 seata-server.sh[24638]: log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
Jul 28 20:05:03 n223 seata-server.sh[24638]: 2020-07-28 20:05:03.023  INFO --- [IOWorker_1_1_16] i.s.c.r.n.AbstractNettyRemotingServer    : 192.168.100.223:54390 to server channel inactive.
Jul 28 20:05:03 n223 seata-server.sh[24638]: 2020-07-28 20:05:03.024  INFO --- [IOWorker_1_1_16] i.s.c.r.n.AbstractNettyRemotingServer    : remove unused channel:[id: 0x670cb...0.223:54390]
Hint: Some lines were ellipsized, use -l to show in full.
```

```
[root@n223 /usr/lib/systemd/system]# systemctl status seata@1
● seata@1.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Tue 2020-07-28 20:09:20 CST; 5min ago
 Main PID: 24638 (code=exited, status=143)

Jul 28 20:09:02 n223 seata-server.sh[24638]: 2020-07-28 20:09:02.968  INFO --- [IOWorker_1_5_16] i.s.c.r.n.AbstractNettyRemotingServer    : 192.168.100.223:56734 to server channel inactive.
Jul 28 20:09:02 n223 seata-server.sh[24638]: 2020-07-28 20:09:02.968  INFO --- [IOWorker_1_5_16] i.s.c.r.n.AbstractNettyRemotingServer    : remove unused channel:[id: 0x41d99...0.223:56734]
Jul 28 20:09:12 n223 seata-server.sh[24638]: 2020-07-28 20:09:12.968  INFO --- [IOWorker_1_6_16] i.s.c.r.n.AbstractNettyRemotingServer    : 192.168.100.223:56788 to server channel inactive.
Jul 28 20:09:12 n223 seata-server.sh[24638]: 2020-07-28 20:09:12.969  INFO --- [IOWorker_1_6_16] i.s.c.r.n.AbstractNettyRemotingServer    : remove unused channel:[id: 0x569ff...0.223:56788]
Jul 28 20:09:16 n223 systemd[1]: Stopping The Seata Server...
Jul 28 20:09:20 n223 systemd[1]: seata@1.service: main process exited, code=exited, status=143/n/a
Jul 28 20:09:20 n223 systemd[1]: Stopped The Seata Server.
Jul 28 20:09:20 n223 systemd[1]: Unit seata@1.service entered failed state.
Jul 28 20:09:20 n223 systemd[1]: seata@1.service failed.
Jul 28 20:09:25 n223 systemd[1]: [/usr/lib/systemd/system/seata@.service:14] Failed to parse output specifier, ignoring: /opt/seata/logs/seata-run.log

systemctl status seata@1
● seata@1.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2020-07-28 20:36:47 CST; 8s ago
 Main PID: 31288 (sh)
   CGroup: /system.slice/system-seata.slice/seata@1.service
           ├─31288 /bin/sh -c /opt/seata/bin/seata-server.sh -n 1 2>&1 > /opt/seata/logs/seata-1.log
           └─31289 /usr/bin/java -server -Xmx2048m -Xms2048m -Xmn1024m -Xss512k -XX:SurvivorRatio=10 -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=1024m -XX:-O...

Jul 28 20:36:47 n223 systemd[1]: Started The Seata Server.
Jul 28 20:36:49 n223 sh[31288]: log4j:WARN No appenders could be found for logger (org.apache.http.client.protocol.RequestAddCookies).
Jul 28 20:36:49 n223 sh[31288]: log4j:WARN Please initialize the log4j system properly.
Jul 28 20:36:49 n223 sh[31288]: log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.

[root@n223 /opt/seata/logs]# ll
total 16
-rw-r--r--. 1 root root 15239 Jul 28 20:37 seata-1.log
-rw-r--r--. 1 root root     0 Jul 28 20:36 seata_gc.log
```

> 参考链接：  
> 1、[Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)  
> 2、[systemctl服务编写，及日志控制](https://blog.csdn.net/jeccisnd/article/details/103166554/)  
> 3、[linux kill信号列表](https://www.cnblogs.com/the-tops/p/5604537.html)  
>