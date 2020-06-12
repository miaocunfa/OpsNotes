## emptyDir
emptyDir生命周期同pod容器，pod结束，存储卷也结束。

### emptyDir 配置清单

```
pods
	spec
		containers
			volumeMounts
				name        #存储卷名
				mountPath   #挂载路径
				readOnly    #只读挂载
		volumes
			emptyDir
				medium:disk,default ""  #磁盘
					   Memory           #使用内存当磁盘用，就是当缓存用
				sizeLimit:         #空间上限，使用内存当缓存用，内存会被吃完
```

### gitRepo
gitRepo，基于emptyDir，在运行过程中基于宿主机git命令将git仓库克隆至存储卷上，在pod运行过程中，git仓库发生变化，存储卷不会同步，获得一定的持久能力。

## hostPath
hostPath，宿主机路径，在pod被删除时，这个存储卷不会被删除，但pod只能调度在这个宿主机上，节点级持久。

### hostPath 配置清单

```
pods
	spec
		containers
			volumeMounts
				name        #存储卷名
				mountPath   #挂载路径
				readOnly    #只读挂载
		volumes
			hostPath
				path
				type
				
type
DirectoryOrCreate 宿主机上的目录，不存在就创建
Directory  宿主机必须存在这个目录，不存在就报错
FileOrCreate 宿主机上的文件，不存在就创建
File   宿主机必须存在这个文件，不存在就报错
Socket  必须是一个socker类型的文件
CharDevice  必须是一个字符型设备
BlockDevice  必须是一个块设备
```

### hostPath示例
```
[root@master volume]# cat hostpath-demo.yaml 
kind: Pod
apiVersion: v1
metadata: 
  name: hostpath-demo
  namespace: default
  labels:
    app: hostpath
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html/
  volumes:
  - name: html
    hostPath:
      path: /data/pod/volume_1
      type: DirectoryOrCreate
[root@master volume]#

# 在节点note01创建存储卷目录，并创建index.html
mkdir -pv /data/pod/volume_1
[root@note01 ~]# cat /data/pod/volume_1/index.html
host:note01

# 在节点note02创建存储卷目录，并创建index.html
mkdir -pv /data/pod/volume_1
[root@note02 ~]# cat /data/pod/volume_1/index.html
host:note02

# 根据配置清单创建pod
[root@master volume]# kubectl apply -f hostpath-demo.yaml 
pod/hostpath-demo created
# 发现k8s调度pod到了note03节点上。
[root@master volume]# kubectl get pods -o wide
NAME            READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
hostpath-demo   1/1     Running   0          11s   10.100.72.16   note03   <none>           <none>
# 因为节点上没有创建存储卷，是pod自己创建的，所以没有主页文件。
[root@master volume]# curl 10.100.72.16
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.12.2</center>
</body>
</html>
[root@master volume]# kubectl delete -f hostpath-demo.yaml 
pod "hostpath-demo" deleted

#重新创建pod
[root@master volume]# kubectl apply -f hostpath-demo.yaml 
pod/hostpath-demo created
# 这次pod调度到note02上了
[root@master volume]# kubectl get pods -o wide
NAME            READY   STATUS    RESTARTS   AGE   IP              NODE     NOMINATED NODE   READINESS GATES
hostpath-demo   1/1     Running   0          17s   10.100.139.12   note02   <none>           <none>
# 访问pod的ip，跟我们创建的主页一样，至此完成持久化的试验。
[root@master volume]# curl 10.100.139.12
host:note02
[root@master volume]#
```

## NFS

### NFS配置清单

```bash
   path	  #非空，nfs服务路径
   server #非空，nfs服务主机
   readOnly	<boolean>  #是否只读挂载
```

### NFS服务验证

使用note04节点做nfs共享存储

```bash
# 安装nfs服务
[root@note04 ~]# yum -y install nfs-utils
# 创建挂载点
[root@note04 ~]# mkdir /data/volumes -pv
mkdir: created directory ‘/data’
mkdir: created directory ‘/data/volumes’
# 配置nfs服务
[root@note04 ~]# cat /etc/exports
/data/volumes 10.0.0.26(rw,no_root_squash)
/data/volumes 10.0.0.61(rw,no_root_squash)
/data/volumes 10.0.0.115(rw,no_root_squash)
# 启动nfs服务
[root@note04 ~]# systemctl start nfs
# nfs服务已经启动
[root@note04 ~]# ss -tnlp
State       Recv-Q Send-Q                                Local Address:Port                                               Peer Address:Port              
LISTEN      0      64                                                *:2049                                                          *:*                  
```

在k8s工作节点上挂载nfs，测试nfs完成后需要卸载。

