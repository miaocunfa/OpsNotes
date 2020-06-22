---
title: "Python报错"
date: "2020-06-22"
categories:
    - "技术"
tags:
    - "运维"
    - "shell"
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
