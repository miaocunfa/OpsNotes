---
title: "Zabbix 自定义脚本实现系统监控"
date: "2021-03-08"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
    - "ansible"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                                                                                                        |
| ---------- | ----------------------------------------------------------------------------------------------------------- |
| 2021-03-08 | 初稿                                                                                                        |
| 2021-03-09 | 1、批量更新主机 </br> 2、CPU </br> 3、内存 </br> 4、IO </br> 5、TCP                                         |
| 2021-03-11 | 1、CPU 增加整体负载百分比 </br> 2、内存 增加使用率 </br> 3、TCP 增加 CLOSEWAIT 状态 </br> 4、增加磁盘使用率 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |

## 一、zabbix agent配置

需要先将 zabbix agent 的配置做一下修改

``` zsh
# 要加下面这句
➜  vim /etc/zabbix/zabbix_agentd.conf
Include=/etc/zabbix/zabbix_agentd.d/*.conf
```

## 二、zabbix server 配置

### 2.1、zabbix server 创建新模板

配置 --> 模板 --> 创建模板

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_template_20210308.jpg)

### 2.2、批量更新主机模板

配置 --> 主机 --> 选中所有主机 --> 批量更新

![更新主机](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_template_03_20210309.jpg)

## 三、CPU

### 3.1、脚本 && 配置

脚本

``` zsh
➜  vim /etc/zabbix/scripts/cpu_load_status.sh
#!/bin/bash
############################################################
# @Name:            cpu_load_status.sh
# @Version:         v1.1
# @Function:        cpu Status
# @Author:          guozhimin
# @Create Date:     2018-06-23
# @Update Date：    2021-03-11
# @Description:     Monitor CPU Service Status
############################################################

export TERM=linux

function minute_1(){
        uptime | awk '{print $10}'
}

function minute_5(){
       uptime | awk '{print $11}'
}

function minute_15(){
       uptime | awk '{print $12}'
}

function Usage(){
        cpucore=`cat /proc/cpuinfo | grep 'processor' |wc -l`
        cpuload=`top -bn 1 | grep 'load average' | awk -F":" '{print $5}' | awk -F"," '{print $1*100}'`
        cpuload_percent=$[${cpuload}/${cpucore}]
        echo $cpuload_percent
}

[ $# -ne 1 ] && echo "minute_1|minute_5|minute_15|Usage" && exit 1

$1
```

配置

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/cpu_load_status.conf
UserParameter=cpu_load_status[*],/bin/bash /etc/zabbix/scripts/cpu_load_status.sh "$1"
```

### 3.2、使用 ansible 批量推送

``` zsh
➜  ansible all -m shell -a "mkdir -p /etc/zabbix/scripts/"
➜  ansible all -m copy -a "src=/root/ansible/cpu_load_status.conf dest=/etc/zabbix/zabbix_agentd.d/cpu_load_status.conf"
➜  ansible all -m copy -a "src=/root/ansible/cpu_load_status.sh   dest=/etc/zabbix/scripts/cpu_load_status.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```

### 3.3、zabbix server - 验证

添加完监控脚本以后，可使用 zabbix_get 命令验证是否生效。

``` zsh
# -k 后面指定键值，就是 UserParameter 的值。
➜  zabbix_get -s 192.168.189.186 -p 10050 -k cpu_load_status[minute_1]
0.47,
```

### 3.4、zabbix server - UI 添加监控项

配置 --> 模板 --> [找到自定义模板] --> 点击'监控项'

![进入自定义模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_template_02_20210308.jpg)

点击 --> 创建监控项

![创建监控项](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_monitor_items_03_20210309.jpg)

### 3.5、验证监控项

检测 --> 最新数据 --> 选择主机

![监控项数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_monitor_items_04_20210309.jpg)

## 四、内存

添加监控项操作与上述一致，就不一一截图了。只贴出监控脚本 && 配置。

### 4.1、脚本 && 配置

脚本

``` zsh
➜  vim /etc/zabbix/scripts/free_status.sh
#!/bin/bash

function Total(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $2}'
}

function Used(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $3}'
}

function Free(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $4}'
}

function Shared(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $5}'
}

function Buff_Cache(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $6}'
}

function Available(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $7}'
}

function Swap_total(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $2}'
}

function Swap_userd(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $3}'
}

function Swap_free(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $4}'
}

function Usage(){
    total=$(/usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $2}')
    used=$(/usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $3}')
    usage=$(awk 'BEGIN{printf "%.2f\n",('$used'/'$total')*100}')
    echo $usage
}

[ $# -ne 1 ] && echo "Total|Used|Free|Shared|Buff_Cache|Available|Swap_total|Swap_userd|Swap_free|Usage" && exit 1

#根据脚本参数执行对应函数
$1
```

