---
title: "基于 Docker 升级 Zabbix6.2"
date: "2022-08-03"
categories:
    - "技术"
tags:
    - "Docker"
    - "Zabbix"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                                       |
| ---------- | ------------------------------------------ |
| 2022-08-03 | 初稿                                       |
| 2022-08-04 | 增加忽略表部分                             |
| 2022-08-05 | 增加修改 SQL 部分 && 升级 MySQL 至 8.0     |
| 2022-08-08 | 问题处理2：历史数据 & 问题处理3：修改密码  |
| 2022-08-08 | 升级 zabbix agent2                         |
| 2022-08-23 | 增加本地脚本映射 执行自定义报警脚本        |
| 2022-08-24 | 修改zabbix容器镜像版本 && 增加修改时区问题 |

## 软件版本

| soft          | Version                                           |
| ------------- | ------------------------------------------------- |
| CentOS        | 7.7                                               |
| Zabbix Server | 4.0.32 --> 6.2.0                                  |
| Zabbix Agent  | zabbix agent（4.0.32） --> zabbix agent2（6.2.0） |
| MySQL         | 5.7.26 --> 8.0.30                                 |

## 一、准备工作

①数据迁移

先查看 zabbix 数据库，各表大小

``` mysql
mysql> SELECT
    ->     table_schema AS '数据库',
    ->     table_name AS '表名',
    ->     table_rows AS '记录数',
    ->     TRUNCATE ( data_length / 1024 / 1024, 2 ) AS '数据容量(MB)',
    ->     TRUNCATE ( index_length / 1024 / 1024, 2 ) AS '索引容量(MB)' 
    -> FROM
    ->     information_schema.TABLES 
    -> WHERE
    ->     table_schema = 'zabbix' 
    -> ORDER BY
    ->     table_rows DESC,
    ->     index_length DESC;
+-----------+----------------------------+-----------+------------------+------------------+
| 数据库    | 表名                       | 记录数    | 数据容量(MB)     | 索引容量(MB)     |
+-----------+----------------------------+-----------+------------------+------------------+
| zabbix    | history_text               |  52810586 |          2424.00 |          1392.00 |
| zabbix    | history_uint               |  21695056 |          1089.00 |           583.00 |
| zabbix    | history                    |   7354305 |           378.89 |           209.96 |
| zabbix    | history_str                |   5957909 |           369.89 |           161.84 |
| zabbix    | trends_uint                |   5507984 |           341.98 |             0.00 |
| zabbix    | trends                     |   3669553 |           221.82 |             0.00 |
| zabbix    | alerts                     |   1497038 |           483.00 |           253.65 |
```

可以看到 history 的数据量比较多，一会儿在导出记录的时候忽略这些表

``` zsh
# HOST: 192.168.196.84

# 备份导出 SQL && 并忽略 history表
➜  mysqldump -uroot -p --databases zabbix --ignore-table=zabbix.history_text --ignore-table=zabbix.history_uint --ignore-table=zabbix.history --ignore-table=zabbix.history_str --ignore-table=zabbix.trends_uint --ignore-table=zabbix.trends --ignore-table=zabbix.alerts > zabbix_ignore_20220804.sql

# 获取忽略表 的表结构
➜  mysqldump -uroot -p -d zabbix history_text history_uint history history_str trends_uint trends alerts> zabbix_ignore_create_20220804.sql

# 修改 SQL
➜  vim zabbix_ignore_20220804.sql
CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

#-------------------------------------------
# HOST: 192.168.196.83
# 创建 DB 与 用户

➜  mysql -uroot -p
> CREATE DATABASE `zabbix` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
> create user 'zabbix'@'%' identified by 'zbx62^@%@#$';
> GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'%' with grant option;
> FLUSH PRIVILEGES;
> exit

# 导入 SQL
➜  mysql -uroot -p
> source /root/zabbix_ignore_20220804.sql;
> commit;

> use zabbix;
> source /root/zabbix_ignore_create_20220804.sql
> commit;
```

②服务停止

``` zsh
# 停止旧服务释放端口
➜  systemctl stop zabbix-server
➜  systemctl stop zabbix-agent
```

## 二、docker 启动 zabbix server

创建专用于 Zabbix 组件容器的网络

``` zsh
➜  docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net
```

启动 java-gateway 服务，用于监控 Java服务。

``` zsh
➜  docker run -d --name zabbix-java-gateway -t \
      --network=zabbix-net \
      --restart unless-stopped \
      zabbix/zabbix-java-gateway:centos-6.2.0
```

启动 Zabbix server 实例

``` zsh
➜  docker run -d --name zabbix-server -t \
      -e DB_SERVER_HOST="192.168.196.83" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zbx62^@%@#$" \
      -e MYSQL_ROOT_PASSWORD="qawsEDRF@@@" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --network=zabbix-net \
      -p 10051:10051 \
      --restart unless-stopped \
      -v /usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts \
      zabbix/zabbix-server-mysql:centos-6.2.0
```

启动 Zabbix Web 界面，并将其关联到已创建的 Zabbix server 实例

