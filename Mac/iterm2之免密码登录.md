---
title: "iterm2之免密码登录"
date: "2020-09-28"
categories:
    - "技术"
tags:
    - "iterm2"
toc: false
original: true
---

## 一、登录脚本

``` zsh
➜  cd /usr/local/bin
➜  vim iterm2-login.exp
#!/usr/bin/expect

set timeout 30
spawn ssh -p [lindex $argv 0] [lindex $argv 1]@[lindex $argv 2]
expect {
       "(yes/no)?"
       {send "yes\n";exp_continue}
       "password:"
       {send "[lindex $argv 3]\n"}
}
interact

➜  chmod u+x iterm2-login.exp
```

登录脚本中有四个参数：  
$argv 0 端口  
$argv 1 用户名  
$argv 2 地址  
$argv 3 密码  

## 二、iterm2配置

General --> Basics  
Name: 填写便于记忆的名称  

General --> Command  
选择 Login shell  
Send text at start: `/usr/local/bin/iterm2-login.exp 22 root 192.168.100.223 'test123'`

![iterm2配置](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm2_20200928_01.png)

## 三、iterm2验证

启动iterm2 在菜单栏中选择 'Profiles' --> 标签'test' --> 名称'n223' 登录主机

![iterm2验证](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm2_20200928_02.png)

我们可以看到脚本已经生效，不需要再输入密码了。

> 参考链接：  
> 1、[mac iterm2配置账号密码](https://blog.csdn.net/huangcl_0416/article/details/89511273)