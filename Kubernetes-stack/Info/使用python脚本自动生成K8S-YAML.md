---
title: "使用python脚本自动生成K8S-YAML"
date: "2020-06-11"
categories:
    - "技术"
tags:
    - "python"
    - "Kubernetes"
    - "容器化"
    - "json"
    - "yaml"
toc: false
indent: false
original: true
---

## 1、生成 servie.yaml

### 1.1、yaml转json

service模板yaml

``` yaml
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
```

转成json的结构

``` json
{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "${jarName}",
    "labels": {
      "name": "${jarName}",
      "version": "v1"
    }
  },
  "spec": {
    "ports": [
      {
        "port": "${port}",
        "targetPort": "${port}"
      }
    ],
    "selector": {
      "name": "${jarName}"
    }
  }
}
```

### 1.2、关键代码

``` py
# 通过传入service_name及ports列表
def create_service_yaml(service_name, ports):

  # 将yaml读取为json，然后修改所有需要修改的${jarName}
  service_data['metadata']['name'] = service_name
  service_data['metadata']['labels']['name'] = service_name
  service_data['spec']['selector']['name'] = service_name

  # .spec.ports 比较特殊，是一个字典列表，由于传入的ports难以确定数量，难以直接修改
  # 新建一个列表，遍历传入的ports列表，将传入的每个port都生成为一个字典，添加入新列表中
  new_spec_ports = []
  for port in ports:
      port = int(port)
      new_port = {'port': port, 'targetPort': port}
      new_spec_ports.append(new_port)

  # 修改.spec.ports为新列表
  service_data['spec']['ports'] = new_spec_ports
```

## 2、生成 deployment.yaml

### 2.1、yaml转json

deployment模板yaml

``` yaml
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

转成的json结构

``` json
{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "${jarName}",
    "labels": {
      "name": "${jarName}"
    }
  },
  "spec": {
    "selector": {
      "matchLabels": {
        "name": "${jarName}"
      }
    },
    "replicas": 1,
    "template": {
      "metadata": {
        "labels": {
          "name": "${jarName}"
        }
      },
      "spec": {
        "containers": [
          {
            "name": "${jarName}",
            "image": "reg.test.local/library/${jarName}:${tag}"
          }
        ],
        "imagePullSecrets": [
          {
            "name": "registry-secret"
          }
        ]
      }
    }
  }
}
```

### 2.2、关键代码

``` py
# 传入service_name及image tag
def create_deploy_yaml(service_name, tag):

  # 首先修改所有的${jarName}
  deploy_data['metadata']['name'] = service_name
  deploy_data['metadata']['labels']['name'] = service_name
  deploy_data['spec']['selector']['matchLabels']['name'] = service_name
  deploy_data['spec']['template']['metadata']['labels']['name'] = service_name  

  # 由于.spec.template.spec.containers的特殊性，我们采用直接修改的方式
  # 首先拼接image字段
  image = "reg.test.local/library/" + service_name + ":" + tag
  # 创建new_containers字典列表
  new_containers = [{'name': service_name, 'image': image}]
  deploy_data['spec']['template']['spec']['containers'] = new_containers
```

## 3、完整脚本

``` py
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
from ruamel.yaml import YAML

yaml = YAML()

def create_service_yaml(service_name, ports):

    service_mould_file = "mould/info-service-mould.yaml"
    isServiceMould = os.path.isfile(service_mould_file)

    if isServiceMould:
        # read Service-mould yaml convert json
        with open(service_mould_file, encoding='utf-8') as yaml_obj:
            service_data = yaml.load(yaml_obj)

        # Update jarName
        service_data['metadata']['name'] = service_name
        service_data['metadata']['labels']['name'] = service_name
        service_data['spec']['selector']['name'] = service_name

        # Update port
        new_spec_ports = []
        for port in ports:
            port = int(port)
            portname = 'port' + str(port)
            new_port = {'name': portname, 'port': port, 'targetPort': port}
            new_spec_ports.append(new_port)
        service_data['spec']['ports'] = new_spec_ports

        # json To service yaml
        save_file = tag + '/' + service_name + '_svc.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(service_data, yaml_obj)

        print(save_file + ": Success!")
    else:
        print("Service Mould File is Not Exist!")


