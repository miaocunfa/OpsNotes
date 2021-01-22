---
title: "运维自动化神器 Ansible之Ping(二)"
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

## 一、概述

&nbsp;
**ping模块** 用来检测主机连通性。

ping模块返回值
```
RETURN VALUES:

ping:
    description: value provided with the data parameter
    returned: success
    type: str
    sample: pong
```

因为ping模块只是用来检测主机连通性，所以使用ping模块时是不需要-a指定参数的。

## 二、示例
``` bash
[root@master01 ~]# ansible 172.31.194.117 -m ping
/usr/lib/python2.7/site-packages/requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.25.3) or chardet (2.2.1) doesn't match a supported version!
  RequestsDependencyWarning)
172.31.194.117 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
```

ping返回pong这就说明主机是可以连接的，可以进行后续的其他操作了。
