---
title: "CentOS-7.6 升级内核 && 开启BBR"
date: "2020-07-01"
categories:
    - "技术"
tags:
    - "内核升级"
    - "Linux"
    - "Kernel"
toc: false
indent: false
original: false
draft: false
---

## 0、系统环境

| 系统版本   | 系统当前              | 系统升级                  |
| ---------- | --------------------- | ------------------------- |
| CentOS 7.6 | 3.10.0-957.el7.x86_64 | 5.7.6-1.el7.elrepo.x86_64 |

## 1、检查内核版本

``` zsh
# 查看当前内核版本
➜  uname -r
3.10.0-957.el7.x86_64
```

## 2、安装升级 repo

``` zsh
# 载入公钥
➜  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

# 安装 repo
➜  rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# 载入 elrepo-kernel 元数据
➜  yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
```

## 3、升级内核

``` zsh
# 查看可用的 kernel 版本
➜  yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * elrepo-kernel: hkg.mirror.rackspace.com
Installed Packages
kernel.x86_64                                                                                 3.10.0-957.el7                                                                    @anaconda
kernel-headers.x86_64                                                                         3.10.0-957.el7                                                                    @anaconda
kernel-tools.x86_64                                                                           3.10.0-957.el7                                                                    @anaconda
kernel-tools-libs.x86_64                                                                      3.10.0-957.el7                                                                    @anaconda
Available Packages
kernel-lt.x86_64                                                                              4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-devel.x86_64                                                                        4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-doc.noarch                                                                          4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-headers.x86_64                                                                      4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools.x86_64                                                                        4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools-libs.x86_64                                                                   4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-lt-tools-libs-devel.x86_64                                                             4.4.228-2.el7.elrepo                                                              elrepo-kernel
kernel-ml.x86_64                                                                              5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-devel.x86_64                                                                        5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-doc.noarch                                                                          5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-headers.x86_64                                                                      5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-tools.x86_64                                                                        5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-tools-libs.x86_64                                                                   5.7.6-1.el7.elrepo                                                                elrepo-kernel
kernel-ml-tools-libs-devel.x86_64                                                             5.7.6-1.el7.elrepo                                                                elrepo-kernel

# 安装最新主线版本的kernel
# lt：long term support，长期支持版本
# ml：mainline，主线版本
➜  yum --disablerepo=\* --enablerepo=elrepo-kernel install  kernel-ml.x86_64  -y

# 删除旧版本工具包
➜  yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64  -y

# 安装新版本工具包
➜  yum --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml-tools.x86_64  -y
```

## 4、内核启动顺序

``` zsh
# 查看内核插入顺序
➜  awk -F \' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
2 : CentOS Linux (0-rescue-f3296d4df760440c9ddd35b809fb282a) 7 (Core)
或
➜  grep "^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2
CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-f3296d4df760440c9ddd35b809fb282a) 7 (Core)

# 查看当前实际启动顺序
➜  grub2-editenv list
saved_entry=CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)

# 设置默认启动
➜  grub2-set-default 'CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)'
➜  grub2-editenv list
saved_entry=CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)
或
➜  grub2-set-default 0　　# 0与上面文件/etc/grub2.cfg中的第一行一致
➜  grub2-editenv list
saved_entry=0
```

## 5、重启 && 检查

``` zsh
➜  reboot
➜  5.7.6-1.el7.elrepo.x86_64
```

## 6、开启bbr

``` zsh
# 修改内核参数
➜  vim /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 刷新内核参数
➜  sysctl -p

# 验证是否开启bbr
➜  sysctl net.ipv4.tcp_available_congestion_control
net.ipv4.tcp_available_congestion_control = reno cubic bbr
➜  lsmod | grep bbr
tcp_bbr                20480  2
```

> 参考文章:  
> 1、<https://www.cnblogs.com/ding2016/p/10429640.html>
> 2、<https://apad.pro/centos-bbr/>
>