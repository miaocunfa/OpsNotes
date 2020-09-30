---
title: "iterm2 之免密码登录"
date: "2020-09-28"
categories:
    - "技术"
tags:
    - "iterm2"
toc: false
original: true
---

## 更新记录

| 时间       | 内容           |
| ---------- | -------------- |
| 2020-09-28 | 初稿           |
| 2020-09-29 | 增加触发器部分 |
| 2020-09-30 | 触发器部分完成 |

## 一、使用脚本

### 1.1、登录脚本

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

登录脚本中有四个参数:  
$argv 0 端口  
$argv 1 用户名  
$argv 2 地址  
$argv 3 密码  

### 1.2、iterm2配置

General --> Basics  
Name: 填写便于记忆的名称  

General --> Command  
选择 Login shell  
Send text at start: `/usr/local/bin/iterm2-login.exp 22 root 192.168.100.223 'test123'`

![iterm2配置](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm2_20200928_01.png)

### 1.3、iterm2验证

启动iterm2 在菜单栏中选择 'Profiles' --> 标签'test' --> 名称'n223' 登录主机

![iterm2验证](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm2_20200928_02.png)

我们可以看到脚本已经生效，不需要再输入密码了。

## 二、使用触发器

profile - 通用部分
![profile - 通用部分](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm_20200929_04.png)

profile - 触发器配置
![profile - 触发器配置](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm_20200929_03.png)

登录验证
![登录验证](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm_20200929_05.png)

我们看到使用触发器已经成功登录了，但是有一个问题是，当你在命令行中也输入 `password` 的时候，会直接触发 触发器，在 `password` 字符串后追加密码 `test123`

> 参考文档：  
> 1、[mac iterm2配置账号密码](https://blog.csdn.net/huangcl_0416/article/details/89511273)  
> 2、[iterm2利用trigger自动登录服务器](https://zhuanlan.zhihu.com/p/69379306)  
>