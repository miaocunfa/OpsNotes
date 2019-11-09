## 运维自动化神器ansible之ping(二)

### 一、概述

&nbsp;
**ping模块** 用来检测节点连通性。

### 二、参数介绍

&nbsp;
- _**name：**_ 用于指定操作的 **user**，**必须项**。


```
RETURN VALUES:

ping:
    description: value provided with the data parameter
    returned: success
    type: str
    sample: pong
```


### 三、参数详解

&nbsp;
下列英文文档部分来自于 **`ansible-doc`**，参数的**修饰符号**为 **"="** 或 **"-"**
OPTIONS (= is mandatory)：**=** 号开始的为**必须**给出的参数

#### 3.1    name

_**name：**_ 用于指定操作的 **user**，**必须项**

``` bash
= name
        Name of the user to create, remove or modify.
        (Aliases: user)
        type: str
```
&nbsp;

##### 3.1.1  示例

使用 **ansible** 在 **note1** 节点上增加 **test** 用户

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=test"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1000, 
    "home": "/home/test", 
    "name": "test", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1000
}
[root@note0 ~]#
```
&nbsp;

验证 **用户** 是否 **添加** 成功，查看 **note1** 节点下的 **`/etc/passwd`** 文件

``` bash
[root@note1 ~]# tail -1 /etc/passwd
test:x:1000:1000::/home/test:/bin/bash
```
&nbsp;
