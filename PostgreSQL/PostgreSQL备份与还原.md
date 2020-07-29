---
title: "PostgreSQL备份与还原"
date: "2020-07-03"
categories:
    - "技术"
tags:
    - "postgre"
toc: false
indent: false
original: true
---

## 一、备份

### 1.1、存储为SQL

``` zsh
➜  cd /usr/pgsql-10/bin
➜  ./pg_dump info > ~/info_20200703.sql
```

### 1.2、存储为目录

``` zsh
➜  ./pg_dump -Fd info -f ~/20200703
```

### 1.3、

``` zsh
➜  cd /usr/pgsql-10/bin
➜  ./pg_dump info -F c -T comm > ~/info_20200727.dump
```

## 二、还原

### 2.1、

``` zsh
scp info_20200727.dump n212:~

➜  cd /usr/pgsql-10/bin
➜  ./pg_restore -h 192.168.100.243 -p 9999 -d infov3 ~/info_20200727.dump
```
