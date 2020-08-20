---
title: "linux常用命令"
date: "2020-08-20"
categories: 
    - "技术"
tags: 
    - "linux"
    - "shell"
    - "运维"
toc: false
original: false
---

## 1、定时查找删除180天之前的文件

``` zsh
➜  find /home/ysyf/backup -type f -name "ysyf_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;
➜  find /home/hsp/backup -type f -name "hsp_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;

-mtime +180 是查找修改日期在180以上的文件
-mtime -180 是查找修改日期在180以内的文件
```

加入crontab

``` zsh
# Remove 180 Ago ysyf-archive
00 02 * * * find /home/ysyf/backup -type f -name "ysyf_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;

# Remove 180 Ago hsp-archive
00 02 * * * find /home/hsp/backup -type f -name "hsp_*_DailyBk.tar.gz" -mtime +180 -exec rm -f {} \;
```