```bash
# note01
[root@note01 ~]# mount -t nfs note04:/data/volumes /mnt
[root@note01 ~]# mount
note04:/data/volumes on /mnt type nfs4 (rw,relatime,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.26,local_lock=none,addr=10.0.0.189)
[root@note01 ~]# umount /mnt


# note02
[root@note02 ~]# mount -t nfs note04:/data/volumes /mnt
[root@note02 ~]# mount
note04:/data/volumes on /mnt type nfs4 (rw,relatime,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.61,local_lock=none,addr=10.0.0.189)
[root@note02 ~]# umount /mnt

# note03
[root@note03 ~]# mount -t nfs note04:/data/volumes /mnt
[root@note03 ~]# mount
note04:/data/volumes on /mnt type nfs4 (rw,relatime,vers=4.1,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.0.115,local_lock=none,addr=10.0.0.189)
[root@note03 ~]# umount /mnt
```

### NFS实例

```bash
# nfs-demo配置清单
[root@master volume]# cat nfs-demo.yaml 
apiVersion: v1
kind: Pod
metadata: 
  name: nfs-demo
  namespace: default
  labels:
    app: pod-nfs-demo
spec:
  containers:
  - name: myapp
    image: ikubernetes/myapp:v1
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html/
  volumes:
  - name: html
    nfs:
      path: /data/volumes
      server: note04
      
# 创建pod
[root@master volume]# kubectl apply -f nfs-demo.yaml 
pod/nfs-demo created
[root@master volume]# kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP              NODE     NOMINATED NODE   READINESS GATES
nfs-demo   1/1     Running   0          8s    10.100.139.13   note02   <none>           <none>
[root@master volume]# curl 10.100.139.13
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.12.2</center>
</body>
</html>

# 在note04节点创建index.html
[root@note04 ~]# echo "note04:nfs-server" >> /data/volumes/index.html
# 重新访问pod
[root@master volume]# curl 10.100.139.13
note04:nfs-server
```

使用deployment创建多个pods，同时访问共享存储。

基于nfs做存储卷，有了真正意义上的持久存储能力，但nfs并不是分布式存储，没有冗余能力。

## PV、PVC

PVC和PV是一一对应，一旦某个PV被某个PVC占用了，他会显示PV状态为binding
一个PVC创建后，就相当于一个存储卷了，这个存储卷可以被多个pod访问。

### PV 配置清单解析
```
apiVersion: v1
kind: PersistentVolume
metadata
	name
	label
	集群级别的资源不能定义在名称空间中。
spec
	accessModes  #读写模式
	capacity     #空间大小，G(千进制) Gi(1024制)
	persistentVolumeReclaimPolicy #pv回收策略
	storageClassName
	nfs  #存储形式，可选择其他存储形式
		path     #非空
		server   #非空
		readOnly

---
accessModes：读写模式,需要底层存储设备支持，定义的时候可以设置为存储设备的子集，不能超集
ReadWriteOnce(RWO) 单路读写
ReadOnlyMany(ROX)  多路只读
ReadWriteMany(RWX) 多路读写
---
persistentVolumeReclaimPolicy：某一个pvc绑定了这个pv，后来pvc又释放了，绑定不存在了，pv怎么处理。
Retain  #保留数据不处理
Delete  #pvc不要这个pv了，这个pv就自杀 ╮(￣▽￣)╭
Recycle #回收，把数据全删掉
```

### PVC 配置清单解析
```
apiversion: v1
kind: persistentVolumeClaim
metadata:
	name
	namespace
spec
	accessModes #访问模式,设置一定为PV的子集才可以。
	dataSource
    resources   #资源限制,PV要大于这个值才会被匹配到。
    	request
    		storage
    selector
    storageClassName #存储类名称
    volumeMode
    volumeName
    
---

```

### PV实例
现在通过NFS服务器做测试，先将NFS的卷做成PV
```bash
[root@note04 ~]# cd /data/volumes/
# 创建挂载点
[root@note04 volumes]# mkdir -pv v{1,2,3,4,5}
mkdir: created directory ‘v1’
mkdir: created directory ‘v2’
mkdir: created directory ‘v3’
mkdir: created directory ‘v4’
mkdir: created directory ‘v5’
# 修改nfs配置文件
[root@note04 ~]# cat /etc/exports
/data/volumes/v1 10.0.0.0/24(rw,no_root_squash)
/data/volumes/v2 10.0.0.0/24(rw,no_root_squash)
/data/volumes/v3 10.0.0.0/24(rw,no_root_squash)
/data/volumes/v4 10.0.0.0/24(rw,no_root_squash)
/data/volumes/v5 10.0.0.0/24(rw,no_root_squash)
# 导出挂载
[root@note04 volumes]# exportfs -arv
exporting 10.0.0.0/24:/data/volumes/v5
exporting 10.0.0.0/24:/data/volumes/v4
exporting 10.0.0.0/24:/data/volumes/v3
exporting 10.0.0.0/24:/data/volumes/v2
exporting 10.0.0.0/24:/data/volumes/v1
# 查看挂载
[root@note04 volumes]# showmount -e
Export list for note04:
/data/volumes/v5 10.0.0.0/24
/data/volumes/v4 10.0.0.0/24
/data/volumes/v3 10.0.0.0/24
/data/volumes/v2 10.0.0.0/24
/data/volumes/v1 10.0.0.0/24
```

