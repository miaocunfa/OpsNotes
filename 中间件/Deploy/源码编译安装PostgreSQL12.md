---
title: "源码编译安装 PostgreSQL 12"
date: "2019-11-08"
categories:
    - "技术"
tags:
    - "PostgreSQL"
    - "数据库"
    - "服务部署"
toc: true
original: true
draft: false
---

## 一、环境准备

``` bash
# 创建组和用户
groupadd postgre
useradd -g postgre -G postgre -d /home/postgresql postgre
# 修改用户密码
passwd postgre  # web2019+
# 安装依赖包
[root@jiexian /home/postgresql]# yum install -y bzip2 readline-devel zlib-devel
```

## 二、源码包下载

``` bash
[root@jiexian ~]#cd /home/postgresql/
[root@jiexian /home/postgresql]# wget https://mirrors.tuna.tsinghua.edu.cn/postgresql/source/v12.0/postgresql-12.0.tar.bz2
```

## 三、编译安装

``` bash
[root@jiexian /home/postgresql]# bunzip2 postgresql-12.0.tar.bz2
[root@jiexian /home/postgresql]# tar -xvf ./postgresql-12.0.tar

[root@jiexian /home/postgresql]# cd postgresql-12.0/
[root@jiexian /home/postgresql/postgresql-12.0]# ./configure --prefix=/home/postgresql/dbhome
[root@jiexian /home/postgresql/postgresql-12.0]# make && make install
```

make及make install完成后最后一行输出信息为下即为安装成功

``` zsh
PostgreSQL installation complete.
```

安装完成后，PostgreSQL安装在如下位置

``` bash
[root@jiexian /home/postgresql/postgresql-12.0]# cd /home/postgresql/dbhome/
[root@jiexian /home/postgresql/dbhome]# ll
总用量 16
drwxr-xr-x 2 root root 4096 11月  8 21:07 bin
drwxr-xr-x 6 root root 4096 11月  8 21:07 include
drwxr-xr-x 4 root root 4096 11月  8 21:07 lib
drwxr-xr-x 6 root root 4096 11月  8 21:07 share
```

## 四、环境变量

``` bash
[root@jiexian ~]# su - postgre
[postgre@jiexian ~]$ vi .bash_profile
export LD_LBRARY_PATH=$HOME/dbhome/lib:$LD_LIBRARY_PATH
export PATH=$HOME/dbhome/bin:$PATH

# 加载环境变量
[postgre@jiexian ~]$ source .bash_profile
```

## 五、PostgreSQL使用

``` bash
# 创建PostgreSQL的数据路径
[postgre@jiexian ~]$ mkdir $HOME/data

# 初始化数据库
[postgre@jiexian ~]$initdb --locale=C -E UNICODE -D $HOME/data/
The files belonging to this database system will be owned by user "postgre".
This user must also own the server process.

The database cluster will be initialized with locale "C".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /home/postgresql/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... PRC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

initdb: warning: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    pg_ctl -D /home/postgresql/data/ -l logfile start

# 初始化完成后，在最后一行会提示我们启动数据库的方法
# 查看一下 $HOME/data 路径中的内容
[postgre@jiexian ~]$cd data
[postgre@jiexian ~/data]$ll
总用量 116
drwx------ 5 postgre postgre  4096 11月  8 21:31 base
drwx------ 2 postgre postgre  4096 11月  8 21:31 global
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_commit_ts
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_dynshmem
-rw------- 1 postgre postgre  4513 11月  8 21:31 pg_hba.conf
-rw------- 1 postgre postgre  1636 11月  8 21:31 pg_ident.conf
drwx------ 4 postgre postgre  4096 11月  8 21:31 pg_logical
drwx------ 4 postgre postgre  4096 11月  8 21:31 pg_multixact
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_notify
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_replslot
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_serial
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_snapshots
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_stat
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_stat_tmp
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_subtrans
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_tblspc
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_twophase
-rw------- 1 postgre postgre     3 11月  8 21:31 PG_VERSION
drwx------ 3 postgre postgre  4096 11月  8 21:31 pg_wal
drwx------ 2 postgre postgre  4096 11月  8 21:31 pg_xact
-rw------- 1 postgre postgre    88 11月  8 21:31 postgresql.auto.conf
-rw------- 1 postgre postgre 26575 11月  8 21:31 postgresql.conf
```

## 六、配置文件

主要修改 $HOME/data 中的 postgresql.conf 及 pg_hba.conf 文件
postgresql.conf 用来配置数据库实例
pg_hba.conf 用来配置数据库访问授权

### postgresql.conf

将监听地址修改为 ifconfig 中的地址，端口禁用去掉。

``` conf
listen_addresses = '172.16.100.187'             # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
port = 5432                             # (change requires restart)
```

### pg_hba.conf

将下列内容追加至 pg_hba.conf 最后一行

``` zsh
# 允许所有网段访问 PostgreSQL
host    all             all             0.0.0.0/0               trust
```

## 七、数据库启停

PostgreSQL启动关闭命令

``` zsh
pg_ctl -D <数据存放路径> [ stop | start ]
```

示例如下

``` bash
[postgre@jiexian ~/data]$pg_ctl -D $HOME/data -l logfile start
waiting for server to start.... done
server started
[postgre@jiexian ~/data]$pg_ctl -D $HOME/data stop
waiting for server to shut down.... done
server stopped
```

``` zsh
# 启动时 -l logfile 指明日志输出的位置
[postgre@jiexian ~/data]$ll
-rw------- 1 postgre postgre   929 11月  8 21:44 logfile
```