配置

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/free_status.conf
UserParameter=free_status[*],/bin/bash /etc/zabbix/scripts/free_status.sh "$1"
```

### 4.2、使用 ansible 批量推送

``` zsh
➜  ansible all -m copy -a "src=/root/ansible/free_status.conf dest=/etc/zabbix/zabbix_agentd.d/free_status.conf"
➜  ansible all -m copy -a "src=/root/ansible/free_status.sh   dest=/etc/zabbix/scripts/free_status.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```

## 五、IO

### 5.1、脚本 && 配置

脚本

``` zsh
➜  vim /etc/zabbix/scripts/io_status.sh
#!/bin/bash

if [ $# -ne 1 ];then
    echo "Follow the script name with an argument"
fi

case $1 in

    rrqm)
        iostat -dxk 1 1|grep -w vda |awk '{print $2}'
        ;;

    wrqm)
        iostat -dxk 1 1|grep -w vda |awk '{print $3}'
        ;;

    rps)
        iostat -dxk 1 1|grep -w vda|awk '{print $4}'
        ;;

    wps)
        iostat -dxk 1 1|grep -w vda |awk '{print $5}'
        ;;

    rKBps)
        iostat -dxk 1 1|grep -w vda |awk '{print $6}'
        ;;

    wKBps)
        iostat -dxk 1 1|grep -w vda |awk '{print $7}'
        ;;

    avgrq-sz)
        iostat -dxk 1 1|grep -w vda |awk '{print $8}'
        ;;

    avgqu-sz)
        iostat -dxk 1 1|grep -w vda |awk '{print $9}'
        ;;

    await)
        iostat -dxk 1 1|grep -w vda|awk '{print $10}'
        ;;

    svctm)
        iostat -dxk 1 1|grep -w vda |awk '{print $13}'
        ;;

    util)
        iostat -dxk 1 1|grep -w vda |awk '{print $14}'
        ;;

    *)
        echo -e "\033[32mUsage: sh $0 [rrqm|wrqm|rps|wps|rKBps|wKBps|avgqu-sz|avgrq-sz|await|svctm|util]\033[0m"
esac
```

配置

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/io_status.conf
UserParameter=io_status[*],/bin/bash /etc/zabbix/scripts/io_status.sh "$1"
```

### 5.2、使用 ansible 批量推送

``` zsh
➜  ansible all -m copy -a "src=/root/ansible/io_status.conf dest=/etc/zabbix/zabbix_agentd.d/io_status.conf"
➜  ansible all -m copy -a "src=/root/ansible/io_status.sh   dest=/etc/zabbix/scripts/io_status.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```

## 六、TCP

### 6.1、脚本 && 配置

脚本

``` zsh
➜  vim /etc/zabbix/scripts/tcp_status.sh
#!/bin/bash

function SYNRECV {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'SYN-RECV' | awk '{print $2}'
}

function ESTAB {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'ESTAB' | awk '{print $2}'
}

function FINWAIT1 {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-1' | awk '{print $2}'
}

function FINWAIT2 {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-2' | awk '{print $2}'
}

function TIMEWAIT {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'TIME-WAIT' | awk '{print $2}'
}

function CLOSEWAIT {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'CLOSE-WAIT' | awk '{print $2}'
}

function LASTACK {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LAST-ACK' | awk '{print $2}'
}

function LISTEN {
    /usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LISTEN' | awk '{print $2}'
}

$1
```

配置

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/tcp_status.conf
UserParameter=tcp_status[*],/bin/bash /etc/zabbix/scripts/tcp_status.sh "$1"
```

### 6.2、使用 ansible 批量推送

``` zsh
➜  ansible all -m copy -a "src=/root/ansible/tcp_status.conf dest=/etc/zabbix/zabbix_agentd.d/tcp_status.conf"
➜  ansible all -m copy -a "src=/root/ansible/tcp_status.sh   dest=/etc/zabbix/scripts/tcp_status.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```

## 七、磁盘

### 7.1、脚本 && 配置

脚本

``` zsh
➜  vim /etc/zabbix/scripts/disk_usage.sh
#!/bin/bash
############################################################
# @Name:            disk Usage Shell
# @Version:         v0.0.1
# @Author:          miaocunfa
# @Create Date:     2021-03-11
# @Update Date：    2021-03-11
# @Description:     return disk usage
############################################################

df -h | grep -w vda1 | awk -F'[ %]+' '{print $5}'
```

配置

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/disk_usage.conf
UserParameter=disk_usage,/bin/bash /etc/zabbix/scripts/disk_usage.sh
```

### 7.2、使用 ansible 批量推送

``` zsh
➜  ansible all -m copy -a "src=/root/ansible/disk_usage.conf dest=/etc/zabbix/zabbix_agentd.d/disk_usage.conf"
➜  ansible all -m copy -a "src=/root/ansible/disk_usage.sh   dest=/etc/zabbix/scripts/disk_usage.sh"
➜  ansible all -m shell -a "systemctl restart zabbix-agent"
```
