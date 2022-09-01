
搭建k8s 集群

## 问题处理

1、harbor http问题

``` zsh
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  12m                  default-scheduler  Successfully assigned default/enterprise-gateway-5f755479dc-m4rql to test-k8s-node02
  Normal   Pulling    10m (x4 over 12m)    kubelet            Pulling image "172.31.229.139:9999/gjr-test/enterprise-gateway:17"
  Warning  Failed     10m (x4 over 12m)    kubelet            Failed to pull image "172.31.229.139:9999/gjr-test/enterprise-gateway:17": rpc error: code = Unknown desc = failed to pull and unpack image "172.31.229.139:9999/gjr-test/enterprise-gateway:17": failed to resolve reference "172.31.229.139:9999/gjr-test/enterprise-gateway:17": failed to do request: Head https://172.31.229.139:9999/v2/gjr-test/enterprise-gateway/manifests/17: http: server gave HTTP response to HTTPS client
  Warning  Failed     10m (x4 over 12m)    kubelet            Error: ErrImagePull
  Warning  Failed     10m (x6 over 12m)    kubelet            Error: ImagePullBackOff
  Normal   BackOff    106s (x44 over 12m)  kubelet            Back-off pulling image "172.31.229.139:9999/gjr-test/enterprise-gateway:17"
```

问题解决

``` zsh
# 所有 worker节点都要执行
➜  vim /etc/containerd/config.toml

    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry.cn-hangzhou.aliyuncs.com"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."172.31.229.139:9999"]
          endpoint = ["http://172.31.229.139:9999"]

# 重启 containerd
➜  systemctl restart containerd

# 查看 pod状态
➜  kubectl get pods
NAME                                 READY   STATUS    RESTARTS   AGE
enterprise-gateway-d75c57857-p82ch   1/1     Running   0          2m
```

## 测试 DNS状态

``` zsh
➜  kubectl exec -it enterprise-gateway-d75c57857-p82ch -- /bin/bash
[root@enterprise-gateway-d75c57857-p82ch jdk]# ping r-m5ex8cg50xgw56uj3e.redis.rds.aliyuncs.com
PING r-m5ex8cg50xgw56uj3e.redis.rds.aliyuncs.com (192.168.99.110) 56(84) bytes of data.
64 bytes from 192.168.99.110 (192.168.99.110): icmp_seq=1 ttl=101 time=0.506 ms
64 bytes from 192.168.99.110 (192.168.99.110): icmp_seq=2 ttl=101 time=0.512 ms
64 bytes from 192.168.99.110 (192.168.99.110): icmp_seq=3 ttl=101 time=0.538 ms
^C
--- r-m5ex8cg50xgw56uj3e.redis.rds.aliyuncs.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 0.506/0.518/0.538/0.029 ms
```

## 安装nginx ingress

``` zsh
# 修改yaml
https://www.jianshu.com/p/90a0c85d263d

➜  kubectl get ingressclasses
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       29d

# ingress 安装好后 无法生效
➜  cat enterprise-api-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: enterprise-api-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx" # 绑定ingress-class
    nginx.ingress.kubernetes.io/ssl-redirect: "false" # 关闭SSL跳转
spec:
  rules:
  - host: enterprise.apitest.gongjiangren.net
    http:
      paths:
      - path: /
        pathType: Prefix
        backend: 
           service: 
             name: enterprise-gateway
             port: 
               number: 8800

➜  kubectl get ing
NAME                     CLASS    HOSTS                                 ADDRESS   PORTS   AGE
enterprise-api-ingress   <none>   enterprise.apitest.gongjiangren.net             80      25d
```
