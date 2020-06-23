#!/usr/bin/python
# encoding: utf-8

"""
The Script for Auto Create Deployment Yaml.

File:               rollback.py
User:               miaocunfa
Create Date:        2020-06-23
Create Time:        14:01
"""

import os
import sys
import json
import time
import psutil


def rollback(jar):
    print("\n开始回退: " + jar)
    version_jar = workDir + jar  + '.' + version
    if os.path.isfile(version_jar):
        print("存在")

        pid = os.popen("ps -ef | grep " + jar + " | grep -v grep | awk '{print $2}' ")
        pid.readlines()

        sconn_list = psutil.net_connections(kind='tcp')

        # my_sconn_list = [sconn for sconn in sconn_list if
        #                  isinstance(sconn.raddr,
        #                             addr) and sconn.raddr.port == port and sconn.status == 'ESTABLISHED']

        # see: https://github.com/giampaolo/psutil/issues/1513
        my_sconn_list = [sconn for sconn in sconn_list if sconn.status == 'ESTABLISHED' and sconn.raddr.port == port]


    else:
        print("对不起，版本文件 " + version_jar +  " 不存在!")


answer_list = {
    'y'   : '1',
    'Y'   : '1',
    'yes' : '1',
    'YES' : '1',
    'YEs' : '1',
    'Yes' : '1',
    'n'   : '0',
    'N'   : '0',
    'no'  : '0',
    'NO'  : '0',
    'No'  : '0',
}

workDir = "/opt/aihangxunxi/lib/"

# 读取版本信息至文件
version_file = "/home/miaocunfa/bin/version.json"
with open(version_file) as json_obj:
    version_info = json.load(json_obj)
print("上次发布的版本信息：")
print(json.dumps(version_info, indent=4))
version = version_info['version']


prompt = "\n是否要回退全部版本!(Y/N): "
answer = input(prompt)
isAll = answer_list.get(answer, 'None')


if isAll == 'None' :
    raise SystemExit('对不起，您入的信息有误! 程序退出! ')

if isAll == '1':
    print("开始回退全部版本")
    jars = version_info['jars']
    for jar in jars:
        rollback(jar)

if isAll == '0':

    Active = True
    while Active:

        prompt = "\n请输入要回退的服务!"
        prompt += "\n输入'quit'退出! "
        jar = input(prompt)

        if jar == 'quit':
            break
        if jar in version_info:
            rollback(jar)
        else:
            print("\n" + jar + ": 不在上次发布的版本内!")