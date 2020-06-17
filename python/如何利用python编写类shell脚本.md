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
➜  cd /opt
➜  ipython

# 列出根目录下的文件列表
In [1]: import os

In [2]: os.listdir("/")
Out[2]:
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

### 1.2、pwd命令

``` python
In [1]: import os

In [2]: os.getcwd()
Out[2]: '/root/Python_demo'
```

### 1.3、cd命令

使用os.chdir(dirname), 必须传入参数变更的目录path, 这一点是跟shell有区别的, shell cd不跟参数可以跳转到主目录. 

``` python
# 修改目录到根目录并列出文件列表
In [1]: import os

In [2]: os.chdir("/")

In [3]: os.getcwd()
Out[3]: '/'
```

### 1.4、scp命令

``` zsh
➜  pip3 install paramiko  -i https://pypi.douban.com/simple
➜  pip3 install scpclient -i https://pypi.mirrors.ustc.edu.cn/simple/

#!/usr/bin/python
import paramiko
import scpclient
from contextlib import closing

# 创建ssh访问
ssh = paramiko.SSHClient()
ssh.load_system_host_keys()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())    # 允许连接不在know_hosts文件中的主机
ssh.connect(host, port=22, username='root', password='test123')

#创建scp
with closing(scpclient.Write(ssh.get_transport(), remote_path=remote_path)) as scp:
    scp.send_file(local_filename, preserve_times=True, remote_filename=jar)
```

``` zsh
➜  pip3 install scp -i http://mirrors.aliyun.com/pypi/simple/
```
