---
title: "运维自动化神器 Ansible之User(四)"
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

### 一、概述

&nbsp;
**user模块** 可管理远程主机上的 **用户**，比如创建用户、修改用户、删除用户、为用户创建密钥对等操作。

### 二、参数介绍

&nbsp;
- _**name：**_ 用于指定操作的 **user**，**必须项**。
- _**uid：**_     用于指定 **user** 的 **UID**，**默认为空**。
- _**non_unique：**_ 与**uid**参数**一起**使用，允许**改变**UID为**非唯一**值。
- _**group：**_ 参数用于指定用户 **主组**。**默认值**为**空**，为空时创建的用户**组名**跟**用户名**一致。
- _**groups：**_ 参数用于指定用户**属组**，可以在**创建用户**时指定用户属组，也可以管理**已经存在**的用户属组。
- _**append：**_ 跟groups参数一起使用管理用户属组，**默认**为**false**，如果 **`append='yes'`** ，则从groups参数中增加用户的属组；如果 **`append='no'`** ，则用户属组只设置为groups中的组，移除其他所有属组。
- _**state：**_ 参数用于指定用户**是否存在**于**远程主机**中。**可选值**有 **present**、**absent**，**默认值**为 **present**。
- _**remove：**_ 参数在 **`state=absent`** 时使用，等价于 **`userdel --remove`**  **布尔类型**，**默认值**为 **false**。
- _**force：**_ 参数在 **`state=absent`** 时使用，等价于 **`userdel --force`**，**布尔类型**，**默认值**为 **false**。
- _**home：**_ 参数用于指定用户**home目录**，值为**路径**
- _**create_home：**_ 在用户**创建**时或home目录**不存在**时为用户**创建**home目录，**布尔类型**，**默认值**为 **true**
- _**move_home：**_ 如果设置为**yes**，结合**home=** 使用，临时**迁移**用户**家目录**到**特定目录**
- _**comment：**_ 参数用于指定用户**注释信息**
- _**shell：**_ 参数用于指定用户**默认shell**
- _**system：**_ 参数用于指定用户是否是**系统用户**
- _**expires：**_ 参数用于指定用户**过期时间**，相当于设置 **`/etc/shadow`** 文件中的的 **第8列**
- _**passwd：**_ 参数用于指定用户**密码**，但是这个密码**不能**是**明文密码**，而是一个对**明文**密码**加密后**的**字符串**，**默认为空**
- _**password_lock：**_ 参数用于**锁定**指定用户，**布尔类型**，**默认为空**
- _**update_password：**_ 参数**可选值**有**always** 和 **on_create**，**默认**为**always** 。
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;当设置为**always**时，**password参数**的值与 **`/etc/shadow`** 中密码字符串不一致时**更新**用户的密码；
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;当设置为**on_create**时，**password参数**的值与 **`/etc/shadow`** 中密码字符串不一致时也**不会**更新用户的密码，但如果是**新创建**的用户，则此参数即使为**on_create**，也**会更新**用户密码。
- _**generate_ssh_key：**_ 参数用于指定是否**生成ssh密钥对**，**布尔类型**，**默认为false**。当设置为yes时，为用户生成 ssh 密钥对，默认在 **`~/.ssh`** 目录中生成名为 **id_rsa私钥** 和 **id_rsa.pub公钥**，如果同名密钥已经存在，则不做任何操作。
- _**sssh_key_bits：**_ 当 **`generate_ssh_key=yes`** 时，指定生成的ssh key**加密位数**。
- _**ssh_key_file：**_ 当 **`generate_ssh_key=yes`** 时，使用此参数指定ssh私钥的**路径**及**名称**，会在**同路径**下生成以私钥名开头以 **`.pub`** 结尾对应公钥。
- _**ssh_key_comment：**_ 当 **`generate_ssh_key=yes`** 时，在创建证书时，使用此参数设置公钥中的注释信息。如果同名密钥已经存在，则不做任何操作。当不指定此参数时，**默认**注释信息为"ansible-generated on \$hostname”。
- _**ssh_key_passphrase：**_ 当 **`generate_ssh_key=yes`** 时，在创建证书时，使用此参数设置**私钥密码**。如果同名密钥已经存在，则不做任何操作。
- _**ssh_key_type：**_ 当 **`generate_ssh_key=yes`** 时，在创建证书时，使用此参数指定密钥对的类型。默认值为 **rsa**，如果同名密钥已经存在，则不做任何操作。


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

