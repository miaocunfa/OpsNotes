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
---

## seata

### start seata

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

### stop seata

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

## es

### es start

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

### es stop

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
