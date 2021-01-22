---
title: "运维自动化神器 Ansible之安装(一)"
date: "2019-11-09"
categories:
    - "技术"
tags:
    - "ansible"
    - "自动化运维"
    - "DevOps"
toc: false
original: true
draft: false
---

## 一、安装部署
``` bash
yum install ansible
```

### 通过rpm -ql命令我们可以看到 ansible 有很多的子命令以及他们的安装位置。
``` bash
[root@master01 ~]# rpm -ql ansible | grep bin
/usr/bin/ansible
/usr/bin/ansible-2
/usr/bin/ansible-2.7
/usr/bin/ansible-config
/usr/bin/ansible-connection
/usr/bin/ansible-console
/usr/bin/ansible-console-2
/usr/bin/ansible-console-2.7
/usr/bin/ansible-doc
/usr/bin/ansible-doc-2
/usr/bin/ansible-doc-2.7
/usr/bin/ansible-galaxy
/usr/bin/ansible-galaxy-2
/usr/bin/ansible-galaxy-2.7
/usr/bin/ansible-inventory
/usr/bin/ansible-playbook
/usr/bin/ansible-playbook-2
/usr/bin/ansible-playbook-2.7
/usr/bin/ansible-pull
/usr/bin/ansible-pull-2
/usr/bin/ansible-pull-2.7
/usr/bin/ansible-vault
/usr/bin/ansible-vault-2
/usr/bin/ansible-vault-2.7
```

## 二、配置文件
ansible配置文件默认安装在/etc/ansible下
``` bash
[root@master01 ansible]# pwd
/etc/ansible
[root@master01 ansible]# ll
total 28
-rw-r--r-- 1 root root 19980 Sep 14 04:00 ansible.cfg
-rw-r--r-- 1 root root  1016 Sep 14 04:00 hosts
drwxr-xr-x 2 root root  4096 Sep 14 04:00 roles
```

### 2.1、hosts配置文件解析
hosts文件是我们使用ansible操作的主机模板文件。
``` config
# 可以如以下模块这样配置域名或者主机IP地址
green.example.com
blue.example.com
192.168.100.1
192.168.100.10

# 也可以设置分组, 使用ansible的时候指定操作的组。
[webservers]
alpha.example.org
beta.example.org
192.168.1.100
192.168.1.110

# 如果多个主机遵循一个命名规则，也可以如下配置。
www[001:006].example.com
```

### 2.2、配置ansible.cfg文件
因为我们不配置ssh免密验证，所以要修改一下ansible.cfg文件。
``` bash
[root@master01 ansible]# vi /etc/ansible/ansible.cfg
host_key_checking = False
```

### 2.3、配置hosts文件
如果主机间还没有配置ssh免密验证，需要在配置文件中配置用户名、密码。
```
[master]
172.31.194.114 ansible_ssh_user='root' ansible_ssh_pass='miao123!'
172.31.194.115 ansible_ssh_user='root' ansible_ssh_pass='miao123!'
172.31.194.116 ansible_ssh_user='root' ansible_ssh_pass='miao123!'

[node]
172.31.194.117 ansible_ssh_user='root' ansible_ssh_pass='miao123!'
```

## 三、ansible使用语法
这里只列出一些重要的ansible语法及参数。
``` bash
[root@master01 ansible]# ansible --help
Usage: ansible <host-pattern> [options]      # 我们可以看到ansible命令后需要指定主机模板文件，默认hosts文件不需要指定。

Options:
  -C, --check                                # 使用 -C 或 --check 来干跑一遍不执行任何修改（检查语法错误及查看目标达成状态）  
  -f FORKS, --forks=FORKS                    # 指定一次运行几台主机的任务，默认是5
  -m MODULE_NAME, --module-name=MODULE_NAME  # 执行的模块名称 
  -a MODULE_ARGS, --args=MODULE_ARGS         # 使用 -a 或 -args 来指定模块参数
  -h, --help                                 # 获得帮助
  --list-hosts                               # 列出有哪些主机执行操作                  
```

## 四、连通性调试
### 4.1、先通过--list-host查看hosts文件配置是否有误。
``` bash
# 列出所有主机
[root@master01 ansible]# ansible all --list-host
  hosts (4):
    172.31.194.117
    172.31.194.114
    172.31.194.115
    172.31.194.116

# 列出所有master主机
[root@master01 ansible]# ansible master --list-host
  hosts (3):
    172.31.194.114
    172.31.194.115
    172.31.194.116

# 列出所有node主机
[root@master01 ansible]# ansible node --list-host
  hosts (1):
    172.31.194.117
```

### 4.2、ping模块测试主机连通性

使用 ping 模块时，不用再指定-a参数了。
``` bash
# 使用 ping 模块测试所有主机的连通性
[root@master01 ansible]# ansible all -m ping
/usr/lib/python2.7/site-packages/requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.25.3) or chardet (2.2.1) doesn't match a supported version!
  RequestsDependencyWarning)
172.31.194.114 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"     # 我们看到这一行 ping 返回 pong 说明主机可以连接了。
}
172.31.194.116 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
172.31.194.117 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
172.31.194.115 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```
