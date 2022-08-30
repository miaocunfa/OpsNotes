---
title: "MongoDB 数据导入 && 导出"
date: "2020-05-27"
categories:
    - "技术"
tags:
    - "MongoDB"
    - "数据导出"
    - "数据导入"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                                     |
| ---------- | ---------------------------------------- |
| 2020-05-27 | 初稿                                     |
| 2020-08-07 | 添加 mongoimport                         |
| 2020-08-12 | 文档优化 && 添加 mongodump、mongorestore |
| 2020-08-17 | 导出目录 && 常用数据操作                 |

## 环境

| Server       | Version |
| ------------ | ------- |
| mongodump    | r4.2.2  |
| mongorestore | r4.2.2  |
| mongoexport  | r4.2.2  |
| mongoimport  | r4.2.2  |

## 一、数据导出

### 1.1、mongoexport

mongoexport 主要针对 集合级别的数据导出及格式化
mongoexport 与 mongoimport 配合使用

``` zsh
➜  mongoexport --help
Usage:
  mongoexport <options>

Export data from MongoDB in CSV or JSON format.

See http://docs.mongodb.org/manual/reference/program/mongoexport/ for more information.


# 常用选项：
  -h, --host=<hostname>                           mongodb host to connect to (setname/host1,host2 for replica sets)                      # 连接的数据库
      --port=<port>                               server port (can also use --host hostname:port)                                        # 连接的端口
  -d, --db=<database-name>                        database to use                                                                        # 数据库名
  -c, --collection=<collection-name>              collection to use                                                                      # 集合名
  -o, --out=<filename>                            output file; if not specified, stdout is used                                          # 输出的文件名，若不指定该选项输出至stdout
      --type=<type>                               the output format, either json or csv (defaults to 'json') (default: json)             # 可选择json、csv格式，默认json
  -f, --fields=<field>[,<field>]*                 comma separated list of field names (required for exporting CSV) e.g. -f "name,age"    # type为csv格式时，必须指定字段名
      --fieldFile=<filename>                      file with field names - 1 per line


# 常用导出：
# 1、导出指定集合
➜  mongoexport -h mongo1:27017 -d info -c collection1 -o /home/miaocunfa/info_collection1.json
➜  chown miaocunfa:miaocunfa /home/miaocunfa/info_collection1.json

# 2、导出至标准输出 stdout
➜  mongoexport -h mongo1:27017 -d info -c collection1
➜  mongoexport -h mongo1:27017 -d info -c collection1 | mongoimport -h mongo1:21000 -d talk -c collection1
```

### 2.2、mongodump

mongodump 主要用于 MongoDB备份
mongodump 与 mongorestore 配合使用

``` zsh
Usage:
  mongodump <options>

Export the content of a running server into .bson files.

Specify a database with -d and a collection with -c to only dump that database or collection.

See http://docs.mongodb.org/manual/reference/program/mongodump/ for more information.

# 常用选项：
  -h, --host=<hostname>                                     mongodb host to connect to (setname/host1,host2 for replica sets)    # 连接的数据库
      --port=<port>                                         server port (can also use --host hostname:port)                      # 连接的端口
  -d, --db=<database-name>                                  database to use                                                      # 数据库名
  -c, --collection=<collection-name>                        collection to use                                                    # 集合名
  -o, --out=<directory-path>                                output directory, or '-' for stdout (defaults to 'dump')             # 导出目录
      --archive=<file-path>                                 dump as an archive to the specified path. If flag is specified without a value, archive is written to stdout # 导出文件
      --gzip                                                compress archive our collection output with Gzip


# 常用导出：
# --archive
# 导出为归档文件，--archive 指定归档文件名字
➜  mongodump -h 192.168.100.226:27017 --archive=aihang3.20200812.archive -d aihang3

➜  mkdir -p /opt/mongodump
➜  ./mongodump -h 192.168.100.224:28018 --archive=/opt/mongodump/aihang3.20200814.archive -d aihang3
➜  ./mongodump -h 192.168.100.224:28018 --archive=/opt/mongodump/aitalk.20200814.archive -d aitalk

# 导出为目录文件
➜  mkdir -p /home/miaocunfa/mongodump/20200817
➜  ./mongodump -h pg1:21000 -o /home/miaocunfa/mongodump/20200817 -d aitalk
# 目录结构
➜  tree 20200817
20200817
└── aitalk
    ├── blacklist.bson
    ├── blacklist.metadata.json
    ├── conversation.bson
    ├── conversation.metadata.json
    ├── friendship.bson
    ├── friendship.metadata.json
    ├── group.bson
    ├── group.metadata.json
    ├── invitation.bson
    ├── invitationGroup.bson
    ├── invitationGroup.metadata.json
    ├── invitation.metadata.json
    ├── resource.bson
    ├── resource.metadata.json
    ├── subscription.bson
    ├── subscription.metadata.json
    ├── systemInforms.bson
    ├── systemInforms.metadata.json
    ├── team.bson
    ├── team.metadata.json
    ├── user.bson
    └── user.metadata.json

# --archive 不指定文件名 则输出至stdout，一般与 mongorestore连用
➜  mongodump -h 192.168.100.226:27017 --archive -d aihang3
➜  mongodump -h 192.168.100.226:27017 --archive -d aihang3  | mongorestore -h 192.168.100.226:21000 --archive

➜  mongodump -h 192.168.100.226:21000 --archive -d aihang3  | mongorestore -h 192.168.100.226:27017 --archive
➜  mongodump -h 192.168.100.226:21000 --archive -d aitalk  | mongorestore -h 192.168.100.226:27017 --archive
```

