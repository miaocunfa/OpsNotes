#!/usr/bin/python
# encoding: utf-8
"""
Created by PyCharm.
File:               OpsNotes:uat-docker-para.py
User:               miaocunfa
Create Date:        2021-03-02
Create Time:        16:46
Update Date:        2021-03-08
Update Time:        11:10
Version:            v0.1.3
"""

import yaml
import sys
import getopt

service_info = yaml.safe_load('''
  coupon:
    name: V_Test_Coupon
    target: /target/uat-coupon
    ports:
    - name:
        HostPort: 4488
        ContainerPort: 8896
  admin:
    ports:
    - name:
        HostPort: 8071
        ContainerPort: 8070
  bidding:
    name: V_Test_Bidding
    target: /target/uat-bidding
    ports:
    - name:
        HostPort: 8958
        ContainerPort: 9588
  business:
    ports:
    - name:
        HostPort: 8051
        ContainerPort: 8050
  communication:
    ports:
    - name:
        HostPort: 16969
        ContainerPort: 16969
  craftsman:
    ports:
    - name:
        HostPort: 8041
        ContainerPort: 8040
  eureka:
    ports:
    - name:
        HostPort: 8080
        ContainerPort: 8080
  integral:
    ports:
    - name:
        HostPort: 4468
        ContainerPort: 4468
  machine:
    ports:
    - name:
        HostPort: 8031
        ContainerPort: 8030
  order:
    ports:
    - name:
        HostPort: 4422
        ContainerPort: 4421
  project:
    ports:
    - name:
        HostPort: 8021
        ContainerPort: 8020
  school:
    ports:
    - name:
        HostPort: 9002
        ContainerPort: 9001
  telephone:
    ports:
    - name:
        HostPort: 8888
        ContainerPort: 8888
    - name:
        HostPort: 9002
        ContainerPort: 9002
  tracking:
    ports:
    - name:
        HostPort: 9599
        ContainerPort: 9598
  user:
    ports:
    - name:
        HostPort: 4412
        ContainerPort: 4411
  zuuls:
    ports:
    - name:
        HostPort: 4413
        ContainerPort: 4413
  cleaning:
    ports:
    - name:
        HostPort: 7088
        ContainerPort: 8082
  job:
    ports:
    - name:
        HostPort: 4416
        ContainerPort: 4416
  processing:
    ports:
    - name:
        HostPort: 7089
        ContainerPort: 8081
  three:
    ports:
    - name:
        HostPort: 89
        ContainerPort: 80
  account:
    ports:
    - name:
        HostPort: 4889
        ContainerPort: 8888
  management:
    ports:
    - name:
        HostPort: 4460
        ContainerPort: 4460
  square:
    ports:
    - name:
        HostPort: 8059
        ContainerPort: 8050
  transaction:
    ports:
    - name:
        HostPort: 4888
        ContainerPort: 8888
''')


def main(argv):
    service = ""

    try:
        opts, args = getopt.getopt(argv, "hpt", ["help", "port", "target"])
    except getopt.GetoptError:
        printUsage()
        sys.exit(2)

    # 先判断service是否存在
    if args:
        # 校验 service 合法性
        service = args[0]
        if service in service_info.keys():
            pass
        else:
            print("service: " + service + " 不存在, 请检查!")
            sys.exit()
    else:
        printUsage()
        sys.exit()

    # 处理选项
    print(opts)
    for opt, arg in opts:
        if opt in ("-n", "--name"):
            getContainerName(service)
        elif opt in ("-p", "--port"):
            getContainerPort(service)
        elif opt in ("-t", "--target"):
            getServiceTarget(service)
        elif opt in ("-h", "--help"):
            printUsage()
            sys.exit()


def getContainerName(service):
    if service_info[service]['name']:
        return service_info[service]['name']
    else:
        return ''


def getContainerPort(service):
    if service_info[service]['ports']:
        return service_info[service]['ports']
    else:
        return ''


def getServiceTarget(service):
    if service_info[service]['target']:
        return service_info[service]['target']
    else:
        return ''


def printUsage():
    print()
    print('Usage: uat-docker-para.py [options] Service')
    print()
    print('Options:')
    print('  -n, --name     return container name')
    print('  -p, --port     return container expose port')
    print('  -t, --target   return image build PATH')
    print('  -h, --help     return Usage')
    print()


if __name__ == "__main__":
    # sys.argv[1:]为要处理的参数列表，sys.argv[0]为脚本名，所以用sys.argv[1:]过滤掉脚本名。
    main(sys.argv[1:])
