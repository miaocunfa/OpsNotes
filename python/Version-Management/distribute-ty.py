#!/usr/bin/python
# encoding: utf-8
"""
Created by VS Code.
File:               OpsNotes:distribute-test.py
User:               miaocunfa
Create Date:        2020-05-05
Create Time:        16:44
 """

import os
import sys
import json
import time
import paramiko
from scp import SCPClient

def progress4(filename, size, sent, peername):
    sys.stdout.write("(%s:%s) %s\'s progress: %.2f%%   \r" % (peername[0], peername[1], filename, float(sent)/float(size)*100) )

def sendfile(local_filename, remote_filename, remote_hosts):
    for host in remote_hosts:
        ssh.connect(host, port=remote_port, username=remote_user, password=remote_pass) 
        with SCPClient(ssh.get_transport(), progress4=progress4) as scp:
            scp.put(local_filename, remote_filename)
            print("")

deploy_info = {
    'info-gateway.jar':           ['s1', 's4'],
    'info-cms.jar':               ['ng1'],
    'info-org-property.jar':      ['ng1'],
    'info-org-hotel.jar':         ['ng2'],
    'info-config.jar':            ['s1'],
    'info-consumer-service.jar':  ['s2'],
    'info-message-service.jar':   ['192.168.100.222'],
    'info-scheduler-service.jar': ['s3'],
    'info-agent-service.jar':     ['s2', 's3'],
    'info-ad-service.jar':        ['192.168.100.222'],
    'info-auth-service.jar':      ['s2', 's3'],
    'info-community-service.jar': ['s2', 's3'],
    'info-groupon-service.jar':   ['s2', 's3'],
    'info-hotel-service.jar':     ['s2', 's3'],
    'info-nearby-service.jar':    ['s2', 's3'],
    'info-news-service.jar':      ['s2', 's3'],
    'info-payment-service.jar':   ['s2', 's3'],
    'info-uc-service.jar':        ['192.168.100.222'],
}

#version_hosts = ['s1', 's2', 's3', 's4', 'ng1', 'ng2']
version_hosts = ['192.168.100.218', '192.168.100.222']

distribute_dir = "/home/wangchaochao/distributeJar/"
distribute_jars = os.listdir(distribute_dir)
version_time = time.strftime('%Y%m%d%H%M',time.localtime(time.time()))
distributed_file = "/home/miaocunfa/bin/distributed.json"

remote_path="/home/miaocunfa/deployJar/"
remote_port="22"
#remote_user="miaocunfa"
#remote_pass="@WSX#EDC"
remote_user="root"
remote_pass="test123"

# 创建ssh访问
ssh = paramiko.SSHClient()
ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())   # 允许连接不在know_hosts文件中的主机

if distribute_jars:
    print("")
    print("Version: " + version_time)
    print("")
    print("Deploy Jars: ")
    print(json.dumps(distribute_jars, indent=4))
    print("")
    
    distributed_info = {}       # 声明一个空的分发信息, 用来存储所有的分发版本
    distributed_version = {}    # 声明一个空的分发版本, 用来存储分发版本的信息
    distributed_Jars = []       # 声明一个空的列表, 用来存储当前版本分发了哪些Jar

    distributed_info['last-state'] = "Not distributed"   # 更新初始状态
    distributed_info['last-distributed'] = ""             # 更新初始状态
    
    for jar in distribute_jars:
        if jar in deploy_info:

            hosts = deploy_info[ jar ]
            remote_filename = remote_path + jar
            local_filename = distribute_dir + jar

            # 分发版本信息更新
            jarInfo = {}        # 用于存储分发版本中的Jar信息
            jarInfo['version'] = version_time
            jarInfo['hosts'] = hosts
            jarInfo['state'] = "Not distributed"
            distributed_version[jar] = jarInfo
            
            # 发送部署文件至部署主机
            # 发送信息及状态展示
            print(jar + ': ', end='')
            print(hosts)
            sendfile(local_filename, remote_filename, hosts)

            # 发送Jar成功, 更新Jar的分发信息
            distributed_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
            distributed_version[jar]['distributed-time'] = distributed_time
            distributed_version[jar]['state'] = "distributed"
            distributed_info[version_time] = distributed_version
            distributed_Jars.append(jar)
        else:
            raise SystemExit(jar + ': is Not In deploy_info{}')

    # 所有Jar发送成功, 更新分发版本信息
    distributed_info[version_time]['distributed-Jars'] = distributed_Jars
    distributed_info['last-distributed'] = version_time
    distributed_info['last-state'] = "distributed"

    # 写入分发信息至文件
    with open(distributed_file, mode='w', encoding='utf-8') as json_obj:
        json.dump(distributed_info, json_obj)

    print("")
    print("Send Version Info: ")

    # 发送分发信息至主机
    sendfile(distributed_file, distributed_file, version_hosts)
else:
    print(distribute_dir + ": is Empty!")