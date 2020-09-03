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

## 更新记录

| 时间       | 内容                         |
| ---------- | ---------------------------- |
| 2020-07-03 | 初稿                         |
| 2020-07-29 | 1、增加Usage<\br>2、增加还原 |

## 一、备份

### 1.1、pg_dump Usage  

``` zsh
➜  ./pg_dump --help
pg_dump dumps a database as a text file or to other formats.

Usage:
  pg_dump [OPTION]... [DBNAME]

General options:
  -f, --file=FILENAME          output file or directory name                             # 输出文件的名字
  -F, --format=c|d|t|p         output file format (custom, directory, tar,               # 输出文件的格式
                               plain text (default))
  -j, --jobs=NUM               use this many parallel jobs to dump
  -v, --verbose                verbose mode
  -V, --version                output version information, then exit
  -Z, --compress=0-9           compression level for compressed formats
  --lock-wait-timeout=TIMEOUT  fail after waiting TIMEOUT for a table lock
  --no-sync                    do not wait for changes to be written safely to disk
  -?, --help                   show this help, then exit

Options controlling the output content:
  -a, --data-only              dump only the data, not the schema                         # 只导出数据
  -b, --blobs                  include large objects in dump
  -B, --no-blobs               exclude large objects in dump
  -c, --clean                  clean (drop) database objects before recreating
  -C, --create                 include commands to create database in dump
  -E, --encoding=ENCODING      dump the data in encoding ENCODING
  -n, --schema=SCHEMA          dump the named schema(s) only
  -N, --exclude-schema=SCHEMA  do NOT dump the named schema(s)
  -o, --oids                   include OIDs in dump
  -O, --no-owner               skip restoration of object ownership in
                               plain-text format
  -s, --schema-only            dump only the schema, no data                               # 只导出结构
  -S, --superuser=NAME         superuser user name to use in plain-text format
  -t, --table=TABLE            dump the named table(s) only                                # 只导出指定表
  -T, --exclude-table=TABLE    do NOT dump the named table(s)                              # 导出数据时忽略指定表
  -x, --no-privileges          do not dump privileges (grant/revoke)
  --binary-upgrade             for use by upgrade utilities only
  --column-inserts             dump data as INSERT commands with column names
  --disable-dollar-quoting     disable dollar quoting, use SQL standard quoting
  --disable-triggers           disable triggers during data-only restore
  --enable-row-security        enable row security (dump only content user has
                               access to)
  --exclude-table-data=TABLE   do NOT dump data for the named table(s)
  --if-exists                  use IF EXISTS when dropping objects
  --inserts                    dump data as INSERT commands, rather than COPY
  --no-publications            do not dump publications
  --no-security-labels         do not dump security label assignments
  --no-subscriptions           do not dump subscriptions
  --no-synchronized-snapshots  do not use synchronized snapshots in parallel jobs
  --no-tablespaces             do not dump tablespace assignments
  --no-unlogged-table-data     do not dump unlogged table data
  --quote-all-identifiers      quote all identifiers, even if not key words
  --section=SECTION            dump named section (pre-data, data, or post-data)
  --serializable-deferrable    wait until the dump can run without anomalies
  --snapshot=SNAPSHOT          use given snapshot for the dump
  --strict-names               require table and/or schema include patterns to
                               match at least one entity each
  --use-set-session-authorization
                               use SET SESSION AUTHORIZATION commands instead of
                               ALTER OWNER commands to set ownership

Connection options:
  -d, --dbname=DBNAME      database to dump                                                 # 连接指定 数据库
  -h, --host=HOSTNAME      database server host or socket directory                         # 连接指定 主机
  -p, --port=PORT          database server port number                                      # 连接指定 Port
  -U, --username=NAME      connect as specified database user                               # 连接指定 用户
  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)
  --role=ROLENAME          do SET ROLE before dump

If no database name is supplied, then the PGDATABASE environment
variable value is used.

Report bugs to <pgsql-bugs@postgresql.org>.
```

### 1.1、存储为SQL

``` zsh
➜  cd /usr/pgsql-10/bin
➜  ./pg_dump info > ~/info_20200703.sql
```

### 1.2、存储为目录

