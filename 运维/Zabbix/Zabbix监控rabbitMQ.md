---
title: "Zabbix 监控 rabbitMQ"
date: "2021-03-18"
categories:
    - "技术"
tags:
    - "zabbix"
    - "rabbitmq"
    - "中间件监控"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-03-18 | 初稿 |

## 软件版本

| soft          | Version |
| ------------- | ------- |
| zabbix server | 4.0.21  |
| zabbix agent  | 4.0.29  |
| ansible       | 2.9.17  |

## 引言

在`zabbix`上监控`rabbitmq`, 我们使用这个[开源项目](https://github.com/jasonmcintosh/rabbitmq-zabbix)  

其中已经将我们需要的 `监控脚本`、`配置文件`以及`zabbix模板`配置好了，我们只需要按照自己的环境修改一下，导入即可。  

其中`api.py`是基于`python2`环境的  

## 拉取文件

``` zsh
➜  cd /root/ansible
➜  git clone https://github.com/jasonmcintosh/rabbitmq-zabbix.git
```

## 修改文件

### 1、默认参数

在`scripts/rabbitmq`下创建`.rab.auth`文件, 就是跟`api.py`脚本同级目录下

``` zsh
➜  cd /root/ansible/rabbitmq-zabbix/scripts/rabbitmq
➜  vim .rab.auth
USERNAME=admin                                   # rabbit管理界面登录用户名
PASSWORD=admin                                   # rabbit管理界面登录密码
CONF=/etc/zabbix/zabbix_agentd.conf              # zabbix_agentd 配置文件路径
LOGLEVEL=DEBUG                                   # 指定日志级别，如果监控调试OK，可将此值改为INFO
LOGFILE=/var/log/zabbix/rabbitmq_zabbix.log      # 指定日志文件路径
PORT=15672                                       # rabbit管理界面访问端口
```

### 2、修改脚本

修改所有shell脚本
将 `. .rab.auth` 改为 `. ./.rab.auth`

## 推送文件

``` zsh
# 推送文件
➜  ansible mq -m copy -a "src=/root/ansible/rabbitmq-zabbix/scripts/rabbitmq/ dest=/etc/zabbix/scripts/rabbitmq/"
➜  ansible mq -m copy -a "src=/root/ansible/rabbitmq-zabbix/zabbix_agentd.d/zabbix-rabbitmq.conf dest=/etc/zabbix/zabbix_agentd.d/"

# 修改权限
➜  ansible mq -m shell -a "cd /etc/zabbix/scripts/rabbitmq/; chown -R zabbix:zabbix ./*; chmod u+x ./*"

# 重启agent
➜  ansible mq -m shell -a "systemctl restart zabbix-agent"
```

## 导入模板

将根目录下的 `rabbitmq.template.xml` 文件导入 `zabbix server`  
导入的模板名为 `Template App RabbitMQ v3`

修改客户端类型为 'Zabbix 客户端(主动式)' --> 'Zabbix 客户端'

> 参考文档：  
> [1] [github - rabbitmq-zabbix](https://github.com/jasonmcintosh/rabbitmq-zabbix)  
> [2] [使用Zabbix监控RabbitMQ消息队列](https://www.cnblogs.com/minseo/p/10309121.html)  
>