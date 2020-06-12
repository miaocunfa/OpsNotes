---
title: "使用Samba进行文件共享"
date: "2020-05-07"
categories:
    - "技术"
tags:
    - "运维"
    - "Samba"
toc: false
original: true
---

## 一、部署
``` bash
yum install samba -y
```

## 二、配置

### 2.1、创建用户
新增用户ssadmin、ssread
``` bash
# 创建系统用户
useradd -s /sbin/nologin ssadmin  # 设置为禁止登陆
useradd -s /sbin/nologin ssread

# 修改系统密码
echo "ssadmin" | passwd --stdin ssadmin
echo "ssread" | passwd --stdin ssread

# 将系统用户添加至samba用户中
smbpasswd -a ssadmin     # admin123!@#
smbpasswd -a ssread      # read2020

# 查看列表
pdbedit -L
ssadmin:1001:
ssread:1002:
```

### 2.2、共享目录
新建/share目录，并设置属组属主为nobody。
``` bash
mkdir /share
chown -R nobody:nobody /share/
```

### 2.3、配置文件
``` bash
vim /etc/samba/smb.conf
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.

# 全局参数：
#==================Global Settings ===================
[global]
	workgroup = WORKGROUP
	# 说明：设定 Samba Server 所要加入的工作组或者域。

    security = user  
    # 说明：设置用户访问Samba Server的验证方式，一共有四种验证方式。
    # 1. share：用户访问Samba Server不需要提供用户名和口令, 安全性能较低。
    # 2. user：Samba Server共享目录只能被授权的用户访问,由Samba Server负责检查账号和密码的正确性。账号和密码要在本Samba Server中建立。
    # 3. server：依靠其他Windows NT/2000或Samba Server来验证用户的账号和密码,是一种代理验证。此种安全模式下,系统管理员可以把所有的Windows用户和口令集中到一个NT系统上,使用 Windows NT进行Samba认证, 远程服务器可以自动认证全部用户和口令,如果认证失败,Samba将使用用户级安全模式作为替代的方式。
    # 4. domain：域安全级别,使用主域控制器(PDC)来完成认证。

	passdb backend = tdbsam
    # 说明：passdb backend就是用户后台的意思。目前有三种后台：smbpasswd、tdbsam 和 ldapsam。sam应该是security account manager（安全账户管理）的简写。
    # 1.smbpasswd：该方式是使用smb自己的工具smbpasswd来给系统用户（真实用户或者虚拟用户）设置一个Samba密码，客户端就用这个密码来访问Samba的资源。smbpasswd文件默认在/etc/samba目录下，不过有时候要手工建立该文件。
    # 2.tdbsam： 该方式则是使用一个数据库文件来建立用户数据库。数据库文件叫passdb.tdb，默认在/etc/samba目录下。passdb.tdb用户数据库 可以使用smbpasswd –a来建立Samba用户，不过要建立的Samba用户必须先是系统用户。我们也可以使用pdbedit命令来建立Samba账户。pdbedit命令的 参数很多，我们列出几个主要的。
　　#     pdbedit –a username            新建Samba账户。
　　#     pdbedit –x username            删除Samba账户。
　　#     pdbedit –L                     列出Samba用户列表，读取passdb.tdb数据库文件。
　　#     pdbedit –Lv                    列出Samba用户列表的详细信息。
　　#     pdbedit –c "[D]" –u username   暂停该Samba用户的账号。
　　#     pdbedit –c "[]" –u username    恢复该Samba用户的账号。
    # 3.ldapsam： 该方式则是基于LDAP的账户管理方式来验证用户。首先要建立LDAP服务，然后设置“passdb backend = ldapsam:ldap://LDAP Server”

	printing = cups
    # 说明：设置Samba共享打印机的类型。现在支持的打印系统有：bsd, sysv, plp, lprng, aix, hpux, qnx

	printcap name = cups
    # 说明：设置共享打印机的配置文件。

	load printers = no
    # 说明：设置是否在启动Samba时就共享打印机。

	cups options = raw

    log file = /var/log/samba/log.%m
    # 定义Samba用户的日志文件，%m代表客户端主机名

# 共享参数：
#================== Share Definitions ==================
[share]

    comment = samba221
    # 说明：comment是对该共享的描述，可以是任意字符串。

    path = /share
    # 说 明：path用来指定共享目录的路径。可以用%u、%m这样的宏来代替路径里的unix用户和客户机的Netbios名，用宏表示主要用于[homes] 共享域。例如：如果我们不打算用home段做为客户的共享，而是在/home/share/下为每个Linux用户以他的用户名建个目录，作为他的共享目 录，这样path就可以写成：path = /home/share/%u; 。用户在连接到这共享时具体的路径会被他的用户名代替，要注意这个用户名路径一定要存在，否则，客户机在访问时会找不到网络路径。同样，如果我们不是以用户来划分目录，而是以客户机来划分目录，为网络上每台可以访问samba的机器都各自建个以它的netbios名的路径，作为不同机器的共享资源，就可以 这样写：path = /home/share/%m 。

    browseable = yes
    # 说明：browseable用来指定该共享是否可以浏览。

    writable = yes
    # 说明：writable用来指定该共享路径是否可写。

    available = yes
    # 说明：available用来指定该共享资源是否可用。

    admin users = ssadmin
    # 说明：admin users用来指定该共享的管理员（对该共享具有完全控制权限）。在samba 3.0中，如果用户验证方式设置成“security=share”时，此项无效。
    # 例如：admin users =david，sandy（多个用户中间用逗号隔开）。

    valid users = ssadmin, ssread
    # 说明：valid users用来指定允许访问该共享资源的用户。
    # 例如：valid users = david，@dave，@tech（多个用户或者组中间用逗号隔开，如果要加入一个组就用“@组名”表示。）

    invalid users = root
    # 说明：invalid users用来指定不允许访问该共享资源的用户。
    # 例如：invalid users = root，@bob（多个用户或者组中间用逗号隔开。）

    write list = ssadmin
    # 说明：write list用来指定可以在该共享下写入文件的用户。
    # 例如：write list = david，@dave

    public = no
    # 说明：public用来指定该共享是否允许guest账户访问。

    guest ok = no
    # 说明：意义同“public”。

[homes]
	comment = Home Directories
    valid users = %S, %D%w%S
	browseable = No
	read only = No
	inherit acls = Yes

[printers]
	comment = All Printers
	path = /var/tmp
	printable = Yes
	create mask = 0600
	browseable = No

[print$]
	comment = Printer Drivers
	path = /var/lib/samba/drivers
	write list = @printadmin root
	force group = @printadmin
	create mask = 0664
	directory mask = 0775
```

Samba安装好后，使用testparm命令可以测试smb.conf配置是否正确。使用testparm –v命令可以详细的列出smb.conf支持的配置参数。
``` bash
testparm
```

## 三、服务

### 3.1、启动服务
``` bash
systemctl start smb    # 启动smb服务
systemctl status smb   # 查看smb状态
```

### 3.2、windows
文件资源管理器中输入
```
\\192.168.100.221\share
```
然后再输入samba用户密码即可

>参考列表  
>1、https://blog.csdn.net/weixin_40806910/java/article/details/81917077   
>2、https://blog.csdn.net/hypon2016/article/details/94136415