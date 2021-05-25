---
title: "yum安装mysql5.7"
date: "2021-05-21"
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
| 2021-05-21 | 初稿 |

## 软件版本

| soft  | Version |
| ----- | ------- |
| MySQL | 5.7.34  |

## 环境

``` zsh
# yum repo 设置
➜  cat mysql-community.repo
[mysql57-community]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
```

## 安装

``` zsh
# 刷新 yun 缓存
➜  yum makecache

# 查找 mysql
➜  yum search mysql --enablerepo=mysql57-community

# 安装 mysql 客户端及服务端
➜  yum install mysql-community-server.x86_64 mysql-community-client.x86_64 --enablerepo=mysql57-community -y
➜  yum install mysql-devel --enablerepo=mysql57-community -y
```

## 配置

``` zsh
# 查看系统 空间
➜  df -h
Filesystem               Size  Used Avail Use% Mounted on
devtmpfs                  16G     0   16G   0% /dev
tmpfs                     16G     0   16G   0% /dev/shm
tmpfs                     16G  170M   16G   2% /run
tmpfs                     16G     0   16G   0% /sys/fs/cgroup
/dev/mapper/centos-root   50G  4.0G   47G   8% /
/dev/sda2               1014M  176M  839M  18% /boot
/dev/sda1                200M   12M  189M   6% /boot/efi
/dev/sdb1                932G  1.3G  930G   1% /disk2
/dev/mapper/centos-home  165G   33M  165G   1% /home

# 创建 mysql data 目录
➜  mkdir -p /disk2/data/mysql

# 修改 mysql 配置文件
➜  vim /etc/my.cnf
[client]
port = 3306
socket=/disk2/data/mysql/mysql.sock

[mysqld]
port = 3306

datadir=/disk2/data/mysql
socket=/disk2/data/mysql/mysql.sock

log-error=/disk2/data/mysql/mysqld.log
pid-file=/disk2/data/mysql/mysqld.pid
```

## 启动

``` zsh
➜  systemctl start mysqld
```

## 使用

### 获取初始root密码

![获取初始root密码](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/mysql_20210521_01.jpg)

### 修改root密码

``` zsh
➜  mysql -uroot -p
mysql> alter user 'root'@'localhost' identified by 'gjr155!@#@@$$';
```

### 授权远程连接

如果我们不进行远程连接授权，会报1045这个错误

![远程连接报错](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/mysql_20210521_02.jpg)

使用以下语句进行远程授权

``` mysql
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'gjr155!@#@@$$' WITH GRANT OPTION;
mysql> FLUSH PRIVILEGES;
```
