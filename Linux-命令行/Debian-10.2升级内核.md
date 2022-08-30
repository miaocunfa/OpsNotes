---
title: "Debian-10.2 升级内核"
date: "2021-03-25"
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

## 引言

目前 Debian 10 自带的内核版本为 4.19，以下方法同时也适用于未来以及先前的 Debian 版本，步骤一致，唯一的区别是将文中的 **buster**-backports 中的系统版本号 buster 更换为你正在使用的系统的版本号。

首先来到 [Debian Backports](https://backports.debian.org/) 网站查询当前版本是否已经提供 Backports 支持， 这个反向移植是从下一个Debian发行版（称为“测试”）中获取的软件包，它们经过调整和重新编译后可以在Debian稳定版中使用。

也可以访问 [Debian Package List](https://packages.debian.org/en/buster-backports/) 选择 buster-backports 查看可用的软件包列表。
如果要升级内核，可以在 Debian Package List 页面找到 [Kernel](https://packages.debian.org/en/buster-backports/kernel/) 分类并进入对应的页面，并使用浏览器搜索 linux-image 来查看可用的内核版本。

但是要注意，linux-image-5.2.0-0.bpo.2-amd64 这种并不是我们想要安装的软件包，如果安装了这种特定版本的软件包会导致未来 Backports 中有新版本发布时系统仍然停留在已安装的特定版本内核，不会自动更新。

## 安装与卸载

不过仍然有一点要注意，直接使用 apt install 上面提到的软件包名并不能直接安装 Backports 内核，因为同样的软件包名也存在于我们当前运行的版本的软件源中，且当前版本的软件源不能被移除 --- 不然你就没有办法安装大部分软件了

编辑 /etc/apt/sources.list 加入以下内容:

``` zsh
➜  vim /etc/apt/sources.list
deb https://deb.debian.org/debian buster-backports main
➜  apt-get update
```

执行 apt update 更新软件列表，然后执行以下命令进行安装：

``` zsh
➜  sudo apt install -t buster-backports linux-image-cloud-amd64 linux-headers-cloud-amd64
```

> 注意：如果你使用的不是 buster，而是更早的 stretch 或是未来的版本，请替换 buster 为你的版本代号。当然，也不要忘了替换包名...

安装成功后重启即默认使用最新版本内核，如有疑问可以运行 uname -r 再次确认正在运行的系统内核版本。

> 注意: 如果安装了新的内核导致设备无法启动，在重新启动时的 GRUB 菜单中选择旧版内核启动并执行 sudo apt purge -t buster-backports linux-image-cloud-amd64 linux-headers-cloud-amd64即可卸载 Backports 内核。

> 参考文档:  
> [1] [为Debian 10升级Linux Kernel 5.x](https://async.sh/2019/09/25/upgrade-linux-kernel-5-for-debian-buster/)  
> [2] [Debian Backports](https://backports.debian.org/)  
>