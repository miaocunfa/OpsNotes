# 构建gitlab+Jenkins+harbor+kubernetes的DevOps持续集成持续部署环境

整个环境的结构图。![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/ae6987f7e22871a3e891fbbf6468096f.png)

## 一、准备工作

gitlab和harbor我是安装在kubernetes集群外的一台主机上的。

### 1.1、设置镜像源

#### docker-ce.repo

``` bash
[root@support harbor]# cat /etc/yum.repos.d/docker-ce.repo 
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-debuginfo]
name=Docker CE Stable - Debuginfo $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/debug-$basearch/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

[docker-ce-stable-source]
name=Docker CE Stable - Sources
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/7/source/stable
enabled=0
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg

```

### 1.2、安装依赖包

``` bash
[root@support yum.repos.d]# yum install -y docker-ce-18.09.7
[root@support yum.repos.d]# yum install -y docker-compose
[root@support yum.repos.d]# git
[root@support yum.repos.d]# cat /etc/docker/daemon.json
{"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
[root@support yum.repos.d]# systemctl start docker
```


## 二、harbor部署
### 2.1、安装包

``` bash
[root@support yum.repos.d]# wget -b https://storage.googleapis.com/harbor-releases/release-1.9.0/harbor-offline-installer-v1.9.0.tgz
Continuing in background, pid 9771.
Output will be written to ‘wget-log’.
[root@support ~]# tar zxf harbor-offline-installer-v1.9.0.tgz
[root@support ~]# cd harbor
[root@support harbor]# vi harbor.yml
hostname: 139.9.134.177
http:
  port: 8080
```

### 2.2、部署
```
[root@support harbor]# ./prepare 

[root@support harbor]# ./install.sh 

[root@support harbor]# docker-compose ps
      Name                     Command              State             Ports          
-------------------------------------------------------------------------------------
harbor-core         /harbor/harbor_core             Up                               
harbor-db           /docker-entrypoint.sh           Up      5432/tcp                 
harbor-jobservice   /harbor/harbor_jobservice       Up                               
                    ...                                                              
harbor-log          /bin/sh -c /usr/local/bin/      Up      127.0.0.1:1514->10514/tcp
                    ...                                                              
harbor-portal       nginx -g daemon off;            Up      8080/tcp                 
nginx               nginx -g daemon off;            Up      0.0.0.0:8080->8080/tcp   
redis               redis-server /etc/redis.conf    Up      6379/tcp                 
registry            /entrypoint.sh /etc/regist      Up      5000/tcp                 
                    ...                                                              
registryctl         /harbor/start.sh                Up 
```

## 三、gitlab部署
### 3.1、拉取镜像
```
[root@support yum.repos.d]# docker pull gitlab/gitlab-ce
Using default tag: latest
latest: Pulling from gitlab/gitlab-ce
16c48d79e9cc: Pull complete 
3c654ad3ed7d: Pull complete 
6276f4f9c29d: Pull complete 
a4bd43ad48ce: Pull complete 
075ff90164f7: Pull complete 
8ed147de678c: Pull complete 
c6b08aab9197: Pull complete 
6c15d9b5013c: Pull complete 
de3573fbdb09: Pull complete 
4b6e8211dc80: Verifying Checksum 
latest: Pulling from gitlab/gitlab-ce
16c48d79e9cc: Pull complete 
3c654ad3ed7d: Pull complete 
6276f4f9c29d: Pull complete 
a4bd43ad48ce: Pull complete 
075ff90164f7: Pull complete 
8ed147de678c: Pull complete 
c6b08aab9197: Pull complete 
6c15d9b5013c: Pull complete 
de3573fbdb09: Pull complete 
4b6e8211dc80: Pull complete 
Digest: sha256:eee5fc2589f9aa3cd4c1c1783d5b89667f74c4fc71c52df54660c12cc493011b
Status: Downloaded newer image for gitlab/gitlab-ce:latest
docker.io/gitlab/gitlab-ce:latest
[root@support yum.repos.d]#
```

### 3.2、启动容器

