---
title: "linux命令速查表"
date: "2020-01-19"
categories: 
    - "技术"
tags: 
    - "linux"
    - "shell"
toc: false
original: false
---

## 线上查询及帮助命令
| 命令 | 释义 | 
| ---- | ---- |
| man  | 查看命令帮助, 命令的词典, 更复杂的还有info, 但不常用. |
| help | 查看Linux内置命令的帮助, 比如cd命令. --help也可以使用|

## 文件和目录操作命令
| 命令 | 释义 | 
| ---- | ---- |
| cd | 全拼 change directory, 功能是从当前工作目录切换到指定的工作目录. |
| cp | 全拼 copy, 其功能为复制文件或目录. |
| find | 查找的意思, 用于查找目录及目录下的文件. |
| mkdir | 全拼 make directories, 其功能是创建目录. |
| mv | 全拼 move, 其功能是移动或重命名文件. |
| pwd | 全拼 print working directory, 其功能是显示当前工作目录的绝对路径. |
| rename | 用于重命名文件. |
| rm | 全拼 remove, 其功能是删除一个或多个文件或目录. |
| rmdir | 全拼 remove empty directories, 功能是删除空目录. |
| touch | 创建新的空文件, 改变已有文件的时间戳属性. |
| tree | 功能是以树形结构显示目录下的内容. |
| basename | 显示文件名或目录名. | 
| dirname | 显示文件或目录路径. |
| chattr | 改变文件的扩展属性. |
| lsattr | 查看文件的扩展属性. |
| file | 显示文件的类型. |
| md5sum | 计算和校验文件的 MD5值. |

## 查看文件及内容处理命令
| 命令 | 释义 | 
| ---- | ---- |
| cat | 全拼 concatenate, 功能是用于连接多个文件并且打印到屏幕输出或重定向到指定文件中. |
| tac | tac 是 cat 的反向拼写, 因此命令的功能为反向显示文件内容. |
| more | 分页显示文件内容. |
| less | 分页显示文件内容, more 命令的相反用法. |
| head | 显示文件内容的头部. |
| tail | 显示文件内容的尾部. 常用的是 tail -f 动态显示文件追加的内容 |
| cut | 将文件的每一行按指定分隔符分隔并输出. |
| split | 分隔文件为不同的小片段. |
| paste | 按行合并文件内容. |
| sort | 对文件的文本内容排序. |
| uniq | 去除重复行. |
| wc | 统计文件的行数、单词数或字节数. |
| iconv | 转换文件的编码格式. |
| dos2unix | 将 DOS 格式文件转换成 UNIX 格式. |
| diff | 全拼 difference, 比较文件的差异, 常用于文本文件. |
| vimdiff | 命令行可视化文件比较工具, 常用于文本文件. |
| rev | 反向输出文件内容. |
| grep/egrep | 过滤字符串, 三剑客老三. |
| join | 按两个文件的相同字段合并. |
| tr | 替换或删除字符. |
| vi/vim | 命令行文本编辑器. |

## 文件压缩及解压缩命令
| 命令 | 释义 | 
| ---- | ---- |
| tar | 打包压缩 |
| unzip | 解压文件 |
| gzip | gzip    压缩工具 |
| zip | 压缩工具 |

## 信息显示命令
| 命令 | 释义 | 
| ---- | ---- |
| uname | 显示操作系统相关信息的命令 |
| hostname | 显示或者设置当前系统的主机名 |
| dmesg | 显示开机信息, 用于诊断系统故障 |
| uptime | 显示系统运行时间及负载 |
| stat | 显示文件或者文件系统的状态 |
| du | 计算磁盘空间使用情况 |
| df | 报告文件系统磁盘空间的使用情况 |
| top | 实时显示系统资源使用情况 |
| free | 查看系统内存 |
| date | 显示与设置系统时间 |
| cal | 查看日历等时间信息 |

## 搜索文件命令
| 命令 | 释义 | 
| ---- | ---- |
| which | 查找二进制命令, 按环境变量 PATH 路径查找 |
| find | 从磁盘遍历查找文件或目录 |
| whereis | 查找二进制命令, 按环境变量 PATH 路径查找 |
| locate | 从数据库(/var/lib/mlocate/mlocate.db)查找命令, 使用updatedb更新库 |

## 用户管理命令
| 命令 | 释义 | 
| ---- | ---- |
| useradd | 添加用户 |
| usermod | 修改系统已经存在的用户属性 |
| userdel | 删除用户 |
| groupadd | 添加用户组 |
| passwd | 修改用户密码 |
| chage | 修改用户密码有效期限 |
| id | 查看用户的 uid, gid 及归属的用户组 |
| su | 切换用户身份 |
| visudo | 编辑 /etc/sudoers 文件的专属命令 |
| sudo | 以另外一个用户身份(默认 root 用户) 执行事先在 sudoers 文件允许的命令 |

未完待续......

> 作者：马哥linux运维  
> 链接：https://mp.weixin.qq.com/s/ePP1e5pQh0jU9eJR_bYYFQ  
> 