#### 3.2    uid

_**uid：**_ 用于指定 **user** 的 **UID**，**默认为空**

``` bash
- uid
        Optionally sets the `UID' of the user.
        [Default: (null)]
        type: int
```

##### 3.2.1  示例

使用 **ansible** 在 **note1** 节点上增加 **testuid** 用户

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testuid uid=2000"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 2000, 
    "home": "/home/testuid", 
    "name": "testuid", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 2000
}
[root@note0 ~]#
```

&nbsp;
验证 **用户** 是否 **添加** 成功，查看 **note1** 节点下的  **`/etc/passwd`** 文件

``` bash
[root@note1 ~]# tail -1 /etc/passwd
testuid:x:2000:2000::/home/testuid:/bin/bash
```

#### 3.3    state

_**state：**_ 参数用于指定用户**是否存在**于**远程主机**中。
**可选值**有 **present**、**absent**：
**默认值**为 **present**，表示用户**存在**，相当于在远程主机**创建**用户；
当设置为 **absent** 时表示用户**不存在**，相当于在远程主机**删除**用户。

``` bash
- state
        Whether the account should exist or not, taking action if the state is different from what is stated.
        (Choices: absent, present)[Default: present]
        type: str
```

##### 3.3.1  示例

使用 **ansible** 在 **note1** 节点上删除 **test** 用户

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=test state=absent"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "force": false, 
    "name": "test", 
    "remove": false, 
    "state": "absent"
}
[root@note0 ~]#
```

&nbsp;
验证 **用户** 是否 **删除** 成功，查看 **note1** 节点下是否存在 **test** 用户

``` bash
[root@note1 ~]# id test
id: test: no such user
```

#### 3.4    remove

_**remove：**_ 参数在 **`state=absent`** 时使用，等价于 **`userdel --remove`**  布尔类型，**默认值**为 **false**。

``` bash
- remove
        This only affects `state=absent', it attempts to remove directories associated with the user.
        The behavior is the same as `userdel --remove', check the man page for details and support.
        [Default: False]
        type: bool
```

##### 3.4.1  示例1

在 **示例3.3.1** 中我们已经使用 **ansible** 在 **note1** 节点上删除了 **test** 用户，现在让我们查看**test**用户**home目录**是否存在。

``` bash
[root@note1 ~]# cd /home
#查看home目录
[root@note1 home]# ll
总用量 0
drwx------ 2    1000    1000 59 7月   9 16:41 test
drwx------ 2 testuid testuid 59 7月   9 17:01 testuid
[root@note1 home]#
```

我们可以看到，通过**state=absent**删除的用户**home目录**还存在，下面我们来演示一下彻底删除一个用户。

##### 3.4.2  示例2

使用 **ansible** 在 **note1** 节点上删除 **testuid** 用户

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testuid state=absent remove=yes"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "force": false, 
    "name": "testuid", 
    "remove": true, 
    "state": "absent"
}
[root@note0 ~]#
```

&nbsp;
下面我们来验证一下，**用户**及**home目录**是否**彻底删除**

``` bash
#查看testuid用户是否存在
[root@note1 home]# id testuid
id: testuid: no such user
#查看home目录
[root@note1 home]# ll
总用量 0
drwx------ 2 1000 1000 59 7月   9 16:41 test
[root@note1 home]#
```

#### 3.5    group

_**group：**_ 参数用于指定用户 **主组**。**默认值**为**空**，创建的用户**组名**跟**用户名**一致。

``` bash
- group
        Optionally sets the user's primary group (takes a group name).
        [Default: (null)]
        type: str
```

##### 3.5.1  示例

使用 **ansible** 在 **note1** 节点上 **创建test** 用户，并指定主组为 **testgrp**