```
[root@bogon /]# docker run --detach \
--hostname 139.9.134.177 \
--publish 10443:443 --publish 10080:80 --publish 10022:22 \
--name gitlab \
--restart always \
--volume /opt/gitlab/config:/etc/gitlab \
--volume /opt/gitlab/logs:/var/log/gitlab \
--volume /opt/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```


```
git仓库初始化
git init --bare 
git clone 
```

```
yum install jenkins -y
java -version

tail -f /var/log/jenkins/jenkins.log
log中输出jenkins网页端初始化密码。
```

## 四、jenkins部署

> github上的kubernetes集群部署 jenkins
>
> https://github.com/jenkinsci/kubernetes-plugin/blob/master/src/main/kubernetes/jenkins.yml

### 4.1、NFS-PV动态供给

NFS服务准备

```bash
# yum安装nfs-utils
[root@support ~]# yum install -y nfs-utils
[root@support ~]# mkdir /ifs/kubernetes
[root@support ~]# cat /etc/exports
# 提供共享目录给10.0.0.0网段主机
/ifs/kubernetes 10.0.0.0/24(rw,no_root_squash)
[root@support ~]# systemctl start nfs
[root@support ~]# exportfs -arv
exporting 10.0.0.0/24:/ifs/kubernetes
```

#### nfs.yaml

```yaml
[root@master jenkins]# cat nfs.yaml 
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
    
---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    namespace: default
roleRef:
  kind: ClusterRole
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
  
---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
    
---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io

---

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "true"

---

kind: ServiceAccount
apiVersion: v1
metadata:
  name: nfs-client-provisioner
  
---

kind: Deployment
apiVersion: apps/v1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector: 
    matchLabels:
      app: nfs-client-provisioner
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: lizhenliang/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 10.0.0.123
            - name: NFS_PATH
              value: /ifs/kubernetes
      volumes:
        - name: nfs-client-root
          nfs:
            server: 10.0.0.123
            path: /ifs/kubernetes
[root@master jenkins]#
```

```
# 创建PV动态供给
root@master jenkins]# kubectl apply -f nfs.yaml
```

### 4.2、Jenkins在kubernetes上部署

jenkins-master调度到K8S的master节点。

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/webp.png)

#### jenkins.yaml

```yaml
[root@master jenkins]# cat jenkins.yaml 
apiVersion: v1
kind: Service
metadata:
  name: jenkins
spec:
  selector:
    name: jenkins
  type: NodePort
  ports:
    -
      name: http
      port: 80
      targetPort: 8080
      protocol: TCP
      nodePort: 30006
    -
      name: agent
      port: 50000
      protocol: TCP
      
---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: jenkins
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get","list","watch"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins

---

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: jenkins
  labels:
    name: jenkins
spec:
  serviceName: jenkins
  replicas: 1
  updateStrategy:
    type: RollingUpdate
  selector: 
    matchLabels:
      name: jenkins
  template:
    metadata:
      name: jenkins
      labels:
        name: jenkins
    spec:
      terminationGracePeriodSeconds: 10
      serviceAccountName: jenkins
      # 调度到主节点上
      nodeSelector:
        labelName: master
      # 容忍主节点污点
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts-alpine
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
            - containerPort: 50000
          env:
            - name: LIMITS_MEMORY
              valueFrom:
                resourceFieldRef:
                  resource: limits.memory
                  divisor: 1Mi
            - name: JAVA_OPTS
              value: -Xmx$(LIMITS_MEMORY)m -XshowSettings:vm -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85
          volumeMounts:
            - name: jenkins-home
              mountPath: /var/jenkins_home
          livenessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
          readinessProbe:
            httpGet:
              path: /login
              port: 8080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 12
      securityContext:
        fsGroup: 1000
  volumeClaimTemplates:
  - metadata:
      name: jenkins-home
    spec:
      storageClassName: "managed-nfs-storage"
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```
```bash
# 创建jenkins Pod
root@master jenkins]# kubectl apply -f jenkins.yaml

# 打开浏览器访问jenkins地址
http://139.9.139.49:30006/

# 卡在启动界面好久
[root@support default-jenkins-home-jenkins-0-pvc-ea84462f-241e-4d38-a408-e07a59d4bf0e]# cat hudson.model.UpdateCenter.xml 
<?xml version='1.1' encoding='UTF-8'?>
<sites>
  <site>
    <id>default</id>
    <url>http://mirror.xmission.com/jenkins/updates/update-center.json</url>
  </site>
</sites>
```

