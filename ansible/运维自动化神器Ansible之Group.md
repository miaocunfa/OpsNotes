---
title: "运维自动化神器 Ansible之Group(三)"
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

group模块是用来添加或者删除组

首先使用ansible-doc来查看用法
```bash
[root@note0 ansible]# ansible-doc -s group
- name: Add or remove groups
  group:
      gid:                   # Optional `GID' to set for the group.
      local:                 # Forces the use of "local" command alternatives on platforms that implement it. This is useful in environments that use centralized
                               authentication when you want to manipulate the local groups. (e.g. it uses `lgroupadd' instead of
                               `groupadd'). This requires that these commands exist on the targeted host, otherwise it will be a fatal
                               error.
      name:                  # (required) Name of the group to manage.
      non_unique:            # This option allows to change the group ID to a non-unique value. Requires `gid'. Not supported on macOS or BusyBox distributions.
      state:                 # Whether the group should be present or not on the remote host.
      system:                # If `yes', indicates that the group created is a system group.
```

通过上面的参数列表我们可以了解到group模块有几个重要属性

OPTIONS (= is mandatory):选项前面为=的为必填参数

## 一、name

```
= name
        Name of the group to manage.
        type: str
        
要操作的group的组名，string类型，必填项
```

### 1.1、示例

创建一个名字为test的组。

```bash
[root@note0 ~]# ansible local -m group -a "name=test"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    <font color="red">"changed": true,</font>#可以看到changed状态为true，代表已经在主机添加组成功。
    "gid": 1000, 
    "name": "test", 
    "state": "present", 
    "system": false
}
```

查看主机/etc/group文件验证
```
[root@note1 ~]# cat /etc/group
test:x:1000:
```

## 二、state

```
- state
        Whether the group should be present or not on the remote host.
        (Choices: absent, present)[Default: present]
        type: str
        
state用于指定用户组在远程主机上是否被更改或删除，string类型。
有两个选项：absent，present。默认值为present，absent为删除组。
```

### 2.1、示例

我们来删除一下刚才创建的组。

```
[root@note0 ~]# ansible local -m group -a "name=test state=absent"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "name": "test", 
    "state": "absent"
}
```

## 三、gid

```
- gid
        Optional `GID' to set for the group.
        [Default: (null)]
        type: int
        
gid用于设定用户组gid，int类型，默认值为空
```
### 3.1、示例

创建一个gid为1005，名字为test的组。

```
[root@note0 ~]# ansible local -m group -a "name=test gid=1005 state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1005, 
    "name": "test", 
    "state": "present", 
    "system": false
}
```

查看主机/etc/group文件，我们可以看到新创建的组gid为1005。
```
[root@note1 ~]# cat /etc/group
test:x:1005:
```

## 四、system

```
- system
        If `yes', indicates that the group created is a system group.
        [Default: False]
        type: bool
        
system用于指定创建的用户组是否为系统组，布尔类型，可用选项false，true，默认为false
```

### 4.1、示例

创建一个名字为test的系统组。

```bash
[root@note0 ~]# ansible local -m group -a "name=test state=present system=true"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 994, 
    "name": "test", 
    "state": "present", 
    "system": true
}
```

查看主机/etc/group文件验证

```bash
[root@note1 ~]# cat /etc/group
test:x:994:
```

可以看到test组的gid为994，gid小于1000为系统组。