``` bash
#首先创建使用ansible创建testgrp组
[root@note0 ~]# ansible note1 -m group -a "name=testgrp state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "gid": 1000, 
    "name": "testgrp", 
    "state": "present", 
    "system": false
}
#使用ansible创建test用户
[root@note0 ~]# ansible note1 -m user -a "name=test group=testgrp state=present"
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
验证 **用户** 是否 **创建** 成功

``` bash
[root@note1 home]# id test
uid=1000(test) gid=1000(testgrp) 组=1000(testgrp)
```

#### 3.6    groups、append

_**groups：**_ 参数用于指定用户**属组**，可以在**创建用户**时指定用户属组，也可以管理**已经存在**的用户属组。

**groups**为**列表类型**，多个参数以**逗号**分隔，例如 **`groups='grp,mygrp'`**；**默认值** 为 **空** ，也可以设置空字符串 **groups=''**，**groups=\`null\`** ，**groups=\`~\`** ，将用户从其他属组 **移除**。

_**append：**_ 跟groups参数一起使用管理用户属组。**布尔类型**，默认为**false**，如果 **`append='yes'`** ，则从groups参数中增加用户的属组；如果 **`append='no'`** ，则用户属组只设置为groups中的组，移除其他所有属组。

``` bash
- groups
        List of groups user will be added to. When set to an empty string `''', `null', or `~', the user is removed from all groups
        except the primary group. (`~' means `null' in YAML)
        Before Ansible 2.3, the only input format allowed was a comma separated string.
        [Default: (null)]
        type: list
        
- append
        If `yes', add the user to the groups specified in `groups'.
        If `no', user will only be added to the groups specified in `groups', removing them from all other groups.
        [Default: False]
        type: bool
```

##### 3.6.1  示例1-创建用户时指定属组

先使用 **ansible** 在 **note1** 节点上创建 **mygrp1**，**mygrp2**，**mygrp3** 测试组

``` bash
#首先创建使用创建测试组
[root@note0 ~]# ansible note1 -m group -a "name=mygrp1 gid=2001 state=present"
[root@note0 ~]# ansible note1 -m group -a "name=mygrp2 gid=2002 state=present"
[root@note0 ~]# ansible note1 -m group -a "name=mygrp3 gid=2003 state=present"

#测试组创建成功
[root@note1 home]# cat /etc/group
mygrp1:x:2001:
mygrp2:x:2002:
mygrp3:x:2003:
```

&nbsp;
创建用户 **testuser**，并指定属组为 **mygrp1** **mygrp2** 

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testuser groups=mygrp1,mygrp2 state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1001, 
    "groups": "mygrp1,mygrp2", 
    "home": "/home/testuser", 
    "name": "testuser", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1001
}
[root@note0 ~]#
```

&nbsp;
验证用户 **testuser**的**属组**为**mygrp1**，**mygrp2** 

``` bash
[root@note1 home]# id testuser
uid=1001(testuser) gid=1001(testuser) 组=1001(testuser),2001(mygrp1),2002(mygrp2)
```

##### 3.6.2  示例2-已创建用户增加属组

将**testuser**的**属组**变更为**mygrp1**，**mygrp2**，**mygrp3**
 
##### 3.6.2.1  不使用append，使用groups指明用户的所有属组即可
 
 ``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testuser groups='mygrp1,mygrp2,mygrp3' state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "append": false, 
    "changed": true, 
    "comment": "", 
    "group": 1001, 
    "groups": "mygrp1,mygrp2,mygrp3", 
    "home": "/home/testuser", 
    "move_home": false, 
    "name": "testuser", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1001
}
[root@note0 ~]#
```

&nbsp;
验证用户**testuser**的**属组**是否为**mygrp1**，**mygrp2**，**mygrp3**

``` bash
[root@note1 home]# id testuser
uid=1001(testuser) gid=1001(testuser) 组=1001(testuser),2001(mygrp1),2002(mygrp2),2003(mygrp3)
```

##### 3.6.2.2  使用append属性

先将**testuser**用户**属组**还原为**mygrp1**，**mygrp2**
再**增加**属组**mygrp3**

``` bash
#使用append=yes时，只将要添加的属组填入groups参数中即可。
[root@note0 ~]# ansible note1 -m user -a "name=testuser groups='mygrp3' append=yes state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "append": true, 
    "changed": true, 
    "comment": "", 
    "group": 1001, 
    "groups": "mygrp3", 
    "home": "/home/testuser", 
    "move_home": false, 
    "name": "testuser", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1001
}
[root@note0 ~]#
```

&nbsp;
验证用户**testuser**的**属组**是否为**mygrp1**，**mygrp2**，**mygrp3**

``` bash
[root@note1 home]# id testuser
uid=1001(testuser) gid=1001(testuser) 组=1001(testuser),2001(mygrp1),2002(mygrp2),2003(mygrp3)
```

##### 3.6.3  示例3-已创建用户移除属组
将**testuser**的**属组**变更为**mygrp1**

##### 3.6.3.1  不使用append，使用groups指明用户的所有属组即可
``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testuser groups='mygrp1' state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "append": false, 
    "changed": true, 
    "comment": "", 
    "group": 1001, 
    "groups": "mygrp1", 
    "home": "/home/testuser", 
    "move_home": false, 
    "name": "testuser", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1001
}
[root@note0 ~]#
```

