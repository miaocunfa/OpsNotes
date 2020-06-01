---
title: "Gitlab版本升级"
date: "2020-06-01"
categories:
    - "技术"
tags:
    - "Gitlab"
    - "版本升级"
toc: false
indent: false
original: true
---

## 一、环境

根据需求，需要将gitlab的版本进行升级

``` zsh
    11.11.3  -->  13.0.3
```

## 二、升级

由于版本跨度比较大，所以要逐步升级版本，确保每一次升级没有问题后，再进行下一个版本的升级

``` zsh
    11.11.3  -->  12.0.9  --> 12.10.8  -->  13.0.3
```

### 2.1、下载rpm包

``` zsh
# 下载安装包
➜  cd ~
➜  wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-12.0.9-ce.0.el7.x86_64.rpm
➜  wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
➜  wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-13.0.3-ce.0.el7.x86_64.rpm
```

### 2.2、版本升级

```zsh
# 使用rpm -Uvh, 每次升级检查成功后再升下一个版本
➜  rpm -Uvh gitlab-ce-12.0.9-ce.0.el7.x86_64.rpm
➜  rpm -Uvh gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
➜  rpm -Uvh gitlab-ce-13.0.3-ce.0.el7.x86_64.rpm
```

## 三、错误

### 3.1、版本升级跨度较大

``` zsh
# 安装13.0.3报错
➜  rpm -Uvh gitlab-ce-13.0.3-ce.0.el7.x86_64.rpm
warning: gitlab-ce-13.0.3-ce.0.el7.x86_64.rpm: Header V4 RSA/SHA1 Signature, key ID f27eab47: NOKEY
Preparing...                          ################################# [100%]
gitlab preinstall: It seems you are upgrading from major version 11 to major version 13.
gitlab preinstall: It is required to upgrade to the latest 12.10.x version first before proceeding.    # 提示先升级到 12.10.x
gitlab preinstall: Please follow the upgrade documentation at https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations
error: %pre(gitlab-ce-13.0.3-ce.0.el7.x86_64) scriptlet failed, exit status 1
error: gitlab-ce-13.0.3-ce.0.el7.x86_64: install failed
error: gitlab-ce-11.11.3-ce.0.el7.x86_64: erase skipped
```

#### 错误解决

``` zsh
# 下载12.10.8
➜  wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
# 安装12.10.8报错
➜  rpm -Uvh gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
warning: gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm: Header V4 RSA/SHA1 Signature, key ID f27eab47: NOKEY
Preparing...                          ################################# [100%]
gitlab preinstall: It seems you are upgrading from major version 11 to major version 12.
gitlab preinstall: It is required to upgrade to the latest 12.0.x version first before proceeding.    # 提示先升级到 12.0.x
gitlab preinstall: Please follow the upgrade documentation at https://docs.gitlab.com/ee/policy/maintenance.html#upgrade-recommendations
error: %pre(gitlab-ce-12.10.8-ce.0.el7.x86_64) scriptlet failed, exit status 1
error: gitlab-ce-12.10.8-ce.0.el7.x86_64: install failed
error: gitlab-ce-11.11.3-ce.0.el7.x86_64: erase skipped

# 升级顺序为
    11.11.3  -->  12.0.9  --> 12.10.8  -->  13.0.3
```

### 3.2、reconfigure错误

``` zsh
# 安装12.0.9
➜  rpm -Uvh gitlab-ce-12.0.9-ce.0.el7.x86_64.rpm
There was an error running gitlab-ctl reconfigure:

service[grafana] (dynamically defined) had an error: Mixlib::ShellOut::ShellCommandFailed: Expected process to exit with [0], but received '1'
---- Begin output of /opt/gitlab/embedded/bin/chpst -u root:root /opt/gitlab/embedded/bin/sv restart /opt/gitlab/service/grafana ----
STDOUT: timeout: run: /opt/gitlab/service/grafana: (pid 176262) 49s, got TERM
STDERR:
---- End output of /opt/gitlab/embedded/bin/chpst -u root:root /opt/gitlab/embedded/bin/sv restart /opt/gitlab/service/grafana ----
Ran /opt/gitlab/embedded/bin/chpst -u root:root /opt/gitlab/embedded/bin/sv restart /opt/gitlab/service/grafana returned 1

Running handlers complete
Chef Client failed. 80 resources updated in 04 minutes 37 seconds
Ensuring PostgreSQL is updated:Traceback (most recent call last):
    8: from /opt/gitlab/embedded/bin/omnibus-ctl:23:in `<main>'
    7: from /opt/gitlab/embedded/bin/omnibus-ctl:23:in `load'
    6: from /opt/gitlab/embedded/lib/ruby/gems/2.6.0/gems/omnibus-ctl-0.6.0/bin/omnibus-ctl:31:in `<top (required)>'
    5: from /opt/gitlab/embedded/lib/ruby/gems/2.6.0/gems/omnibus-ctl-0.6.0/lib/omnibus-ctl.rb:746:in `run'
    4: from /opt/gitlab/embedded/lib/ruby/gems/2.6.0/gems/omnibus-ctl-0.6.0/lib/omnibus-ctl.rb:204:in `block in add_command_under_category'
    3: from /opt/gitlab/embedded/service/omnibus-ctl/pg-upgrade.rb:64:in `block in load_file'
    2: from /opt/gitlab/embedded/service/omnibus-ctl/lib/gitlab_ctl/util.rb:105:in `roles'
    1: from /opt/gitlab/embedded/service/omnibus-ctl/lib/gitlab_ctl/util.rb:64:in `get_node_attributes'
/opt/gitlab/embedded/service/omnibus-ctl/lib/gitlab_ctl/util.rb:52:in `parse_json_file': Attributes not found in /opt/gitlab/embedded/nodes/n238.json, has reconfigure been run yet? (GitlabCtl::Errors::NodeError)
Ensuring PostgreSQL is updated: NOT OK
Error ensuring PostgreSQL is updated. Please check the logs
warning: %posttrans(gitlab-ce-12.0.9-ce.0.el7.x86_64) scriptlet failed, exit status 1

# reconfigure报错
➜  rpm -Uvh gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
warning: gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm: Header V4 RSA/SHA1 Signature, key ID f27eab47: NOKEY
Preparing...                          ################################# [100%]
Malformed configuration JSON file found at /opt/gitlab/embedded/nodes/n238.json.
This usually happens when your last run of `gitlab-ctl reconfigure` didn't complete successfully.
This file is used to check if any of the unsupported configurations are enabled,
and hence require a working reconfigure before upgrading.
Please run `sudo gitlab-ctl reconfigure` to fix it and try again.    # 提示使用命令修复
error: %pre(gitlab-ce-12.10.8-ce.0.el7.x86_64) scriptlet failed, exit status 1
error: gitlab-ce-12.10.8-ce.0.el7.x86_64: install failed
error: gitlab-ce-12.0.9-ce.0.el7.x86_64: erase skipped
```

#### 错误解决

``` zsh
# gitlab reconfigure
➜  sudo gitlab-ctl reconfigure
# 再升级，成功
➜  rpm -Uvh gitlab-ce-12.10.8-ce.0.el7.x86_64.rpm
```
