#!/usr/bin/python
# encoding: utf-8
"""
Created by PyCharm.
File:               OpsNotes:uat-docker-para.py
User:               miaocunfa
Create Date:        2021-03-02
Create Time:        16:46
Update Date:        2021-03-10
Update Time:        15:42
Version:            v0.1.7
"""

import yaml
import json
import sys
import getopt

service_yaml = yaml.safe_load('''
coupon:
    name: V_Test_Coupon
    target: /target/uat-coupon
    host: docker-2
    ports:
      - name: port1
        HostPort: 4488
        ContainerPort: 8896
admin:
    name: V_Test_Admin
    target: /target/uat-admin
    host: docker-3
    ports:
      - name: port1
        HostPort: 8071
        ContainerPort: 8082
bidding:
    name: V_Test_Bidding-0310
    target: /target/uat-bidding
    host: docker-2
    ports:
      - name: port1
        HostPort: 8959
        ContainerPort: 9588
business:
    name: V_Test_Business
    target: /target/uat-business
    host: docker-node04
    ports:
      - name: port1
        HostPort: 8051
        ContainerPort: 8050
communication:
    name: V_Test_Gps_Communication
    target: /target/uat-communication/
    host: docker-2
    ports:
      - name: port1
        HostPort: 16969
        ContainerPort: 16969
      - name: port2
        HostPort: 80
        ContainerPort: 80
craftsman:
    name: V_Test_Craftsman
    target: /target/uat-coupon
    host: docker-2
    ports:
      - name: port1
        HostPort: 8041
        ContainerPort: 8040
eureka:
    name: V_Test_Eureka
    target: /target/uat-eureka
    host: docker-3
    ports:
      - name: port1
        HostPort: 8089
        ContainerPort: 8089
integral:
    name: V_Test_coin
    target: /target/uat-integral
    host: docker-2
    ports:
      - name: port1
        HostPort: 4468
        ContainerPort: 4468
machine:
    name: V_Test_Machine
    target: /target/uat-machine
    host: docker-2
    ports:
      - name: port1
        HostPort: 8031
        ContainerPort: 8030
order:
    name: V_Test_Order
    target: /target/uat-order
    host: docker-node04
    ports:
      - name: port1
        HostPort: 4422
        ContainerPort: 4421
project:
    name: V_Test_Project
    target: /target/uat-project
    host: docker-node04
    ports:
      - name: port1
        HostPort: 8021
        ContainerPort: 8020
school:
    name: V_Test_School
    target: /target/uat-school
    host: docker-node04
    ports:
      - name: port1
        HostPort: 9002
        ContainerPort: 9001
telephone:
    name: V_Test_telephone
    target: /target/uat-telephone
    host: docker-2
    ports:
      - name: port1
        HostPort: 8888
        ContainerPort: 8888
      - name: port2
        HostPort: 9002
        ContainerPort: 9002
tracking:
    name: V_Test_Tracking
    target: /target/uat-tracking
    host: docker-2
    ports:
      - name: port1
        HostPort: 9599
        ContainerPort: 9598
user:
    name: V_Test_User
    target: /target/uat-user
    host: docker-2
    ports:
      - name: port1
        HostPort: 4412
        ContainerPort: 4411
zuuls:
    name: V_Test_Zuuls
    target: /target/uat-zuuls
    host: docker-2
    ports:
      - name: port1
        HostPort: 4413
        ContainerPort: 4413
cleaning:
    name: V_Test_Gps_Cleaning
    target: /target/uat-cleaning
    host: docker-3
    ports:
      - name: port1
        HostPort: 7088
        ContainerPort: 8082
processing:
    name: V_Test_Gps_Processing
    target: /target/uat-processing
    host: docker-3
    ports:
      - name: port1
        HostPort: 7089
        ContainerPort: 8081
job:
    name: V_Test_job
    target: /target/uat-job
    host: docker-node04
    ports:
      - name: port1
        HostPort: 4416
        ContainerPort: 4416
three:
    name: V_Test_ThreeParty
    target: /target/uat-threeparty
    host: docker-3
    ports:
      - name: port1
        HostPort: 89
        ContainerPort: 80
account:
    name: V_Uat_Account
    target: /target/uat-account
    host: docker-node04
    ports:
      - name: port1
        HostPort: 4889
        ContainerPort: 8888
management:
    name: V_Test_Management
    target: /target/uat-management
    host: docker-node04
    ports:
      - name: port1
        HostPort: 4460
        ContainerPort: 4460
square:
    name: V_Test_Square
    target: /target/uat-square
    host: docker-node04
    ports:
      - name: port1
        HostPort: 8059
        ContainerPort: 8050
transaction:
    name: V_Uat_Transaction
    target: /target/uat-transaction
    host: docker-node04
    ports:
      - name: port1
        HostPort: 4888
        ContainerPort: 8888
''')


def main(argv):
    service = ""

    try:
        opts, args = getopt.getopt(argv, "hnptH", ["help", "name", "port", "target", "host"])
    except getopt.GetoptError:
        printUsage()
        sys.exit(2)

    # 先判断 service 是否存在
    if args:
        # 校验 service 合法
        service = args[0]
        if service not in service_yaml.keys():
            print("service_info: " + service + " 不存在, 请检查!")
            sys.exit()
    else:
        printUsage()
        sys.exit()

    # 处理选项
    for opt, arg in opts:
        if opt in ("-n", "--name"):
            getContainerName(service)
        elif opt in ("-p", "--port"):
            getContainerPort(service)
        elif opt in ("-t", "--target"):
            getServiceTarget(service)
        elif opt in ("-H", "--host"):
            getContainerHost(service)
        elif opt in ("-h", "--help"):
            printUsage()
            sys.exit()


def getContainerName(service):
    if 'name' in service_yaml[service]:
        print(service_yaml[service]['name'])
    else:
        print('null')


def getContainerPort(service):
    if 'ports' in service_yaml[service]:
        print(json.dumps(service_yaml[service]['ports']))
    else:
        print('null')


def getServiceTarget(service):
    if 'target' in service_yaml[service]:
        print(service_yaml[service]['target'])
    else:
        print('null')


def getContainerHost(service):
    if 'host' in service_yaml[service]:
        print(service_yaml[service]['host'])
    else:
        print('null')


def printUsage():
    print()
    print('Usage: uat-docker-para.py [options] Service')
    print()
    print('Options:')
    print('  -n, --name     return container name')
    print('  -H, --host     return container host')
    print('  -p, --port     return container expose port')
    print('  -t, --target   return image build PATH')
    print('  -h, --help     return Usage')
    print()


if __name__ == "__main__":
    # sys.argv[1:]为要处理的参数列表，sys.argv[0]为脚本名，所以用sys.argv[1:]过滤掉脚本名。
    main(sys.argv[1:])
