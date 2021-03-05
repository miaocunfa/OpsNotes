---
title: "非Kubernetes环境下部署Loki"
date: "2020-07-20"
categories:
    - "技术"
tags:
    - "Loki"
    - "日志监控"
toc: false
indent: false
original: true
draft: false
---

## 环境规划

| Server   | Node                                                                                |
| -------- | ----------------------------------------------------------------------------------- |
| loki     | 192.168.100.235                                                                     |
| promtail | 192.168.100.222（2.0）</br>192.168.100.223（3.0）</br>192.168.100.231（3.0 - 压测） |
| grafana  | 192.168.100.233                                                                     |

## 一、准备安装包

### 1.1、直接下载

``` zsh
# 下载程序包
➜  curl -O -L https://github.com/grafana/loki/releases/download/v1.5.0/promtail-linux-amd64.zip
➜  curl -O -L https://github.com/grafana/loki/releases/download/v1.5.0/loki-linux-amd64.zip

# n231 - promtail
➜  mkdir -p /opt/promtail
➜  mkdir -p /ahdata/promtail

# n235 - loki
➜  mkdir -p /opt/loki
➜  mkdir -p /ahdata/loki

# 拷贝程序包至指定主机
➜  scp loki-linux-amd64.zip n235:/opt/loki
➜  scp promtail-linux-amd64.zip n231:/opt/promtail

# 解压程序包
# n235
➜  cd /opt/loki; unzip loki-linux-amd64.zip
# n231
➜  cd /opt/promtail; unzip promtail-linux-amd64.zip
```

### 1.2、编译安装

#### 1.2.1、Golang 环境

需要 Golang v1.10+ 以上的环境

#### 1.2.2、编译loki

``` zsh
➜  go get github.com/grafana/loki
➜  cd $GOPATH/src/github.com/grafana/loki # GOPATH is $HOME/go by default.

➜  go build ./cmd/loki
# 编译出可执行文件loki
➜  ll
-rwxr-xr-x.  1 root root  87M Jul 21 14:02 loki
```

#### 1.2.3、编译promtail

``` zsh
➜  go build ./cmd/promtail
```

## 二、配置文件

### 2.1、loki

``` yaml
# n235
➜  vim /opt/loki/loki-local-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s
  max_transfer_retries: 0

schema_config:
  configs:
    - from: 2018-04-15
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /ahdata/loki/index

  filesystem:
    directory: /ahdata/loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
```

### 2.2、promtail

``` yaml
# n231
➜  vim /opt/promtail/promtail-local-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /ahdata/promtail/positions.yaml

clients:
  - url: http://192.168.100.235:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs  
      __path__: /var/log/*log

- job_name: ahxx
  static_configs:
  - targets:
      - localhost
    labels:
      job: infologs
      host: n231
      __path__: /opt/aihangxunxi/logs/*.log
```

## 三、启动

``` zsh
# n235
➜  nohup ./loki-linux-amd64 -config.file=./loki-local-config.yaml &

# n231
➜  nohup ./promtail-linux-amd64 -config.file=./promtail-local-config.yaml &
```

## 四、grafana

由于我们已经装过grafana，在 [官网](https://grafana.com/grafana/download) 找到最新的安装包升级即可

### 4.1、下载安装包

``` zsh
➜  wget -b https://dl.grafana.com/oss/release/grafana-7.1.0-1.x86_64.rpm
```

### 4.2、升级

``` zsh
➜  yum upgrade grafana-7.1.0-1.x86_64.rpm -y

➜  rpm -ql grafana.x86_64
/etc/grafana
/etc/init.d/grafana-server
/etc/sysconfig/grafana-server
/usr/lib/systemd/system/grafana-server.service
/usr/sbin/grafana-cli
/usr/sbin/grafana-server
```

### 4.3、启动

``` zsh
➜  systemctl start grafana-server
```

## 五、使用

### 5.1、配置data source

在grafana中添加Loki数据源

![图床配置04](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/loki_not_k8s_20200722_04.png)

### 5.2、日志查询

![loki使用](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/loki_not_k8s_20200722_05.png)
![日志查询](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/loki_20200723_03.png)

### 5.3、日志过滤

日志过滤语法，更多详细内容请查看 [LogQL](https://github.com/grafana/loki/blob/master/docs/logql.md#filter-expression)

``` zsh
|=: Log line contains string.
!=: Log line does not contain string.
|~: Log line matches regular expression.
!~: Log line does not match regular expression.
```

使用示例

![日志过滤](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/loki_20200723_04.png)

### 5.4、journal

添加查询系统日志

``` yaml
# promtail 配置文件
➜  vim /opt/promtail/promtail-local-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /ahdata/promtail/positions.yaml

clients:
  - url: http://192.168.100.235:3100/loki/api/v1/push

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs  
      __path__: /var/log/*log

- job_name: ahxx
  static_configs:
  - targets:
      - localhost
    labels:
      job: ahxx-3.0-logs
      host: n231
      __path__: /opt/aihangxunxi/logs/*.log

- job_name: journal
  journal:
    max_age: 12h
    labels:
      job: systemd-journal
  relabel_configs:
    - source_labels: ['__journal__systemd_unit']
      target_label: 'unit'
```

增加了后journal，查看日志

![journal](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/loki_20200723_05.png)

> 参考链接：  
> 1、[loki github](https://github.com/grafana/loki)  
> 2、[loki LogQL](https://github.com/grafana/loki/blob/master/docs/logql.md#filter-expression)  
> 3、[promtail config](https://github.com/grafana/loki/blob/v1.5.0/docs/clients/promtail/configuration.md)  
>