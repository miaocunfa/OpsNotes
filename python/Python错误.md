---
title: "Python报错"
date: "2020-06-22"
categories:
    - "技术"
tags:
    - "错误汇总"
    - "python"
toc: false
original: true
---

## 一、psutil

### 1.1、问题描述

``` zsh
# 安装psutil报错
➜  pip3 install psutil -i https://pypi.douban.com/simple

    psutil/_psutil_common.c:9:20: fatal error: Python.h: No such file or directory
     #include <Python.h>
                        ^
    compilation terminated.
    error: command 'gcc' failed with exit status 1

    ----------------------------------------
Command "/usr/bin/python3 -u -c "import setuptools, tokenize;__file__='/tmp/pip-build-1gefw13o/psutil/setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record /tmp/pip-muoi4hrq-record/install-record.txt --single-version-externally-managed --compile" failed with error code 1 in /tmp/pip-build-1gefw13o/psutil/

# 查到应该是缺少python-devel包
➜  yum -y install python3-devel

Total                                                                                                                                                         16 MB/s | 7.5 MB  00:00:00
Running transaction check
Running transaction test


Transaction check error:
  file /etc/rpm/macros.ghc-srpm from install of redhat-rpm-config-9.1.0-88.el7.centos.noarch conflicts with file from package epel-release-6-8.noarch

Error Summary
-------------
# 安装报错，与现有包epel-release产生冲突。
```

### 1.2、问题解决

``` zsh
# 查询epel-release版本
➜  yum info epel-release
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
Installed Packages
Name        : epel-release
Arch        : noarch
Version     : 6
Release     : 8
Size        : 22 k
Repo        : installed
Summary     : Extra Packages for Enterprise Linux repository configuration
URL         : http://dl.fedoraproject.org/pub/epel/
License     : GPLv2
Description : This package contains the Extra Packages for Enterprise Linux (EPEL) repository
            : GPG key as well as configuration for yum and up2date.

Available Packages
Name        : epel-release    # 发现有新版本可用于更新
Arch        : noarch
Version     : 7
Release     : 12
Size        : 15 k
Repo        : aliyun-epel/7/x86_64
Summary     : Extra Packages for Enterprise Linux repository configuration
URL         : http://download.fedoraproject.org/pub/epel
License     : GPLv2
Description : This package contains the Extra Packages for Enterprise Linux (EPEL) repository
            : GPG key as well as configuration for yum.

# 更新epel-release包
➜  yum upgrade epel-release
Running transaction
  Updating   : epel-release-7-12.noarch                                                                                                                                                  1/2
  Cleanup    : epel-release-6-8.noarch                                                                                                                                                   2/2
  Verifying  : epel-release-7-12.noarch                                                                                                                                                  1/2
  Verifying  : epel-release-6-8.noarch                                                                                                                                                   2/2

Updated:
  epel-release.noarch 0:7-12

Complete!

# 安装python-devel
➜  yum install python3-devel.x86_64

# 成功安装psutil包
➜  pip3 install psutil -i https://pypi.douban.com/simple
WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.
Collecting psutil
  Downloading https://pypi.doubanio.com/packages/c4/b8/3512f0e93e0db23a71d82485ba256071ebef99b227351f0f5540f744af41/psutil-5.7.0.tar.gz (449kB)
    100% |████████████████████████████████| 450kB 3.0MB/s
Installing collected packages: psutil
  Running setup.py install for psutil ... done
Successfully installed psutil-5.7.0
```

## 二、文件名与主程序冲突

### 2.1、问题描述

``` zsh
# 主程序部分
➜  cat jinja2.py
def create_deploy_yaml(service_name, service):

    # 变量赋值
    cpuRequest = "50m"
    memoryRequest = "100Mi"
    cpuLimit = "500m"
    memoryLimit = "1000Mi"

    replicas = int(service['replicas'])

    deploy_mould_file = "jinja2/info-deploy-mould.yaml"
    isDeployMould = os.path.isfile(deploy_mould_file)

    if isDeployMould:

        path, filename = os.path.split(deploy_mould_file)
        template = jinja2.environment.Environment( loader=jinja2.FileSystemLoader(path or './') ).get_template(filename)

        result = template.render(jarName=service_name, replicas=replicas, tag=tag, cpuRequest=cpuRequest, memoryRequest=memoryRequest, cpuLimit=cpuLimit, memoryLimit=memoryLimit)
        print(result)

    else:
        print("Deploy Mould File is Not Exist!")


# 执行报错
➜  python3 jinja2.py
Traceback (most recent call last):
  File "jinja2.py", line 15, in <module>
    import jinja2
  File "/root/iKubernetes/ahang/info/jinja2.py", line 241, in <module>
    create_deploy_yaml('info-message-service', services['info-message-service'])
  File "/root/iKubernetes/ahang/info/jinja2.py", line 74, in create_deploy_yaml
    template = jinja2.environment.Environment( loader=jinja2.FileSystemLoader(path or './') ).get_template(filename)
AttributeError: module 'jinja2' has no attribute 'environment'


```

### 2.2、问题解决

``` zsh
# 观察发现，犯了一个弱智问题，程序名写的跟import的模块一样了，所以导入的是脚本，当然找不到定义的函数。
➜  ll
total 28
drwxr-xr-x. 2 root root   96 Jul  3 11:21 jinja2
-rw-r--r--. 1 root root 6953 Jul  3 12:32 jinja2.py
drwxr-xr-x. 2 root root   35 Jul  3 12:32 __pycache__

# 修改程序名
# 再执行就成功了
➜  mv jinja2.py templating-k8s-with-jinja2.py
➜  ll
total 28
drwxr-xr-x. 2 root root   96 Jul  3 14:30 jinja2
-rw-r--r--. 1 root root 6436 Jul  3 14:28 templating-k8s-with-jinja2.py
```
