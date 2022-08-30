#!/usr/bin/python
# encoding: utf-8

"""
The Script for rollback last deploy.

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


# Set Parameter
workDir = "/opt/aihangxunxi/"
ahanglib = workDir + "lib/"
ahangbin = workDir + "bin/"

def rollback(jar):
    print("\n开始回退: " + jar)

    version_jar = ahanglib + jar  + "." + version

    if os.path.isfile(version_jar):
        stop_stdout = os.popen(ahangbin + "stop.sh " + jar)
        stop_contents = stop_stdout.read()
        print(stop_contents.rstrip())

        # 回退版本
        os.chdir(ahanglib)
        os.rename(jar, jar + '.rollback')
        os.rename(jar + "." + version, jar)

        if jar == 'info-message-service.jar':
            checkMessagePort()

        start_stdout = os.popen(ahangbin + "start.sh " + jar)
        start_contents = start_stdout.read()
        print(start_contents.rstrip())

    else:
        print("对不起，版本文件 " + version_jar +  " 不存在!")


def checkMessagePort():
    print("\nWaiting for MessageService Port Connection Close!")
    Active = True
    while Active:
        sconn_list = psutil.net_connections(kind='tcp')
        message_8555_conn = len([sconn for sconn in sconn_list if sconn.status == 'ESTABLISHED' and sconn.laddr.port == 8555])
        message_9666_conn = len([sconn for sconn in sconn_list if sconn.status == 'ESTABLISHED' and sconn.laddr.port == 9666])

        print('Port 8555 connection num: ' + str(message_8555_conn))
        print('Port 9666 connection num: ' + str(message_9666_conn))

        if message_8555_conn == 0 and message_9666_conn == 0:
            Active = False
        else:
            time.sleep(3)


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


# 读取版本信息至文件
version_file = "/home/miaocunfa/bin/version.json"
with open(version_file) as json_obj:
    version_info = json.load(json_obj)
print("上次发布的版本信息：")
print(json.dumps(version_info, indent=4))
version = version_info['version']

# 接收用户输入
prompt = "\n是否要回退全部版本!(Y/N): "
answer = input(prompt)
isAll = answer_list.get(answer, 'None')

# 输入错误退出
if isAll == 'None' :
    raise SystemExit('对不起，您入的信息有误! 程序退出! ')

# 全服务
if isAll == '1':
    print("开始回退全部版本")
    jars = version_info['jars']
    for jar in jars:
        rollback(jar)

# 单服务
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