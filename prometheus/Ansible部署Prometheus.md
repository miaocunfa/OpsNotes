---
title: "Ansible部署Prometheus"
date: "2019-11-19"
categories:
    - "技术"
tags:
    - "Ansible"
    - "Prometheus"
    - "监控系统"
toc: false
indent: false
original: true
---

prometheus架构图，讲解

## 一、exporter
exporter讲解
https://prometheus.io/docs/instrumenting/exporters/

### 1.1、node_exporter

#### 1.1.1、ansible 配置 node_exporter节点
``` bash
$ cat /etc/ansible/hosts
[21]
192.168.100.[211:218] ansible_ssh_user='root' ansible_ssh_pass='test123
```

#### 1.1.2、下载 node_exporter
``` bash
# github仓库
https://github.com/prometheus/node_exporter

# 下载
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
```

#### 1.1.3、安装 node_exporter
``` bash
# 将node_exporter拷贝至所有节点的/opt下
$ ansible all -m copy -a "src=/root/node_exporter-0.18.1.linux-amd64.tar.gz dest=/opt/"

# 解压所有节点node_exporter程序包，并启动
$ ansible all -m shell -a "cd /opt; tar -zxvf node_exporter-0.18.1.linux-amd64.tar.gz; cd node_exporter-0.18.1.linux-amd64; nohup ./node_exporter &"
```

### 1.2、redis_exporter

#### 1.2.1、ansible 配置 redis_exporter节点
``` bash
$ cat /etc/ansible/hosts
[redis]
192.168.100.[211:212] ansible_ssh_user='root' ansible_ssh_pass='test123'
```

#### 1.2.2、下载 redis_exporter
``` bash
# github仓库
https://github.com/oliver006/redis_exporter

# 下载
wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.4/redis_exporter-v1.3.4.linux-amd64.tar.gz
```

#### 1.2.3、启动 redis_exporter
``` bash
# 将redis_exporter拷贝至所有节点的/opt下
$ ansible redis -m copy -a "src=/root/redis_exporter-v1.3.4.linux-amd64.tar.gz dest=/opt"

# 解压所有节点redis_exporter程序包，并启动
$ ansible redis -m shell -a "cd /opt; tar -zxvf redis_exporter-v1.3.4.linux-amd64.tar.gz; cd redis_exporter-v1.3.4.linux-amd64; nohup ./redis_exporter &"
```

### 1.3、mysqld_exporter

#### 1.3.1、ansible 配置 mysqld_exporter节点
``` bash
$ cat /etc/ansible/hosts
[mysql]
192.168.100.[212:213] ansible_ssh_user='root' ansible_ssh_pass='test123'
```

#### 1.3.1、下载 mysqld_exporter
``` bash
# github仓库
https://github.com/prometheus/mysqld_exporter

# 下载
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz
```

#### 1.3.2、启动 mysqld_exporter
``` bash
# 将mysqld_exporter拷贝至所有节点的/opt下
$ ansible mysql -m copy -a "src=/root/mysqld_exporter-0.12.1.linux-amd64.tar.gz dest=/opt"

# 解压所有节点mysqld_exporter程序包，并启动
$ ansible mysql -m shell -a "cd /opt; tar -zxvf mysqld_exporter-0.12.1.linux-amd64.tar.gz; cd mysqld_exporter-0.12.1.linux-amd64; nohup ./mysqld_exporter &"
```

### 1.4、elasticsearch_exporter

#### 1.4.1、ansible 配置 elasticsearch_exporter节点
``` bash
$ cat /etc/ansible/hosts
[es]
192.168.100.[211:213] ansible_ssh_user='root' ansible_ssh_pass='test123'
```

#### 1.4.2、下载 elasticsearch_exporter
``` bash
# github仓库
https://github.com/justwatchcom/elasticsearch_exporter

# 下载
wget https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v1.1.0/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz
```

#### 1.4.3、启动 elasticsearch_exporter
```
# 将elasticsearch_exporter拷贝至所有节点的/opt下
$ ansible es -m copy -a "src=/root/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz dest=/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz"

# 解压所有节点elasticsearch_exporter程序包，并启动
$ ansible es -m shell -a "cd /opt; tar -zxvf elasticsearch_exporter-1.1.0.linux-amd64.tar.gz; cd elasticsearch_exporter-1.1.0.linux-amd64; nohup ./elasticsearch_exporter &"
```

## 二、alert_manager

### 2.1、下载 alert_manager
``` bash
# github仓库
https://github.com/prometheus/alertmanager

# 下载
wget https://github.com/prometheus/alertmanager/releases/download/v0.19.0/alertmanager-0.19.0.linux-amd64.tar.gz
```

### 2.2、安装 alert_manager 
将alertmanager部署在/usr/local下
``` bash
$ tar -zxvf alertmanager-0.19.0.linux-amd64.tar.gz -C /usr/local/
```

### 2.3、配置 alert_manager 
``` yaml
$ cd /usr/local/alertmanager-0.19.0.linux-amd64/
$ cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:25'
  smtp_from: 'youremail@163.com'
  smtp_auth_username: 'youremail@163.com'
  smtp_auth_password: '授权码'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: live-monitoring

receivers:
- name: 'live-monitoring'
  email_configs:
  - to: '接收报警信息的邮箱'
```

### 2.4、启动 alert_manager
``` bash
$ nohup ./alertmanager &
```

