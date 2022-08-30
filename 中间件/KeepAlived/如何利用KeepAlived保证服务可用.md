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
draft: false
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

isServiceRun=`ps -C grunt --no-header |wc -l`

while [ $isServiceRun -eq 0 ]
do
    cd /usr/local/elasticsearch-head
    npm run start &

    sleep 5
    isServiceRun=$(ps -ef | grep info | grep -v "grep" | wc -l)
done

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
    interval 10   # 每隔10秒运行一次脚本
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

    #virtual_ipaddress {
    #    192.168.100.244
    #}

}
```

## 四、重启服务

``` zsh
➜  systemctl restart keepalived
```

## 五、验证服务

``` zsh
# 查看服务状态
➜  ps -C grunt --no-header
13368 ?        00:00:00 grunt
➜  ss -tnlp | grep 9100
LISTEN     0      128          *:9100                     *:*                   users:(("grunt",pid=13368,fd=10))

# 杀掉进程
➜  kill 13368
➜  ss -tnlp | grep 9100

# 等待几秒后，进程已经重启完成
➜  ps -C grunt --no-header
24235 ?        00:00:00 grunt
➜  ss -tnlp | grep 9100
LISTEN     0      128          *:9100                     *:*                   users:(("grunt",pid=24235,fd=10))
```

> 参考列表：  
> 1、[Keepalived配置Nginx自动重启](https://blog.csdn.net/kuangxie4668/article/details/104511135)  
> 2、[keepalived实现服务高可用](https://www.cnblogs.com/clsn/p/8052649.html#auto-id-28)  
>