#!/usr/bin/python
# encoding: utf-8

"""
The Script for Auto Create Kubernetes Yaml With jinja2

File:               templating-k8s-with-jinja2
User:               miaocunfa
Create Date:        2020-07-03
Create Time:        11:06
"""

import os
import jinja2

def create_service_yaml(service_name, service, tag):

    # 传入 jinja2 模板的变量赋值
    ports = service['ports']
    jarName = service_name

    # 判断模板文件是否存在
    service_mould_file = "jinja2/info-service-mould.yaml"
    isServiceMould = os.path.isfile(service_mould_file)

    if isServiceMould:

        # 模板渲染
        path, filename = os.path.split(service_mould_file)
        template = jinja2.Environment(loader=jinja2.FileSystemLoader(path or './')).get_template(filename)
        result = template.render(**locals())

        # 将结果写入到yaml 
        save_file = tag + '/' + service_name + '_svc.yaml'
        with open(save_file, mode='w', encoding='utf-8') as f:
            f.write(result)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("Service Mould File is Not Exist!")


def create_deploy_yaml(service_name, service, tag):

    # 传入 jinja2 模板的变量赋值
    cpuRequest = "50m"
    memoryRequest = "100Mi"
    cpuLimit = "500m"
    memoryLimit = "1000Mi"
    jarName = service_name
    replicas = int(service['replicas'])

    # 判断模板文件是否存在
    deploy_mould_file = "jinja2/info-deploy-mould.yaml"
    isDeployMould = os.path.isfile(deploy_mould_file)

    if isDeployMould:

        # 模板渲染
        path, filename = os.path.split(deploy_mould_file)
        template = jinja2.Environment(loader=jinja2.FileSystemLoader(path or './')).get_template(filename)
        result = template.render(**locals())

        # 将结果写入到yaml 
        save_file = tag + '/' + service_name + '_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as f:
            f.write(result)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("Deploy Mould File is Not Exist!")


def create_basic_yaml(service_name, service, tag):

    # 传入 jinja2 模板的变量赋值
    cpuRequest = "50m"
    memoryRequest = "100Mi"
    cpuLimit = "500m"
    memoryLimit = "1000Mi"
    jarName = service_name
    replicas = int(service['replicas'])

    # 判断模板文件是否存在
    basic_mould_file = "jinja2/info-basic-mould.yaml"
    isbasicMould = os.path.isfile(basic_mould_file)

    if isbasicMould:

        # 模板渲染
        path, filename = os.path.split(basic_mould_file)
        template = jinja2.Environment(loader=jinja2.FileSystemLoader(path or './')).get_template(filename)
        result = template.render(**locals())

        # 将结果写入到yaml 
        save_file = tag + '/basic/' + service_name + '_deploy.yaml'
        with open(save_file, mode='w', encoding='utf-8') as f:
            f.write(result)

        # 打印消息
        print(save_file + ": Success!")
    else:
        print("basic Mould File is Not Exist!")


# 服务信息
services = {
	'info-gateway': {
		'ports': [{
			'portName': 'info-gateway',
			'port': '9999'
		}],
		'isBasic': '1',
		'replicas': '2',
	},
	'info-admin': {
		'ports': [{
			'portName': 'info-admin',
			'port': '7777'
		}],
		'isBasic': '1',
		'replicas': '1',
	},
	'info-config': {
		'ports': [{
			'portName': 'info-admin',
			'port': '8888'
		}],
		'isBasic': '1',
		'replicas': '1',
	},
	'info-message-service': {
		'ports': [{
			'portName': 'message-web',
			'port': '8555'
		}, {
			'portName': 'message-socket',
			'port': '9666'
		}],
		'isBasic': '0',
		'replicas': '1',
	},
	'info-auth-service': {
		'ports': [{
			'portName': 'info-auth-service',
			'port': '8666'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-scheduler-service': {
		'ports': [{
			'portName': 'info-scheduler-service',
			'port': '8777'
		}],
		'isBasic': '0',
		'replicas': '1',
	},
	'info-uc-service': {
		'ports': [{
			'portName': 'info-uc-service',
			'port': '8800'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-ad-service': {
		'ports': [{
			'portName': 'info-ad-service',
			'port': '8801'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-community-service': {
		'ports': [{
			'portName': 'info-community-service',
			'port': '8802'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-groupon-service': {
		'ports': [{
			'portName': 'info-groupon-service',
			'port': '8803'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-hotel-service': {
		'ports': [{
			'portName': 'info-hotel-service',
			'port': '8804'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-nearby-service': {
		'ports': [{
			'portName': 'info-nearby-service',
			'port': '8805'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-news-service': {
		'ports': [{
			'portName': 'info-news-service',
			'port': '8806'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-store-service': {
		'ports': [{
			'portName': 'info-store-service',
			'port': '8807'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-payment-service': {
		'ports': [{
			'portName': 'info-payment-service',
			'port': '8808'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-agent-service': {
		'ports': [{
			'portName': 'info-agent-service',
			'port': '8809'
		}],
		'isBasic': '0',
		'replicas': '2',
	},
	'info-consumer-service': {
		'ports': [{
			'portName': 'info-consumer-service',
			'port': '8090'
		}],
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
            create_service_yaml(service_name, services[service_name], tag)
            create_basic_yaml(service_name, services[service_name], tag)
        else:
            create_service_yaml(service_name, services[service_name], tag)
            create_deploy_yaml(service_name, services[service_name], tag) 

# tag = '0.0.2'
# create_deploy_yaml('info-message-service', services['info-message-service'], tag)
# create_service_yaml('info-message-service', services['info-message-service'], tag)
# create_basic_yaml('info-gateway', services['info-gateway'], tag)