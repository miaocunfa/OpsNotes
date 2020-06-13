https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/metrics-server
https://github.com/kubernetes-incubator/metrics-server


```
[root@master metrics]# kubectl logs -n kube-system metrics-server-v0.3.6-54765b6f4c-4wwsn
Error from server (BadRequest): a container name must be specified for pod metrics-server-v0.3.6-54765b6f4c-4wwsn, choose one of: [metrics-server metrics-server-nanny]
[root@master metrics]# kubectl logs -n kube-system metrics-server-v0.3.6-54765b6f4c-4wwsn -c metrics-server
Flag --deprecated-kubelet-completely-insecure has been deprecated, This is rarely the right option, since it leaves kubelet communication completely insecure.  If you encounter auth errors, make sure you've enabled token webhook auth on the Kubelet, and if you're in a test cluster with self-signed Kubelet certificates, consider using kubelet-insecure-tls instead.
I1028 16:13:43.954765       1 serving.go:312] Generated self-signed cert (apiserver.local.config/certificates/apiserver.crt, apiserver.local.config/certificates/apiserver.key)
I1028 16:13:44.846043       1 secure_serving.go:116] Serving securely on [::]:443
E1028 16:14:14.856830       1 manager.go:111] unable to fully collect metrics: [unable to fully scrape metrics from source kubelet_summary:node01: unable to fetch metrics from Kubelet node01 (172.31.194.106): Get http://172.31.194.106:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.106:10255: connect: connection refused, unable to fully scrape metrics from source kubelet_summary:master: unable to fetch metrics from Kubelet master (172.31.194.108): Get http://172.31.194.108:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.108:10255: connect: connection refused, unable to fully scrape metrics from source kubelet_summary:node02: unable to fetch metrics from Kubelet node02 (172.31.194.107): Get http://172.31.194.107:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.107:10255: connect: connection refused]
E1028 16:14:44.853965       1 manager.go:111] unable to fully collect metrics: [unable to fully scrape metrics from source kubelet_summary:master: unable to fetch metrics from Kubelet master (172.31.194.108): Get http://172.31.194.108:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.108:10255: connect: connection refused, unable to fully scrape metrics from source kubelet_summary:node02: unable to fetch metrics from Kubelet node02 (172.31.194.107): Get http://172.31.194.107:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.107:10255: connect: connection refused, unable to fully scrape metrics from source kubelet_summary:node01: unable to fetch metrics from Kubelet node01 (172.31.194.106): Get http://172.31.194.106:10255/stats/summary?only_cpu_and_memory=true: dial tcp 172.31.194.106:10255: connect: connection refused]
[root@master metrics]# kubectl logs -n kube-system metrics-server-v0.3.6-54765b6f4c-4wwsn -c metrics-server-nanny
ERROR: logging before flag.Parse: I1028 16:15:20.258383       1 pod_nanny.go:65] Invoked by [/pod_nanny --config-dir=/etc/config --cpu={{ base_metrics_server_cpu }} --extra-cpu=0.5m --memory={{ base_metrics_server_memory }} --extra-memory={{ metrics_server_memory_per_node }}Mi --threshold=5 --deployment=metrics-server-v0.3.6 --container=metrics-server --poll-period=300000 --estimator=exponential --minClusterSize={{ metrics_server_min_cluster_size }}]
invalid argument "{{ metrics_server_min_cluster_size }}" for "--minClusterSize" flag: strconv.ParseUint: parsing "{{ metrics_server_min_cluster_size }}": invalid syntax
Usage of /pod_nanny:
      --config-dir string      Path of configuration containing base resource requirements. (default "MISSING")
      --container string       The name of the container to watch. This defaults to the nanny itself. (default "pod-nanny")
      --cpu string             The base CPU resource requirement.
      --deployment string      The name of the deployment being monitored. This is required.
      --estimator string       The estimator to use. Currently supported: linear, exponential (default "linear")
      --extra-cpu string       The amount of CPU to add per node.
      --extra-memory string    The amount of memory to add per node.
      --extra-storage string   The amount of storage to add per node. (default "0Gi")
      --memory string          The base memory resource requirement.
      --minClusterSize uint    The smallest number of nodes resources will be scaled to. Must be > 1. This flag is used only when an exponential estimator is used. (default 16)
      --namespace string       The namespace of the ward. This defaults to the nanny pod's own namespace. (default "kube-system")
      --pod string             The name of the pod to watch. This defaults to the nanny's own pod. (default "metrics-server-v0.3.6-54765b6f4c-4wwsn")
      --poll-period int        The time, in milliseconds, to poll the dependent container. (default 10000)
      --storage string         The base storage resource requirement. (default "MISSING")
      --threshold int          A number between 0-100. The dependent's resources are rewritten when they deviate from expected by more than threshold.
	  
[root@master ~]# kubectl proxy --port=8080
Starting to serve on 127.0.0.1:8080

[root@master ~]# curl http://localhost:8080/apis/metrics.k8s.io/v1beta1
{
  "kind": "APIResourceList",
  "apiVersion": "v1",
  "groupVersion": "metrics.k8s.io/v1beta1",
  "resources": [
    {
      "name": "nodes",
      "singularName": "",
      "namespaced": false,
      "kind": "NodeMetrics",
      "verbs": [
        "get",
        "list"
      ]
    },
    {
      "name": "pods",
      "singularName": "",
      "namespaced": true,
      "kind": "PodMetrics",
      "verbs": [
        "get",
        "list"
      ]
    }
  ]
}

[root@master ~]# curl http://localhost:8080/apis/metrics.k8s.io/v1beta1/nodes
{
  "kind": "NodeMetricsList",
  "apiVersion": "metrics.k8s.io/v1beta1",
  "metadata": {
    "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes"
  },
  "items": [
    {
      "metadata": {
        "name": "master",
        "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/master",
        "creationTimestamp": "2019-10-29T01:59:41Z"
      },
      "timestamp": "2019-10-29T01:59:34Z",
      "window": "30s",
      "usage": {
        "cpu": "183769010n",
        "memory": "2587192Ki"
      }
    },
    {
      "metadata": {
        "name": "node01",
        "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/node01",
        "creationTimestamp": "2019-10-29T01:59:41Z"
      },
      "timestamp": "2019-10-29T01:59:38Z",
      "window": "30s",
      "usage": {
        "cpu": "110568764n",
        "memory": "2651332Ki"
      }
    },
    {
      "metadata": {
        "name": "node02",
        "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/node02",
        "creationTimestamp": "2019-10-29T01:59:41Z"
      },
      "timestamp": "2019-10-29T01:59:39Z",
      "window": "30s",
      "usage": {
        "cpu": "107222170n",
        "memory": "2810568Ki"
      }
    }
  ]
}
      
```

