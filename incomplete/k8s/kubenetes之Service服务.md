k8s之Service

在k8s平台上pod有生命周期，为了给客户端提供固定的访问端点，因此我们在客户端与服务端（pod）之间添加一个固定中间层（service），service强依赖k8s上部署的dns服务，较新版本的k8s用的是CoreDNS，1.11之前用的是kube-dns。k8s要想向客户端提供网络功能，需要依赖第三方网络查件，只要满足cni接口（容器网络标准）即可，



三种网络

节点网络

pod网络

集群网络（service地址，虚拟地址）



kube-proxy --> 始终监控(watch) apiserver有关service资源的变动信息 --> 转化为当前节点能够实现service资源调度的规则（iptables，ipvs）

service三种工作模式：userspace、iptables、ipvs

service  --> endpoint --> pod

服务名的解析方式 SVC_NAME.NS_NAME.DOMAIN.LTD.

svc.cluster.local.

无头(headless)service，没有clusterIP，设置为None，直接解析为pod地址。



