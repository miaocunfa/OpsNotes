---
title: "部署 Harbor + 阿里云OSS后端存储"
date: "2021-10-14"
categories:
    - "技术"
tags:
    - "harbor"
    - "OSS"
    - "容器化"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                         |
| ---------- | ---------------------------- |
| 2021-10-14 | 初稿                         |
| 2021-10-15 | 阿里云 OSS                   |
| 2021-10-16 | OSS 权限调整 && 文档结构优化 |

## 软件版本

| soft           | Version |
| -------------- | ------- |
| CentOS         | 7.6     |
| harbor         | v2.3.3  |
| docker-ce      | 20.10.9 |
| docker-compose | 1.18.0  |

## 一、阿里云 OSS 环境准备

①首先打开阿里云 [RAM访问控制](https://ram.console.aliyun.com/users/)，创建OSS管理用户添加权限如下图

![RAM访问控制](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20211015_02.jpg)

②使用OSS管理用户的 `accesskey` 登陆 `OSS Browser` 创建 Bucket 管理，[点击下载OSS Browser](https://help.aliyun.com/document_detail/209974.html)

![创建bucket](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20211015_03.jpg)

③获取访问Bucket的信息

harbor官网 [关于如何配置后端存储的链接](https://goharbor.io/docs/2.3.0/install-config/configure-yml-file/#backend)
docker官网 [关于如何配置后端存储的链接](https://docs.docker.com/registry/configuration/#storage)
github [OSS驱动说明文档](https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/oss.md)  

下面是OSS驱动说明文档中的重要部分

| Parameter         | Required | Description                                                                                                                                                                                                                                                                   |
| :---------------- | :------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `accesskeyid`     | yes      | Your access key ID.                                                                                                                                                                                                                                                           |
| `accesskeysecret` | yes      | Your access key secret.                                                                                                                                                                                                                                                       |
| `region`          | yes      | The name of the OSS region in which you would like to store objects (for example oss-cn-beijing). For a list of regions, you can look at the [official documentation](https://www.alibabacloud.com/help/doc-detail/31837.html).                                               |
| `endpoint`        | no       | An endpoint which defaults to `[bucket].[region].aliyuncs.com` or `[bucket].[region]-internal.aliyuncs.com` (when `internal=true`). You can change the default endpoint by changing this value.                                                                               |
| `internal`        | no       | An internal endpoint or the public endpoint for OSS access. The default is false. For a list of regions, you can look at the [official documentation](https://www.alibabacloud.com/help/doc-detail/31837.html).                                                               |
| `bucket`          | yes      | The name of your OSS bucket where you wish to store objects (needs to already be created prior to driver initialization).                                                                                                                                                     |
| `encrypt`         | no       | Specifies whether you would like your data encrypted on the server side. Defaults to false if not specified.                                                                                                                                                                  |
| `secure`          | no       | Specifies whether to transfer data to the bucket over ssl or not. If you omit this value, `true` is used.                                                                                                                                                                     |
| `chunksize`       | no       | The default part size for multipart uploads (performed by WriteStream) to OSS. The default is 10 MB. Keep in mind that the minimum part size for OSS is 5MB. You might experience better performance for larger chunk sizes depending on the speed of your connection to OSS. |
| `rootdirectory`   | no       | The root directory tree in which to store all registry files. Defaults to an empty string (bucket root)                                                                                                                                                                       |

综合上述说明，我们知道在 `harbor` 的配置文件 `harbor.yml` 中 `storage.oss` 选项下有四个必填项，`accesskeyid`，`accesskeysecret`，`region`，`bucket`，而且因为同地域下的ECS访问OSS，内网流量免费。所以其他选项 `endpoint` 以及 `internal` 也需要配置

这些信息可以在 [OSS控制台中获取](https://oss.console.aliyun.com/bucket)

## 二、harbor 环境准备

接下来我们可以安装harbor了

①安装 harbor 依赖 docker 以及 docker-compose, 需要先安装这两个包

``` zsh
# 安装依赖
➜  yum install -y docker-ce docker-compose

# 启动 docker
➜  systemctl start docker
```

②下载 harbor 离线安装包

``` zsh
# 从 github 下载离线安装包
➜  wget https://github.com/goharbor/harbor/releases/download/v2.3.3/harbor-offline-installer-v2.3.3.tgz
➜  tar -zxf harbor-offline-installer-v2.3.3.tgz -C /usr/local

# 查看解压后的目录
➜  cd /usr/local/harbor
➜  ll
total 610348
-rw-r--r-- 1 root root      3361 Sep 24 14:57 common.sh
-rw-r--r-- 1 root root 624956679 Sep 24 14:58 harbor.v2.3.3.tar.gz
-rw-r--r-- 1 root root      7840 Sep 24 14:57 harbor.yml.tmpl
-rwxr-xr-x 1 root root      2500 Sep 24 14:57 install.sh
-rw-r--r-- 1 root root     11347 Sep 24 14:57 LICENSE
-rwxr-xr-x 1 root root      1881 Sep 24 14:57 prepare
```

## 三、配置 && 安装

①配置文件

``` zsh
# 复制模板文件 
➜  cp harbor.yml.tmpl harbor.yml

# 修改好的配置文件全文如下
➜  vi harbor.yml
# 配置域名地址
hostname: harbor.prod.local
http:
  port: 80

harbor_admin_password: gjr@@#$$Prod@@

database:
  password: root123
  max_idle_conns: 100
  max_open_conns: 900

# 这个地方是需要配置的，官网说 配置storage_service就禁用此选项不对。
data_volume: /data/harbor

# 数据存储位置
storage_service:
  ca_bundle:
  oss:
    accesskeyid: [你的accesskeyid]
    accesskeysecret: [你的accesskeysecret]
    region: oss-cn-qingdao
    endpoint: gjr-harbor-prod.oss-cn-qingdao-internal.aliyuncs.com
    internal: true
    bucket: gjr-harbor-prod
    secure: false

trivy:
  ignore_unfixed: false
  skip_update: false
  insecure: false

jobservice:
  max_job_workers: 10

notification:
  webhook_job_max_retry: 10

chart:
  absolute_url: disabled

# Log configurations
log:
  level: info
  local:
    rotate_count: 50
    rotate_size: 200M
    location: /data/harbor.log

_version: 2.3.0

proxy:
  http_proxy:
  https_proxy:
  no_proxy:
  components:
    - core
    - jobservice
    - trivy

metric:
  enabled: false
  port: 9090
  path: /metrics

# 可以在安装前 先检查配置文件
➜  ./prepare

# 打印输出以下信息说明配置没问题
Clean up the input dir
```

②安装

``` zsh
# 执行安装脚本
➜  ./install.sh

# 打印输出以下信息证明安装成功
? ----Harbor has been installed and started successfully.----

# 使用 docker-compose 查看容器状态
➜  docker-compose ps
      Name                     Command               State             Ports
--------------------------------------------------------------------------------------
harbor-core         /harbor/entrypoint.sh            Up
harbor-db           /docker-entrypoint.sh 96 13      Up
harbor-jobservice   /harbor/entrypoint.sh            Up
harbor-log          /bin/sh -c /usr/local/bin/ ...   Up      127.0.0.1:1514->10514/tcp
harbor-portal       nginx -g daemon off;             Up
nginx               nginx -g daemon off;             Up      0.0.0.0:80->8080/tcp
redis               redis-server /etc/redis.conf     Up
registry            /home/harbor/entrypoint.sh       Up
registryctl         /home/harbor/start.sh            Up
```

## 四、推送镜像

要推送镜像到harbor，docker主机首先要执行以下几步操作

①修改hosts文件

``` zsh
# 配置harbor 私有域名
➜  vim /etc/hosts
192.168.189.182   harbor.prod.local
```

②修改docker配置文件

``` zsh
➜  vim /etc/docker/daemon.json
{
"insecure-registries": [
    "harbor.prod.local"
  ]
}
```

③登陆私有仓库

``` zsh
➜  docker login harbor.prod.local
Username: admin
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

④重新打tag

``` zsh
➜  docker tag busybox harbor.prod.local/library/busybox
➜  docker push harbor.prod.local/library/busybox
The push refers to repository [harbor.prod.local/library/busybox]
67f770da229b: Pushed
latest: digest: sha256:1ccc0a0ca577e5fb5a0bdf2150a1a9f842f47c8865e861fa0062c5d343eb8cac size: 527
```

五、OSS验证

使用 `OSS Browser` 可以看到 Bucket 中已经有了刚才传上来的镜像

![OSS验证](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/harbor_20211015_08.jpg)

> 参考文章：  
>
> - [github - 关于data_volume与storage_service共存的issues](https://github.com/goharbor/harbor/issues/15787)  
> - [通过ossbrowser进行简单的权限管理](https://help.aliyun.com/document_detail/92270.html)  
> - [github - oss说明文档](https://github.com/docker/docker.github.io/blob/master/registry/storage-drivers/oss.md)  
> - [docker官网 - 关于如何配置后端存储的链接](https://docs.docker.com/registry/configuration/#storage)  
> - [harbor官网 - 关于如何配置后端存储的链接](https://goharbor.io/docs/2.2.0/install-config/configure-yml-file/)  
>