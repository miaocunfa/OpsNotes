---
title: "如何利用python编写类shell脚本"
date: "2020-05-04"
categories:
    - "技术"
tags:
    - "运维"
    - "shell"
    - "python"
toc: false
original: true
---

## 一、os模块
使用os中的函数, 需要先导入os模块, 否则会报命名错误`NameError: name 'os' is not defined`
``` python
>>> import os
```

### 1.1、ls命令
使用os.listdir(dirname)可以列出目录下的文件列表, 若不传入目录参数则列出的目录为进入python命令解释行时的目录  
``` python
# 列出/opt下的文件列表
[root@MQ2 ~]# cd /opt
[root@MQ2 /opt]# python3
>>> import os
>>> os.listdir()
['rh', 'zbox', 'node_exporter-0.18.1.linux-amd64.tar.gz', 'node_exporter-0.18.1.linux-amd64', 'history_format.conf', 'aihangxunxi', 'containerd', 'rabbitmq_server-3.8.2']

# 列出根目录下的文件列表
>>> os.listdir("/")
['boot', 'dev', 'home', 'proc', 'run', 'sys', 'etc', 'root', 'var', 'tmp', 'usr', 'bin', 'sbin', 'lib', 'lib64', 'media', 'mnt', 'opt', 'srv', 'ahdata']
```

### 1.2、pwd命令
``` python
>>> os.getcwd()
'/opt'
```

### 1.3、cd命令
使用os.chdir(dirname), 必须传入参数变更的目录path, 这一点是跟shell有区别的, shell cd不跟参数可以跳转到主目录. 
``` python
# 修改目录到根目录并列出文件列表
>>> os.chdir("/")
>>> os.getcwd()
'/'
```

### 1.4、scp命令
