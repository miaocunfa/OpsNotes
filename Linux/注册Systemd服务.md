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

| 时间       | 内容                                                                                    |
| ---------- | --------------------------------------------------------------------------------------- |
| 2020-07-28 | 初稿                                                                                    |
| 2020-07-30 | 增加 promtail                                                                           |
| 2020-08-04 | 1、增加 node_exporter </br> 2、增加 prometheus </br> 3、文档结构优化 </br> 4、增加 Loki |
| 2020-08-06 | 1、增加 pg-etcd </br> 2、增加 pg-patroni                                                |
| 2020-08-07 | 修改启动脚本日志部分                                                                    |

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

## 1、seata

``` shell
➜  vim /usr/lib/systemd/system/seata@.service
[Unit]
Description=The Seata Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/seata/bin/seata-server.sh -n %i > /opt/seata/logs/seata-%i.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### 1.1、启动服务

``` zsh
➜  systemctl daemon-reload

➜  systemctl start seata@3
➜  systemctl status seata@3
● seata@3.service - The Seata Server
   Loaded: loaded (/usr/lib/systemd/system/seata@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-07-29 08:43:43 CST; 1s ago
 Main PID: 17960 (sh)
   CGroup: /system.slice/system-seata.slice/seata@3.service
           ├─17960 /bin/sh -c /opt/seata/bin/seata-server.sh -n 3 > /opt/seata/logs/seata-3.log 2>&1
           └─17961 /usr/bin/java -server -Xmx2048m -Xms2048m -Xmn1024m -Xss512k -XX:SurvivorRatio=10 -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=256m -XX:MaxDirectMemorySize=1024m -XX:-O...

Jul 29 08:43:43 node225 systemd[1]: Started The Seata Server.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN No appenders could be found for logger (org.apache.http.client.protocol.RequestAddCookies).
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN Please initialize the log4j system properly.
Jul 29 08:43:45 node225 sh[17960]: log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.

➜  ll /opt/seata/logs/
total 32
-rw-r--r-- 1 root root 28037 Jul 29 08:46 seata-3.log
-rw-r--r-- 1 root root   986 Jul 29 08:44 seata_gc.log
```

## 2、promtail

``` zsh
➜  vim /usr/lib/systemd/system/promtail.service
[Unit]
Description=The Promtail Client
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/promtail/promtail-linux-amd64 -config.file=/opt/promtail/promtail-local-config.yaml > /opt/promtail/promtail.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 3、node_exporter

``` zsh
➜  vim /usr/lib/systemd/system/node_exporter.service
[Unit]
Description=The node_exporter Client
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/node_exporter-0.18.1.linux-amd64/node_exporter --web.listen-address=:10091 > /opt/node_exporter-0.18.1.linux-amd64/node_exporter.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 4、prometheus

``` zsh
➜  vim /usr/lib/systemd/system/prometheus.service
[Unit]
Description=The Prometheus Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/prometheus-2.13.1.linux-amd64/prometheus --config.file=/opt/prometheus-2.13.1.linux-amd64/prometheus.yml --storage.tsdb.retention=180d --web.enable-admin-api > /opt/prometheus-2.13.1.linux-amd64/prometheus.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 5、loki

``` zsh
➜  vim /usr/lib/systemd/system/loki.service
[Unit]
Description=The Loki Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/loki/loki-linux-amd64 -config.file=/opt/loki/loki-local-config.yaml > /opt/loki/loki.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 6、pg-etcd

``` zsh
➜  vim /usr/lib/systemd/system/pg-etcd.service
[Unit]
Description=The etcd Server for postgre
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/pg-HA/etcd/start_etcd.sh > /opt/pg-HA/etcd/etcd.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 7、pg-patroni

``` zsh
➜  vim /usr/lib/systemd/system/pg-patroni.service
[Unit]
Description=The patroni Server for postgre-cluster
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/pg-HA/patroni/start_patroni.sh'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 8、consul

``` zsh
cd /home/wangshuxian
➜  mkdir consul-HA; mv consul consul-HA

# S1
➜  vim /home/wangshuxian/consul-HA/start_consul.sh
consul agent -server \
       -bootstrap-expect 3 \
       -data-dir /tmp/consul \
       -node=c1 \
       -bind=172.19.26.2 \
       -client=0.0.0.0 \
       -ui \
       -retry-join=172.19.26.2 \
       -retry-join=172.19.26.9 \
       -retry-join=172.19.26.10

# S2
➜  vim /home/wangshuxian/consul-HA/start_consul.sh
consul agent -server \
       -bootstrap-expect 3 \
       -data-dir /tmp/consul \
       -node=c2 \
       -bind=172.19.26.9 \
       -client=0.0.0.0 \
       -ui \
       -retry-join=172.19.26.2 \
       -retry-join=172.19.26.9 \
       -retry-join=172.19.26.10

# S3
➜  vim /home/wangshuxian/consul-HA/start_consul.sh
consul agent -server \
       -bootstrap-expect 3 \
       -data-dir /tmp/consul \
       -node=c3 \
       -bind=172.19.26.10 \
       -client=0.0.0.0 \
       -ui \
       -retry-join=172.19.26.2 \
       -retry-join=172.19.26.9 \
       -retry-join=172.19.26.10

➜  vim /usr/lib/systemd/system/consul.service
[Unit]
Description=The consul Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/consul-HA/start_consul.sh > /opt/consul-HA/consul.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

## 9、consul 单节点

``` zsh
vim /usr/lib/systemd/system/consul.service
[Unit]
Description=The consul Server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/bin/sh -c '/opt/consul-standalone/consul agent -dev -advertise 127.0.0.1 -enable-local-script-checks -client=0.0.0.0 > /opt/consul-standalone/consul.log 2>&1'
Restart=always
ExecStop=/usr/bin/kill -15  $MAINPID
KillSignal=SIGTERM
KillMode=mixed
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

> 参考链接：  
> 1、[Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)  
> 2、[systemctl服务编写，及日志控制](https://blog.csdn.net/jeccisnd/article/details/103166554/)  
> 3、[linux kill信号列表](https://www.cnblogs.com/the-tops/p/5604537.html)  
>