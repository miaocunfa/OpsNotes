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

## 一、python 命令行解释器 && python源

### 1.1、iPython

我们使用更好用的python命令行解释器 ipython

``` zsh
# 使用yum安装
➜  yum install -y ipython

➜  ipython
Python 2.7.5 (default, Oct 30 2018, 23:45:53) 
Type "copyright", "credits" or "license" for more information.

IPython 3.2.1 -- An enhanced Interactive Python.
?         -> Introduction and overview of IPython's features.
%quickref -> Quick reference.
help      -> Python's own help system.
object?   -> Details about 'object', use 'object??' for extra details.

In [1]: print("Hello, iPython")
Hello, iPython

In [2]:
```

### 1.2、python源

由于众所周知的原因，我们直接使用pip导入python模块的时候非常的龟速

我们可以在使用pip的时候指定下载源

``` zsh
➜  pip3 help install

  # 使用-i选项指定
  -i, --index-url <url>       Base URL of Python Package Index (default http://mirrors.cloud.aliyuncs.com/pypi/simple/). This should point to a repository compliant with PEP 503 (the
                              simple repository API) or a local directory laid out in the same format.
```

几个比较常用的国内下载源

``` log
# 阿里云
https://mirrors.aliyun.com/pypi/simple/
# 中国科技大学
https://pypi.mirrors.ustc.edu.cn/simple/
# 豆瓣(douban)
http://pypi.douban.com/simple/
# 清华大学
https://pypi.tuna.tsinghua.edu.cn/simple/
# 中国科学技术大学
http://pypi.mirrors.ustc.edu.cn/simple/
```

## 二、os 模块

使用os中的函数, 需要先导入os模块, 否则会报命名错误`NameError: name 'os' is not defined`

``` py
➜  ipython

In [1]: import os
```

### 2.1、ls 命令

使用os.listdir(dirname)可以列出目录下的文件列表, 若不传入目录参数则列出的目录为进入python命令解释行时的目录  

``` py

➜  cd /opt
➜  ipython

In [1]: import os

# 使用os.listdir()默认参数
# 会列出进入python shell时的路径下的所有文件
In [2]: os.listdir()
Out[2]:
['rh',
 'zbox',
 'node_exporter-0.18.1.linux-amd64.tar.gz',
 'node_exporter-0.18.1.linux-amd64',
 'history_format.conf',
 'aihangxunxi',
 'containerd',
 'rabbitmq_server-3.8.2']

# 我们也可以指定要列出的目录
In [3]: os.listdir("/")
Out[3]:
['boot',
 'dev',
 'home',
 'proc',
 'run',
 'sys',
 'etc',
 'root',
 'var',
 'tmp',
 'usr',
 'bin',
 'sbin',
 'lib',
 'lib64',
 'media',
 'mnt',
 'opt',
 'srv',
 'ahdata']
```

### 2.2、pwd命令

``` python
➜  ipython

In [1]: import os

# 获取当前工作目录
In [2]: os.getcwd()
Out[2]: '/root/Python_demo'
```

### 2.3、cd命令

使用os.chdir(dirname), 必须传入参数变更的目录path, 这一点是跟shell有区别的, shell cd不跟参数可以跳转到主目录.

``` python
In [1]: import os

# 修改目录到根目录
In [2]: os.chdir("/")

# 获取当前工作目录
In [3]: os.getcwd()
Out[3]: '/'
```

## 三、paramiko 模块

### 3.1、scp

``` zsh
➜  pip3 install paramiko  -i https://pypi.douban.com/simple
➜  pip3 install scp       -i https://pypi.douban.com/simple

➜  vim distribute.py
#!/usr/bin/python

import paramiko
from scp import SCPClient
def progress4(filename, size, sent, peername):
    sys.stdout.write("(%s:%s) %s\'s progress: %.2f%%   \r" % (peername[0], peername[1], filename, float(sent)/float(size)*100) )

# 创建ssh访问
ssh = paramiko.SSHClient()
ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())   # 允许连接不在know_hosts文件中的主机
ssh.connect(host, port=remote_port, username=remote_user, password=remote_pass)

with SCPClient(ssh.get_transport(), progress4=progress4) as scp:
    scp.put(local_filename, remote_filename)
    print("")
```

## 四、nmap模块

### 4.1、安装

``` zsh
➜  yum install -y nmap
➜  pip3 install python-nmap -i https://pypi.douban.com/simple
```

## 五、psutil模块