### 4.3、插件安装

在jenkins中安装插件 系统管理 --> 插件管理

#### 4.3.1、需要下载的插件列表

```bash
Git plugin        git
GitLab Plugin     gitlab
Kubernetes plugin 动态创建代理
Pipeline          流水线
Email Extension   邮件扩展
```

安装插件实在太慢。几kb每秒 ╮(￣▽￣)╭

我们有一个思路解决这个问题 []~(￣▽￣)~*

#### 4.3.2、告诉jenkins 我哪些插件需要更新

使用清华大学镜像地址https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

1.进入jenkins系统管理
2.进入插件管理（Manage Plugins）

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571308227988.png)

-- > 高级 -- > 升级站点

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571308284414.png)

#### 4.3.3、原理

https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json 这个文件里面 包含了所有插件的更新地址，清华把这个文件拿过来了，但是没有把里面的插件升级地址改成清华。下载插件还是要到国外主机去下载，这样只会获取更新信息快，实际下载插件慢的一批。

```
curl -vvvv  http://updates.jenkins-ci.org/download/plugins/ApicaLoadtest/1.10/ApicaLoadtest.hpi
302到
http://mirrors.jenkins-ci.org/plugins/ApicaLoadtest/1.10/ApicaLoadtest.hpi
又重定向到一个ftp地址分流。

清华的地址是：
https://mirrors.tuna.tsinghua.edu.cn/jenkins/plugins/ApicaLoadtest/1.10/ApicaLoadtest.hpi
只要把mirrors.jenkins-ci.org 代理到 mirrors.tuna.tsinghua.edu.cn/jenkins 即可。
```

#### 4.3.4、欺骗jenkins去清华下载插件

绑定 `mirrors.jenkins-ci.org` 域名到本机 `/etc/hosts` 中
``` bash
[root@support nginx]# cat /etc/hosts
127.0.0.1 mirrors.jenkins-ci.org
```

nginx反向代理至清华的jenkins插件下载地址
``` bash
[root@support ~]# cat /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {

    access_log  /var/log/nginx/access.log;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server
    {
        listen 80;
        server_name mirrors.jenkins-ci.org;
        root    /usr/share/nginx/html;

        location / {
            proxy_redirect off;
            proxy_pass https://mirrors.tuna.tsinghua.edu.cn/jenkins/;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Accept-Encoding "";
            proxy_set_header Accept-Language "zh-CN";
        }
        index index.html index.htm index.php;

        location ~ /\.
        {
            deny all;
        }

    }

}
```

最后我们来看一下nginx访问日志。从本机发送的jenkins下载插件的请求全部转发到清华镜像源了。
```
127.0.0.1 - - [14/Oct/2019:23:40:32 +0800] "GET /plugins/kubernetes-credentials/0.4.1/kubernetes-credentials.hpi HTTP/1.1" 200 17893 "-" "Java/1.8.0_222"
127.0.0.1 - - [14/Oct/2019:23:40:37 +0800] "GET /plugins/variant/1.3/variant.hpi HTTP/1.1" 200 10252 "-" "Java/1.8.0_222"
127.0.0.1 - - [14/Oct/2019:23:40:40 +0800] "GET /plugins/kubernetes-client-api/4.6.0-2/kubernetes-client-api.hpi HTTP/1.1" 200 11281634 "-" "Java/1.8.0_222"
127.0.0.1 - - [14/Oct/2019:23:40:42 +0800] "GET /plugins/kubernetes/1.20.0/kubernetes.hpi HTTP/1.1" 200 320645 "-" "Java/1.8.0_222"
127.0.0.1 - - [14/Oct/2019:23:40:45 +0800] "GET /plugins/git/3.12.1/git.hpi HTTP/1.1" 200 2320552 "-" "Java/1.8.0_222"
127.0.0.1 - - [14/Oct/2019:23:40:47 +0800] "GET /plugins/gitlab-plugin/1.5.13/gitlab-plugin.hpi HTTP/1.1" 200 8456411 "-" "Java/1.8.0_222"
```

