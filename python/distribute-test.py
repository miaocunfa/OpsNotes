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
    for host in hosts:
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
    'info-message-service.jar':   ['s3'],
    'info-scheduler-service.jar': ['s3'],
    'info-agent-service.jar':     ['s2', 's3'],
    'info-ad-service.jar':        ['s2', 's3'],
    'info-auth-service.jar':      ['s2', 's3'],
    'info-community-service.jar': ['s2', 's3'],
    'info-groupon-service.jar':   ['s2', 's3'],
    'info-hotel-service.jar':     ['s2', 's3'],
    'info-nearby-service.jar':    ['s2', 's3'],
    'info-news-service.jar':      ['s2', 's3'],
    'info-payment-service.jar':   ['s2', 's3'],
    'info-uc-service.jar':        ['s2', 's3'],
    'info-test1-service.jar':     ['192.168.100.237'],
    'info-test2-service.jar':     ['192.168.100.237'],
    'info-test3-service.jar':     ['192.168.100.237'],
}

#version_hosts = ['s1', 's2', 's3', 's4', 'ng1', 'ng2']
version_hosts = ['192.168.100.237']

deploy_dir = "/home/wangchaochao/"
deploy_jars = os.listdir(deploy_dir)
version_time = time.strftime('%Y%m%d%H%M',time.localtime(time.time()))
version_file = "/opt/aihangxunxi/bin/version.json"

remote_path="/home/miaocunfa/"
remote_port="22"
#remote_user="miaocunfa"
remote_user="root"
#remote_pass="@WSX#EDC"
remote_pass="test123"

# 创建ssh访问
ssh = paramiko.SSHClient()
ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())   # 允许连接不在know_hosts文件中的主机

if deploy_jars: 
    print("deploy jars: ")
    print(json.dumps(deploy_jars, indent=4))
    print("")

    # 声明一个空的版本信息
    version_info = {}

    for jar in deploy_jars:
        if jar in deploy_info:
            hosts = deploy_info[ jar ]
            remote_filename=remote_path + jar
            local_filename=deploy_dir + jar

            # 版本信息更新
            jarInfo = {}
            jarInfo['version'] = version_time
            jarInfo['hosts'] = hosts
            version_info[jar] = jarInfo

            # 发送部署文件至部署主机
            sendfile(local_filename, remote_filename, hosts)
        else:
            raise SystemExit(jar + ': is Not In deploy_info{}')

    # 写入版本信息至文件
    with open(version_file, mode='w', encoding='utf-8') as json_obj:
        json.dump(version_info, json_obj)

    print("")
    print("Version: " + version_time)
    print("Send Version Info: ")

    # 发送版本信息至主机
    sendfile(version_file, version_file, version_hosts)
else:
    print(deploy_dir + ": is Empty!")