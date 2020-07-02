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

def create_service_yaml(service_name, service):

    # 变量赋值 
    ports = service['ports']

    service_mould_file = "mould/info-service-mould.yaml"
    isServiceMould = os.path.isfile(service_mould_file)

    if isServiceMould:
        # 读取yaml模板
        with open(service_mould_file, encoding='utf-8') as yaml_obj:
            service_data = yaml.load(yaml_obj)

        # 修改服务名部分
        service_data['metadata']['name'] = service_name
        service_data['metadata']['labels']['serviceName'] = service_name
        service_data['metadata']['labels']['tag'] = tag
        service_data['spec']['selector']['serviceName'] = service_name

        # 生成.spec.ports
        new_spec_ports = []
        for port in ports:
            port = int(port)
            portname = 'port' + str(port)
            new_port = {'name': portname, 'port': port, 'targetPort': port}
            new_spec_ports.append(new_port)
        service_data['spec']['ports'] = new_spec_ports

        # 将json写入yaml
        save_file = tag + '/' + service_name + '_svc.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(service_data, yaml_obj)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("Service Mould File is Not Exist!")


def create_deploy_yaml(service_name, service):

    # 变量赋值
    cpuRequest = "50m"
    memoryRequest = "100Mi"
    cpuLimit = "500m"
    memoryLimit = "1000Mi"

    replicas = int(service['replicas'])

    deploy_mould_file = "mould/info-deploy-mould.yaml"
    isDeployMould = os.path.isfile(deploy_mould_file)

    if isDeployMould:
        # 读取yaml模板
        with open(deploy_mould_file, encoding='utf-8') as yaml_obj:
            deploy_data = yaml.load(yaml_obj)

        # 修改服务名部分
        deploy_data['metadata']['name'] = service_name
        deploy_data['metadata']['labels']['serviceName'] = service_name
        deploy_data['spec']['selector']['matchLabels']['serviceName'] = service_name
        deploy_data['spec']['template']['metadata']['labels']['serviceName'] = service_name

        # 修改副本数
        deploy_data['spec']['replicas'] = replicas

        # 修改容器部分
        image = "reg.test.local/library/" + service_name + ":" + tag
        #resources = { "requests": {"cpu": cpuRequest, "memory": memoryRequest }, "limits": {"cpu": cpuLimit, "memory": memoryLimit } }
        resources = { "requests": {"memory": memoryRequest }, "limits": {"memory": memoryLimit } }
        new_containers = [{'name': service_name, 'image': image, 'resources': resources}]
        deploy_data['spec']['template']['spec']['containers'] = new_containers

        # 修改亲和性
        matchExpressions = [{'key': 'serviceName', 'operator': 'In', 'values': [service_name]}]
        deploy_data['spec']['template']['spec']['affinity']['podAntiAffinity']['preferredDuringSchedulingIgnoredDuringExecution'][0]['podAffinityTerm']['labelSelector']['matchExpressions'] = matchExpressions

        # 将json写入yaml
        save_file = tag + '/' + service_name + '_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(deploy_data, yaml_obj)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("Deploy Mould File is Not Exist!")


def create_basic_yaml(service_name, service):

    # 变量赋值
    cpuRequest = "50m"
    memoryRequest = "100Mi"
    cpuLimit = "500m"
    memoryLimit = "1000Mi"

    replicas = int(service['replicas'])

    basic_mould_file = "mould/info-basic-mould.yaml"
    isbasicMould = os.path.isfile(basic_mould_file)

    if isbasicMould:

        # 读取模板yaml
        with open(basic_mould_file, encoding='utf-8') as yaml_obj:
            basic_data = yaml.load(yaml_obj)

        # 修改服务名部分
        basic_data['metadata']['name'] = service_name
        basic_data['metadata']['labels']['serviceName'] = service_name
        basic_data['spec']['selector']['matchLabels']['serviceName'] = service_name
        basic_data['spec']['template']['metadata']['labels']['serviceName'] = service_name

        # 修改副本数
        basic_data['spec']['replicas'] = replicas

        # 修改容器部分
        image = "reg.test.local/library/" + service_name + ":" + tag
        #resources = { "requests": {"cpu": cpuRequest, "memory": memoryRequest }, "limits": {"cpu": cpuLimit, "memory": memoryLimit } }
        resources = { "requests": {"memory": memoryRequest }, "limits": {"memory": memoryLimit } }
        new_containers = [{'name': service_name, 'image': image, 'resources': resources}]
        basic_data['spec']['template']['spec']['containers'] = new_containers

        # 修改亲和性
        matchExpressions = [{'key': 'serviceName', 'operator': 'In', 'values': [service_name]}]
        basic_data['spec']['template']['spec']['affinity']['podAntiAffinity']['preferredDuringSchedulingIgnoredDuringExecution'][0]['podAffinityTerm']['labelSelector']['matchExpressions'] = matchExpressions

        # 将json写入yaml
        save_file = tag + '/basic/' + service_name + '_basic_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as yaml_obj:
            yaml.dump(basic_data, yaml_obj)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("basic Mould File is Not Exist!")


# 服务信息
services = {
	'info-gateway': {
		'ports': ['9999'],
		'isBasic': '1',
        'replicas': '2',
	},
	'info-admin': {
		'ports': ['7777'],
		'isBasic': '1',
        'replicas': '1',
	},
	'info-config': {
		'ports': ['8888'],
		'isBasic': '1',
        'replicas': '1',
	},
	'info-message-service': {
		'ports': ['8555', '9666'],
		'isBasic': '0',
        'replicas': '1',
	},
	'info-auth-service': {
		'ports': ['8666'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-scheduler-service': {
		'ports': ['8777'],
		'isBasic': '0',
        'replicas': '1',
	},
	'info-uc-service': {
		'ports': ['8800'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-ad-service': {
		'ports': ['8801'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-community-service': {
		'ports': ['8802'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-groupon-service': {
		'ports': ['8803'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-hotel-service': {
		'ports': ['8804'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-nearby-service': {
		'ports': ['8805'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-news-service': {
		'ports': ['8806'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-store-service': {
		'ports': ['8807'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-payment-service': {
		'ports': ['8808'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-agent-service': {
		'ports': ['8809'],
		'isBasic': '0',
        'replicas': '2',
	},
	'info-consumer-service': {
		'ports': ['8090'],
		'isBasic': '0',
        'replicas': '1',
	},
}

prompt = "\n请输入要生成的tag: "
answer = input(prompt)
print("")

if os.path.isdir(answer):
    raise SystemExit(answer + ': is Already exists!')
else:
    tag = answer
    os.makedirs(tag)
    os.makedirs(tag + '/basic')
    for service_name in services.keys():
        if services[service_name]['isBasic'] == '1':
            create_service_yaml(service_name, services[service_name])
            create_basic_yaml(service_name, services[service_name])
        else:
            create_service_yaml(service_name, services[service_name])
            create_deploy_yaml(service_name, services[service_name]) 

#tag = '0.0.2'
#create_deploy_yaml('info-message-service', services['info-message-service'])
#create_service_yaml('info-message-service', services['info-message-service'])
#create_basic_yaml('info-gateway', services['info-gateway'])