按照推荐做法，发现速度太快了，基本上秒下 (￣ˇ￣) 网上的大部分教程只做到第一步，设置完了，有时候能加速，有时候不能，这才是真正的最终解决方案。

> 当然为了做到这一步踩了一晚上的坑，首先在K8S中以pod部署的jenkins不能用这种代理方式。在苦试无果后，我只能非常粗暴的在NFS服务器上安装了一个同版本的jenkins，实测发现pod中的本地持久目录/var/jenkins_home所对应的路径中的文件直接拷贝至/var/lib/jenkins中，这个新jenkins的运行状态与pod中的jenkins一致。所以在新jenkins下载插件后，将插件目录/var/lib/jenkins/plugins直接拷贝进pod持久卷即可。
>

### 4.4、gitlab触发jenkins

#### 4.4.1、gitlab生成token

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571121059036.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571126582928.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571126690361.png)

复制此token，此token只显示一次：**vze6nS8tLAQ1dVpdaHYU**

#### 4.4.2、jenkins配置连接gitlab

点击 系统管理 --> 系统设置，找到gitlab

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571141514383.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571126994610.png)

类型选择gitlab api token，将gitab生成的token填入

#### 4.4.3、创建jenkins任务

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185154.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185223.png)

这个地址用来设置gitlab的webhook：http://139.9.139.49:30006/project/gitlab-citest-pipeline

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185236.png)

点击生成token：**2daf58bf638f04ce9e201ef0df9bec0f**

此token也是用来设置gitlab的**webhook**

#### 4.4.4、gitlab设置webhooks

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185544.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185552.png)

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191017204517.png)

#### 4.4.5、提交代码至gitlab触发jenkins任务

先将gitlab上面的仓库克隆至本地

```
[root@support ~]# git clone http://139.9.134.177:10080/miao/citest.git
Cloning into 'citest'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
```

修改后提交代码至gitlab

```bash
[root@support citest]# git commit -m "Testing gitlab and jenkins Connection #1"
[master 03264a7] Testing gitlab and jenkins Connection 1
 1 file changed, 3 insertions(+), 1 deletion(-)
[root@support citest]# git push origin master
Username for 'http://139.9.134.177:10080': miao
Password for 'http://miao@139.9.134.177:10080': 
Counting objects: 5, done.
Writing objects: 100% (3/3), 294 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To http://139.9.134.177:10080/miao/citest.git
   25f05bb..03264a7  master -> master
```

jenkins任务已经开始执行

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191015185613.png)

显示任务由gitlab触发，第一阶段成功。

### 4.5、jenkins在kubernetes中创建动态代理

我们这里使用了Docker in Docker技术，就是把jenkins部署在k8s里。jenkins master会动态创建slave pod，使用slave pod运行代码克隆，项目构建，镜像构建等指令操作。构成完成以后删除这个slave pod。减轻jenkins-master的负载，可以极大地提高资源利用率。

#### 4.5.1、配置连接kubernetes

我们已经安装了Kubernetes插件，我们直接在jenkins中点击

系统管理 -- > 系统设置 -- > 拉到最底下有一个云。

新增一个云 --> kubernetes

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571188089972.png)

因为jenkins是直接运行在k8s上的，所以可以直接通过k8s的dns访问kubernetes的service名称的。点击 --> 测试连接，成功连接k8s。

然后点击-->保存

#### 4.5.2、构建Jenkins-Slave镜像

> github官方构建slave文档
>
> https://github.com/jenkinsci/docker-jnlp-slave

构建jenkins-slave镜像我们需要准备四个文件

1、在jenkins地址栏输入下列地址获取slave.jar

http://119.3.226.210:30006/jnlpJars/slave.jar

2、slave.jar的启动脚本jenkins-slave

