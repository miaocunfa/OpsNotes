```
[root@master01 ~]# sealos init --passwd miao123! --master 172.31.194.113  --master 172.31.194.112  --master 172.31.194.110  --node 172.31.194.111 --pkg-url https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz --version v1.16.0
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:21] [172.31.194.113]  ------------ check ok
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:22] [172.31.194.113]  ------------ session[0xc000178000]
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:21] [172.31.194.112]  ------------ check ok
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:22] [172.31.194.112]  ------------ session[0xc000178090]
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:21] [172.31.194.110]  ------------ check ok
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:22] [172.31.194.110]  ------------ session[0xc000178120]
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:21] [172.31.194.111]  ------------ check ok
2019-11-07 17:25:57 [CRIT] [github.com/fanux/sealos/install/check.go:22] [172.31.194.111]  ------------ session[0xc0000b8480]
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/print.go:13] 
[globals]sealos config is:  {"Hosts":["172.31.194.113","172.31.194.112","172.31.194.110","172.31.194.111"]}
2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:320] [172.31.194.111]please wait for tar zxvf exec
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.111]exec cmd is : ls -l /root | grep kube1.16.0.tar.gz | wc -l
2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:320] [172.31.194.113]please wait for tar zxvf exec
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : ls -l /root | grep kube1.16.0.tar.gz | wc -l
2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:320] [172.31.194.112]please wait for tar zxvf exec
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : ls -l /root | grep kube1.16.0.tar.gz | wc -l
2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:320] [172.31.194.110]please wait for tar zxvf exec
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : ls -l /root | grep kube1.16.0.tar.gz | wc -l
2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: 0

2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.111]command result is: 0

2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: 0

2019-11-07 17:25:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: 0

2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : cd /root &&   wget --no-check-certificate  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz && tar zxvf kube1.16.0.tar.gz
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.111]exec cmd is : cd /root &&   wget --no-check-certificate  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz && tar zxvf kube1.16.0.tar.gz
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : cd /root &&   wget --no-check-certificate  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz && tar zxvf kube1.16.0.tar.gz
2019-11-07 17:25:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : cd /root &&   wget --no-check-certificate  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz && tar zxvf kube1.16.0.tar.gz
2019-11-07 17:26:00 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 45.53MB
2019-11-07 17:26:00 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 46.25MB
2019-11-07 17:26:00 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 44.56MB
2019-11-07 17:26:00 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 46.36MB
2019-11-07 17:26:03 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 79.77MB
2019-11-07 17:26:03 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 79.56MB
2019-11-07 17:26:03 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 81.92MB
2019-11-07 17:26:03 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 81.39MB
2019-11-07 17:26:06 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 117.78MB
2019-11-07 17:26:06 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 117.29MB
2019-11-07 17:26:06 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 118.06MB
2019-11-07 17:26:06 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 118.14MB
2019-11-07 17:26:09 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 153.95MB
2019-11-07 17:26:09 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 155.44MB
2019-11-07 17:26:09 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 154.25MB
2019-11-07 17:26:09 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 154.88MB
2019-11-07 17:26:12 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 191.20MB
2019-11-07 17:26:12 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 191.32MB
2019-11-07 17:26:12 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 190.15MB
2019-11-07 17:26:12 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 190.26MB
2019-11-07 17:26:15 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 226.94MB
2019-11-07 17:26:15 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 227.37MB
2019-11-07 17:26:15 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 226.24MB
2019-11-07 17:26:15 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 226.98MB
2019-11-07 17:26:18 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 263.83MB
2019-11-07 17:26:18 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 263.98MB
2019-11-07 17:26:18 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 262.64MB
2019-11-07 17:26:18 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 264.35MB
2019-11-07 17:26:21 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 300.04MB
2019-11-07 17:26:21 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 300.15MB
2019-11-07 17:26:21 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 299.17MB
2019-11-07 17:26:21 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 300.03MB
2019-11-07 17:26:24 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 335.06MB
2019-11-07 17:26:24 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 336.34MB
2019-11-07 17:26:24 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 334.34MB
2019-11-07 17:26:24 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 335.15MB
2019-11-07 17:26:27 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 369.90MB
2019-11-07 17:26:27 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 371.59MB
2019-11-07 17:26:27 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 373.14MB
2019-11-07 17:26:27 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 372.44MB
2019-11-07 17:26:30 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 407.45MB
2019-11-07 17:26:30 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 408.77MB
2019-11-07 17:26:30 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 409.51MB
2019-11-07 17:26:30 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 408.32MB
2019-11-07 17:26:33 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 445.03MB
2019-11-07 17:26:33 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 445.19MB
2019-11-07 17:26:33 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 443.92MB
2019-11-07 17:26:33 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 444.98MB
2019-11-07 17:26:36 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 479.24MB
2019-11-07 17:26:36 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 481.72MB
2019-11-07 17:26:36 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 481.81MB
2019-11-07 17:26:36 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 480.99MB
2019-11-07 17:26:39 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 517.38MB
2019-11-07 17:26:39 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 516.41MB
2019-11-07 17:26:39 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 518.08MB
2019-11-07 17:26:39 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 517.57MB
2019-11-07 17:26:42 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.110]transfer total size is: 540.02MB
2019-11-07 17:26:43 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.113]transfer total size is: 540.02MB
2019-11-07 17:26:43 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.111]transfer total size is: 540.02MB
2019-11-07 17:26:43 [ALRT] [github.com/fanux/sealos/install/utils.go:91] [172.31.194.112]transfer total size is: 540.02MB
2019-11-07 17:26:56 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: --2019-11-07 17:25:57--  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz
Resolving sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)... 59.110.190.37
Connecting to sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)|59.110.190.37|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 566256509 (540M) [application/x-gzip]
Saving to: ‘kube1.16.0.tar.gz’

100% 566,256,509 12.0MB/s   in 44s          

2019-11-07 17:26:42 (12.3 MB/s) - ‘kube1.16.0.tar.gz’ saved [566256509/566256509]

kube/
kube/shell/
kube/shell/init.sh
kube/shell/master.sh
kube/shell/docker.sh
kube/README.md
kube/bin/
kube/bin/kubelet
kube/bin/sealos
kube/bin/kubectl
kube/bin/crictl
kube/bin/kubeadm
kube/bin/kubelet-pre-start.sh
kube/conf/
kube/conf/docker.service
kube/conf/kubeadm.yaml
kube/conf/kubelet.service
kube/conf/calico.yaml
kube/conf/10-kubeadm.conf
kube/conf/net/
kube/conf/net/calico.yaml
kube/docker/
kube/docker/docker.tgz
kube/docker/README.md
kube/images/
kube/images/images.tar
kube/images/README.md

2019-11-07 17:26:56 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : cd /root/kube/shell && sh init.sh
2019-11-07 17:26:56 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.111]command result is: --2019-11-07 17:25:57--  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz
Resolving sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)... 59.110.190.37
Connecting to sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)|59.110.190.37|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 566256509 (540M) [application/x-gzip]
Saving to: ‘kube1.16.0.tar.gz’

100% 566,256,509 12.0MB/s   in 44s          

2019-11-07 17:26:41 (12.4 MB/s) - ‘kube1.16.0.tar.gz’ saved [566256509/566256509]

kube/
kube/shell/
kube/shell/init.sh
kube/shell/master.sh
kube/shell/docker.sh
kube/README.md
kube/bin/
kube/bin/kubelet
kube/bin/sealos
kube/bin/kubectl
kube/bin/crictl
kube/bin/kubeadm
kube/bin/kubelet-pre-start.sh
kube/conf/
kube/conf/docker.service
kube/conf/kubeadm.yaml
kube/conf/kubelet.service
kube/conf/calico.yaml
kube/conf/10-kubeadm.conf
kube/conf/net/
kube/conf/net/calico.yaml
kube/docker/
kube/docker/docker.tgz
kube/docker/README.md
kube/images/
kube/images/images.tar
kube/images/README.md

2019-11-07 17:26:56 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.111]exec cmd is : cd /root/kube/shell && sh init.sh
2019-11-07 17:26:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: --2019-11-07 17:25:58--  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz
Resolving sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)... 59.110.190.37
Connecting to sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)|59.110.190.37|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 566256509 (540M) [application/x-gzip]
Saving to: ‘kube1.16.0.tar.gz’

100% 566,256,509 12.3MB/s   in 44s          

2019-11-07 17:26:41 (12.4 MB/s) - ‘kube1.16.0.tar.gz’ saved [566256509/566256509]

kube/
kube/shell/
kube/shell/init.sh
kube/shell/master.sh
kube/shell/docker.sh
kube/README.md
kube/bin/
kube/bin/kubelet
kube/bin/sealos
kube/bin/kubectl
kube/bin/crictl
kube/bin/kubeadm
kube/bin/kubelet-pre-start.sh
kube/conf/
kube/conf/docker.service
kube/conf/kubeadm.yaml
kube/conf/kubelet.service
kube/conf/calico.yaml
kube/conf/10-kubeadm.conf
kube/conf/net/
kube/conf/net/calico.yaml
kube/docker/
kube/docker/docker.tgz
kube/docker/README.md
kube/images/
kube/images/images.tar
kube/images/README.md

2019-11-07 17:26:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : cd /root/kube/shell && sh init.sh
2019-11-07 17:26:57 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: --2019-11-07 17:25:57--  https://sealyun.oss-cn-beijing.aliyuncs.com/37374d999dbadb788ef0461844a70151-1.16.0/kube1.16.0.tar.gz
Resolving sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)... 59.110.190.37
Connecting to sealyun.oss-cn-beijing.aliyuncs.com (sealyun.oss-cn-beijing.aliyuncs.com)|59.110.190.37|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 566256509 (540M) [application/x-gzip]
Saving to: ‘kube1.16.0.tar.gz’

100% 566,256,509 12.3MB/s   in 44s          

2019-11-07 17:26:41 (12.3 MB/s) - ‘kube1.16.0.tar.gz’ saved [566256509/566256509]

kube/
kube/shell/
kube/shell/init.sh
kube/shell/master.sh
kube/shell/docker.sh
kube/README.md
kube/bin/
kube/bin/kubelet
kube/bin/sealos
kube/bin/kubectl
kube/bin/crictl
kube/bin/kubeadm
kube/bin/kubelet-pre-start.sh
kube/conf/
kube/conf/docker.service
kube/conf/kubeadm.yaml
kube/conf/kubelet.service
kube/conf/calico.yaml
kube/conf/10-kubeadm.conf
kube/conf/net/
kube/conf/net/calico.yaml
kube/docker/
kube/docker/docker.tgz
kube/docker/README.md
kube/images/
kube/images/images.tar
kube/images/README.md

2019-11-07 17:26:57 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : cd /root/kube/shell && sh init.sh
2019-11-07 17:28:07 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.111]command result is: * Applying /usr/lib/sysctl.d/00-system.conf ...
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
* Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ...
kernel.yama.ptrace_scope = 0
* Applying /usr/lib/sysctl.d/50-default.conf ...
kernel.sysrq = 16
kernel.core_uses_pid = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/99-sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.d/k8s.conf ...
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
setenforce: SELinux is disabled
fe9a8b4f1dcc: Loading layer  43.87MB/43.87MB
fb965c8779b8: Loading layer  174.7MB/174.7MB
Loaded image: k8s.gcr.io/kube-apiserver:v1.16.0
9a01478873f3: Loading layer  183.2MB/183.2MB
ec2dc9e995e3: Loading layer  21.18MB/21.18MB
Loaded image: k8s.gcr.io/etcd:3.3.15-0
d8a33133e477: Loading layer  72.47MB/72.47MB
337ec577cf9c: Loading layer     33MB/33MB
45cc6dfacce1: Loading layer  3.584kB/3.584kB
7b3ecdc818b0: Loading layer  3.584kB/3.584kB
2b0805a50f82: Loading layer  21.85MB/21.85MB
c9bf76343513: Loading layer  11.26kB/11.26kB
f4176618c27b: Loading layer  11.26kB/11.26kB
4dcaff1da822: Loading layer   6.55MB/6.55MB
92e6b8f58573: Loading layer  2.945MB/2.945MB
5f970d4ac62d: Loading layer  35.84kB/35.84kB
b1a2a2446599: Loading layer  55.22MB/55.22MB
014866f8df9e: Loading layer   1.14MB/1.14MB
Loaded image: calico/node:v3.8.2
d69483a6face: Loading layer  209.5MB/209.5MB
4d5bbb6f00de: Loading layer  84.17MB/84.17MB
0c8fcaeca178: Loading layer  12.32MB/12.32MB
Loaded image: fanux/lvscare:latest
ba0d3c73e565: Loading layer    121MB/121MB
Loaded image: k8s.gcr.io/kube-controller-manager:v1.16.0
15c9248be8a9: Loading layer  3.403MB/3.403MB
e965763669eb: Loading layer  40.64MB/40.64MB
Loaded image: k8s.gcr.io/kube-proxy:v1.16.0
de4b4a4f6616: Loading layer  44.95MB/44.95MB
Loaded image: k8s.gcr.io/kube-scheduler:v1.16.0
225df95e717c: Loading layer  336.4kB/336.4kB
169c87e3a0eb: Loading layer  43.89MB/43.89MB
Loaded image: k8s.gcr.io/coredns:1.6.2
466b4a33898e: Loading layer  88.05MB/88.05MB
dd824a99572a: Loading layer  10.24kB/10.24kB
d8fdd74cc7ed: Loading layer   2.56kB/2.56kB
Loaded image: calico/cni:v3.8.2
8b62fd4eb2dd: Loading layer  43.99MB/43.99MB
40fe7b163104: Loading layer  2.828MB/2.828MB
Loaded image: calico/kube-controllers:v3.8.2
3fc64803ca2d: Loading layer  4.463MB/4.463MB
f03a403b18a7: Loading layer   5.12kB/5.12kB
0de6f9b8b1f7: Loading layer  5.166MB/5.166MB
Loaded image: calico/pod2daemon-flexvol:v3.8.2
e17133b79956: Loading layer  744.4kB/744.4kB
Loaded image: k8s.gcr.io/pause:3.1
driver is systemd
Failed to execute operation: File exists

2019-11-07 17:28:07 [EROR] [github.com/fanux/sealos/install/utils.go:114] [172.31.194.111]Error exec command failed: Process exited with status 1
2019-11-07 17:28:11 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: * Applying /usr/lib/sysctl.d/00-system.conf ...
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
* Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ...
kernel.yama.ptrace_scope = 0
* Applying /usr/lib/sysctl.d/50-default.conf ...
kernel.sysrq = 16
kernel.core_uses_pid = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/99-sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.d/k8s.conf ...
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
setenforce: SELinux is disabled
fe9a8b4f1dcc: Loading layer  43.87MB/43.87MB
fb965c8779b8: Loading layer  174.7MB/174.7MB
Loaded image: k8s.gcr.io/kube-apiserver:v1.16.0
9a01478873f3: Loading layer  183.2MB/183.2MB
ec2dc9e995e3: Loading layer  21.18MB/21.18MB
Loaded image: k8s.gcr.io/etcd:3.3.15-0
d8a33133e477: Loading layer  72.47MB/72.47MB
337ec577cf9c: Loading layer     33MB/33MB
45cc6dfacce1: Loading layer  3.584kB/3.584kB
7b3ecdc818b0: Loading layer  3.584kB/3.584kB
2b0805a50f82: Loading layer  21.85MB/21.85MB
c9bf76343513: Loading layer  11.26kB/11.26kB
f4176618c27b: Loading layer  11.26kB/11.26kB
4dcaff1da822: Loading layer   6.55MB/6.55MB
92e6b8f58573: Loading layer  2.945MB/2.945MB
5f970d4ac62d: Loading layer  35.84kB/35.84kB
b1a2a2446599: Loading layer  55.22MB/55.22MB
014866f8df9e: Loading layer   1.14MB/1.14MB
Loaded image: calico/node:v3.8.2
d69483a6face: Loading layer  209.5MB/209.5MB
4d5bbb6f00de: Loading layer  84.17MB/84.17MB
0c8fcaeca178: Loading layer  12.32MB/12.32MB
Loaded image: fanux/lvscare:latest
ba0d3c73e565: Loading layer    121MB/121MB
Loaded image: k8s.gcr.io/kube-controller-manager:v1.16.0
15c9248be8a9: Loading layer  3.403MB/3.403MB
e965763669eb: Loading layer  40.64MB/40.64MB
Loaded image: k8s.gcr.io/kube-proxy:v1.16.0
de4b4a4f6616: Loading layer  44.95MB/44.95MB
Loaded image: k8s.gcr.io/kube-scheduler:v1.16.0
225df95e717c: Loading layer  336.4kB/336.4kB
169c87e3a0eb: Loading layer  43.89MB/43.89MB
Loaded image: k8s.gcr.io/coredns:1.6.2
466b4a33898e: Loading layer  88.05MB/88.05MB
dd824a99572a: Loading layer  10.24kB/10.24kB
d8fdd74cc7ed: Loading layer   2.56kB/2.56kB
Loaded image: calico/cni:v3.8.2
8b62fd4eb2dd: Loading layer  43.99MB/43.99MB
40fe7b163104: Loading layer  2.828MB/2.828MB
Loaded image: calico/kube-controllers:v3.8.2
3fc64803ca2d: Loading layer  4.463MB/4.463MB
f03a403b18a7: Loading layer   5.12kB/5.12kB
0de6f9b8b1f7: Loading layer  5.166MB/5.166MB
Loaded image: calico/pod2daemon-flexvol:v3.8.2
e17133b79956: Loading layer  744.4kB/744.4kB
Loaded image: k8s.gcr.io/pause:3.1
cp: cannot create regular file ‘/usr/bin/sealos’: Text file busy
driver is systemd
Failed to execute operation: File exists

2019-11-07 17:28:11 [EROR] [github.com/fanux/sealos/install/utils.go:114] [172.31.194.113]Error exec command failed: Process exited with status 1
2019-11-07 17:28:18 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: * Applying /usr/lib/sysctl.d/00-system.conf ...
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
* Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ...
kernel.yama.ptrace_scope = 0
* Applying /usr/lib/sysctl.d/50-default.conf ...
kernel.sysrq = 16
kernel.core_uses_pid = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/99-sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.d/k8s.conf ...
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
setenforce: SELinux is disabled
fe9a8b4f1dcc: Loading layer  43.87MB/43.87MB
fb965c8779b8: Loading layer  174.7MB/174.7MB
Loaded image: k8s.gcr.io/kube-apiserver:v1.16.0
9a01478873f3: Loading layer  183.2MB/183.2MB
ec2dc9e995e3: Loading layer  21.18MB/21.18MB
Loaded image: k8s.gcr.io/etcd:3.3.15-0
d8a33133e477: Loading layer  72.47MB/72.47MB
337ec577cf9c: Loading layer     33MB/33MB
45cc6dfacce1: Loading layer  3.584kB/3.584kB
7b3ecdc818b0: Loading layer  3.584kB/3.584kB
2b0805a50f82: Loading layer  21.85MB/21.85MB
c9bf76343513: Loading layer  11.26kB/11.26kB
f4176618c27b: Loading layer  11.26kB/11.26kB
4dcaff1da822: Loading layer   6.55MB/6.55MB
92e6b8f58573: Loading layer  2.945MB/2.945MB
5f970d4ac62d: Loading layer  35.84kB/35.84kB
b1a2a2446599: Loading layer  55.22MB/55.22MB
014866f8df9e: Loading layer   1.14MB/1.14MB
Loaded image: calico/node:v3.8.2
d69483a6face: Loading layer  209.5MB/209.5MB
4d5bbb6f00de: Loading layer  84.17MB/84.17MB
0c8fcaeca178: Loading layer  12.32MB/12.32MB
Loaded image: fanux/lvscare:latest
ba0d3c73e565: Loading layer    121MB/121MB
Loaded image: k8s.gcr.io/kube-controller-manager:v1.16.0
15c9248be8a9: Loading layer  3.403MB/3.403MB
e965763669eb: Loading layer  40.64MB/40.64MB
Loaded image: k8s.gcr.io/kube-proxy:v1.16.0
de4b4a4f6616: Loading layer  44.95MB/44.95MB
Loaded image: k8s.gcr.io/kube-scheduler:v1.16.0
225df95e717c: Loading layer  336.4kB/336.4kB
169c87e3a0eb: Loading layer  43.89MB/43.89MB
Loaded image: k8s.gcr.io/coredns:1.6.2
466b4a33898e: Loading layer  88.05MB/88.05MB
dd824a99572a: Loading layer  10.24kB/10.24kB
d8fdd74cc7ed: Loading layer   2.56kB/2.56kB
Loaded image: calico/cni:v3.8.2
8b62fd4eb2dd: Loading layer  43.99MB/43.99MB
40fe7b163104: Loading layer  2.828MB/2.828MB
Loaded image: calico/kube-controllers:v3.8.2
3fc64803ca2d: Loading layer  4.463MB/4.463MB
f03a403b18a7: Loading layer   5.12kB/5.12kB
0de6f9b8b1f7: Loading layer  5.166MB/5.166MB
Loaded image: calico/pod2daemon-flexvol:v3.8.2
e17133b79956: Loading layer  744.4kB/744.4kB
Loaded image: k8s.gcr.io/pause:3.1
driver is systemd
Failed to execute operation: File exists

2019-11-07 17:28:18 [EROR] [github.com/fanux/sealos/install/utils.go:114] [172.31.194.110]Error exec command failed: Process exited with status 1
2019-11-07 17:28:22 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: * Applying /usr/lib/sysctl.d/00-system.conf ...
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
* Applying /usr/lib/sysctl.d/10-default-yama-scope.conf ...
kernel.yama.ptrace_scope = 0
* Applying /usr/lib/sysctl.d/50-default.conf ...
kernel.sysrq = 16
kernel.core_uses_pid = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.all.promote_secondaries = 1
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
* Applying /etc/sysctl.d/99-sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.d/k8s.conf ...
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
* Applying /etc/sysctl.conf ...
vm.swappiness = 0
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.sysrq = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
setenforce: SELinux is disabled
fe9a8b4f1dcc: Loading layer  43.87MB/43.87MB
fb965c8779b8: Loading layer  174.7MB/174.7MB
Loaded image: k8s.gcr.io/kube-apiserver:v1.16.0
9a01478873f3: Loading layer  183.2MB/183.2MB
ec2dc9e995e3: Loading layer  21.18MB/21.18MB
Loaded image: k8s.gcr.io/etcd:3.3.15-0
d8a33133e477: Loading layer  72.47MB/72.47MB
337ec577cf9c: Loading layer     33MB/33MB
45cc6dfacce1: Loading layer  3.584kB/3.584kB
7b3ecdc818b0: Loading layer  3.584kB/3.584kB
2b0805a50f82: Loading layer  21.85MB/21.85MB
c9bf76343513: Loading layer  11.26kB/11.26kB
f4176618c27b: Loading layer  11.26kB/11.26kB
4dcaff1da822: Loading layer   6.55MB/6.55MB
92e6b8f58573: Loading layer  2.945MB/2.945MB
5f970d4ac62d: Loading layer  35.84kB/35.84kB
b1a2a2446599: Loading layer  55.22MB/55.22MB
014866f8df9e: Loading layer   1.14MB/1.14MB
Loaded image: calico/node:v3.8.2
d69483a6face: Loading layer  209.5MB/209.5MB
4d5bbb6f00de: Loading layer  84.17MB/84.17MB
0c8fcaeca178: Loading layer  12.32MB/12.32MB
Loaded image: fanux/lvscare:latest
ba0d3c73e565: Loading layer    121MB/121MB
Loaded image: k8s.gcr.io/kube-controller-manager:v1.16.0
15c9248be8a9: Loading layer  3.403MB/3.403MB
e965763669eb: Loading layer  40.64MB/40.64MB
Loaded image: k8s.gcr.io/kube-proxy:v1.16.0
de4b4a4f6616: Loading layer  44.95MB/44.95MB
Loaded image: k8s.gcr.io/kube-scheduler:v1.16.0
225df95e717c: Loading layer  336.4kB/336.4kB
169c87e3a0eb: Loading layer  43.89MB/43.89MB
Loaded image: k8s.gcr.io/coredns:1.6.2
466b4a33898e: Loading layer  88.05MB/88.05MB
dd824a99572a: Loading layer  10.24kB/10.24kB
d8fdd74cc7ed: Loading layer   2.56kB/2.56kB
Loaded image: calico/cni:v3.8.2
8b62fd4eb2dd: Loading layer  43.99MB/43.99MB
40fe7b163104: Loading layer  2.828MB/2.828MB
Loaded image: calico/kube-controllers:v3.8.2
3fc64803ca2d: Loading layer  4.463MB/4.463MB
f03a403b18a7: Loading layer   5.12kB/5.12kB
0de6f9b8b1f7: Loading layer  5.166MB/5.166MB
Loaded image: calico/pod2daemon-flexvol:v3.8.2
e17133b79956: Loading layer  744.4kB/744.4kB
Loaded image: k8s.gcr.io/pause:3.1
driver is systemd
Failed to execute operation: File exists

2019-11-07 17:28:22 [EROR] [github.com/fanux/sealos/install/utils.go:114] [172.31.194.112]Error exec command failed: Process exited with status 1
2019-11-07 17:28:22 [DEBG] [github.com/fanux/sealos/install/print.go:20] ==>SendPackage
2019-11-07 17:28:22 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : echo "apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.16.0
controlPlaneEndpoint: "apiserver.cluster.local:6443"
networking:
  podSubnet: 100.64.0.0/10
apiServer:
        certSANs:
        - 127.0.0.1
        - apiserver.cluster.local
        - 172.31.194.113
        - 172.31.194.112
        - 172.31.194.110
        - 10.103.97.2
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
        excludeCIDRs: 
        - "10.103.97.2/32"" > /root/kubeadm-config.yaml
2019-11-07 17:28:22 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: 
2019-11-07 17:28:22 [DEBG] [github.com/fanux/sealos/install/print.go:20] ==>SendPackage==>KubeadmConfigInstall
2019-11-07 17:28:22 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : echo 172.31.194.113 apiserver.cluster.local >> /etc/hosts
2019-11-07 17:28:22 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: 
2019-11-07 17:28:22 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : kubeadm init --config=/root/kubeadm-config.yaml --upload-certs
2019-11-07 17:28:49 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: [init] Using Kubernetes version: v1.16.0
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "master01" could not be reached
	[WARNING Hostname]: hostname "master01": lookup master01 on 100.100.2.138:53: no such host
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local apiserver.cluster.local apiserver.cluster.local] and IPs [10.96.0.1 172.31.194.113 127.0.0.1 172.31.194.113 172.31.194.112 172.31.194.110 10.103.97.2]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master01 localhost] and IPs [172.31.194.113 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master01 localhost] and IPs [172.31.194.113 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 20.002280 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.16" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
74faeb3087e87ddba32fe720208ecf84ebb7f643a02e74a8996a2337fd86be6c
[mark-control-plane] Marking the node master01 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master01 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: p78po9.9ql486f671zshs87
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of the control-plane node running the following command on each as root:

  kubeadm join apiserver.cluster.local:6443 --token p78po9.9ql486f671zshs87 \
    --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 \
    --control-plane --certificate-key 74faeb3087e87ddba32fe720208ecf84ebb7f643a02e74a8996a2337fd86be6c

Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use 
"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join apiserver.cluster.local:6443 --token p78po9.9ql486f671zshs87 \
    --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 



kubernetes HA install: https://github.com/fanux/sealos
www.sealyun.com
QQ group: 98488045




2019-11-07 17:28:49 [INFO] [github.com/fanux/sealos/install/sealos.go:84] [globals]join command is:  apiserver.cluster.local:6443 --token p78po9.9ql486f671zshs87 \
    --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 \
    --control-plane --certificate-key 74faeb3087e87ddba32fe720208ecf84ebb7f643a02e74a8996a2337fd86be6c


2019-11-07 17:28:49 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : mkdir -p /root/.kube && cp /etc/kubernetes/admin.conf /root/.kube/config
2019-11-07 17:28:49 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: 
2019-11-07 17:28:49 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.113]exec cmd is : kubectl apply -f /root/kube/conf/net/calico.yaml || true
2019-11-07 17:28:50 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.113]command result is: configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
daemonset.apps/calico-node created
serviceaccount/calico-node created
deployment.apps/calico-kube-controllers created
serviceaccount/calico-kube-controllers created

2019-11-07 17:28:50 [DEBG] [github.com/fanux/sealos/install/print.go:20] ==>SendPackage==>KubeadmConfigInstall==>InstallMaster0
2019-11-07 17:28:50 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : echo 172.31.194.113 apiserver.cluster.local >> /etc/hosts
2019-11-07 17:28:50 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: 
2019-11-07 17:28:50 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : kubeadm join 172.31.194.113:6443 --token p78po9.9ql486f671zshs87 --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 --control-plane --certificate-key 74faeb3087e87ddba32fe720208ecf84ebb7f643a02e74a8996a2337fd86be6c
2019-11-07 17:29:31 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: This is a control plan
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "master02" could not be reached
	[WARNING Hostname]: hostname "master02": lookup master02 on 100.100.2.136:53: no such host
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master02 localhost] and IPs [172.31.194.112 127.0.0.1 ::1]
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master02 localhost] and IPs [172.31.194.112 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master02 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local apiserver.cluster.local apiserver.cluster.local] and IPs [10.96.0.1 172.31.194.112 127.0.0.1 172.31.194.113 172.31.194.112 172.31.194.110 10.103.97.2]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
[etcd] Announced new etcd member joining to the existing etcd cluster
[etcd] Creating static Pod manifest for "etcd"
[etcd] Waiting for the new etcd member to join the cluster. This can take up to 40s
{"level":"warn","ts":"2019-11-07T17:29:23.075+0800","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"passthrough:///https://172.31.194.112:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = context deadline exceeded"}
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[mark-control-plane] Marking the node master02 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master02 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane (master) label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.




kubernetes HA install: https://github.com/fanux/sealos
www.sealyun.com
QQ group: 98488045




2019-11-07 17:29:31 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.112]exec cmd is : sed "s/172.31.194.113/172.31.194.112/g" -i /etc/hosts
2019-11-07 17:29:31 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.112]command result is: 
2019-11-07 17:29:31 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : echo 172.31.194.113 apiserver.cluster.local >> /etc/hosts
2019-11-07 17:29:32 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: 
2019-11-07 17:29:32 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : kubeadm join 172.31.194.113:6443 --token p78po9.9ql486f671zshs87 --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 --control-plane --certificate-key 74faeb3087e87ddba32fe720208ecf84ebb7f643a02e74a8996a2337fd86be6c
2019-11-07 17:30:08 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: This is a control plan
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "master03" could not be reached
	[WARNING Hostname]: hostname "master03": lookup master03 on 100.100.2.136:53: no such host
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[preflight] Running pre-flight checks before initializing the new control plane instance
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[download-certs] Downloading the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master03 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local apiserver.cluster.local apiserver.cluster.local] and IPs [10.96.0.1 172.31.194.110 127.0.0.1 172.31.194.113 172.31.194.112 172.31.194.110 10.103.97.2]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [master03 localhost] and IPs [172.31.194.110 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [master03 localhost] and IPs [172.31.194.110 127.0.0.1 ::1]
[certs] Valid certificates and keys now exist in "/etc/kubernetes/pki"
[certs] Using the existing "sa" key
[kubeconfig] Generating kubeconfig files
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[check-etcd] Checking that the etcd cluster is healthy
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...
[etcd] Announced new etcd member joining to the existing etcd cluster
[etcd] Creating static Pod manifest for "etcd"
[etcd] Waiting for the new etcd member to join the cluster. This can take up to 40s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[mark-control-plane] Marking the node master03 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master03 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]

This node has joined the cluster and a new control plane instance was created:

* Certificate signing request was sent to apiserver and approval was received.
* The Kubelet was informed of the new secure connection details.
* Control plane (master) label and taint were applied to the new node.
* The Kubernetes control plane instances scaled up.
* A new etcd member was added to the local/stacked etcd cluster.

To start administering your cluster from this node, you need to run the following as a regular user:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

Run 'kubectl get nodes' to see this node join the cluster.




kubernetes HA install: https://github.com/fanux/sealos
www.sealyun.com
QQ group: 98488045




2019-11-07 17:30:08 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.110]exec cmd is : sed "s/172.31.194.113/172.31.194.110/g" -i /etc/hosts
2019-11-07 17:30:08 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.110]command result is: 
2019-11-07 17:30:08 [DEBG] [github.com/fanux/sealos/install/print.go:20] ==>SendPackage==>KubeadmConfigInstall==>InstallMaster0==>JoinMasters
2019-11-07 17:30:08 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.111]exec cmd is : echo 10.103.97.2 apiserver.cluster.local >> /etc/hosts
2019-11-07 17:30:08 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.111]command result is: 
2019-11-07 17:30:08 [INFO] [github.com/fanux/sealos/install/utils.go:98] [172.31.194.111]exec cmd is : kubeadm join 10.103.97.2:6443 --token p78po9.9ql486f671zshs87 --discovery-token-ca-cert-hash sha256:2d85b9248c27a8e0dd3742711a908a961c09e622389a99c4947c400d023f3624 --master 172.31.194.113:6443 --master 172.31.194.112:6443 --master 172.31.194.110:6443
2019-11-07 17:30:20 [DEBG] [github.com/fanux/sealos/install/utils.go:111] [172.31.194.111]command result is: This is not a control plan
lvscare command is: [/usr/bin/lvscare care --vs 10.103.97.2:6443 --health-path /healthz --health-schem https --rs 172.31.194.113:6443 --rs 172.31.194.112:6443 --rs 172.31.194.110:6443]
IP: 10.103.97.2, Port: 6443IP: 172.31.194.113, Port: 6443IP: 172.31.194.112, Port: 6443IP: 172.31.194.110, Port: 6443IP: 172.31.194.113, Port: 6443IP: 172.31.194.112, Port: 6443IP: 172.31.194.110, Port: 6443creat ipvs first time 10.103.97.2:6443 [172.31.194.113:6443 172.31.194.112:6443 172.31.194.110:6443]
[preflight] Running pre-flight checks
	[WARNING Hostname]: hostname "node01" could not be reached
	[WARNING Hostname]: hostname "node01": lookup node01 on 100.100.2.138:53: no such host
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.16" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.




kubernetes HA install: https://github.com/fanux/sealos
www.sealyun.com
QQ group: 98488045




2019-11-07 17:30:20 [DEBG] [github.com/fanux/sealos/install/print.go:20] ==>SendPackage==>KubeadmConfigInstall==>InstallMaster0==>JoinMasters==>JoinNodes
2019-11-07 17:30:20 [INFO] [github.com/fanux/sealos/install/print.go:25] sealos install success.
[root@master01 ~]#
```