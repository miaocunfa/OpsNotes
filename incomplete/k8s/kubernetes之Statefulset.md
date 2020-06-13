## kubernetes之statefulset

三个核心组件： 

headless service、

StatefulSet、

volumeClaimTemplate 卷申请模板

pod_name.m.ns_name.svc.cluster.local



每个节点应该有自己专有的存储卷。

基于deployment的pod模板创建的pod