``` zsh
➜  ./pg_dump -Fd info -f ~/20200703

➜  ll ~/20200703
total 1383380
-rw-rw-r--. 1 postgres postgres 1413711315 Jul  3 16:05 5257.dat.gz
-rw-rw-r--. 1 postgres postgres        785 Jul  3 16:05 5258.dat.gz
-rw-rw-r--. 1 postgres postgres        489 Jul  3 16:05 5259.dat.gz
-rw-rw-r--. 1 postgres postgres       2329 Jul  3 16:05 5260.dat.gz
-rw-rw-r--. 1 postgres postgres       2620 Jul  3 16:05 5261.dat.gz
...
-rw-rw-r--. 1 postgres postgres         25 Jul  3 16:05 5370.dat.gz
-rw-rw-r--. 1 postgres postgres         25 Jul  3 16:05 5371.dat.gz
-rw-rw-r--. 1 postgres postgres         25 Jul  3 16:05 5372.dat.gz
-rw-rw-r--. 1 postgres postgres         25 Jul  3 16:05 5373.dat.gz
-rw-rw-r--. 1 postgres postgres     633687 Jul  3 16:01 toc.dat
```

### 1.3、存储为自定义格式

``` zsh
➜  cd /usr/pgsql-10/bin

➜  pg_dump -h 192.168.100.243 -p 9999 infov3 -Fc > ~/infov3_20200814.dump

# 导出为自定义格式，且忽略comm表
➜  pg_dump -h 192.168.100.241 info -Fc -T comm > ~/info_20200902.dump
```

## 二、还原

### 2.1 pg_restore Usage

``` zsh
➜  ./pg_restore --help
pg_restore restores a PostgreSQL database from an archive created by pg_dump.

Usage:
  pg_restore [OPTION]... [FILE]

General options:
  -d, --dbname=NAME        connect to database name
  -f, --file=FILENAME      output file name
  -F, --format=c|d|t       backup file format (should be automatic)
  -l, --list               print summarized TOC of the archive
  -v, --verbose            verbose mode
  -V, --version            output version information, then exit
  -?, --help               show this help, then exit

Options controlling the restore:
  -a, --data-only              restore only the data, no schema
  -c, --clean                  clean (drop) database objects before recreating
  -C, --create                 create the target database
  -e, --exit-on-error          exit on error, default is to continue
  -I, --index=NAME             restore named index
  -j, --jobs=NUM               use this many parallel jobs to restore
  -L, --use-list=FILENAME      use table of contents from this file for
                               selecting/ordering output
  -n, --schema=NAME            restore only objects in this schema
  -N, --exclude-schema=NAME    do not restore objects in this schema
  -O, --no-owner               skip restoration of object ownership
  -P, --function=NAME(args)    restore named function
  -s, --schema-only            restore only the schema, no data
  -S, --superuser=NAME         superuser user name to use for disabling triggers
  -t, --table=NAME             restore named relation (table, view, etc.)
  -T, --trigger=NAME           restore named trigger
  -x, --no-privileges          skip restoration of access privileges (grant/revoke)
  -1, --single-transaction     restore as a single transaction
  --disable-triggers           disable triggers during data-only restore
  --enable-row-security        enable row security
  --if-exists                  use IF EXISTS when dropping objects
  --no-data-for-failed-tables  do not restore data of tables that could not be
                               created
  --no-publications            do not restore publications
  --no-security-labels         do not restore security labels
  --no-subscriptions           do not restore subscriptions
  --no-tablespaces             do not restore tablespace assignments
  --section=SECTION            restore named section (pre-data, data, or post-data)
  --strict-names               require table and/or schema include patterns to
                               match at least one entity each
  --use-set-session-authorization
                               use SET SESSION AUTHORIZATION commands instead of
                               ALTER OWNER commands to set ownership

Connection options:
  -h, --host=HOSTNAME      database server host or socket directory
  -p, --port=PORT          database server port number
  -U, --username=NAME      connect as specified database user
  -w, --no-password        never prompt for password
  -W, --password           force password prompt (should happen automatically)
  --role=ROLENAME          do SET ROLE before restore

The options -I, -n, -N, -P, -t, -T, and --section can be combined and specified
multiple times to select multiple objects.

If no input file name is supplied, then standard input is used.

Report bugs to <pgsql-bugs@postgresql.org>.
```

### 2.2、

``` zsh
➜  scp info_20200727.dump n212:~

➜  cd /usr/pgsql-10/bin

# 导入infov3库
➜  pg_restore -h pg2 -d infov3 ~/infov3_20200818.dump
# 导入info库
➜  pg_restore -h 192.168.100.243 -p 9999 -d info ~/info_20200902.dump
```
