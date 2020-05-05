#!/usr/bin/python
# encoding: utf-8
"""
Created by VS Code.
File:               OpsNotes:distribute.py
User:               miaocunfa
Create Date:        2020-05-05
Create Time:        16:44
 """

import os
import paramiko

deploy={
    'info-gateway.jar':           ['s2'],
    'info-cms.jar':               ['ng1'],
    'info-org-hotel.jar':         ['ng2'],
    'info-consumer-service.jar':  ['s1', 's4'],
    'info-agent-service.jar':     ['s2', 's3'],
    'info-ad-service.jar':        ['s2', 's3'],
    'info-auth-service.jar':      ['s2', 's3'],
    'info-community-service.jar': ['s2', 's3'],
    'info-groupon-service.jar':   ['s2', 's3'],
    'info-hotel-service.jar':     ['s2', 's3'],
    'info-message-service.jar':   ['s2', 's3'],
    'info-nearby-service.jar':    ['s2', 's3'],
    'info-news-service.jar':      ['s2', 's3'],
    'info-payment-service.jar':   ['s2', 's3'],
    'info-scheduler-service.jar': ['s2', 's3'],
    'info-uc-service.jar':        ['s2', 's3'],
    'info-store-service.jar':     ['s2', 's3'],
}

deploy_dir = "/home/wangchaochao/"
deploy_jars = os.listdir(deploy_dir)

# 创建ssh访问
ssh = paramiko.SSHClient()
ssh.load_system_host_keys()
# 允许连接不在know_hosts文件中的主机
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())   

if deploy_jars:
    for jar, hosts in deploy:
        if jar in deploy_jars:
            for host in hosts:
                remote_path="/home/miaocunfa/"
                remote_filename=remote_path + jar
                local_filename=deploy_dir + jar

                # 远程访问的服务器信息
                ssh.connect(host, port=22, username=root, password=test123) 
   
                #创建scp
                with closing(scpclient.Write(ssh.get_transport(), remote_path=remote_path)) as scp:
                    scp.send_file(local_filename, preserve_times=True, remote_filename=remote_filename) 