```shell
[root@support jenkins-slave]# cat jenkins-slave 
#!/usr/bin/env sh

if [ $# -eq 1 ]; then

	# if `docker run` only has one arguments, we assume user is running alternate command like `bash` to inspect the image
	exec "$@"

else

	# if -tunnel is not provided try env vars
	case "$@" in
		*"-tunnel "*) ;;
		*)
		if [ ! -z "$JENKINS_TUNNEL" ]; then
			TUNNEL="-tunnel $JENKINS_TUNNEL"
		fi ;;
	esac

	# if -workDir is not provided try env vars
	if [ ! -z "$JENKINS_AGENT_WORKDIR" ]; then
		case "$@" in
			*"-workDir"*) echo "Warning: Work directory is defined twice in command-line arguments and the environment variable" ;;
			*)
			WORKDIR="-workDir $JENKINS_AGENT_WORKDIR" ;;
		esac
	fi

	if [ -n "$JENKINS_URL" ]; then
		URL="-url $JENKINS_URL"
	fi

	if [ -n "$JENKINS_NAME" ]; then
		JENKINS_AGENT_NAME="$JENKINS_NAME"
	fi  

	if [ -z "$JNLP_PROTOCOL_OPTS" ]; then
		echo "Warning: JnlpProtocol3 is disabled by default, use JNLP_PROTOCOL_OPTS to alter the behavior"
		JNLP_PROTOCOL_OPTS="-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=true"
	fi

	# If both required options are defined, do not pass the parameters
	OPT_JENKINS_SECRET=""
	if [ -n "$JENKINS_SECRET" ]; then
		case "$@" in
			*"${JENKINS_SECRET}"*) echo "Warning: SECRET is defined twice in command-line arguments and the environment variable" ;;
			*)
			OPT_JENKINS_SECRET="${JENKINS_SECRET}" ;;
		esac
	fi
	
	OPT_JENKINS_AGENT_NAME=""
	if [ -n "$JENKINS_AGENT_NAME" ]; then
		case "$@" in
			*"${JENKINS_AGENT_NAME}"*) echo "Warning: AGENT_NAME is defined twice in command-line arguments and the environment variable" ;;
			*)
			OPT_JENKINS_AGENT_NAME="${JENKINS_AGENT_NAME}" ;;
		esac
	fi

	#TODO: Handle the case when the command-line and Environment variable contain different values.
	#It is fine it blows up for now since it should lead to an error anyway.

	exec java $JAVA_OPTS $JNLP_PROTOCOL_OPTS -cp /usr/share/jenkins/slave.jar hudson.remoting.jnlp.Main -headless $TUNNEL $URL $WORKDIR $OPT_JENKINS_SECRET $OPT_JENKINS_AGENT_NAME "$@"
fi
```

3、maven的配置文件

```xml
[root@support jenkins-slave]# cat settings.xml 
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <pluginGroups>
  </pluginGroups>
  <proxies>
  </proxies>
  <servers>
  </servers>
  <mirrors>
    <mirror>     
      <id>central</id>     
      <mirrorOf>central</mirrorOf>     
      <name>aliyun maven</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
  <profiles>
  </profiles>
</settings>
```

4、Dockerfile

```bash
FROM centos:7
LABEL maintainer lizhenliang

# 使镜像具有拖git仓库，编译java代码的能力
RUN yum install -y java-1.8.0-openjdk maven curl git libtool-ltdl-devel && \ 
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    mkdir -p /usr/share/jenkins

# 将获取到slave.jar放入镜像
COPY slave.jar /usr/share/jenkins/slave.jar
# jenkins-slave执行脚本
COPY jenkins-slave /usr/bin/jenkins-slave
# settings.xml中设置了aliyun的镜像
COPY settings.xml /etc/maven/settings.xml
RUN chmod +x /usr/bin/jenkins-slave

ENTRYPOINT ["jenkins-slave"]
```

把这4个文件放在同级目录下，接下来我们开始构建slave镜像

构建镜像并打上标签

```bash
[root@support jenkins-slave]# docker build . -t 139.9.134.177:8080/jenkinsci/jenkins-slave-jdk:1.8
[root@support jenkins-slave]# docker image ls
REPOSITORY                                       TAG                        IMAGE ID            CREATED             SIZE
139.9.134.177:8080/jenkinsci/jenkins-slave-jdk   1.8                        940e56848837        3 minutes ago       535MB
```

开始推送镜像

http登录拒绝，docker默认是https的，需要修改daemon.json

