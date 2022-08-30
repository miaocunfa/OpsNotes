---
title: "yum 安装 mysql 8.0"
date: "2022-08-05"
categories:
    - "技术"
tags:
    - "mysql"
    - "deploy"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-08-05 | 初稿 |

## 软件版本

| soft  | Version |
| ----- | ------- |
| CentOS | 7.9    |
| MySQL | 8.0.30  |

## 环境

yum 配置

``` zsh
# yum repo 设置
➜  rpm -Uvh http://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

➜  vim /etc/yum.repos.d/
[mysql57-community]
enabled=1  -->  0  # enabled 改为0, 关闭 5.7版本
[mysql80-community]
enabled=0  -->  1  # enabled 改为1, 开启 8.0版本

:%s@gpgcheck=1@gpgcheck=0@g  # 将所有 gpgcheck=1 关闭

# yum 更新repo
➜  yum makecache
➜  yum repolist enabled | grep mysql
mysql-connectors-community/x86_64           MySQL Connectors Community       199
mysql-tools-community/x86_64                MySQL Tools Community             92
mysql80-community/x86_64                    MySQL 8.0 Community Server       364
```

用户组

``` zsh
➜  groupadd mysql
➜  useradd -g mysql mysql
```

数据目录

``` zsh
# 创建 mysql data 目录
➜  mkdir -p /data/mysql/{tmp,logs,data}
➜  chown -R mysql:mysql /data/mysql/
```

## 安装

``` zsh
# 查看本地是否已安装旧版本
➜  yum list installed|grep mysql
mysql57-community-release.noarch       el7-9                           installed
# 移除旧版本
➜  yum remove mysql57-community-release.noarch

# 安装 mysql 客户端及服务端
➜  yum install mysql-community-server.x86_64 mysql-community-client.x86_64  mysql-devel -y
```

## 启动服务

配置文件

``` zsh
# 修改 mysql 配置文件
➜  vim /etc/my.cnf
[client]
port        = 3306
socket      = /data/mysql/tmp/mysql.sock
 
[mysqld]
user     = mysql
port     = 3306
#basedir = /usr/local/mysql
datadir = /data/mysql/data
socket   = /data/mysql/tmp/mysql.sock
pid-file = /data/mysql/tmp/mysql.pid
log-error=/data/mysql/logs/mysql_error.log
slow_query_log=on
long_query_time=2
slow_query_log_file=/data/mysql/logs/mysql_slow_query.log

default_storage_engine = InnoDB

#数据库默认字符集,主流字符集支持一些特殊表情符号（特殊表情符占用4个字节）
character-set-server = utf8mb4

#数据库字符集对应一些排序等规则，注意要和character-set-server对应
collation-server = utf8mb4_general_ci

#设置client连接mysql时的字符集,防止乱码
init_connect='SET NAMES utf8mb4'

max_allowed_packet = 100M
```

启动服务

``` zsh
➜  systemctl start mysqld
```

## 修改密码

``` zsh
# 先查看 MySQL密码
➜  vim /data/mysql/logs/mysql_error.log 
2022-08-05T10:55:25.663669Z 0 [System] [MY-013169] [Server] /usr/sbin/mysqld (mysqld 8.0.30) initializing of server in progress as process 24134
2022-08-05T10:55:25.672858Z 1 [System] [MY-013576] [InnoDB] InnoDB initialization has started.
2022-08-05T10:55:26.371728Z 1 [System] [MY-013577] [InnoDB] InnoDB initialization has ended.
2022-08-05T10:55:27.638116Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: zzPwy%_=i4qi # 密码

# 进入 MySQL
➜  mysql -uroot -p'zzPwy%_=i4qi'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.30                                              # 8.0.30版本

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '2Df$%@#@';      # 先设置一个复杂密码, 再退出修改密码策略
Query OK, 0 rows affected (0.04 sec)

mysql> exit;
Bye

# 修改密码策略
➜  mysql -uroot -p
mysql> set global validate_password.policy = low;                   # 设置密码安全策略为 低
mysql> show VARIABLES LIKE 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password.check_user_name    | ON    |
| validate_password.dictionary_file    |       |
| validate_password.length             | 8     |
| validate_password.mixed_case_count   | 1     |
| validate_password.number_count       | 1     |
| validate_password.policy             | LOW   |
| validate_password.special_char_count | 1     |
+--------------------------------------+-------+
7 rows in set (0.01 sec)

mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'qawsEDRF@@@';    # 修改密码
mysql> update user set host='%' where user='root';                   # 授权远程访问
mysql> flush privileges;
mysql> exit
```