&nbsp;
验证用户**testuser**的**属组**是否为**mygrp1**

``` bash
[root@note1 home]# id testuser
uid=1001(testuser) gid=1001(testuser) 组=1001(testuser),2001(mygrp1)
```

##### 3.6.3.2  使用append属性
先将**testuser**用户**属组**还原为**mygrp1**，**mygrp2**，**mygrp3**
再**变更**用户**testuser**属组为**mygrp3**

``` bash
#使用append=no时，用户的属组只设置为groups参数中的组
[root@note0 ~]# ansible note1 -m user -a "name=testuser groups='mygrp1' append='no' state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "append": false, 
    "changed": true, 
    "comment": "", 
    "group": 1001, 
    "groups": "mygrp1", 
    "home": "/home/testuser", 
    "move_home": false, 
    "name": "testuser", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1001
}
[root@note0 ~]#
```

&nbsp;
验证用户**testuser**的**属组**是否为**mygrp1**

``` bash
[root@note1 home]# id testuser
uid=1001(testuser) gid=1001(testuser) 组=1001(testuser),2001(mygrp1)
```

#### 3.7    passwd

_**passwd：**_ 参数用于指定用户**密码**，但是这个密码**不能**是**明文密码**，而是一个对**明文**密码**加密后**的**字符串**，相当于 `/etc/shadow` 文件中的**密码字段**，是一个对明文密码进行**哈希**后的字符串，可以使用**命令生成**明文密码对应的**加密字符串**。


``` bash
- password
        Optionally set the user's password to this crypted value.
        On macOS systems, this value has to be cleartext. Beware of security issues.
        To create a disabled account on Linux systems, set this to `'!'' or `'*''.
        See https://docs.ansible.com/ansible/faq.html#how-do-i-generate-crypted-passwords-for-the-user-module for details on various
        ways to generate these password values.
        [Default: (null)]
        type: str
```

&nbsp;
要生成**md5算法**的密码，使用**openssl**即可。
``` bash
openssl passwd -1 '123456'
openssl passwd -1 -salt 'abcdefg' '123456'
```

&nbsp;
但 **`openssl passwd`** 不支持生成**sha-256**和**sha-512**算法的密码。使用python命令生成**sha-512**算法
```  python
python -c 'import crypt,getpass;pw="123456";print(crypt.crypt(pw))'
```

&nbsp;
现在就方便多了，直接将结果**赋值**给**变量**即可。
```  bash
[root@note0 ~]# a=$(python -c 'import crypt,getpass;pw="123456";print(crypt.crypt(pw))')
[root@note0 ~]# echo $a
$6$uKhnBg5A4/jC8KaU$scXof3ZwtYWl/6ckD4GFOpsQa8eDu6RDbHdlFcRLd/2cDv5xYe8hzw5ekYCV5L2gLBBSfZ.Uc166nz6TLchlp.
```

&nbsp;
例如，ansible创建用户并指定密码：
``` bash
[root@note0 ~]# a=$(python -c 'import crypt,getpass;pw="123456";print(crypt.crypt(pw))')
[root@note0 ~]# ansible note1 -m user -a 'name=testpass password="$a" update_password=always'
 [WARNING]: The input password appears not to have been hashed. The 'password' argument must be encrypted for this module to work properly.

