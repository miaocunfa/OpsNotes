---
title: "使用mariabackup备份mariadb10.3+"
date: "2020-04-03"
categories:
    - "技术"
tags:
    - "mariabackup"
    - "mariadb"
    - "mysql"
    - "xtrabackup"
toc: false
indent: false
original: true
draft: false
---

## 环境版本

``` zsh
    mariadb: 10.3.16
    mariabackup: 10.3.22
```

本来开始想使用xtrabackup进行物理备份的。但是根据percona官网的 [issue：xtrabackup & mariadb 10.3](https://jira.percona.com/browse/PXB-1550) 所述  

``` zsh
XtraBackup is not compatible with MariaDB 10.3 and later.
```

我们使用mariadb的开源解决方案 [mariabackup](https://mariadb.com/kb/en/mariabackup/
)

## 一、安装

``` zsh
# 下载离线包
➜  wget https://mirrors.ustc.edu.cn/mariadb/yum/10.3/centos7-amd64/rpms/MariaDB-backup-10.3.22-1.el7.centos.x86_64.rpm

# 安装离线包
➜  yum -y install MariaDB-backup-10.3.22-1.el7.centos.x86_64.rpm
```

## 二、语法格式

### 选项

``` zsh
Usage: mariabackup [--defaults-file=#] [--backup | --prepare | --copy-back | --move-back] [OPTIONS]

    --defaults-file    指定配置文件：只能从给定的文件中读取默认选项。 且必须作为命令行上的第一个选项；必须是一个真实的文件，它不能是一个符号链接。

    --backup       备份数据库    使用此命令选项，Mariabackup会对您的数据库执行备份操作。备份将写入目标目录，由--target-dir选项设置。

    --prepare      准备备份    Mariabackup在目标目录中创建的数据文件在时间点上不一致，因为在备份操作期间数据文件是在不同的时间复制的。如果您尝试从这些文件中还原，InnoDB会发现不一致之处并崩溃以保护您免受损坏。在恢复备份之前，首先需要使用--prepare选项。在完全备份的情况下，这使得文件的时间点保持一致。如果是增量备份，这会将增量应用于基本备份。准备好备份后，就可以使用--copy-back还原备份。
    
    --copy-back    还原备份    使用此命令，Mariabackup将备份从目标目录复制到数据目录，如--datadir选项所定义。您必须在运行此命令之前停止MariaDB服务器。数据目录必须为空。如果要使用备份覆盖数据目录，请使用该--force-non-empty-directories选项。
    
    --move-back    还原备份并移除    在还原备份的过程中，运行--copy-back命令会将备份文件复制到数据目录，并且备份会被保留。如果您不想保存备份以供日后使用，请使用该--move-back命令。
```

### options

``` zsh
    --target-dir=name
    --tables=name       filtering by regexp for table names.
    --tables-file=name  filtering by list of the exact database.table name in the
                      file.
    --databases=#       指定备份的数据库和表，格式为：--database="db1[.tb1] db2[.tb2]" 多个库之间以空格隔开，如果此选项不被指定，将会备份所有的数据库。
    --databases-file=name 
                      filtering by list of databases in the file.
```

### 用户授权

Mariabackup执行备份操作时（即，指定了--backup选项时）需要与数据库服务器进行身份验证。对于大多数使用情况，执行备份需求的用户帐户有RELOAD，PROCESS，LOCK TABLES和REPLICATION CLIENT 全局权限的数据库服务器上。

``` zsh
mysql > CREATE USER 'mariabackup'@'localhost' IDENTIFIED BY 'back123!@#';
mysql > GRANT RELOAD, PROCESS, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'mariabackup'@'localhost';
```

## 三、全量备份 && 还原

### 3.1、全量备份

为了备份数据库，您需要运行 `mariabackup --backup` 并且使用 `--target-dir` 选项指定将备份文件放置在何处。进行完全备份时，目标目录必须为空或不存在。

``` zsh
➜  mkdir -p /ahdata/mariabackup/$(date +'%Y%m%d')

➜  mariabackup --backup \
        --databases=produce_move \
        --target-dir=/ahdata/mariabackup/$(date +'%Y%m%d') \
        --user=mariabackup --password='back123!@#'


[00] 2020-04-03 15:32:48 Backup created in directory '/ahdata/mariabackup/20200403/'
[00] 2020-04-03 15:32:48 Writing backup-my.cnf
[00] 2020-04-03 15:32:48         ...done
[00] 2020-04-03 15:32:48 Writing xtrabackup_info
[00] 2020-04-03 15:32:48         ...done
[00] 2020-04-03 15:32:48 Redo log (from LSN 33611469985 to 33611469994) was copied.
[00] 2020-04-03 15:32:48 completed OK!
```

备份所需的时间取决于要备份的数据库或表的大小。您可以根据需要取消备份，因为备份过程不会修改数据库。

Mariabackup将备份文件写入目标目录。如果目标目录不存在，那么它将创建它。如果目标目录存在并包含文件，那么它将引发错误并中止。

### 3.2、准备

在恢复备份之前，首先需要使用--prepare选项。在完全备份的情况下，这使得文件的时间点保持一致。

``` zsh
➜  mariabackup --prepare --target-dir=/ahdata/mariabackup/$(date +'%Y%m%d') 
```

### 3.3、还原

在MariaDB 10.1.36，MariaDB 10.2.18和MariaDB 10.3.10之前，如果您正在执行--copy-back操作，并且没有datadir在命令行或受支持的服务器选项组之一上为该选项明确指定值，在选项文件中，则Mariabackup不会默认为服务器的default datadir。相反，Mariabackup会因错误而失败。

``` log
    Error: datadir must be specified.
```

还原准备

``` zsh
➜  tar -zcvf mariabackup-20200403.tgz /ahdata/mariabackup/20200403
➜  scp MariaDB-backup-10.3.22-1.el7.centos.x86_64.rpm n215:~
➜  scp mariabackup-20200403.tgz n215:~
➜  scp MariaDB.repo n215:/etc/yum.repos.d/

# node215
➜  yum install -y MariaDB-backup-10.3.22-1.el7.centos.x86_64.rpm
➜  mkdir -p /ahdata/mariabackup/

➜  yum install mariadb-server
➜  mkdir -p /ahdata/mysql
➜  chown -R mysql:mysql /ahdata/mysql/
➜  vim /etc/my.cnf.d/server.cnf
datadir=/ahdata/mysql

➜  tar -zxvf ~/mariabackup-20200403.tgz -C /ahdata/mariabackup/

```

还原

``` zsh
➜  mariabackup --copy-back --target-dir=/ahdata/mariabackup/20200403
```

## 四、增量备份 && 还原

``` zsh
    --incremental                      这个选项用于创建一个增量备份，而不是完全备份。它传递到mariabackup子进程。当指定这个选项，可以设置 --incremental-lsn 或 --incremental-basedir。如果这2个选项都没有被指定，--incremental-basedir 传递给 mariabackup 默认值，默认值为：基础备份目录的第一个时间戳备份目录。

　　--incremental-basedir=DIRECTORY    该选项接受一个字符串参数，该参数指定作为增量备份的基本数据集的完整备份目录。它与 --incremental 一起使用。

　　--incremental-dir=DIRECTORY        该选项接受一个字符串参数，该参数指定了增量备份将与完整备份相结合的目录，以便进行新的完整备份。它与 --incremental 选项一起使用。
```

## 五、增量备份策略 && 脚本
