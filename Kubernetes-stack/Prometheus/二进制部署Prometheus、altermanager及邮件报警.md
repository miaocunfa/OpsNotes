# 二进制部署 Prometheus、altermanager及邮件报警

## 一、源码下载
``` bash
# 下载二进制安装包
wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
wget https://github.com/prometheus/alertmanager/releases/download/v0.19.0/alertmanager-0.19.0.linux-amd64.tar.gz
```


## 二、安装部署
``` bash
# 解压安装包
tar -zxvf prometheus-2.13.1.linux-amd64.tar.gz
tar -zxvf alertmanager-0.19.0.linux-amd64.tar.gz
```

## 三、altermanager
altermanager 配置文件
``` yaml
[root@ansible alertmanager-0.19.0.linux-amd64]# cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.163.com:25'
  smtp_from: 'miaocunf@163.com'
  smtp_auth_username: '邮箱发件账号'
  smtp_auth_password: '邮箱账号授权码'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: live-monitoring

receivers:
- name: 'live-monitoring'
  email_configs:
  - to: 'i@miaocf.com'
```

报警规则, 需要配置在 prometheus 程序路径下, 在 prometheus.yml 中导入
``` 
# 检测 node 主机是否在线, 如果不在线一分钟以后触发规则。
[root@ansible prometheus-2.13.1.linux-amd64]# cat node_down.yml
groups:
- name: example
  rules:
  - alert: InstanceDown
    expr: up == 0
    for: 1m
    labels:
      user: root 
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minutes."
```

启动 altermanager
```
nohup ./alertmanager &
```

## 四、prometheus
prometheus 配置文件
``` yaml
[root@ansible prometheus-2.13.1.linux-amd64]# cat prometheus.yml
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    # 配置 alertmanager 服务
    - targets: ["localhost:9093"]
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
    # 导入报警规则
    - "node_down.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      # 配置 node 节点
      - targets: ['192.168.100.231:9100','192.168.100.232:9100','192.168.100.236:9100','192.168.100.237:9100']
```

启动 prometheus
```
nohup ./prometheus  &
```

日志输出在 nohup.out 文件中
```
[root@ansible prometheus-2.13.1.linux-amd64]# ll
total 136116
-rw------- 1 root root     7950 Nov 13 15:00 nohup.out
```

``` log
level=info ts=2019-11-13T09:32:40.052Z caller=main.go:673 msg="TSDB started"
level=info ts=2019-11-13T09:32:40.052Z caller=main.go:743 msg="Loading configuration file" filename=prometheus.yml
level=info ts=2019-11-13T09:32:40.055Z caller=main.go:771 msg="Completed loading of configuration file" filename=prometheus.yml
level=info ts=2019-11-13T09:32:40.055Z caller=main.go:626 msg="Server is ready to receive web requests."
```

## 五、服务验证与报警验证
### 服务验证
```
验证节点
http://192.168.100.233:9090/targets

验证报警规则
http://192.168.100.233:9090/alerts
```

### 报警验证
删除 node-exporter 来触发报警规则
```
[root@master ~]# kubectl get pods -n kube-system
NAME                                         READY   STATUS    RESTARTS   AGE
monitor-prometheus-node-exporter-bddvf       1/1     Running   0          14m
monitor-prometheus-node-exporter-j6f4w       1/1     Running   0          14m
monitor-prometheus-node-exporter-mpxkf       1/1     Running   0          14m
monitor-prometheus-node-exporter-xjjvl       1/1     Running   0          14m
[root@master ~]# 
[root@master ~]# kubectl get ds -n kube-system
NAME                               DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
kube-flannel-ds-amd64              4         4         4       4            4           beta.kubernetes.io/arch=amd64     58d
kube-flannel-ds-arm                0         0         0       0            0           beta.kubernetes.io/arch=arm       58d
kube-flannel-ds-arm64              0         0         0       0            0           beta.kubernetes.io/arch=arm64     58d
kube-flannel-ds-ppc64le            0         0         0       0            0           beta.kubernetes.io/arch=ppc64le   58d
kube-flannel-ds-s390x              0         0         0       0            0           beta.kubernetes.io/arch=s390x     58d
kube-proxy                         4         4         4       4            4           <none>                            58d
monitor-prometheus-node-exporter   4         4         4       4            4           <none>                            14m
[root@master ~]# 
[root@master ~]# kubectl delete ds -n kube-system monitor-prometheus-node-exporter
daemonset.extensions "monitor-prometheus-node-exporter" deleted
```