176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1005, 
    "home": "/home/testpass", 
    "name": "testpass", 
    "password": "NOT_LOGGING_PASSWORD", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1005
}
[root@note0 ~]#
```

&nbsp;
登录验证
``` bash
[root@note0 ~]# ssh testpass@note1
testpass@note1's password: 
Last login: Thu Jul 11 00:12:57 2019 from note0
[testpass@note1 ~]$ who am i
testpass pts/1        2019-07-11 00:13 (note0)
[testpass@note1 ~]$
```

#### 3.8    expires
_**expires：**_ 参数用于指定用户**过期时间**，相当于设置 **`/etc/shadow`** 文件中的的 **第8列** ，比如，你想要设置用户的过期日期为2019年07月10日，那么你首先要获取2019年07月10日的 **unix 时间戳**，使用命令 **`date -d 20190710 +%s`** 获取到的**时间戳**为**1562688000**，所以，当设置 **`expires=1562688000`** 时，表示用户的**过期时间**为**2019年07月10日0点0分**，设置成功后，查看远程主机的 `/etc/shadow` 文件，对应用户的**第8列**的值将变成**18086**（表示1970年1月1日到2019年07月10日的天数，unix 时间戳的值会**自动转换**为天数，我们不用手动的进行换算），当前ansible版本此参数支持在**GNU/Linux**, **FreeBSD**, and **DragonFlyBSD** 系统中使用。

##### 3.8.1 示例

设置一个**过期时间**为**20190710**的用户**testexprie**

``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testexpire expires=1562688000 comment='expires date is 20190710' state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "expires date is 20190710", 
    "create_home": true, 
    "group": 1003, 
    "home": "/home/testexpire", 
    "name": "testexpire", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1003
}
[root@note0 ~]#
```

&nbsp;
在**note1**上验证**testexprie**用户
``` bash
[root@note1 home]# cat /etc/shadow
testexpire:!!:18086:0:99999:7::18086:
```

登录失败，提示账号**过期**
```
[root@note0 ~]# ssh testexpire@note1
testexpire@note1's password: 
Your account has expired; please contact your system administrator
Connection closed by 176.16.128.1
```

#### 3.9    home
_**home：**_ 参数用于指定用户**home目录**，值为**路径**

``` bash
- home
        Optionally set the user's home directory.
        [Default: (null)]
        type: path
        
- create_home
        Unless set to `no', a home directory will be made for the user when the account is created or if the home directory does not
        exist.
        Changed from `createhome' to `create_home' in Ansible 2.5.
        (Aliases: createhome)[Default: True]
        type: bool
        
- move_home
        If set to `yes' when used with `home: ', attempt to move the user's old home directory to the specified directory if it isn't
        there already and the old home exists.
        [Default: False]
        type: bool
```

##### 3.9.1 示例
```
[root@note0 ~]# ansible note1 -m user -a "name=testhome home=/home/testdir state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1004, 
    "home": "/home/testdir", 
    "name": "testhome", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1004
}
[root@note0 ~]# 
```

&nbsp;
验证**testhome**用户的**home目录**
``` bash
# 首先登录note1节点，su到testhome用户
[root@note1 ~]# su - testhome
# cd 到主目录
[testhome@note1 ~]$ cd ~
# 执行pwd
[testhome@note1 ~]$ pwd
/home/testdir
[testhome@note1 ~]$
```

#### 3.10    move_home
 _**move_home：**_ 如果设置为**yes**，结合**home=** 使用，临时**迁移**用户**家目录**到**特定目录**
 
 ``` bash
 - move_home
        If set to `yes' when used with `home: ', attempt to move the user's old home directory to the specified directory if it isn't
        there already and the old home exists.
        [Default: False]
        type: bool
 ```
 
##### 3.10.1 示例

首先创建**testmove**用户，然后在testmove用户home目录下创建**test_move_home.txt**文件
```  bash
#创建testmove用户。
[root@note0 ~]# ansible note1 -m user -a "name=testmove state=present"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1006, 
    "home": "/home/testmove", 
    "name": "testmove", 
    "shell": "/bin/bash", 
    "state": "present", 
    "system": false, 
    "uid": 1006
}
#使用ansible的file模块在testmove用户home目录下创建test_move_home.txt文件
[root@note0 ~]# ansible note1 -m file -a "path=/home/testmove/test_move_home.txt state=touch"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/home/testmove/test_move_home.txt", 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "owner": "root", 
    "size": 0, 
    "state": "file", 
    "uid": 0
}

