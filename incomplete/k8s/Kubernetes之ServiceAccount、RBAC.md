Kubernetes之ServiceAccount、RBAC

kubernetes三级认证模式：认证、授权、准入控制

serviceAccount认证用于认证

```
kubectl api-versions
```

.kube/config客户端认证

```bash
kubectl proxy --port=8080
curl http://localhost:8080/api/v1/namespaces
回返回所有namespaces的json
restful风格 表针状态转移。
k8s类型分为三大类别：对象类 绝大部分内容
			   集合，列表
			   虚拟对象，虚拟路径，非对象资源，非资源url 很少用到
只有核心群组v1才可以访问api,其他群组都要访问apis
curl http://localhost:8080/apis/apps/v1/namespaces/kube-system/deployments
```

Object URL:
/apis/<GROUP>/<VERSION>/namespaces/<NAMESPACE_NAME>/<KIND>[/OBJECT_ID]

根据k8s CA证书签署新证书，用于新客户端登录

```
/etc/kubernetes/pki/ca.crt
证书中的持有者必须跟用户名保持一致
为了安全打开子shell
(umask 077; openssl genrsa -out miao.key 2048)
基于私钥生成证书,-subj指明账号名称
openssl req -new -key miao.key -out miao.csr -subj "/CN=miao"
由ca.crt签署
openssl x509 -req -in miao.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out miao.crt -days 365
查看证书信息
openssl x509 in miao.crt -text -noout
Issuer: CN=user
Subject: CN=user

# config文件新增用户信息
kubectl config set-credentials miao --client-certificate=./miao.crt --client-key=./miao.key --embed-certs=true
# config文件新增上下文
kubectl config set-context miao@kubernetes --cluster=kubernetes --user=miao
# 切换用户
kubectl config use-context miao@kubernetes

#新增一个config的用法
kubectl config set-cluster mycluster --kubeconfig=/tmp/test.conf --server="https://172.20.0.70:6443" --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
```

kubernetes授权基于插件实现，用户访问时某一次操作经由其中某一授权插件检查通过后，就不再接受其他授权插件检查了，然后由准入控制插件再进行后续的检查。

在众多授权插件中，常用的有四个：Node, ABAC(基于属性的认证), RBAC(基于角色的认证), Webhook(基于http的回调机制)

RBAC：Role-based access contorl

我们让一个用户扮演一种角色，这个角色用有某种权限，所以用户就拥有了某种权限。我们授权不授予用户而授予角色。

角色 (role)：我们授予角色某种被许可的权限。就是在某些对象上实现某些操作的权限。

许可 (permission)：对于某个对象Objects施加的某种行为action，我们称这种操作叫Operations，在一个对象上能施加的操作组合起来，我们称为许可权限

```
role:
operations
objects

rolebinding:
user account OR service account
role
```

k8s集群资源有两种级别：集群级别、名称空间

Role RoleBinding主要在名称空间级别授予用户权限。可以定义用户获取当前名称空间中的所有pod

ClusterRole ClusterRoleBinding集群级别的用户授权。可以定义用户获取所有名称空间中的所有pod

我们可以使用RoleBinding去绑定Role，代表用户获得当前名称空间的权限

也可以使用ClusterRoleBinding去绑定ClusterRole，代表用户获得集群的权限，

但是我们还可以使用RoleBinding去绑定ClusterRole，代表用户仅能获取他所属名称空间的权限。（应用场景，比如说有10个名称空间，每个名称空间都定义一个名称空间管理员，我需要每个名称空间单独定义Role和RoleBinding，也可以定义一个ClusterRole，使用RoleBinding去绑定）

有两个非常重要的role

```
admin    #用于设置名称空间级别的管理员，直接引用clusterrole
cluster-admin
```









