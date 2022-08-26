
## 1、端口未被监听

``` zsh
2021-11-18T07:48:55.559826Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. Version: '8.0.22'  socket: '/var/lib/mysql/mysql.sock'  port: 0  MySQL Community Server - GPL.
```

``` zsh
[root@master ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 8.0.22 MySQL Community Server - GPL

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show variables like 'port';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 0     |
+---------------+-------+
1 row in set (0.01 sec)

mysql>
mysql> show variables like 'skip_networking';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| skip_networking | ON    |
+-----------------+-------+
1 row in set (0.00 sec)

mysql>
```
