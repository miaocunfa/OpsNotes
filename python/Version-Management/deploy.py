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


# Set Parameter
workDir = "/opt/aihangxunxi/"
ahanglib = workDir + "lib/"
ahangbin = workDir + "bin/"
deploy_dir = "/home/miaocunfa/deployJar"
deploy_jars = os.listdir(deploy_dir)
Not_distributed = 0                                                       # 0: 默认经过分发服务器, 1: 直接部署
version_time = time.strftime('%Y%m%d%H%M',time.localtime(time.time()))    # 直接部署的版本号
distributed_file = "/home/miaocunfa/bin/distributed.json"
repository_file = "/opt/aihangxunxi/bin/Repository.json"
hostname = socket.gethostname()


def deploy(jar):
    stop_stdout = os.popen(ahangbin + "stop.sh " + jar)
    stop_contents = stop_stdout.read()
    print(stop_contents.rstrip())

    # 备份原程序包
    #os.chdir(ahanglib)
    #os.rename(jar, jar + '.rollback')
    #os.rename(jar + "." + version, jar)

    if jar == 'info-message-service.jar':
        checkMessagePort()

    start_stdout = os.popen(ahangbin + "start.sh " + jar)
    start_contents = start_stdout.read()
    print(start_contents.rstrip())


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


# 读取版本库
if os.path.isfile(repository_file):
    with open(repository_file) as json_obj:
        Repository = json.load(json_obj)
else:
    print('Repository File: ' + repository_file + ': No such file or directory')
    Repository = {}

# 读取分发信息
if os.path.isfile(distributed_file):
    with open(distributed_file) as json_obj:
        distributed_info = json.load(json_obj)

    distributed_version = distributed_info['last-distributed']
else:
    Not_distributed = 1


if Not_distributed:
    print("不经过分发")

    deployed_version = {}    # 声明一个空的部署版本, 用来存储部署版本的信息
        
    #Repository['last-state'] = "Not-deployed"    # 更新初始状态
    #Repository['last-deployed'] = ""             # 更新初始状态
        
    print(jar)
    #deploy(jar)

else:
    print("经过分发")
    deploy_version = distributed_version

    if distributed_version not in Repository:
        print("未部署")

        del distributed_info['last-state']
        del distributed_info['last-distributed']
            
        Repository.update(distributed_info)
        deployed_Jars = []       # 声明一个空的列表, 用来存储当前主机部署了哪些Jar
            
        for jar in deploy_jars:
            print(jar)
            #deploy(jar)

            # 部署成功
            deployed_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
            Repository[distributed_version][jar]['state'] = "deployed"
            Repository[distributed_version][jar]['deployed-time'] = deployed_time
            Repository['last-distributed'] = distributed_version
            deployed_Jars.append(jar)

        # 版本更细结束, 更新版本库
        Repository[distributed_version][hostname] = deployed_Jars
        Repository['last-deployed'] = deploy_version
        Repository['last-state'] = "deployed"

        # 更新版本库
        with open(repository_file, mode='w', encoding='utf-8') as json_obj:
            json.dump(Repository, json_obj)

    else:
        print("部分部署")

        for jar in deploy_jars:
            if Repository[deploy_version][jar]['state'] != "deployed": 
                print("部分部署-未部署")
                print(jar)
                #deploy(jar)
            else:
                print(jar + ": is already deployed!")