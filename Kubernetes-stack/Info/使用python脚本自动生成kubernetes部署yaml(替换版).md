---
title: "使用python脚本自动生成kubernetes部署yaml(替换版)"
date: "2020-06-10"
categories:
    - "技术"
tags:
    - "python"
    - "Kubernetes"
    - "容器化"
    - "yaml"
toc: false
indent: false
original: true
---

## 1、模板

``` bash
➜ vim info-mould-deploy.yaml
apiVersion: v1
kind: Service
metadata:
  name: ${jarName}
  labels:
    name: ${jarName}
    version: v1
spec:
  ports:
    - port: ${port}
      targetPort: ${port}
  selector:
    name: ${jarName}

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${jarName}
  labels:
    name: ${jarName}
spec:
  selector:
    matchLabels:
      name: ${jarName}
  replicas: 1
  template:
    metadata:
      labels:
        name: ${jarName}
    spec:
      containers:
      - name: ${jarName}
        image: reg.test.local/library/${jarName}:${tag}
      imagePullSecrets:
        - name: registry-secret
```

## 2、生成脚本

``` shell
➜  vim auto_create_deploy_yaml.py
#!/usr/bin/python
# encoding: utf-8

"""
The Script for Auto Create Deployment Yaml.

File:               auto_create_deploy_yaml
User:               miaocunfa
Create Date:        2020-06-10
Create Time:        17:06
"""

import os

tag = "0.0.1-SNAPSHOT"
mould_file = "info-mould-deploy.yaml"

services = {
    'info-gateway':               ['9999'],
    'info-admin':                 ['7777'],
    'info-config':                ['8888'],
    'info-message-service':       ['8555', '9666'],
    'info-auth-service':          ['8666'],
    'info-scheduler-service':     ['8777'],
    'info-uc-service':            ['8800'],
    'info-ad-service':            ['8801'],
    'info-community-service':     ['8802'],
    'info-groupon-service':       ['8803'],
    'info-hotel-service':         ['8804'],
    'info-nearby-service':        ['8805'],
    'info-news-service':          ['8806'],
    'info-store-service':         ['8807'],
    'info-payment-service':       ['8808'],
    'info-agent-service':         ['8809'],
    'info-consumer-service':      ['8090'],
}

isMould = os.path.isfile(mould_file)

if isMould:
    for service_name, service_ports in services.items():
        for port in service_ports:
            save_file = 'auto/' + service_name + '-deploy.yaml'
            outfile = open(save_file, 'w', encoding='utf-8')

            # 对文件的每一行进行遍历，同时进行替换操作
            with open(mould_file, encoding='utf-8') as f:
                for line in f:
                    line = line.replace("${jarName}", service_name)
                    line = line.replace("${tag}", tag)
                    line = line.replace("${port}", port)
                    outfile.writelines(line)

            outfile.close()
else:
    print("Mould File is Not Exist!")
```

后来发现替换这种方法有缺陷，最后使用的方法是通过编辑json来生成yaml。
