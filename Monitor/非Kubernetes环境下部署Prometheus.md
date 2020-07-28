---
title: "非Kubernetes环境下部署Prometheus"
date: "2019-11-19"
categories:
    - "技术"
tags:
    - "Ansible"
    - "Prometheus"
    - "指标监控"
toc: false
indent: false
original: true
---

## 更新记录

| 时间       | 内容                                                                                     |
| ---------- | ---------------------------------------------------------------------------------------- |
| 2019-09-19 | 初稿                                                                                     |
| 2020-07-28 | 1、增加 Postgre_exporter</br>2、增加文末引用链接</br>3、修改文档结构</br>4、修改部署目录 |

prometheus架构图，讲解

## 一、exporter - 指标收集器

[exporter列表](https://prometheus.io/docs/instrumenting/exporters/)

### 1.1、ansible hosts

``` zsh
➜  vim /etc/ansible/hosts
[21]
192.168.100.[211:219] ansible_ssh_user='root' ansible_ssh_pass='test123'

[22]
192.168.100.[221:229] ansible_ssh_user='root' ansible_ssh_pass='test123'

[23]
192.168.100.[221:229] ansible_ssh_user='root' ansible_ssh_pass='test123'

[redis]
192.168.100.[211:212] ansible_ssh_user='root' ansible_ssh_pass='test123'

[mysql]
192.168.100.[212:213] ansible_ssh_user='root' ansible_ssh_pass='test123'

[es]
192.168.100.[211:213] ansible_ssh_user='root' ansible_ssh_pass='test123'

[pg]
192.168.100.[211:213] ansible_ssh_user='root' ansible_ssh_pass='test123'
```

### 1.2、node_exporter

``` zsh
# github仓库
# https://github.com/prometheus/node_exporter

# 下载
➜  wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz


# 安装 && 使用
# 将 node_exporter 拷贝至所有节点的 /opt 下
➜  ansible all -m copy -a "src=/root/ansible/node_exporter-0.18.1.linux-amd64.tar.gz dest=/opt/"

# 解压所有节点node_exporter程序包，并启动
➜  ansible all -m shell -a "cd /opt; tar -zxvf node_exporter-0.18.1.linux-amd64.tar.gz; cd node_exporter-0.18.1.linux-amd64; nohup ./node_exporter --web.listen-address=':10091' &"
```

### 1.3、redis_exporter

``` zsh
# github仓库
# https://github.com/oliver006/redis_exporter

# 下载
➜  wget https://github.com/oliver006/redis_exporter/releases/download/v1.3.4/redis_exporter-v1.3.4.linux-amd64.tar.gz


# 安装 && 使用
# 将 redis_exporter 拷贝至所有 redis节点的 /opt 下
➜  ansible redis -m copy -a "src=/root/redis_exporter-v1.3.4.linux-amd64.tar.gz dest=/opt"

# 解压所有节点 redis_exporter程序包，并启动
➜  ansible redis -m shell -a "cd /opt; tar -zxvf redis_exporter-v1.3.4.linux-amd64.tar.gz; cd redis_exporter-v1.3.4.linux-amd64; nohup ./redis_exporter &"
```

### 1.4、mysqld_exporter

``` zsh
# github仓库
# https://github.com/prometheus/mysqld_exporter

# 下载
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz


# 安装 && 使用
# 将 mysqld_exporter 拷贝至所有 mysql节点的 /opt下
➜  ansible mysql -m copy -a "src=/root/mysqld_exporter-0.12.1.linux-amd64.tar.gz dest=/opt"

# 解压所有节点 mysqld_exporter程序包，并启动
➜  ansible mysql -m shell -a "cd /opt; tar -zxvf mysqld_exporter-0.12.1.linux-amd64.tar.gz; cd mysqld_exporter-0.12.1.linux-amd64; nohup ./mysqld_exporter &"
```

### 1.5、elasticsearch_exporter

``` zsh
# github仓库
# https://github.com/justwatchcom/elasticsearch_exporter

# 下载
wget https://github.com/justwatchcom/elasticsearch_exporter/releases/download/v1.1.0/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz


# 安装 && 使用
# 将 elasticsearch_exporter 拷贝至所有 es节点的 /opt下
➜  ansible es -m copy -a "src=/root/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz dest=/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz"

# 解压所有节点 elasticsearch_exporter程序包，并启动
➜  ansible es -m shell -a "cd /opt; tar -zxvf elasticsearch_exporter-1.1.0.linux-amd64.tar.gz; cd elasticsearch_exporter-1.1.0.linux-amd64; nohup ./elasticsearch_exporter &"
```

### 1.6、postgres_exporter

``` zsh
# github仓库
# https://github.com/wrouesnel/postgres_exporter

# 下载
➜  wget https://github.com/wrouesnel/postgres_exporter/releases/download/v0.8.0/postgres_exporter_v0.8.0_linux-amd64.tar.gz


# 安装 && 使用
# 将 postgres_exporter 拷贝至所有 pg节点的 /opt下
➜  ansible pg -m copy -a "src=/root/ansible/postgres_exporter_v0.8.0_linux-amd64.tar.gz dest=/opt/postgres_exporter_v0.8.0_linux-amd64.tar.gz"

# 需要在每个节点配置 postgre 连接串
➜  vim /etc/profile
export DATA_SOURCE_USER="postgres"
export DATA_SOURCE_PASS="test%123"
export DATA_SOURCE_URI="192.168.100.243:9999?sslmode=disable"
➜  su - postgres
➜  ./postgres_exporter

# 解压所有节点 postgres_exporter程序包，并启动
➜  ansible pg -m shell -a "cd /opt; tar -zxvf postgres_exporter_v0.8.0_linux-amd64.tar.gz; cd postgres_exporter_v0.8.0_linux-amd64; nohup ./postgres_exporter &"
```

## 二、alert_manager - 告警管理

### 2.1、下载 alert_manager

``` zsh
# github仓库
# https://github.com/prometheus/alertmanager

# 下载
➜  wget https://github.com/prometheus/alertmanager/releases/download/v0.19.0/alertmanager-0.19.0.linux-amd64.tar.gz
➜  tar -zxvf alertmanager-0.19.0.linux-amd64.tar.gz -C /usr/local/
```

### 2.2、配置 alert_manager

``` yaml
➜  cd /usr/local/alertmanager-0.19.0.linux-amd64/
➜  cat alertmanager.yml
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

### 2.3、启动 alert_manager

``` zsh
➜  nohup ./alertmanager &
```

## 三、prometheus

### 3.1、下载 prometheus

``` zsh
# github仓库
# https://github.com/prometheus/prometheus

# 下载
➜  wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
➜  tar -zxvf prometheus-2.13.1.linux-amd64.tar.gz -C /usr/local/
```

### 3.2、配置 alertrules.yml

alertrules配置告警规则

``` yaml
➜  cat alertrules.yml
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

### 3.3、配置 prometheus

``` yaml
➜  cat prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # alertmanager 服务端口
      - localhost:9093

# 报警规则文件
rule_files:
  - "alertrules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets:
      # prometheus 服务端口
      - localhost:9090

  - job_name: 'node-21x'
    static_configs:
      - targets:
        # 监听 node_exporter 服务
        - 192.168.100.211:10091
        - 192.168.100.212:10091
        - 192.168.100.213:10091
        - 192.168.100.214:10091
        - 192.168.100.215:10091
        - 192.168.100.216:10091
        - 192.168.100.217:10091
        - 192.168.100.218:10091
        - 192.168.100.219:10091
        labels:
          instance: node-21x

  - job_name: 'node-22x'
    static_configs:
      - targets:
        - 192.168.100.221:10091
        - 192.168.100.222:10091
        - 192.168.100.223:10091
        - 192.168.100.224:10091
        - 192.168.100.225:10091
        - 192.168.100.226:10091
        - 192.168.100.227:10091
        - 192.168.100.228:10091
        - 192.168.100.229:10091
        labels:
          instance: node-22x

  - job_name: 'node-23x'
    static_configs:
      - targets:
        - 192.168.100.231:10091
        - 192.168.100.232:10091
        - 192.168.100.233:10091
        - 192.168.100.234:10091
        - 192.168.100.235:10091
        - 192.168.100.236:10091
        - 192.168.100.237:10091
        - 192.168.100.238:10091
        - 192.168.100.239:10091
        labels:
          instance: node-23x

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

  - job_name: 'postgre'
    static_configs:
      - targets:
        - 192.168.100.211:9187
        - 192.168.100.212:9187
        - 192.168.100.213:9187
        labels:
          instance: postgre
```

### 3.4、启动 prometheus

``` zsh
➜  nohup ./prometheus --storage.tsdb.retention=180d --web.enable-admin-api &
```

启动admin讲解

### 3.5 prometheus API

API讲解

``` zsh
➜  curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/clean_tombstones'

➜  curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'

➜  curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.226:9100"}'

➜  curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node"}'
```

## 四、日常运维

``` zsh
➜  cd /opt/prometheus-2.13.1.linux-amd64

# 清理数据
➜  rm -rf ./data
```

> 参考链接：  
> 1、[exporter 列表](https://prometheus.io/docs/instrumenting/exporters/)  
> 2、[node_exporter 地址](https://github.com/prometheus/node_exporter)  
> 3、[redis_exporter 地址](https://github.com/oliver006/redis_exporter)  
> 4、[mysqld_exporter 地址](https://github.com/prometheus/mysqld_exporter)  
> 5、[elasticsearch_exporter 地址](https://github.com/justwatchcom/elasticsearch_exporter)  
> 6、[postgres_exporter 地址](https://github.com/wrouesnel/postgres_exporter)  
> 7、[alertmanager 地址](https://github.com/prometheus/alertmanager)  
> 8、[prometheus 地址](https://github.com/prometheus/prometheus)  
>