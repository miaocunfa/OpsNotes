---
title: "Zabbix清除历史数据"
date: "2021-05-19"
categories:
    - "技术"
tags:
    - "Zabbix"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-05-19 | 初稿 |

## 清理脚本

```
➜  vim clearzabbix.sh
#!/bin/bash

User="root"
Passwd="qawsEDRF@@"

# 取7天之前的时间戳
Date=`date -d $(date -d "-7 day" +%Y%m%d) +%s` 

$(which mysql) -u${User} -p${Passwd} -e "
use zabbix;

DELETE FROM history WHERE clock < $Date;
optimize table history;

DELETE FROM history_str WHERE clock < $Date;
optimize table history_str;

DELETE FROM history_uint WHERE clock < $Date;
optimize table history_uint;

DELETE FROM history_text WHERE clock < $Date;
optimize table history_text;

DELETE FROM  trends WHERE clock < $Date;
optimize table  trends;

DELETE FROM trends_uint WHERE clock < $Date;
optimize table trends_uint;

DELETE FROM events WHERE clock < $Date;
optimize table events;
"
```

## 清空表

``` sql
truncate table history;
truncate table history_uint;
truncate table history_str;
truncate table history_text;
truncate table trends;
truncate table trends_uint;
truncate table events;
```

## 定时任务

``` zsh
➜  crontab -e
# remove the zabbix mysql data before 7 day's ago
0 3 * * 0 /usr/local/script/clearzabbix.sh > /usr/local/script/clearzabbix.log
```