## 三、prometheus
### 3.1、下载 prometheus
``` bash
# github仓库
https://github.com/prometheus/prometheus

# 下载
wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
```

### 3.2、安装 prometheus
将alertmanager部署在/usr/local下
```
$ tar -zxvf prometheus-2.13.1.linux-amd64.tar.gz -C /usr/local/
```

### 3.3、配置 alertrules.yml
``` yaml
$ cat alertrules.yml 
groups:
- name: example
  rules:
  - alert: "实例丢失"
    expr: up == 0
    for: 1m
    labels:
      severity: page
    annotations:
      summary: "服务器实例 {{ $labels.instance }} 丢失"
      description: "{{ $labels.instance }} 上的任务 {{ $labels.job }} 已经停止1分钟以上了"

  - alert: "磁盘根目录容量小于 20%"
    expr: 100 - ((node_filesystem_avail_bytes{device="/dev/mapper/centos-root",mountpoint="/",fstype=~"ext4|xfs|ext2|ext3"} * 100) / node_filesystem_size_bytes {job="node",mountpoint=~".*",fstype=~"ext4|xfs|ext2|ext3"}) > 80
    for: 30s
    annotations:
      summary: "服务器实例 {{ $labels.instance }} 磁盘根目录不足 告警通知"
      description: "{{ $labels.instance }}磁盘 {{ $labels.device }} 资源 已不足 20%, 当前值: {{ $value }}"
 
  - alert: "磁盘Home目录容量小于 20%"
    expr: 100 - ((node_filesystem_avail_bytes{device="/dev/mapper/centos-home",mountpoint="/home",fstype=~"ext4|xfs|ext2|ext3"} * 100) / node_filesystem_size_bytes {job="node",mountpoint=~".*",fstype=~"ext4|xfs|ext2|ext3"}) > 80
    for: 30s
    annotations:
      summary: "服务器实例 {{ $labels.instance }} 磁盘Home目录不足 告警通知"
      description: "{{ $labels.instance }}磁盘 {{ $labels.device }} 资源 已不足 20%, 当前值: {{ $value }}"

  - alert: "内存容量小于 10%"
    expr: ((node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes) / (node_memory_MemTotal_bytes )) * 100 > 90
    for: 30s
    labels:
      severity: warning
    annotations:
      summary: "服务器实例 {{ $labels.instance }} 内存不足 告警通知"
      description: "{{ $labels.instance }}内存资源已不足 10%,当前值: {{ $value }}"

  - alert: "CPU 平均负载大于 4 个"
    expr: node_load5 > 4
    for: 30s
    annotations:
      sumary: "服务器实例 {{ $labels.instance }} CPU 负载 告警通知"
      description: "{{ $labels.instance }}CPU 平均负载(5 分钟) 已超过 4 ,当前值: {{ $value }}"

  - alert: "CPU 使用率大于 90%"
    expr: 100 - ((avg by (instance,job,env)(irate(node_cpu_seconds_total{mode="idle"}[30s]))) *100) > 90
    for: 30s
    annotations:
      sumary: "服务器实例 {{ $labels.instance }} CPU 使用率 告警通知"
      description: "{{ $labels.instance }}CPU 使用率已超过 90%, 当前值: {{ $value }}"
```

### 3.4、配置 prometheus
``` yaml
$ cat prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      #alertmanager服务端口
      - localhost:9093

#报警规则文件
rule_files:
  - "alertrules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: 
      #prometheus服务端口
      - localhost:9090

  - job_name: 'node'
    static_configs:
      - targets: 
        #监听node_exporter服务
        - 192.168.100.211:10091
        - 192.168.100.212:10091
        - 192.168.100.213:10091
        - 192.168.100.214:10091
        - 192.168.100.215:10091
        - 192.168.100.216:10091
        - 192.168.100.217:10091
        - 192.168.100.218:10091
        - 192.168.100.221:10091
        - 192.168.100.222:10091
        - 192.168.100.223:10091
        - 192.168.100.224:10091
        - 192.168.100.225:10091
        - 192.168.100.226:10091
        - 192.168.100.227:10091
        - 192.168.100.228:10091
        - 192.168.100.231:10091
        - 192.168.100.232:10091
        - 192.168.100.233:10091
        - 192.168.100.235:10091
        - 192.168.100.236:10091
        - 192.168.100.237:10091
        - 192.168.100.238:10091

  - job_name: 'redis'
    static_configs:
      - targets: 
        - 192.168.100.211:9121
        - 192.168.100.212:9121
        labels:
          instance: redis

  - job_name: 'mysql'
    static_configs:
      - targets: 
        - 192.168.100.212:9104
        - 192.168.100.213:9104
        labels:
          instance: mysql

  - job_name: 'es'
    static_configs:
      - targets: 
        - 192.168.100.211:9114
        - 192.168.100.212:9114
        - 192.168.100.213:9114
        labels:
          instance: elasticsearch

  - job_name: 'service_ps'
    static_configs:
      - targets: 
        - 192.168.100.214:9256
        - 192.168.100.215:9256
        - 192.168.100.216:9256
        labels:
          instance: process
```

### 3.5、启动 prometheus
``` bash
$ nohup ./prometheus --storage.tsdb.retention=180d --web.enable-admin-api &
```
启动admin讲解

### 3.6 prometheus API
API讲解
``` bash
$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/clean_tombstones'

$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'

$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.226:9100"}'

$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node"}'
```