---
title: "Redis常用命令"
date: "2020-07-29"
categories:
    - "技术"
tags:
    - "Redis"
    - "NoSQL"
    - "数据库"
toc: false
original: true
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-07-29 | 初稿 |

## 一、redis-cli

``` zsh
➜  redis-cli --help
redis-cli 5.0.5

Usage: redis-cli [OPTIONS] [cmd [arg [arg ...]]]
  -h <hostname>      Server hostname (default: 127.0.0.1).                          # 指定连接的主机名
  -p <port>          Server port (default: 6379).                                   # 指定连接的端口
  -s <socket>        Server socket (overrides hostname and port).
  -a <password>      Password to use when connecting to the server.
                     You can also use the REDISCLI_AUTH environment
                     variable to pass this password more safely
                     (if both are used, this argument takes predecence).
  -u <uri>           Server URI.
  -r <repeat>        Execute specified command N times.
  -i <interval>      When -r is used, waits <interval> seconds per command.
                     It is possible to specify sub-second times like -i 0.1.
  -n <db>            Database number.                                               # 指定连接的db库
  -x                 Read last argument from STDIN.
  -d <delimiter>     Multi-bulk delimiter in for raw formatting (default: \n).
  -c                 Enable cluster mode (follow -ASK and -MOVED redirections).
  --raw              Use raw formatting for replies (default when STDOUT is
                     not a tty).
  --no-raw           Force formatted output even when STDOUT is not a tty.
  --csv              Output in CSV format.
  --stat             Print rolling stats about server: mem, clients, ...
  --latency          Enter a special mode continuously sampling latency.
                     If you use this mode in an interactive session it runs
                     forever displaying real-time stats. Otherwise if --raw or
                     --csv is specified, or if you redirect the output to a non
                     TTY, it samples the latency for 1 second (you can use
                     -i to change the interval), then produces a single output
                     and exits.
  --latency-history  Like --latency but tracking latency changes over time.
                     Default time interval is 15 sec. Change it using -i.
  --latency-dist     Shows latency as a spectrum, requires xterm 256 colors.
                     Default time interval is 1 sec. Change it using -i.
  --lru-test <keys>  Simulate a cache workload with an 80-20 distribution.
  --replica          Simulate a replica showing commands received from the master.
  --rdb <filename>   Transfer an RDB dump from remote server to local file.
  --pipe             Transfer raw Redis protocol from stdin to server.
  --pipe-timeout <n> In --pipe mode, abort with error if after sending all data.
                     no reply is received within <n> seconds.
                     Default timeout: 30. Use 0 to wait forever.
  --bigkeys          Sample Redis keys looking for keys with many elements (complexity).
  --memkeys          Sample Redis keys looking for keys consuming a lot of memory.
  --memkeys-samples <n> Sample Redis keys looking for keys consuming a lot of memory.
                     And define number of key elements to sample
  --hotkeys          Sample Redis keys looking for hot keys.
                     only works when maxmemory-policy is *lfu.
  --scan             List all keys using the SCAN command.
  --pattern <pat>    Useful with --scan to specify a SCAN pattern.
  --intrinsic-latency <sec> Run a test to measure intrinsic system latency.
                     The test will run for the specified amount of seconds.
  --eval <file>      Send an EVAL command using the Lua script at <file>.
  --ldb              Used with --eval enable the Redis Lua debugger.
  --ldb-sync-mode    Like --ldb but uses the synchronous Lua debugger, in
                     this mode the server is blocked and script changes are
                     not rolled back from the server memory.
  --cluster <command> [args...] [opts...]
                     Cluster Manager command and arguments (see below).
  --verbose          Verbose mode.
  --no-auth-warning  Don't show warning message when using password on command
                     line interface.
  --help             Output this help and exit.
  --version          Output version and exit.

Cluster Manager Commands:
  Use --cluster help to list all available cluster manager commands.

Examples:
  cat /etc/passwd | redis-cli -x set mypasswd
  redis-cli get mypasswd
  redis-cli -r 100 lpush mylist x
  redis-cli -r 100 -i 1 info | grep used_memory_human:
  redis-cli --eval myscript.lua key1 key2 , arg1 arg2 arg3
  redis-cli --scan --pattern '*:12345*'

  (Note: when using --eval the comma separates KEYS[] from ARGV[] items)

When no command is given, redis-cli starts in interactive mode.
Type "help" in interactive mode for information on available commands
and settings.
```

## 二、Redis命令行

### 2.1、help

查看命令的使用帮助

``` redis
192.168.100.240:6379> help
redis-cli 5.0.5
To get help about Redis commands type:
      "help @<group>" to get a list of commands in <group>
      "help <command>" for help on <command>
      "help <tab>" to get a list of possible help topics
      "quit" to exit

To set redis-cli preferences:
      ":set hints" enable online hints
      ":set nohints" disable online hints
Set your preferences in ~/.redisclirc
```

### 2.2、info

info keyspace 查询库中的key信息

``` zsh
192.168.100.240:6379> info keyspace
# Keyspace
db0:keys=16,expires=6,avg_ttl=411836617
db1:keys=10,expires=0,avg_ttl=0
db6:keys=774,expires=0,avg_ttl=0
db7:keys=32,expires=0,avg_ttl=0
```

### 2.3、select

切换db库

``` zsh
192.168.100.240:6379> select 6
OK
192.168.100.240:6379[6]> dbsize
(integer) 774
```

### 2.4、服务器相关

client list

``` zsh
192.168.100.240:6379> client list
id=6018 addr=192.168.100.211:36001 fd=15 name= age=1723130 idle=1 flags=S db=0 sub=0 psub=0 multi=-1 qbuf=0 qbuf-free=0 obl=0 oll=0 omem=0 events=r cmd=replconf
id=1052523 addr=192.168.100.240:55416 fd=7 name= age=553 idle=0 flags=N db=0 sub=0 psub=0 multi=-1 qbuf=26 qbuf-free=32742 obl=0 oll=0 omem=0 events=r cmd=client
```

### 2.5、清理数据

>del key //①删除指定key
>Flushdb //②删除当前数据库中的所有Key
>flushall //③删除所有数据库中的key

``` zsh
127.0.0.1:6379> info keyspace
# Keyspace
db0:keys=10071,expires=1059,avg_ttl=1286146998
db1:keys=1802,expires=0,avg_ttl=0
db2:keys=20142,expires=19839,avg_ttl=75439528
db6:keys=175,expires=0,avg_ttl=0
db7:keys=31,expires=0,avg_ttl=0
127.0.0.1:6379> select 2
OK
127.0.0.1:6379[2]> Flushdb
OK
127.0.0.1:6379[2]> info
# Keyspace
db0:keys=10071,expires=1059,avg_ttl=1273371885
db1:keys=1802,expires=0,avg_ttl=0
db2:keys=49,expires=12,avg_ttl=1886616555
db6:keys=175,expires=0,avg_ttl=0
db7:keys=31,expires=0,avg_ttl=0
```