``` bash
[root@support jenkins-slave]# docker login 139.9.134.177:8080
Username: admin
Password: 
Error response from daemon: Get https://139.9.134.177:8080/v2/: http: server gave HTTP response to HTTPS client
# 增加http的信任
[root@support ~]# cat /etc/docker/daemon.json
{
    "registry-mirrors": ["http://f1361db2.m.daocloud.io"],
    "insecure-registries": ["http://139.9.134.177:8080"]
}
# 成功登录
[root@support ~]# docker login 139.9.134.177:8080
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```
> 所有的k8s主机也需要配置访问harbor的地址。重启docker服务。
>
> 我们设置信任的地址为内网地址，以保证足够的速度。

#### 4.5.3、Jenkins任务由k8s的pod执行

使用以下pipeline脚本动态创建pod
```
// 镜像仓库地址
def registry = "10.0.0.123:8080"

podTemplate(label: 'jenkins-agent', cloud: 'kubernetes', 
    containers: [
    containerTemplate(
        name: 'jnlp', 
        image: "${registry}/jenkinsci/jenkins-slave-jdk:1.8"
    )],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker')
    ]) 
{
  node("jenkins-agent"){
        stage('拉取代码') { // for display purposes
            git 'http://139.9.134.177:10080/miao/citest.git'
            sh 'ls'
        }
        stage('代码编译') {
            echo 'ok'
        }
        stage('部署') {
            echo 'ok'
        }
    }
}
```

### 4.6、使用pipeline脚本持续集成

使用pipeline脚本将每次提交gitlab的代码拉取下来，编译为docker镜像推送至harbor中。

在这里我们需要先配置两个凭据，因为我们gitlab代码仓库是私有的，harbor仓库也是私有的，只有配置凭据jenkins才能访问。

输入gitlab的账号和密码，生成一个凭据后，复制凭据的id，在pipeline中引用

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191017202148.png)

输入harbor的账号和密码，生成一个凭据后，复制凭据的id，在pipeline中引用

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191017202343.png)


```pipeline
// 镜像仓库地址
def registry = "10.0.0.123:8080"
// 镜像仓库项目
def project = "jenkinsci"
// 镜像名称
def app_name = "citest"
// 镜像完整名称
def image_name = "${registry}/${project}/${app_name}:${BUILD_NUMBER}"
// git仓库地址
def git_address = "http://139.9.134.177:10080/miao/citest.git"

// 认证
def harbor_auth = "db4b7f06-7df6-4da7-b5b1-31e91b7a70e3"
def gitlab_auth = "53d88c8f-3063-4048-9205-19fc6222b887"

podTemplate(
    label: 'jenkins-agent', 
    cloud: 'kubernetes', 
    containers: [
        containerTemplate(
            name: 'jnlp', 
            image: "${registry}/jenkinsci/jenkins-slave-jdk:1.8"
        )
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker')
    ]
) 
{
  node("jenkins-agent"){
        stage('拉取代码') { // for display purposes
            checkout([$class: 'GitSCM', branches: [[name: '${Branch}']], userRemoteConfigs: [[credentialsId: "${gitlab_auth}", url: "${git_address}"]]])
            sh "ls"
        }
        stage('代码编译') {
            sh "mvn clean package -Dmaven.test.skip=true"
            sh "ls"
        }
        stage('构建镜像') {
            withCredentials([usernamePassword(credentialsId: "${harbor_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {
				sh """
					echo '
						FROM tomcat
						LABEL maintainer miaocunfa
						RUN rm -rf /usr/local/tomcat/webapps/*
						ADD target/*.war /usr/local/tomcat/webapps/ROOT.war 
					' > Dockerfile

					docker build -t ${image_name} .
					docker login -u ${username} -p '${password}' ${registry}
					docker push ${image_name}
				"""
			}
		}
	}
}
```

写脚本用来提交gitlab
```bash
[root@support ~]# cat gitpush.sh 
testdate=$(date)
cd /root/citest
echo $testdate >> pod-slave.log
git add -A
git commit -m "$testdate"
git push origin master
```

代码提交已经触发了编号为33的任务开始构建。
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571157048086.png)

jenkins构建过程中的日志。
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571157129255.png)

jenkins构建成功后，harbor中已经有了标签为33的镜像。
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571157177558.png)

