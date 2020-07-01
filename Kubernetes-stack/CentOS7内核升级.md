---
title: "CentOS7 升级内核 (3.10.0 --> 5.7.6)"
date: "2020-06-12"
categories:
    - "技术"
tags:
    - "shell"
    - "python"
toc: false
indent: false
original: true
---

``` zsh
➜  uname -r
3.10.0-957.el7.x86_64

➜  yum list kernel
Loaded plugins: fastestmirror, langpacks, priorities
Loading mirror speeds from cached hostfile
8 packages excluded due to repository priority protections
Installed Packages
kernel.x86_64                                                                       3.10.0-957.el7                                                                             @anaconda
Available Packages
kernel.x86_64                                                                       3.10.0-1127.13.1.el7                                                                       aliyun-updates

➜  rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

➜  rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

➜  yum --disablerepo=\* --enablerepo=elrepo-kernel repolist

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

➜  yum --disablerepo=\* --enablerepo=elrepo-kernel install  kernel-ml.x86_64  -y

➜  yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64  -y

➜  yum --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml-tools.x86_64  -y

➜  awk -F \' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
2 : CentOS Linux (0-rescue-f3296d4df760440c9ddd35b809fb282a) 7 (Core)

➜  grep "^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2
CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)
CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
CentOS Linux (0-rescue-f3296d4df760440c9ddd35b809fb282a) 7 (Core)

➜  grub2-editenv list
saved_entry=CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)

➜  grub2-set-default 'CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)'
➜  grub2-editenv list
saved_entry=CentOS Linux (5.7.6-1.el7.elrepo.x86_64) 7 (Core)

➜  reboot
```