def create_deploy_yaml(service_name, tag):

    deploy_mould_file = "mould/info-deploy-mould.yaml"
    isDeployMould = os.path.isfile(deploy_mould_file)

    if isDeployMould:
        with open(deploy_mould_file, encoding='utf-8') as yaml_obj:
            deploy_data = yaml.load(yaml_obj)

        # Update jarName
        deploy_data['metadata']['name'] = service_name
        deploy_data['metadata']['labels']['name'] = service_name
        deploy_data['spec']['selector']['matchLabels']['name'] = service_name
        deploy_data['spec']['template']['metadata']['labels']['name'] = service_name  

        # Update containers
        image = "reg.test.local/library/" + service_name + ":" + tag
        new_containers = [{'name': service_name, 'image': image}]
        deploy_data['spec']['template']['spec']['containers'] = new_containers

        # json To service yaml
        save_file = tag + '/' + service_name + '_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(deploy_data, yaml_obj)

        print(save_file + ": Success!")
    else:
        print("Deploy Mould File is Not Exist!")


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

prompt = "\n请输入要生成的tag: "
answer = input(prompt)
print("")

if os.path.isdir(answer):
    raise SystemExit(answer + ': is Already exists!')
else:
    tag = answer
    os.makedirs(tag)
    for service_name, service_ports in services.items():
        create_service_yaml(service_name, service_ports)
        create_deploy_yaml(service_name, tag)
```

## 4、执行效果

``` zsh
➜  python3 Auto_Create_K8S_YAML.py

请输入要生成的tag: 0.0.1

0.0.1/info-gateway_svc.yaml: Success!
0.0.1/info-gateway_deploy.yaml: Success!
0.0.1/info-admin_svc.yaml: Success!
0.0.1/info-admin_deploy.yaml: Success!
0.0.1/info-config_svc.yaml: Success!
0.0.1/info-config_deploy.yaml: Success!
0.0.1/info-message-service_svc.yaml: Success!
0.0.1/info-message-service_deploy.yaml: Success!
0.0.1/info-auth-service_svc.yaml: Success!
0.0.1/info-auth-service_deploy.yaml: Success!
0.0.1/info-scheduler-service_svc.yaml: Success!
0.0.1/info-scheduler-service_deploy.yaml: Success!
0.0.1/info-uc-service_svc.yaml: Success!
0.0.1/info-uc-service_deploy.yaml: Success!
0.0.1/info-ad-service_svc.yaml: Success!
0.0.1/info-ad-service_deploy.yaml: Success!
0.0.1/info-community-service_svc.yaml: Success!
0.0.1/info-community-service_deploy.yaml: Success!
0.0.1/info-groupon-service_svc.yaml: Success!
0.0.1/info-groupon-service_deploy.yaml: Success!
0.0.1/info-hotel-service_svc.yaml: Success!
0.0.1/info-hotel-service_deploy.yaml: Success!
0.0.1/info-nearby-service_svc.yaml: Success!
0.0.1/info-nearby-service_deploy.yaml: Success!
0.0.1/info-news-service_svc.yaml: Success!
0.0.1/info-news-service_deploy.yaml: Success!
0.0.1/info-store-service_svc.yaml: Success!
0.0.1/info-store-service_deploy.yaml: Success!
0.0.1/info-payment-service_svc.yaml: Success!
0.0.1/info-payment-service_deploy.yaml: Success!
0.0.1/info-agent-service_svc.yaml: Success!
0.0.1/info-agent-service_deploy.yaml: Success!
0.0.1/info-consumer-service_svc.yaml: Success!
0.0.1/info-consumer-service_deploy.yaml: Success!

➜  ll
total 12
drwxr-xr-x. 2 root root 4096 Jun 29 18:24 0.0.1

# 生成的 service yaml
➜  cat info-message-service_svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: info-message-service
  labels:
    name: info-message-service
    version: v1
spec:
  ports:
  - name: port8555
    port: 8555
    targetPort: 8555
  - name: port9666
    port: 9666
    targetPort: 9666
  selector:
    name: info-message-service

# 生成的 deployment yaml
➜  cat info-message-service_deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: info-message-service
  labels:
    name: info-message-service
spec:
  selector:
    matchLabels:
      name: info-message-service
  replicas: 2
  template:
    metadata:
      labels:
        name: info-message-service
    spec:
      containers:
      - name: info-message-service
        image: reg.test.local/library/info-message-service:0.0.1
      imagePullSecrets:
      - name: registry-secret
```
