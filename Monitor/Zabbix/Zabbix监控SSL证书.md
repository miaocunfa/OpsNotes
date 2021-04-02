---
title: "Zabbix 监控 SSL证书"
date: "2021-04-02"
categories:
    - "技术"
tags:
    - "zabbix"
    - "ssl证书"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-04-02 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |

## 引言

现在越来越多的浏览器要求你使用SSL证书，google浏览器直接不允许访问非SSL证书认证的网站，所以现在下公司SSL证书越来越多，这就带来了一个问题，如果SSL证书过期了，会非常影响用户体验。

所以结合公司正在使用的Zabbix监控告警平台，提前告知SSL证书即将过期，将对管理SSL证书非常有效。

## Zabbix Agent

### 自动发现脚本

``` zsh
➜  vim /etc/zabbix/scripts/ssl_discover.py
#!/usr/bin/python
"""
Created by Vscode.
File:               OpsNotes:ssl_discover.py
User:               miaocunfa
Create Date:        2021-04-02
Create Time:        16:08
Update Date:        2021-04-02
Update Time:        17:04
Version:            v0.0.3
"""

import os
import json

# 返回证书列表
def discover():
    d = {}
    d['data'] = []
    with os.popen("cd /usr/local/nginx/conf/https/; ls *.crt") as pipe:
        for line in pipe:
            info = {}
            info['{#CRTFILE}'] = line.replace("\n","")
            d['data'].append(info)
    print(json.dumps(d))

discover()

# 执行脚本 返回如下json
➜  python3 ssl_discover.py
{"data": [{"{#CRTFILE}": "1_api.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_api.qixinbao.net.cn_bundle.crt"}, {"{#CRTFILE}": "1_api.shengshui.com_bundle.crt"}, {"{#CRTFILE}": "1_api.tt321.net_bundle.crt"}, {"{#CRTFILE}": "1_fleetin.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_front.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_market.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_website.page.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_www.gongjiangren.net_bundle.crt"}, {"{#CRTFILE}": "1_www.qixinbao.net.cn_bundle.crt"}, {"{#CRTFILE}": "1_www.shengshui.com_bundle.crt"}, {"{#CRTFILE}": "1_yqfk.gongjiangren.net_bundle.crt"}]}
```

### 监控脚本

``` zsh
➜  vim /etc/zabbix/scripts/ssl_check.sh
#!/bin/bash

# Describe:     ssl_check.sh
# Create Date： 2021-04-02
# Create Time:  15:48
# Update Date:  2021-04-02
# Update Time:  16:59
# Author:       MiaoCunFa
# Version:      v0.0.4

#===================================================================

function Usage(){
    echo "Usage: ssl_check [crtfile] [alertday]"
}

crtfile=$1
alert_date=$2

crtdir="/usr/local/nginx/conf/https"

if [ "$1" == "" ];
then
    Usage
    exit 0
fi

if [ "$2" == "" ];
then
    Usage
    exit 0
fi

#===================================================================

cd $crtdir

# 过期时间 && 过期时间时间戳
expire_date=$(openssl x509 -in $crtfile -noout -text | grep "Not After" | awk -F " : " '{print $2}')
expire_stamp=$(date -d "$expire_date" +%s)

# 提醒日期 && 提醒日期时间戳
alert_stamp=$(($expire_stamp - $alert_date * 86400))

# 当前日期 && 当前日期时间戳
curdate_stamp=$(date +%s)
#curdate_stamp=$(date --date 20210823 +%s)

# 判断当期日期与提醒日期
if [ $curdate_stamp -ge $alert_stamp ]; then
    echo 1
else
    echo 0
fi
```

### 配置文件

``` zsh
➜  vim /etc/zabbix/zabbix_agentd.d/ssl.conf
UserParameter=ssl.discovery,python3 /etc/zabbix/scripts/ssl_discover.py
UserParameter=ssl.check[*],/bin/bash /etc/zabbix/scripts/ssl_check.sh $1 $2
```

### 执行权限 && agent重启

``` zsh
➜  cd /etc/zabbix/scripts
➜  chown -R zabbix:zabbix ssl*
➜  chmod u+x ssl*

➜  systemctl restart zabbix-agent
```

## Zabbix UI

1、创建模板

点击 '配置' --> '模板' --> '创建模板'

![创建模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_02.jpg)

2、创建自动发现

选择模板 --> 点击'自动发现' --> '创建发现规则'

![创建自动发现](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_03.jpg)

3、创建监控项原型

在自动发现规则下 --> 点击 '监控项原型' --> '创建监控项原型'

![创建监控项原型](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_05.jpg)

4、创建触发器

在自动发现规则下 --> 点击 '触发器类型' --> '创建触发器原型'

![创建触发器](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_06.jpg)

5、主机添加模板

点击 '配置' --> 选择'主机' --> 点击'模板' --> 选择'模板'添加

![主机添加模板](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_07.jpg)

6、验证数据

点击 '监测' --> '最新数据' --> 选择'主机'与'应用集' --> '应用'

![验证数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_01.jpg)

7、报警信息

![报警信息](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_ssl_20210402_09.jpg)

> 参考文档：  
> [1] [SSL证书到期时间监控提醒工具+脚本推荐](http://www.vpser.net/manage/ssl-certificate-check-monitor.html)  
> [2] [监控域名HTTPS证书过期时间](https://blog.csdn.net/qq_24794401/article/details/108892057)  
> [3] [查看域名https证书到期时间](http://www.bubuko.com/infodetail-2485591.html)  
> [4] [Shell日期时间和时间戳的转换](https://blog.csdn.net/xfxf996/article/details/103779611)  
>