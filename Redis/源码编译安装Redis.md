---
title: "源码编译安装Redis"
date: "2020-08-19"
categories:
    - "技术"
tags:
    - "Redis"
    - "服务部署"
toc: false
original: true
draft: false
---

## 1、官网下载

``` zsh
➜  wget http://download.redis.io/releases/redis-5.0.5.tar.gz
```

## 2、编译

``` zsh
➜  cd redis-5.0.5
➜  make PREFIX=/usr/local/redis install

➜  tree /usr/local/redis
/usr/local/redis
└── bin
    ├── redis-benchmark
    ├── redis-check-aof
    ├── redis-check-rdb
    ├── redis-cli
    ├── redis-sentinel -> redis-server
    └── redis-server
```

## 3、安装

``` zsh
➜  cd redis-5.0.5/utils
➜  ./install_server.sh
Welcome to the redis service installer
This script will help you easily set up a running redis server

Please select the redis port for this instance: [6379]
Selecting default: 6379
Please select the redis config file name [/etc/redis/6379.conf]
Selected default - /etc/redis/6379.conf
Please select the redis log file name [/var/log/redis_6379.log] /ahdata/redis/redis_6379.log
Please select the data directory for this instance [/var/lib/redis/6379] /ahdata/redis/data
Please select the redis executable path [] /usr/local/redis/bin/redis-server
Selected config:
Port           : 6379
Config file    : /etc/redis/6379.conf
Log file       : /ahdata/redis/redis_6379.log
Data dir       : /ahdata/redis/data
Executable     : /usr/local/redis/bin/redis-server
Cli Executable : /usr/local/redis/bin/redis-cli
Is this ok? Then press ENTER to go on or Ctrl-C to abort.
Copied /tmp/6379.conf => /etc/init.d/redis_6379
Installing service...
Successfully added to chkconfig!
Successfully added to runlevels 345!
Starting Redis server...
Installation successful!
```

## 4、启动

``` zsh
➜  systemctl start redis_6379
➜  systemctl status redis_6379
● redis_6379.service - LSB: start and stop redis_6379
   Loaded: loaded (/etc/rc.d/init.d/redis_6379; bad; vendor preset: disabled)
   Active: active (exited) since Wed 2020-08-19 18:16:14 CST; 2s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 30993 ExecStart=/etc/rc.d/init.d/redis_6379 start (code=exited, status=0/SUCCESS)

Aug 19 18:16:14 pg1.aihangxunxi.com systemd[1]: Starting LSB: start and stop redis_6379...
Aug 19 18:16:14 pg1.aihangxunxi.com redis_6379[30993]: /var/run/redis_6379.pid exists, process is already running or crashed
Aug 19 18:16:14 pg1.aihangxunxi.com systemd[1]: Started LSB: start and stop redis_6379.
```

## 5、运维

``` zsh
# 安装路径：/usr/local/redis/bin

# 加入PATH
➜  vim /etc/profile
export PATH=/usr/local/bin/:/usr/local/redis/bin:$PATH

➜  source /etc/profile
```