``` zsh
➜  docker run -d --name zabbix-web-nginx -t \
      -e ZBX_SERVER_HOST="zabbix-server" \
      -e DB_SERVER_HOST="192.168.196.83" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zbx62^@%@#$" \
      -e MYSQL_ROOT_PASSWORD="qawsEDRF@@@" \
      --network=zabbix-net \
      -p 80:8080 \
      --restart unless-stopped \
      zabbix/zabbix-web-nginx-mysql:centos-6.2.0
```

## 三、升级 Agent

现在登陆 web界面，Zabbix server 服务以及历史数据已经迁移到新版本的 Zabbix上了，
但是监控的主机列表无法获取到新数据，需要升级一下 zabbix agent

Zabbix agent 2是新一代的Zabbix agent 甚至可以替代Zabbix agent. Zabbix agent 2 已经进步到:

- 减少TCP连接数量
- 提供改进的检查并发性
- 使用插件很容易扩展。一个插件应该能够:
  - 提供由几行简单代码组成的简单检查
  - 提供复杂的检查，包括长时间运行的脚本和独立的数据收集，并定期发回数据
- 做一个临时的替代品 Zabbix agent (因为它支持之前的所有功能)

所以我们直接安装 Zabbix agent2  
先在 Zabbix server 上安装

``` zsh
# 禁用原 yum repo
➜  mv /etc/yum.repos.d/zabbix.repo{,.bak}

# 创建新 yum repo
➜  vim /etc/yum.repos.d/zabbix62.repo
[zabbix-6.2]
name=Zabbix Official Repository - $basearch
baseurl=http://repo.zabbix.com/zabbix/6.2/rhel/7/$basearch/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591

# yum 缓存
➜  yum makecache
# 查看所有 agent版本
➜  yum --showduplicates list zabbix-agent2
zabbix-agent2.x86_64             6.2.0-1.el7             zabbix-6.2
zabbix-agent2.x86_64             6.2.1-1.el7             zabbix-6.2
# 安装特定版本 agent
➜  yum install -y zabbix-agent2-6.2.0-1.el7

# 停止原 agent & 启动新 agent2
➜  systemctl stop zabbix-agent
➜  systemctl start zabbix-agent2
```

在所有主机安装 zabbix agent2

``` zsh
➜  ansible all -m shell -a "mv /etc/yum.repos.d/zabbix.repo{,.bak}"

# 分发 repo 至所有主机
➜  ansible all -m copy -a "src=/etc/yum.repos.d/zabbix62.repo dest=/etc/yum.repos.d/zabbix62.repo"

# 在所有主机升级 zabbix-agent
➜  ansible all -m shell -a "yum makecache; yum install -y zabbix-agent2-6.2.0-1.el7"
➜  ansible all -m shell -a "yum list installed | zabbix-agent2"
```

配置文件

``` zsh
# 修改 zabbix-agent2 配置文件
➜  vim /etc/zabbix/zabbix-agent2.conf
Server=192.168.189.181
ServerActive=192.168.189.181
 
# 将 zabbix-agent2.conf 发送至所有节点
➜  ansible all -m copy -a "src=/etc/zabbix/zabbix_agent2.conf dest=/etc/zabbix/zabbix_agent2.conf"
# 将原 zabbix-agent 自定义配置项 复制到 zabbix-agent2 下
➜  ansible all -m shell -a "cp /etc/zabbix/zabbix_agentd.d/*.conf /etc/zabbix/zabbix_agent2.d/"

# 停止原 agent & 启动新 agent2
➜  ansible all -m shell -a "systemctl stop zabbix-agent; systemctl start zabbix-agent2"

# 查看 agent2 状态
➜  ansible all -m shell -a "systemctl status zabbix-agent2"
```

## 四、报错处理

①数据库问题

``` zsh
# zabbix-server 一直在重启
➜  docker ps 
54e8b3361374   zabbix/zabbix-server-mysql:ubuntu-6.2.0      "/usr/bin/tini -- /u…"   2 minutes ago   Restarting (1) 38 seconds ago                                                     zabbix-server

# 查看日志发现两个问题
➜  docker logs -f zabbix-server
7:20220805:055017.048 Zabbix supports only "utf8_bin,utf8mb3_bin,utf8mb4_bin" collation(s). Database "zabbix62" has default collation "utf8_general_ci"
     7:20220805:055017.055 Unsupported DB! MySQL version is 50726 which is smaller than minimum of 50728
     7:20220805:055017.055 Error! Current MySQL database server version is too old (5.07.26)
     7:20220805:055017.055 Must be a least 5.07.28
```

解决问题1, 在其他服务器安装新的 MYSQL 服务
解决问题2, MYSQL字符集，创建数据库时指定 utf8mb4_bin 字符集

②历史数据问题

``` zsh
     7:20220805:115726.545 completed 90% of database upgrade
     7:20220805:115726.859 completed 91% of database upgrade
     7:20220805:115726.967 completed 92% of database upgrade
     7:20220805:115727.164 completed 93% of database upgrade
     7:20220805:115727.165 [Z3005] query failed: [1419] You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable) [create trigger hosts_insert after insert on hosts
for each row
insert into changelog (object,objectid,operation,clock)
values (1,new.hostid,1,unix_timestamp())]
     7:20220805:115727.165 database upgrade failed
     7:20220805:115727.176 database could be upgraded to use primary keys in history tables
```

