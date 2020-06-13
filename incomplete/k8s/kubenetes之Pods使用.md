## k8s pods使用

资源配置清单：

自主式Pod资源

资源的清单格式：

​	一级字段：apiVersion(group/version), kind，metadata(name,namespace,labels,...), spec, status

```
kubectl explain pods.spec.containers
- name <string>
  image <string>
  imagePullPolicy <string>  不允许修改。
    always: 不管本地存在不存在镜像，都要去仓库下载
    Never:  本地有才用，没有也不去仓库下载
    IfNotPresent: 本地有就用本地，没有就去仓库下载
  ports <[]Object> 信息性端口, 并不能起到端口暴露与否。
  - name: http
    containerPort: 80
  command: <[]string>
```

```
command <[]string> # 默认不会运行在shell中，如果没有定义command，默认运行docker镜像中的默认命令
args <[]string> #传递给command的参数，如果没有定义args，执行docker镜像中的args，如果定义了，docker镜像中又有entrypoint和cmd，则docker镜像中的cmd被忽略。
# 类似于docker中entrypoint,cmd
# 如果同时存在entrypoint与cmd,cmd的内容将作为参数传递给entrypoint
```

将Pods利用label来分成多个组，有利于未来管控。

一个资源对象可以使用多个标签，一个标签可以对应多个对象

标签可以在资源创建时添加，也可以在资源创建后使用命令管理。

标签：

​	key=value

​	key最长63个，字符 “字母，数字，下划线，点号，连接点”，只能以字母或数字开头

​	value最长63个字符，可以为空，只能以字母或数字开头及结尾，中间可以用“下划线，点号，连接点”

```
kubectl get pods --show-labels
kubectl get pods -L 显示标签值
kubectl get pods -l 做标签过滤
# 打标签
kubectl label pods pod-demo release=test
# 标签内容重写
kubectl label pods pod-demo release=stable --overwrite
# 标签过滤
kubectl get pods -l release
```

标签选择器：

​	等值关系：=, ==, !=

```
kubectl get pods -l release=stable --show-labels
kubectl get pods -l release!=stable --show-labels
```

​	集合关系：in, notin, key, !key 
```
kubectl get pods -l "release in (stable)"
kubectl get pods -l "release notin (canary,beta,alpha)"
```

有很多类型的资源都需要通过标签选择器关联其他资源，
许多资源支持内嵌字段定义其使用的标签选择器：
matchLabels:直接给定键值
matchExpressions:基于给定的表达式来定义使用标签选择器，{key:"KEY", operator:"OPERATOR", values:[VAL1,VAL2,..]}
	操作符：
		In, NotIn: 	values字段的值必须为非空列表
		Exists, NotExists: values字段的值必须为空列表

节点选择器
```
kubectl label nodes note01 disktype=ssd
```

```
---
kind: Pod
apiVersion: v1
metadata: 
  name: pod-demo
  namespace: default
  labels:
    app: myapp
    tier: frontend
spec:
  containers:
  - name: myapp
    image: nginx
    ports:
    - name: http
      containerPort: 80
  - name: busybox
    image: busybox:latest
    imagePullPolicy: IfNotPresent
    command:
    - "/bin/sh"
    - "-c"
    - "sleep 3600"
  nodeSelector:
    disktype: ssd
```

```
kubectl describe pods pod-demo
```

nodeName <string>

annotations:
	与label不同的地方在于，它不能用于挑选资源对象，仅用于为对象提供“元数据”。

Pod的生命周期
	Pending 挂起，调度尚未完成，没有适合调度的节点
	Running
	Failed
	Successed
	Unknow

Pod生命周期中的重要行为：
	初始化容器
	容器探测：
		存活性探测 liveness probe
		就绪性探测 readiness probe
		每种探测支持三种方式探测
	容器重启策略(restartPolicy):
		Always, OnFailure, Never. Default to Always. 
		
容器探测：
	存活性探测 liveness probe
	就绪性探测 readiness probe
	探针类型三种：
		ExecAction
        TCPSocketAction
        HTTPGetAction
        
``` bash
    kubectl explain pods.spec.containers
    livenessProbe <Object>
    	exec <Object> 探针
    		command <[]string>
    	failureThreshold #失败几次，默认为3
    	initialDelaySeconds #在容器初始化延迟探测的时间，默认为容器启动就探测（容器启动时主程序可能未正常使用）。
    	periodSeconds #多久探测一次，默认为10
    	timeoutSeconds #每次探测超时时间，默认为10
    	httpGet <Object> 探针
    	tcpSocket <Object> 探针
    readinessProbe <Object>
    lifecycle <Object> #生命周期，启动前钩子，启动后钩子
    	postStart
    		exec <Object> 探针
    		httpGet <Object> 探针
    		tcpSocket <Object> 探针
    	preStop
    		exec <Object> 探针
    		httpGet <Object> 探针
    		tcpSocket <Object> 探针
```

	

