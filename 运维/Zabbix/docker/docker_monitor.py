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
        cmd = """sudo /usr/bin/docker exec %s cat /proc/net/dev|sed -n 3p|awk '{print $2,$10}'""" %name
        result = os.popen(cmd).read().split()[0]
        print(result)
    # 网络发包
    elif action == "network_tx_bytes":
        cmd = """sudo /usr/bin/docker exec %s cat /proc/net/dev|sed -n 3p|awk '{print $2,$10}'""" %name
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
