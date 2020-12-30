---
title: "redis-dump操作"
date: "2020-12-09 "
categories:
    - "技术"
tags:
    - "Redis"
toc: false
original: true
---

## 一、安装

### 1.1、环境

``` zsh
➜  yum install ruby rubygems ruby-devel -y
```

### 1.2、更改源

``` zsh
# 查看默认源
➜  gem sources -l
*** CURRENT SOURCES ***

https://rubygems.org/

# 添加国内源 && 移除默认源
➜  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
https://gems.ruby-china.com/ added to sources
https://rubygems.org/ removed from sources

➜  gem sources -l
*** CURRENT SOURCES ***

https://gems.ruby-china.com/ # 确保只有这一个源
```

### 1.3、安装 redis-dump

``` zsh
➜  gem install redis-dump -V
```

### 1.4、版本信息

``` zsh
➜  redis-dump --version
redis-dump v0.4.0
```

## 二、导出、导入

### 2.1、导出

``` zsh
➜  redis-dump -u DB1:6379 -d 2 > ~/redis-dump-2.json
```

### 2.2、导入

``` zsh
# 修改库
➜  vim redis-dump-2.json
%s@"db":2,@"db":13,@g

# 使用 sed
➜  cat redis-dump-2.json | sed 's@"db":2,@"db":13,@g' > 13

➜  cat redis-dump-2.json | redis-load -u DB1:6379
```

## 三、错误

### 3.1、gem源

``` zsh
➜  gem sources -a http://ruby.taobao.org
Error fetching http://ruby.taobao.org:
    server did not return a valid file (http://ruby.taobao.org/specs.4.8.gz)

➜  gem sources --add http://gems.ruby-china.org/ --remove http://rubygems.org
Error fetching http://gems.ruby-china.org/:
    bad response Not Found 404 (http://gems.ruby-china.org/specs.4.8.gz)
```

#### 3.1.1、解决办法

``` zsh
➜  gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
```

### 3.2、Ruby版本

``` zsh
➜  gem install redis-dump -V
ERROR:  Error installing redis-dump:
    redis requires Ruby version >= 2.2.2.
```

#### 3.2.1、解决办法

1、安装rvm

``` zsh
➜  curl -L get.rvm.io | bash -s stable
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   194  100   194    0     0    200      0 --:--:-- --:--:-- --:--:--   200
curl: (7) Failed connect to raw.githubusercontent.com:443; Connection refused

# 打开 https://site.ip138.com/raw.Githubusercontent.com/ 网址
# 修改 hosts文件
➜  vim /etc/hosts
151.101.108.133 raw.githubusercontent.com

➜  curl -L get.rvm.io | bash -s stable
Downloading https://github.com/rvm/rvm/archive/1.29.10.tar.gz
Downloading https://github.com/rvm/rvm/releases/download/1.29.10/1.29.10.tar.gz.asc
gpg: directory `/root/.gnupg' created
gpg: new configuration file `/root/.gnupg/gpg.conf' created
gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run
gpg: keyring `/root/.gnupg/pubring.gpg' created
gpg: Signature made Thu 26 Mar 2020 05:58:42 AM CST using RSA key ID 39499BDB
gpg: Can't check signature: No public key
GPG signature verification failed for '/usr/local/rvm/archives/rvm-1.29.10.tgz' - 'https://github.com/rvm/rvm/releases/download/1.29.10/1.29.10.tar.gz.asc'! Try to install GPG v2 and then fetch the public key:

    gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

or if it fails:

    command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -

In case of further problems with validation please refer to https://rvm.io/rvm/security

➜  gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
➜  curl -L get.rvm.io | bash -s stable
Downloading https://github.com/rvm/rvm/archive/1.29.10.tar.gz
Downloading https://github.com/rvm/rvm/releases/download/1.29.10/1.29.10.tar.gz.asc
gpg: Signature made Thu 26 Mar 2020 05:58:42 AM CST using RSA key ID 39499BDB
gpg: Good signature from "Piotr Kuczynski <piotr.kuczynski@gmail.com>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 7D2B AF1C F37B 13E2 069D  6956 105B D0E7 3949 9BDB
GPG verified '/usr/local/rvm/archives/rvm-1.29.10.tgz'
Creating group 'rvm'
Installing RVM to /usr/local/rvm/
Installation of RVM in /usr/local/rvm/ is almost complete:

  * First you need to add all users that will be using rvm to 'rvm' group,
    and logout - login again, anyone using rvm will be operating with `umask u=rwx,g=rwx,o=rx`.

  * To start using RVM you need to run `source /etc/profile.d/rvm.sh`
    in all your open shell windows, in rare cases you need to reopen all shell windows.
  * Please do NOT forget to add your users to the rvm group.
     The installer no longer auto-adds root or users to the rvm group. Admins must do this.
     Also, please note that group memberships are ONLY evaluated at login time.
     This means that users must log out then back in before group membership takes effect!
Thanks for installing RVM 
Please consider donating to our open collective to help us maintain RVM.

  Donate: https://opencollective.com/rvm/donate
```

2、加载程序

``` zsh
➜  source /usr/local/rvm/scripts/rvm
```

3、列出常用版本

``` zsh
➜  rvm list known
# MRI Rubies
[ruby-]1.8.6[-p420]
[ruby-]1.8.7[-head] # security released on head
[ruby-]1.9.1[-p431]
[ruby-]1.9.2[-p330]
[ruby-]1.9.3[-p551]
[ruby-]2.0.0[-p648]
[ruby-]2.1[.10]
[ruby-]2.2[.10]
[ruby-]2.3[.8]
[ruby-]2.4[.9]
[ruby-]2.5[.7]
[ruby-]2.6[.5]
[ruby-]2.7[.0]
```

4、安装一个ruby版本

``` zsh
➜  rvm install 2.7.0
```

5、使用一个ruby版本

``` zsh
➜  rvm use 2.7.0
Using /usr/local/rvm/gems/ruby-2.7.0
```

6、设置默认版本

``` zsh
➜  rvm use 2.7.0 --default
Using /usr/local/rvm/gems/ruby-2.7.0
```

7、查看ruby版本

``` zsh
➜  ruby --version
ruby 2.7.0p0 (2019-12-25 revision 647ee6f091) [x86_64-linux]
```

> 参考文档：
> 1、[几种redis数据导出导入方式](https://www.cnblogs.com/hjfeng1988/p/7146009.html)  
> 2、[redis requires ruby version 2.2.2的解决方案](https://www.cnblogs.com/PatrickLiu/p/8454579.html)  
>