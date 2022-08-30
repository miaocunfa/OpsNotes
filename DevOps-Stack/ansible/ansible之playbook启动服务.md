---
title: "ansible之playbook启动服务"
date: "2020-10-09"
categories:
    - "技术"
tags:
    - "ansible"
    - "playbook"
toc: false
indent: false
original: true
draft: true
---

## 一、seata

### 1.1、start seata

``` yml
vim /root/ansible/playbook/start_seata.yml
- hosts: 192.168.100.223
  remote_user: root
  gather_facts: no
  tasks:
    - name: start seata@3
      shell: systemctl start seata@3

- hosts: 192.168.100.222
  remote_user: root
  gather_facts: no
  tasks:
    - name: start seata@2
      shell: systemctl start seata@2

- hosts: 192.168.100.225
  remote_user: root
  gather_facts: no
  tasks:
    - name: start seata@5
      shell: systemctl start seata@5
```

### 1.2、stop seata

``` yml
vim /root/ansible/playbook/stop_seata.yml
- hosts: 192.168.100.223
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop seata@3
      shell: systemctl stop seata@3

- hosts: 192.168.100.222
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop seata@2
      shell: systemctl stop seata@2

- hosts: 192.168.100.225
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop seata@5
      shell: systemctl stop seata@5
```

## 二、es

### 2.1、es start

``` yml
vim /root/ansible/playbook/start_es_211-213.yml
- hosts: 192.168.100.211
  remote_user: elasticsearch
  gather_facts: no
  tasks:
    - name: start es - 211
      shell: /opt/elasticsearch-7.1.1/bin/elasticsearch -d

- hosts: 192.168.100.212
  remote_user: elasticsearch
  gather_facts: no
  tasks:
    - name: start es - 212
      shell: /opt/elasticsearch-7.1.1/bin/elasticsearch -d

- hosts: 192.168.100.213
  remote_user: elasticsearch
  gather_facts: no
  tasks:
    - name: start es - 213
      shell: /opt/elasticsearch-7.1.1/bin/elasticsearch -d
```

### 2.2、es stop

``` yml
vim /root/ansible/playbook/stop_es_211-213.yml
- hosts: 192.168.100.211
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop es - 211
      shell: ps -ef | grep elasticsearch-7.1.1 | grep -v grep | awk '{print $2}' | xargs kill

- hosts: 192.168.100.212
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop es - 212
      shell: ps -ef | grep elasticsearch-7.1.1 | grep -v grep | awk '{print $2}' | xargs kill

- hosts: 192.168.100.213
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop es - 213
      shell: ps -ef | grep elasticsearch-7.1.1 | grep -v grep | awk '{print $2}' | xargs kill
```

## 三、mongo

### 3.1、mongo start

``` yml
vim /root/ansible/playbook/start_mongo_226-228.yml
- hosts: 192.168.100.226
  remote_user: root
  gather_facts: no
  tasks:
    - name: start mongo - 226
      shell: cd /opt/mongodb-linux-x86_64-rhel70-4.2.2/; bin/mongod -f conf/config.yaml; bin/mongod -f conf/shard1.yaml; bin/mongod -f conf/shard2.yaml; bin/mongos -f conf/mongos.yaml


- hosts: 192.168.100.227
  remote_user: root
  gather_facts: no
  tasks:
    - name: start mongo - 227
      shell: cd /opt/mongodb-linux-x86_64-rhel70-4.2.2/; bin/mongod -f conf/config.yaml; bin/mongod -f conf/shard1.yaml; bin/mongod -f conf/shard2.yaml; bin/mongos -f conf/mongos.yaml

- hosts: 192.168.100.228
  remote_user: root
  gather_facts: no
  tasks:
    - name: start mongo - 228
      shell: cd /opt/mongodb-linux-x86_64-rhel70-4.2.2/; bin/mongod -f conf/config.yaml; bin/mongod -f conf/shard1.yaml; bin/mongod -f conf/shard2.yaml; bin/mongos -f conf/mongos.yaml
```

### 3.2、mongo stop

``` yml
vim /root/ansible/playbook/stop_mongo_226-228.yml
- hosts: 192.168.100.226
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop mongo - 226
      shell: ps -ef | grep mongo | grep -v grep | awk '{print $2}' | xargs kill

- hosts: 192.168.100.227
  remote_user: root
  gather_facts: no
  tasks:
    - name: stop mongo - 227
      shell: ps -ef | grep mongo | grep -v grep | awk '{print $2}' | xargs kill

- hosts: 192.168.100.228
  remote_user: root
  gather_facts: no
  tasks: 
    - name: stop mongo - 228
      shell: ps -ef | grep mongo | grep -v grep | awk '{print $2}' | xargs kill
```

> 参考文档：
> 1、[Ansible-playbook 部署 ElasticSearch 集群](http://msyblog.lemonit.cn/2019/10/17/ansible-playbook-%E9%83%A8%E7%BD%B2-elasticsearch-%E9%9B%86%E7%BE%A4/)
>