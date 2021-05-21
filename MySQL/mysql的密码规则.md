---
title: "mysql的密码规则"
date: "2021-05-21"
categories:
    - "技术"
tags:
    - "mysql"
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

## ERROR 1819 (HY000): Your password does not satisfy the current policy requirements

```
mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.34

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> alter user 'root'@'localhost' identified by 'gjr2021+-';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
mysql> alter user 'root'@'localhost' identified by 'gjr!@#2021';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
mysql> alter user 'root'@'localhost' identified by 'gjr!@#456';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
mysql> alter user 'root'@'localhost' identified by 'gjr155!@#@@$$';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
mysql> 
```

设置了一堆密码，不管多复杂，密码规则都校验失败。。。

## 密码规则

研究了一下 MySQL 的密码规则，下面是密码的安全等级

![安全等级](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/20190226144810183.png)

``` zsh
# 可以直接使用命令 修改安全等级
mysql> set global validate_password_policy=0;

# 修改密码长度
mysql> set global validate_password_length=4;
```

查看详细的密码规则

``` zsh
# 登录后执行 下列命令
mysql> SHOW VARIABLES LIKE 'validate_password%';
+--------------------------------------+-------+
| Variable_name                        | Value |
+--------------------------------------+-------+
| validate_password_check_user_name    | OFF   |
| validate_password_dictionary_file    |       |
| validate_password_length             | 8     |
| validate_password_mixed_case_count   | 1     |
| validate_password_number_count       | 1     |
| validate_password_policy             | LOW   |
| validate_password_special_char_count | 1     |
+--------------------------------------+-------+
```

> 参考文档：  
> [1] [MySQL 1819 错误](https://blog.csdn.net/calistom/article/details/87939956)  