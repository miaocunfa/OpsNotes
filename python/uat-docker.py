#!/usr/bin/python
# encoding: utf-8
"""
Created by VS Code.
File:               OpsNotes:uat-docker.py
User:               miaocunfa
Create Date:        2021-03-02
Create Time:        16:46
Update Date:        2021-03-02
Update Time:        17:40
"""

import os
import sys
import json
import time

"""
service: 
  coupon: 
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
    ports:
    - name: 
        HostPort: 8958
        ContainerPort: 9588
  business:
    ports:
    - name: 
        HostPort: 8051
        ContainerPort: 8050
  communication
    ports:
    - name: 
        HostPort: 16969
        ContainerPort: 16969
  craftsman
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
"""
