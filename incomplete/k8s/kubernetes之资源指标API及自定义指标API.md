kubernetes中

metrics-server



prometheus：

server端通过不停的数据采集的方式从客户端获取数据。

在每一个主机上要部署一个agent：node_exporter 节点级采集数据

​                                                                mysql等重量级服务有专门的exporter

pod通过metris url

查看这些采集数据使用 PromQL Restful风格

这些指标数据 API 不认识，把 prometheus 收集到的指标数据转为 API 能识别的数据，使用组件，kube-state-metrics 

​							k8s-prometheus-adpater

每个主机日志在/var/log/containers

