#!/usr/bin/python
# encoding: utf-8
"""
Created by VS Code.
File:               OpsNotes:distribute.py
User:               miaocunfa
Create Date:        2020-06-18
Create Time:        17:12
 """

import os
import sys
import json
import time
import socket

def check_ip_port(IP, Ports):
    for port in Ports:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(3)
        result = s.connect_ex((IP, port))
        if result == 0:
            print("The Server IP: {} , Port {} has been used".format(IP, port))
        elif result == 10061:
            print("The Server IP: {} , Port {} not enabled".format(IP, port))
        elif result == 10035:
            print("The Server IP: {} , no response".format(IP, port))
        else:
            print(result)
        s.close()


deploy_dir = "/home/miaocunfa/deployJar"
deploy_jars = os.listdir(deploy_dir)
version_file = "/home/miaocunfa/bin/version.json"

# 读取版本信息至文件
with open(version_file) as json_obj:
    version_info = json.load(json_obj)

version = version_info['version']

if deploy_jars: 
    print("deploy jars: ")
    print(json.dumps(deploy_jars, indent=4))
    print("")

    for jar in deploy_jars:
        if 'info-message-service.jar' in deploy_jars:
            check_ip_port(ip, ['8555', '9666'])
        else:
        
else:
    print(deploy_dir + ": is Empty!")