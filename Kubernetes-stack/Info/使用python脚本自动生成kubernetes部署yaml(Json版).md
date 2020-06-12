---
title: "使用python脚本自动生成kubernetes部署yaml(Json版)"
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

## 1、生成servie.yaml

### 1.1、yaml转json

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

## 2、生成deployment.yaml

### 2.1、yaml转json

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

File:               json_convert_yaml
User:               miaocunfa
Create Date:        2020-06-11
Create Time:        10:30
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
            new_port = {'port': port, 'targetPort': port}
            new_spec_ports.append(new_port)
        service_data['spec']['ports'] = new_spec_ports

        # json To service yaml
        save_file = 'auto-json/' + service_name + '_svc.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(service_data, yaml_obj)
    else:
        print("Service Mould File is Not Exist!")


def create_deploy_yaml(service_name, tag):

    deploy_mould_file = "mould/info-deploy-mould.yaml"
    isDeployMould = os.path.isfile(deploy_mould_file)

    if isDeployMould:

        # read deploy-mould yaml convert json
        with open(deploy_mould_file, encoding='utf-8') as yaml_obj:
            deploy_data = yaml.load(yaml_obj)  # ä¸ºJSON

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
        save_file = 'auto-json/' + service_name + '_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(deploy_data, yaml_obj)
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

tag = "0.0.1-SNAPSHOT"

# Test Function
# create_service_yaml('info-message-service', ['8555', '9666'])
# create_deploy_yaml('info-message-service', tag)

for service_name, service_ports in services.items():
    create_service_yaml(service_name, service_ports)
    create_deploy_yaml(service_name, tag)
```