## 二、数据导入

### 2.1、mongoimport

``` zsh
➜  mongoimport --help
Usage:
  mongoimport <options> <file>

Import CSV, TSV or JSON data into MongoDB. If no file is provided, mongoimport reads from stdin.


# 常用选项：
  -h, --host=<hostname>                           mongodb host to connect to (setname/host1,host2 for replica sets)
      --port=<port>                               server port (can also use --host hostname:port)
  -d, --db=<database-name>                        database to use
  -c, --collection=<collection-name>              collection to use
  -f, --fields=<field>[,<field>]*                 comma separated list of fields, e.g. -f name,age
      --fieldFile=<filename>                      file with field names - 1 per line
      --file=<filename>                           file to import from; if not specified, stdin is used

# 常用导入：
➜  mongoimport -h mongo1:21000 -d ahtest -c info --file=~/aihang3_info.json
```

### 2.2、mongorestore

``` zsh
➜  mongorestore --help
Usage:
  mongorestore <options> <directory or file to restore>

Restore backups generated with mongodump to a running server.

Specify a database with -d to restore a single database from the target directory,
or use -d and -c to restore a single collection from a single .bson file.

See http://docs.mongodb.org/manual/reference/program/mongorestore/ for more information.


# 常用选项：
  -h, --host=<hostname>                                     mongodb host to connect to (setname/host1,host2 for replica sets)
      --port=<port>                                         server port (can also use --host hostname:port)
  -d, --db=<database-name>                                  database to use when restoring from a BSON file
  -c, --collection=<collection-name>                        collection to use when restoring from a BSON file
      --archive=<filename>                                  restore dump from the specified archive file.  If flag is specified without a value, archive is read from stdin
      --dir=<directory-name>                                input directory, use '-' for stdin
      --gzip                                                decompress gzipped input
      --drop                                                drop each collection before import
      --dryRun                                              view summary without importing anything. recommended with verbosity

# 常用导入：
➜  mongorestore -h pg1:21000 --archive=/home/miaocunfa/data/aihang3.20200814.archive -d aihang3
➜  mongorestore -h pg1:21000 --archive=/home/miaocunfa/data/aitalk.20200814.archive -d aitalk

# --archive 不指定文件名 则从stdin获得数据，一般与 mongodump连用
➜  mongorestore -h 192.168.100.226:21000 --archive
➜  mongodump -h 192.168.100.226:27017 --archive -d aihang3  | mongorestore -h 192.168.100.226:21000 --archive
```

## 三、常用数据操作

### 3.1、源库与目标库非同名

``` zsh
# 源库与目标库非同名时，只能使用目录格式，归档文件无法指定导入库
# the --db and --collection args should only be used when restoring from a BSON file.

# 导出 aitalk 库
➜  mkdir -p /home/miaocunfa/mongodump/20200817
➜  ./mongodump -h pg1:21000 -o /home/miaocunfa/mongodump/20200817 -d aitalk
➜  cd /home/miaocunfa/mongodump
➜  tar -zcf aitalk-prod-20200817.tgz 20200817

# 将 aitalk库 导入aitalk-0817
➜  cd /opt/mongodump/
➜  tar -zxf aitalk-prod-20200817.tgz
➜  ./mongorestore -h mongo1:21000 --dir=/opt/mongodump/20200817/aitalk -d aitalk-0817
```

### 3.2、标准输入输出传输数据

``` zsh
➜  mongodump -h 192.168.100.226:27017 --archive -d aihang3  | mongorestore -h 192.168.100.226:21000 --archive
```

``` zsh
➜  mongoexport -h mongo1:21000 -d aihang3-1028 -c info | mongoimport -h mongo1:21000 -d aihang3 -c info
```

> 参考文章：  
> 1、<https://www.jianshu.com/p/7ccad7b8ee18>  
> 2、[mongodump官方文档 - v4.2](https://docs.mongodb.com/v4.2/reference/program/mongodump/)  
> 3、[mongorestore官方文档 -v4.2](https://docs.mongodb.com/v4.2/reference/program/mongorestore/)  
>