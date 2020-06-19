#!/usr/bin/python
# encoding: utf-8
"""
Created by VS Code.
File:               OpsNotes:deploy.py
User:               miaocunfa
Create Date:        2020-06-18
Create Time:        17:12
 """

import os
import sys
import json
import time
import socket


# -------------------------------------------------------------------------
def check_ip_port(IP, Port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(3)
    result = s.connect_ex((IP, Port))
    if result == 0:
        print("The Server IP: {} , Port {} has been used".format(IP, Port))
    elif result == 10061:
        print("The Server IP: {} , Port {} not enabled".format(IP, Port))
    elif result == 10035:
        print("The Server IP: {} , no response".format(IP, Port))
    else:
        print(result)
    s.close()
    return result


def get_host_ip(): 
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    finally:
        s.close()
    return ip


def check_message_service()
    if 'info-message-service.jar' in deploy_jars:
        Active = 0

        while Active:
            return8 = check_ip_port(IP, 8555)
            #print(return8)
            return9 = check_ip_port(IP, 9666)
            #print(return9)

            if ( return8 == '0' ) and ( return9 == '0'):
                print("Port in Use!")
            else:
                Active = 1


# --------------------------------------------------------
deploy_dir = "/home/miaocunfa/deployJar"
deploy_jars = os.listdir(deploy_dir)
version_file = "/home/miaocunfa/bin/version.json"
IP = get_host_ip()

# --------------------------------------------------------
# 读取版本信息至文件
with open(version_file) as json_obj:
    version_info = json.load(json_obj)

version = version_info['version']
print(version)
print(IP)

if deploy_jars: 
    print("deploy jars: ")
    print(json.dumps(deploy_jars, indent=4))
    print("")

    for jar in deploy_jars:
        check_message_service()
        
else:
    print(deploy_dir + ": is Empty!")