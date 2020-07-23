---
title: "PostgreSQL的扩展、复制、备份和恢复"
date: "2020-05-28"
categories:
    - "技术"
tags:
    - "Postgre"
toc: false
original: true
---

## 一、传统扩展

### 1.1、垂直扩展

优点：
1. 无需更改代码

缺点：
1. 线性扩展
可能再次遇到可扩展性的问题
2. 采购和迁移
必须估计在未来几年需要支持的系统负载的准确类型
3. 价格
随着从小型服务器迁移到中型服务器，服务器的价格也会逐渐走高

### 1.2、水平扩展

优点：
1. 可扩展的规模远远超过垂直扩展方法
2. 可以随着需求逐步增加服务器

缺点：
1. 需要监控更多的集群
2. 必须确保为这些集群所做的备份和恢复机制已安排到位
3. 会出现更多的失败点
4. 需要更改应用程序的设置和配置

## 二、复制

### 2.1、主从复制

优点：
并不需要太多的代码更改。就读取而言，这种方法提供了大量节点的扩展能力。

缺点：
就写入而言，扩展能力仅限于一个节点。

PostgreSQL所提供的的所有复制都涉及了Write Ahead Logs(WAL)的使用。我们之前所提及的这些日志记录了对数据所做的所有的更改。一旦一个文件被填满，服务器便会移动并开始写入到下一个文件。一旦已经发生的变化被记录到相应的数据文件中，WAL文件中的数据便不再有用，且可以被覆盖。

所谓日志传递，即把WAL文件（已被填满的）移动到另一个服务器或者在同一个服务器上的另一个集群中使用WAL文件。  

日志传送是**异步**的，其中在主服务器上所提交的数据出现在从服务器之前，可以有一个延迟。从服务器**最终**会与主服务器保持一致，而不是时刻与主服务器保持一致。这也意味着有可能出现**数据丢失**的问题，特别当主服务器发生崩溃时，事务可能未得到及时传递。

PostgreSQL (8.*) 这些早期版本，归档WAL日志是用来为集群故障转移准备的。该集群将在恢复模式下运行，在恢复完成之前（即主服务器故障转移完成前）都不可能连接到服务器上。

PostgreSQL 9.0 版本增加了热备。可以连接到备用服务器执行查询。因此，读取的可扩展性是可能的。但由于WAL日志不得被传递，所以相较主服务器，备用服务器可能仍有滞后。这个滞后可以通过增加流复制来减少。

### 2.2、流复制

WAL记录产生后，无需等日志文件被填充，我们就可以得到这些记录。这样就可以减少滞后。

流复制，可以让我们进行读写分离的水平扩展，且是最低延迟的。在失败的情况下，它会让备用服务器升级为主服务器。

配置主服务器

``` bash
➜  vim /var/lib/pgsql/10/data/postgresql.conf
wal_level = logical                     # minimal, replica, or logical  WAL级别，hot_standby时信息量会上升
                                        # (change requires restart)     改变必须重启
archive_mode = on               # enables archiving; off, on, or always
                                # (change requires restart)
archive_command = 'test ! -f /var/lib/pgsql/10/data/arch_dir/%f && cp %p /var/lib/pgsql/10/data/arch_dir/%f'            # command to use to archive a logfile segment
                                # placeholders: %p = path of file to archive
                                #               %f = file name only
                                # e.g. 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'
#archive_timeout = 0            # force a logfile segment switch after this
                                # number of seconds; 0 disables

➜  vim /var/lib/pgsql/10/data/pg_hba.conf
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     trust
host    replication     all             127.0.0.1/32            trust
host    replication     all             ::1/128                 trust
host    replication     rep             192.168.100.0/24        trust
host    bench           bench           192.168.100.0/24        trust
```

配置从服务器

``` bash
➜  vim /var/lib/pgsql/10/data/recovery.conf
standby_mode = 'on'
primary_conninfo = 'user=rep password=rep123 host=192.168.100.213 port=5432 sslmode=prefer sslcompression=1 krbsrvname=postgres target_session_attrs=any'
```