### 4.7、Jenkins在Kubernetes中持续部署

已经成功使用jenkins构建好镜后，接下来完成将镜像部署在K8s平台。这个过程我们需要用到插件`Kubernetes Continuous Deploy Plugin`

#### 4.7.1、k8s认证

将`.kube/config`的内容拷贝至jenkins中生成凭据

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571195173029.png)

拷贝凭据的id到pipeline脚本中引用

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/20191017202821.png)

#### 4.7.2、k8s添加harbor仓库secret

```bash
[root@master ~]# kubectl create secret docker-registry harbor-pull-secret --docker-server='http://10.0.0.123:8080' --docker-username='admin' --docker-password='Harbor12345'
secret/harbor-pull-secret created
```

#### 4.7.3、pipeline脚本

```pipeline
// 镜像仓库地址
def registry = "10.0.0.123:8080"
// 镜像仓库项目
def project = "jenkinsci"
// 镜像名称
def app_name = "citest"
// 镜像完整名称
def image_name = "${registry}/${project}/${app_name}:${BUILD_NUMBER}"
// git仓库地址
def git_address = "http://139.9.134.177:10080/miao/citest.git"

// 认证
def harbor_auth = "db4b7f06-7df6-4da7-b5b1-31e91b7a70e3"
def gitlab_auth = "53d88c8f-3063-4048-9205-19fc6222b887"

// K8s认证
def k8s_auth = "586308fb-3f92-432d-a7f7-c6d6036350dd"
// harbor仓库secret_name
def harbor_registry_secret = "harbor-pull-secret"
// k8s部署后暴露的nodePort
def nodePort = "30666"

podTemplate(
    label: 'jenkins-agent', 
    cloud: 'kubernetes', 
    containers: [
        containerTemplate(
            name: 'jnlp', 
            image: "${registry}/jenkinsci/jenkins-slave-jdk:1.8"
        )
    ],
    volumes: [
        hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'),
        hostPathVolume(mountPath: '/usr/bin/docker', hostPath: '/usr/bin/docker')
    ]
) 
{
  node("jenkins-agent"){
        stage('拉取代码') { // for display purposes
            checkout([$class: 'GitSCM', branches: [[name: '${Branch}']], userRemoteConfigs: [[credentialsId: "${gitlab_auth}", url: "${git_address}"]]])
            sh "ls"
        }
        stage('代码编译') {
            sh "mvn clean package -Dmaven.test.skip=true"
            sh "ls"
        }
        stage('构建镜像') {
            withCredentials([usernamePassword(credentialsId: "${harbor_auth}", passwordVariable: 'password', usernameVariable: 'username')]) {
				sh """
					echo '
						FROM tomcat
						LABEL maintainer miaocunfa
						RUN rm -rf /usr/local/tomcat/webapps/*
						ADD target/*.war /usr/local/tomcat/webapps/ROOT.war 
					' > Dockerfile

					docker build -t ${image_name} .
					docker login -u ${username} -p '${password}' ${registry}
					docker push ${image_name}
				"""
			}
		}
		stage('部署到K8s'){
            sh """
                sed -i 's#\$IMAGE_NAME#${image_name}#' deploy.yml
                sed -i 's#\$SECRET_NAME#${harbor_registry_secret}#' deploy.yml
                sed -i 's#\$NODE_PORT#${nodePort}#' deploy.yml
            """
            kubernetesDeploy configs: 'deploy.yml', kubeconfigId: "${k8s_auth}"
		}
	}
}
```

##### deploy.yaml

用来将镜像部署为deployment控制器控制的pod，放在代码仓库中跟代码一起推送。
```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: web
spec:
  replicas: 3 
  selector:
    matchLabels:
      app: java-demo
  template:
    metadata:
      labels:
        app: java-demo
    spec:
      imagePullSecrets:
      - name: $SECRET_NAME
      containers:
      - name: tomcat 
        image: $IMAGE_NAME
        ports:
        - containerPort: 8080
          name: web
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 20
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 20
          timeoutSeconds: 5
          failureThreshold: 3

---

kind: Service
apiVersion: v1
metadata:
  name: web
spec:
  type: NodePort
  selector:
    app: java-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      nodePort: $NODE_PORT
```