解决问题

``` zsh
# 修改 配置文件
➜  vim /etc/my.cnf
[mysqld]
log_bin_trust_function_creators = 1

# 重启
➜  systemctl stop mysqld
➜  systemctl start mysqld

# 并删除 zabbix & 重新导入数据
```

③无法登陆问题

[IMG]

解决问题

``` zsh
# 查询
mysql> select userid,username,passwd from users;
+--------+-------------------+--------+
| userid | username          | passwd |
+--------+-------------------+--------+
|      1 | Admin             |        |
|      2 | guest             |        |
|      3 | dingding          |        |
|      4 | Phone             |        |
|      5 | SMS               |        |
|      6 | dingding_disaster |        |
+--------+-------------------+--------+
6 rows in set (0.00 sec)

# 为 Admin 修改新密码: zabbix
mysql> update users set passwd='$2y$10$92nDno4n0Zm7Ej7Jfsz8WukBfgSS/U0QkIuu8WkJPihXBb2A1UrEK' where userid ='1';
mysql> flush privileges;
```

④钉钉脚本权限问题

``` zsh
# 进入容器内
➜  docker exec -it zabbix-server /bin/bash
bash-4.4$ cd /usr/lib/zabbix/alertscripts/
bash-4.4$ ls -l
total 12
drwxr-xr-x 4  995  994 4096 Jul 21  2021 dingding
-rwxr-xr-x 1 root root 2133 Jul 26  2021 phone.py
-rwxr-xr-x 1 root root 1043 Jul 21  2021 short.py
# 根据 容器内zabbix用户的 属主、属组 发现zabbix 没有进入dingding目录的权限
bash-4.4$ id zabbix
uid=1997(zabbix) gid=1995(zabbix) groups=1995(zabbix),0(root),20(dialout)

# 宿主机
➜  cd /usr/lib/zabbix/alertscripts
# 修改属主、属组权限
➜  chown -R root:root dingding/
ll
total 12
drwxr-xr-x 4 root root 4096 Jul 21  2021 dingding
-rwxr-xr-x 1 root root 2133 Jul 26  2021 phone.py
-rwxr-xr-x 1 root root 1043 Jul 21  2021 short.py

# 修改 dingding.sh 执行权限 755
➜  cd dingding/bin
➜  chmod 755 ./dingding.sh 
ll
total 4
-rwxr-xr-x 1 root root 832 Jul 21  2021 dingding.sh
```

已经可以执行脚本了

[img-1]
[img-2]

⑤更改时区、日志记录时间不对

``` zsh
➜  docker exec -it zabbix-server /bin/bash

bash-4.4$ date
Wed Aug 24 09:36:06 UTC 2022

bash-4.4$ tail -f dingding.log
2022-08-24 09:31:13 INFO [content]: OK:测试大数据组件 hadoop.NameNode 不存活\n告警主机:Big_test_node2\n主机地址:192.168.196.83\n故障持续时间:4d 16h 23m 19s\n恢复时间:17:31:09\n告警等级:Disaster告警信息: 测试大数据组件 hadoop.NameNode 不存活\n问题详情:hadoop.NameNode:1\n事件代码:1061725
2022-08-24 09:31:13 INFO [response]: {"errcode":0,"errmsg":"ok"}
```

解决问题

``` zsh
# 修改 Dockerfile
➜  vim Dockerfile
# 1.基础镜像
FROM zabbix/zabbix-server-mysql:centos-6.2.0

# 2.指明该镜像的作者和其电子邮件
MAINTAINER Miaocunfa miaocunf@163.com

# 3.配置环境变量
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo '$TZ' > /etc/timezone
ENV LANG C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# 重新构建镜像
➜  docker build -t harbor.gjr.net/base/zabbix-server-CST:centos-6.2.0 .
```

> 参考文章：  
>
> - [Zabbix官网手册 - 5 从容器中安装](https://www.zabbix.com/documentation/6.0/zh/manual/installation/containers)  
> - [Zabbix使用zabbix-java-gateway监控jvm/tomcat性能](https://blog.csdn.net/tvk872/article/details/79680579)  
> - [Github - docker-compose yaml](https://github.com/zabbix/zabbix-docker/)  
> - [docker容器的重启策略：通过--restart来指定](https://blog.csdn.net/a772304419/article/details/123208605)  
> - [MySQL数据库进行进行脚本导入成功之后，发现没有表](https://blog.csdn.net/m0_64697693/article/details/124008341)  
> - [官方博文 | Zabbix Agent2 新特性](https://blog.51cto.com/u_15094852/4078856)  
> - [官方中文手册 - Agent 2](https://www.zabbix.com/documentation/6.0/zh/manual/concepts/agent2)  
> - [解决 MySQL-1419](https://blog.csdn.net/weixin_42272246/article/details/124319693)  
>