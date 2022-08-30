---
title: "yum 安装 mysql5.6"
date: "2022-03-17"
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
| 2022-03-17 | 初稿 |

## 软件版本

| soft  | Version |
| ----- | ------- |
| MySQL | 5.6.51  |

## 环境准备

yum repo 设置

``` zsh
➜  vim /etc/yum.repos.d/mysql-community.repo
[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.6-community/el/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
```

## 安装

``` zsh
➜  yum install mysql-community-server mysql-community-client mysql-devel --enablerepo=mysql56-community -y
```

## 启动

``` zsh
➜  systemctl start mysqld
```

## 配置密码

``` zsh
# 密码为空，直接回车进入
➜  mysql -u root -p

mysql> set password for 'root'@'localhost'=password('icp@@##%%22');
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES; 
Query OK, 0 rows affected (0.00 sec)
```

## 配置业务

``` mysql
mysql> create database icp;
Query OK, 1 row affected (0.00 sec)

mysql> CREATE USER 'icp'@'%' IDENTIFIED BY 'icp@@##%%22';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL PRIVILEGES ON nacos.* TO 'icp'@'%'  WITH GRANT OPTION;
Query OK, 0 rows affected (0.00 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)
```