#在note1节点上，查看/home/testmove下是否存在test_move_home.txt
[root@note1 ~]# cd /home/testmove
[root@note1 testmove]# ll
总用量 0
-rw-r--r-- 1 root root 0 7月  11 06:22 test_move_home.txt
[root@note1 testmove]#
```

使用ansible的**move_home**参数迁移用户home目录
``` bash
#迁移testmove用户的home目录至/tmp/testmove_new
[root@note0 ~]# ansible note1 -m user -a "user=testmove move_home=yes home=/tmp/testmove_new/"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "append": false, 
    "changed": true, 
    "comment": "", 
    "group": 1006, 
    "home": "/tmp/testmove_new/", 
    "move_home": true, 
    "name": "testmove", 
    "shell": "/bin/bash", 
    "state": "present", 
    "uid": 1006
}
[root@note0 ~]#
```

验证迁移的新home目录下是否存在**test_move_home.txt**文件
``` bash
[root@note1 testmove]# cd /tmp/testmove_new/
[root@note1 testmove_new]# ll
总用量 0
-rw-r--r-- 1 root root 0 7月  11 06:22 test_move_home.txt
[root@note1 testmove_new]#
```

#### 3.11   generate_ssh_key
 _**generate_ssh_key：**_ 参数用于指定是否**生成ssh密钥对**，**布尔类型**，**默认为false**。当设置为yes时，为用户生成 ssh 密钥对，默认在 **`~/.ssh`** 目录中生成名为 **id_rsa私钥** 和 **id_rsa.pub公钥**，如果同名密钥已经存在，则不做任何操作。
 
 ``` bash
 - generate_ssh_key
        Whether to generate a SSH key for the user in question.
        This will *not* overwrite an existing SSH key unless used with `force=yes'.
        [Default: False]
        type: bool
        version_added: 0.9
```

##### 3.11.1   示例
使用ansible创建testssh用户，并生成ssh_key。
``` bash
[root@note0 ~]# ansible note1 -m user -a "name=testssh state=present generate_ssh_key=yes"
176.16.128.1 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "", 
    "create_home": true, 
    "group": 1007, 
    "home": "/home/testssh", 
    "name": "testssh", 
    "shell": "/bin/bash", 
    "ssh_fingerprint": "2048 07:18:48:ea:f1:dc:95:22:75:fc:b5:5e:80:25:a7:1f  ansible-generated on note1 (RSA)", 
    "ssh_key_file": "/home/testssh/.ssh/id_rsa", 
    "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIrQCOP11FK/s50vpOm/z+hXEmet+oEdWqGbyQD0JdN0AJrS/MzHZF3v+sjMf4SoDL7PafPYnFY4iVEtNOuBK8uvQgziVXVRxPs7h9Yy+ZdFw8qFjeiC74pKl+0Mqq49I9TD1GMbOQRd0K7nTycymCAX0MW5lQz7q44f3qa4+4y8C63xxi/4H9x3lJ+JsjDDIzKo4i69CnqU3Bn+0HzfxYi9j63HtcdLF8OwVfyF73lK6xd+vK68AaxRfPIOEj4KJXU3iMdiM5zVvMZgjEKyaGKPJD/uQl35MV2oazmFHTHWrKgA5AXwJEMKJYJzF6a8Z6SrmSnvxp6TpnMmbXAjev ansible-generated on note1", 
    "state": "present", 
    "system": false, 
    "uid": 1007
}
[root@note0 ~]#
```

验证note1节点下的ssh_key文件
``` bash
[root@note1 ~]# cd /home/testssh/.ssh
[root@note1 .ssh]# ll
总用量 8
-rw------- 1 testssh testssh 1679 7月  11 06:39 id_rsa
-rw-r--r-- 1 testssh testssh  408 7月  11 06:39 id_rsa.pub
[root@note1 .ssh]# cat id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIrQCOP11FK/s50vpOm/z+hXEmet+oEdWqGbyQD0JdN0AJrS/MzHZF3v+sjMf4SoDL7PafPYnFY4iVEtNOuBK8uvQgziVXVRxPs7h9Yy+ZdFw8qFjeiC74pKl+0Mqq49I9TD1GMbOQRd0K7nTycymCAX0MW5lQz7q44f3qa4+4y8C63xxi/4H9x3lJ+JsjDDIzKo4i69CnqU3Bn+0HzfxYi9j63HtcdLF8OwVfyF73lK6xd+vK68AaxRfPIOEj4KJXU3iMdiM5zVvMZgjEKyaGKPJD/uQl35MV2oazmFHTHWrKgA5AXwJEMKJYJzF6a8Z6SrmSnvxp6TpnMmbXAjev ansible-generated on note1
[root@note1 .ssh]#
```

&nbsp;
ansible的user模块常用参数就介绍到这里，不做过多赘述了。欢迎指点交流。