#### 4.7.4、推送

下面是整个完整的CI/CD流程

1、git推送代码至gitlab代码仓库

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571306212116.png)

2、gitlab使用webhook触发jenkins任务

左下角webhook已经触发，编号为53的jenkins任务已经开始
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571306150537.png)

jenkins任务流程![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571306189832.png)

3、harbor镜像仓库

tag标签为53的镜像也已经推送至harbor

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571307409818.png)

4、使用kubectl监控pods的变化
jenkins在任务流程中会先构建slave pod，在执行完将镜像部署到kubernetes后，slave pod会销毁，web镜像处于running状态。
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571306688679.png)

5、邮件通知
在整个jenkins任务执行成功后，发送邮件通知

邮件的配置会在4.8优化部分贴出来。

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571307521487.png)

### 4.8、优化部分
#### 4.8.1、pipeline脚本跟代码一起托管

Jenkinsfile放在代码仓库的好处就是，可以对Jenkinsfile也做一个版本的管理，与当前项目生命周期是一致的。

首先将pipeline脚本保存至本地git仓库中，文件名为Jenkinsfile

jenkins配置如下

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571309501720.png)

#### 4.8.2、构建成功后添加邮件通知

1、邮件通知需要用到已经安装好的一个插件Email Extension

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571309688406.png)

2、Email Extension的配置

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571309850703.png)

3、邮件模板内容，html模板

![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571309872051.png)

4、系统默认邮件服务配置，配置完可以发送测试邮件。
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571309995576.png)

5、测试邮件内容
![](https://miao-blog-md.oss-cn-qingdao.aliyuncs.com/img/1571310066732.png)

##### 邮件模板

```html
<!DOCTYPE html>    
<html>    
<head>    
<meta charset="UTF-8">    
<title>${ENV, var="JOB_NAME"}-第${BUILD_NUMBER}次构建日志</title>    
</head>    
    
<body leftmargin="8" marginwidth="0" topmargin="8" marginheight="4"    
    offset="0">    
    <table width="95%" cellpadding="0" cellspacing="0"  style="font-size: 11pt; font-family: Tahoma, Arial, Helvetica, sans-serif">    
        <tr>    
            本邮件由系统自动发出，无需回复！<br/>            
            各位同事，大家好，以下为${PROJECT_NAME }项目构建信息</br> 
            <td><font color="#CC0000">构建结果 - ${BUILD_STATUS}</font></td>   
        </tr>    
        <tr>    
            <td><br />    
            <b><font color="#0B610B">构建信息</font></b>   
            <hr size="2" width="100%" align="center" /></td>    
        </tr>    
        <tr>    
            <td>    
                <ul>    
                    <li>项目名称 ： ${PROJECT_NAME}</li>    
                    <li>构建编号 ： 第${BUILD_NUMBER}次构建</li>    
                    <li>触发原因 ： ${CAUSE}</li>    
                    <li>构建状态 ： ${BUILD_STATUS}</li> 
		    <li>构建信息 ： <a href="${BUILD_URL}">${BUILD_URL}</a></li>					
                    <li>构建日志 ： <a href="${BUILD_URL}console">${BUILD_URL}console</a></li>    
                    <li>构建历史 ： <a href="${PROJECT_URL}">${PROJECT_URL}</a></li> 
		    <!--<li>部署地址 ： <a href="${project_url}">${project_url}</a></li>-->
                </ul>    

				<h4><font color="#0B610B">失败用例</font></h4>
				<hr size="2" width="100%" />
				$FAILED_TESTS<br/>

				<h4><font color="#0B610B">最近提交(#$SVN_REVISION)</font></h4>
				<hr size="2" width="100%" />
				<ul>
				${CHANGES_SINCE_LAST_SUCCESS, reverse=true, format="%c", changesFormat="<li>%d [%a] %m</li>"}
				</ul>
				<font color="#0B610B">详细提交: </font><a href="${PROJECT_URL}changes">${PROJECT_URL}changes</a><br/>

            </td>    
        </tr>    
    </table>    
</body>    
</html> 
```

在持续集成这一块我还是一个初学者，期望得到您的指点。