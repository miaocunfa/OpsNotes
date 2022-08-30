---
title: "Zabbix 监控docker容器"
date: "2021-03-15"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
    - "docker"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-15 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |

## 一、Zabbix agent

### 1.1、zabbix agent 配置

``` conf
➜  vim /etc/zabbix/zabbix_agentd.d/docker.conf
UserParameter=docker.discovery,python3 /etc/zabbix/scripts/docker_monitor.py
UserParameter=docker.[*],python3 /etc/zabbix/scripts/docker_monitor.py $1 $2
```

### 1.2、python 监控脚本

``` py
➜  vim /etc/zabbix/scripts/docker_monitor.py
#!/usr/bin/python
"""
Created by PyCharm.
File:               OpsNotes:docker_monitor.py
User:               miaocunfa
Create Date:        2021-03-12
Create Time:        17:10
Update Date:        2021-03-12
Update Time:        17:10
Version:            v0.0.1
"""

import sys
import os
import json

# 返回容器列表
def discover():
    d = {}
    d['data'] = []
    with os.popen("docker ps -a --format {{.Names}}") as pipe:
        for line in pipe:
            info = {}
            info['{#CONTAINERNAME}'] = line.replace("\n","")
            d['data'].append(info)
    print(json.dumps(d))


def status(name,action):
    # 判断容器运行状态
    if action == "ping":
        cmd = 'docker inspect --format="{{.State.Running}}" %s' %name
        result = os.popen(cmd).read().replace("\n","")
        if result == "true":
            print(1)
        else:
            print(0)
    # 网络收包
    elif action == "network_rx_bytes":
        cmd = """docker exec %s cat /proc/net/dev|sed -n 3p|awk '{print $2,$10}'""" %name
        result = os.popen(cmd).read().split()[0]
        print(result)
    # 网络发包
    elif action == "network_tx_bytes":
        cmd = """docker exec %s cat /proc/net/dev|sed -n 3p|awk '{print $2,$10}'""" %name
        result = os.popen(cmd).read().split()[1]
        print(result)
    # 使用 docker stats 命令获得容器指标
    else:
        cmd = 'docker stats %s --no-stream --format "{{.%s}}"' % (name,action)
        result = os.popen(cmd).read().replace("\n","")
        if "%" in result:
            print(float(result.replace("%","")))
        else:
            print(result)


if __name__ == '__main__':
    try:
        name, action = sys.argv[1], sys.argv[2]
        status(name,action)
    except IndexError:
        discover()
```

### 1.3、推送到服务器

``` zsh
➜  ansible docker -m copy -a "src=/root/ansible/docker.conf dest=/etc/zabbix/zabbix_agentd.d/"
➜  ansible docker -m copy -a "src=/root/ansible/docker_monitor.py dest=/etc/zabbix/scripts/"
➜  ansible docker -m shell -a "systemctl restart zabbix-agent"
```

## 二、Zabbix Server

打开链接，导入 [此模板](https://github.com/miaocunfa/OpsNotes/blob/master/Monitor/Zabbix/docker/zbx_docker_templates.xml)

点击 '配置' --> '模板' --> 找到对应模板 --> '自动发现' --> '监控项原型'

![docker 自动发现规则](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_docker_20210315.jpg)

## 三、问题解决

``` zsh
# 使用 docker.discovery 获取 Docker 列表
# zabbix 用户无法访问 /var/run/docker.sock
➜  zabbix_get -s 192.168.189.180 -p 10050 -k docker.discovery
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/containers/json?all=1: dial unix /var/run/docker.sock: connect: permission denied

# 查看 docker.sock 的权限
# docker.sock 文件 属主root、属组docker
➜  ansible docker -m shell -a "ls -rtl /var/run/docker.sock"
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details
192.168.189.175 | CHANGED | rc=0 >>
srw-rw---- 1 root docker 0 Oct 10  2019 /var/run/docker.sock
192.168.189.177 | CHANGED | rc=0 >>
srw-rw---- 1 root docker 0 Oct 10  2019 /var/run/docker.sock
192.168.189.178 | CHANGED | rc=0 >>
srw-rw---- 1 root docker 0 Oct 10  2019 /var/run/docker.sock
192.168.189.171 | CHANGED | rc=0 >>
srw-rw---- 1 root docker 0 Oct 10  2019 /var/run/docker.sock
192.168.189.176 | CHANGED | rc=0 >>
srw-rw---- 1 root docker 0 Oct 10  2019 /var/run/docker.sock
192.168.189.180 | CHANGED | rc=0 >>
srwxr-xr-x 1 root docker 0 Oct 10  2019 /var/run/docker.sock

# 将 zabbix 用户加入 docker组
# 重启 zabbix-agent 服务以生效
➜  ansible docker -m shell -a "usermod -a -G docker zabbix"
➜  ansible docker -m shell -a "systemctl restart zabbix-agent"

# 获取到 Docker 列表
➜  zabbix_get -s 192.168.189.180 -p 10050 -k docker.discovery
{"data": [{"{#CONTAINERNAME}": "V_Prod_Bidding_Two"}, {"{#CONTAINERNAME}": "V_Prod_Machine_Two"}, {"{#CONTAINERNAME}": "V_Prod_Order_Two"}, {"{#CONTAINERNAME}": "V_Prod_Project_One"}, {"{#CONTAINERNAME}": "V_Prod_Three_One"}, {"{#CONTAINERNAME}": "V_Prod_School_One"}]}
```

## 四、验证数据

检测 --> 最新数据 --> 应用集选 'docker_monitor'

![docker数据](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_docker_data_20210315.jpg)

> 参考文档：  
> [1] [zabbix自发现实时监控docker容器及容器中各个服务的状态线上业务展示](https://blog.51cto.com/13120271/2312106)  
> [2] [zabbix监控docker容器状态](https://www.cnblogs.com/binglansky/p/9132714.html)  
>