```bash
[root@master volume]# cat pv-demo.yaml 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv001
  labels:
    name: pv001
spec:
  nfs:
    path: /data/volumes/v1
    server: note04
  accessModes:
  - "ReadWriteMany"
  - "ReadWriteOnce"
  capacity:
    storage: 2Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv002
  labels:
    name: pv002
spec:
  nfs:
    path: /data/volumes/v2
    server: note04
  accessModes:
  - "ReadWriteMany"
  - "ReadOnlyMany"
  capacity:
    storage: 5Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv003
  labels:
    name: pv003
spec:
  nfs:
    path: /data/volumes/v3
    server: note04
  accessModes:
  - "ReadWriteMany"
  capacity:
    storage: 10Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv004
  labels:
    name: pv004
spec:
  nfs:
    path: /data/volumes/v4
    server: note04
  accessModes:
  - "ReadWriteOnce"
  - "ReadOnlyMany"
  - "ReadWriteMany"
  capacity:
    storage: 20Gi
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv005
  labels:
    name: pv005
spec:
  nfs:
    path: /data/volumes/v5
    server: note04
  accessModes:
  - "ReadWriteMany"
  - "ReadWriteOnce"
  capacity:
    storage: 10Gi
[root@master volume]#
[root@master volume]# kubectl apply -f pv-demo.yaml
persistentvolume/pv001 created
persistentvolume/pv002 created
persistentvolume/pv003 created
persistentvolume/pv004 created
persistentvolume/pv005 created
[root@master volume]# kubectl get pv
NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv001   2Gi        RWO,RWX        Retain           Available                                   6s
pv002   5Gi        ROX,RWX        Retain           Available                                   6s
pv003   10Gi       RWX            Retain           Available                                   6s
pv004   20Gi       RWO,ROX,RWX    Retain           Available                                   6s
pv005   10Gi       RWO,RWX        Retain           Available                                   6s
```

### PVC实例
```bash
[root@master volume]# cat pvc-demo.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  namespace: default
spec:
  accessModes:
  - "ReadOnlyMany"
  resources:
    requests:
      storage: 6Gi
---
apiVersion: v1
kind: Pod
metadata: 
  name: pod-pvc-demo
  namespace: default
  labels:
    app: myapp
spec:
  containers:
  - name: myapp
    image: nginx
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  volumes:
  - name: html
    persistentVolumeClaim:
      claimName: mypvc
      
[root@master volume]# kubectl apply -f pvc-demo.yaml 
persistentvolumeclaim/mypvc unchanged
pod/pod-pvc-demo created
[root@master volume]# kubectl get pods -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
pod-pvc-demo   1/1     Running   0          82s   10.100.72.19   note03   <none>           <none>
# 访问pod，由于主页文件还没有创建所以报403
[root@master volume]# curl 10.100.72.19
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.12.2</center>
</body>
</html>
# 我们可以看到pv04满足条件被选中。
[root@master volume]# kubectl get pvc
NAME    STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mypvc   Bound    pv004    20Gi       RWO,ROX,RWX                   22s
[root@master volume]# kubectl get pv
NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM           STORAGECLASS   REASON   AGE
pv001   2Gi        RWO,RWX        Retain           Available                                           6m14s
pv002   5Gi        ROX,RWX        Retain           Available                                           6m14s
pv003   10Gi       RWX            Retain           Available                                           6m14s
pv004   20Gi       RWO,ROX,RWX    Retain           Bound       default/mypvc                           6m14s
pv005   10Gi       RWO,RWX        Retain           Available                                           6m14s

# 在note04主机上的pv04路径创建主页文件。
[root@note04 ~]# cd /data/volumes/v4
[root@note04 v4]# ll
total 0
[root@note04 v4]# echo "note04:pv-pv004" >> index.html

# 在master主机重新访问成功。
[root@master volume]# curl 10.100.72.19
note04:pv-pv004
```





