---
title: "如何利用KeepAlived保证服务可用"
date: "2020-07-15"
categories:
    - "技术"
tags:
    - "KeepAlived"
    - "elasticsearch-head"
    - "高可用"
toc: false
indent: false
original: true
---

## 概述

由于 elasticsearch-head 服务老是无缘无故杀后台，不胜其扰。
特采用 KeepAlived 来保证服务的高可用。

## 一、安装 KeepAlived

``` zsh
➜  yum install keepalived -y
➜  rpm -ql keepalived
/etc/keepalived
/etc/keepalived/keepalived.conf
/etc/sysconfig/keepalived
/usr/bin/genhash
/usr/lib/systemd/system/keepalived.service
/usr/libexec/keepalived
/usr/sbin/keepalived
```

## 二、监控脚本

``` zsh
➜  vim /etc/keepalived/check_es_head_alive_or_not.sh
#!/bin/bash

A=`ps -C grunt --no-header |wc -l`

# 判断head是否宕机，如果宕机了，尝试重启
if [ $A -eq 0 ];
then
    /usr/local/elasticsearch-head
    npm run start &

    # 等待一小会再次检查head，如果没有启动成功，则停止keepalived，使其启动备用机
    sleep 3
    if [ `ps -C grunt --no-header | wc -l` -eq 0 ];
    then
        killall keepalived
    fi
fi

➜  chmod u+x /etc/keepalived/check_es_head_alive_or_not.sh
```

## 三、主配置文件

``` zsh
➜  vim /etc/keepalived/keepalived.conf
global_defs {
   router_id keep_136
}

vrrp_script check_es_head_alive {
    script "/etc/keepalived/check_es_head_alive_or_not.sh"
    interval 2    # 每隔两秒运行上一行脚本
    weight 10     # 如果脚本运行成功，则升级权重+10
}

vrrp_instance es_head {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }

    track_script {
        check_es_head_alive   # 追踪 es-head 脚本
    }

    virtual_ipaddress {
        192.168.100.244
    }
}
```

## 四、重启服务

``` zsh
➜  systemctl restart keepalived
```

## 五、验证服务

``` zsh
➜  systemctl status keepalived
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-07-15 19:11:20 CST; 8s ago
  Process: 15711 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 15713 (keepalived)
   CGroup: /system.slice/keepalived.service
           ├─15713 /usr/sbin/keepalived -D
           ├─15714 /usr/sbin/keepalived -D
           └─15715 /usr/sbin/keepalived -D

Jul 15 19:11:22 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244
Jul 15 19:11:22 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:11:24 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:11:26 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: VRRP_Instance(es_head) Sending/queueing gratuitous ARPs on eth0 for 192.168.100.244
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244
Jul 15 19:11:27 DB3 Keepalived_vrrp[15715]: Sending gratuitous ARP on eth0 for 192.168.100.244

➜  ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether c6:4b:fd:f9:16:03 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.213/24 brd 192.168.100.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
    inet 192.168.100.244/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.100.241/24 scope global secondary eth0:0
       valid_lft forever preferred_lft forever
    inet6 fe80::340f:4edf:ce53:6c9/64 scope link noprefixroute
       valid_lft forever preferred_lft forever

ps -ef|grep grunt
root      2584  2569  0 16:40 pts/2    00:00:01 grunt
root     16917  2470  0 19:13 pts/2    00:00:00 grep --color=auto grunt
kill -9 2584

systemctl status keepalived
● keepalived.service - LVS and VRRP High Availability Monitor
   Loaded: loaded (/usr/lib/systemd/system/keepalived.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-07-15 19:11:20 CST; 2min 34s ago
  Process: 15711 ExecStart=/usr/sbin/keepalived $KEEPALIVED_OPTIONS (code=exited, status=0/SUCCESS)
 Main PID: 15713 (keepalived)
   CGroup: /system.slice/keepalived.service
           ├─15713 /usr/sbin/keepalived -D
           ├─15714 /usr/sbin/keepalived -D
           ├─15715 /usr/sbin/keepalived -D
           ├─17422 /usr/sbin/keepalived -D
           ├─17423 /bin/bash /etc/keepalived/check_es_head_alive_or_not.sh
           └─17437 sleep 3

Jul 15 19:13:44 DB3 Keepalived_vrrp[15715]: /etc/keepalived/check_es_head_alive_or_not.sh exited due to signal 15
Jul 15 19:13:44 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:13:46 DB3 Keepalived_vrrp[15715]: /etc/keepalived/check_es_head_alive_or_not.sh exited due to signal 15
Jul 15 19:13:46 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:13:48 DB3 Keepalived_vrrp[15715]: /etc/keepalived/check_es_head_alive_or_not.sh exited due to signal 15
Jul 15 19:13:48 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:13:50 DB3 Keepalived_vrrp[15715]: /etc/keepalived/check_es_head_alive_or_not.sh exited due to signal 15
Jul 15 19:13:50 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1
Jul 15 19:13:52 DB3 Keepalived_vrrp[15715]: /etc/keepalived/check_es_head_alive_or_not.sh exited due to signal 15
Jul 15 19:13:52 DB3 Keepalived_vrrp[15715]: /etc/pg_check.sh exited with status 1

ss -tnlp| grep 9100
```

> 参考列表：  
> 1、[Keepalived配置Nginx自动重启](https://blog.csdn.net/kuangxie4668/article/details/104511135)  
>