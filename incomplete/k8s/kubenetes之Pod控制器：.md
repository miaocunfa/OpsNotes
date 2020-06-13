## Pod控制器：

我们使用配置清单创建时 --> apiserver --> 调度器 --> 目标节点创建

我们把pod资源意外删除后不会被重建。我们自己向apiserver请求删除的。

自主式pod不由控制器控制和管理的pod。

我们使用kubectl run创建的pod，如果删除的话，会被重建。是由控制器代为管理的。

代我们管理pod中间层，并确保pod资源与我们所定义或所期望的目标状态一致。

pod控制器有多种类型：

ReplicationController：k8s最早只有这一种pod控制器。设计目标过于庞大，现已废弃。

ReplicaSet: 代用户创建指定数量的pod副本，并确保pod副本数量跟用户所期望的一致，多退少补，自动扩缩容。被称为新一代的ReplicationController。无状态的pod资源。k8s不建议我们直接使用ReplicaSet。

​	三种核心资源：pod副本数，标签选择器，pod模板

*Deployment：Deployment建构在ReplicaSet之上，不直接控制pod，Deployment通过控制ReplicaSet来控制pod。支持滚动更新，回滚，声明式配置。是目前管理无状态pod资源最好的控制器。关注群体的而不是关注个体。

DaemonSet: 运行类似守护进程级的pod，同类pod一个节点只运行一个副本。也可以根据自己的需求在集群的部分节点上运行副本。无状态的。

Job：任务没执行完要重建，任务结束后不重建。用来保证任务的完成。

cronjob：

StatefulSet：用于管理有状态pod，需要人为的把我们所需要的操作定义在脚本中。我们未能考虑到所有情况。我们需要把每一种应用单独开发出来。

TPR：third party Resources, 1.2+, 1.7

CDR:Custom Defined Resources, 1.8+

Operator: 到今天为止成熟的只支持几个。

Helm：跟linux的yum类似，安装无状态应用集群非常方便。



replicaset

模板

实例

kubectl edit rs myapp

更新升级，改容器镜像，只有重建后的才是新版本，只重建一个的，金丝雀发布，一个个删除一个个重建，灰度发布。一次性全部删掉会影响在线用户访问。最稳妥的方式，用蓝绿发布，重新创建rs。



deployment 

apiversion:apps/v1

默认控制10个 replicaset，滚动式自定义自控制的更新。控制更新节奏，在滚动更新中，readiness很重要









