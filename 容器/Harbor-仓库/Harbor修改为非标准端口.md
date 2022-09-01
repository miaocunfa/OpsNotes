---
title: "Harbor 修改为非标准端口"
date: "2021-10-25"
categories:
    - "技术"
tags:
    - "harbor"
    - "运维操作"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2021-10-25 | 初稿 |

## 软件版本

| Soft           | Version |
| -------------- | ------- |
| CentOS         | 7.6     |
| harbor         | v2.3.3  |
| docker-ce      | 20.10.9 |
| docker-compose | 1.18.0  |

## 一、停止 harbor 服务

首先需要将 harbor 服务停止

``` zsh
➜  cd /usr/local/harbor
➜  docker-compose down
Stopping harbor-jobservice ... done
Stopping nginx             ... done
Stopping harbor-core       ... done
Stopping harbor-portal     ... done
Stopping registry          ... done
Stopping registryctl       ... done
Stopping harbor-db         ... done
Stopping redis             ... done
Stopping harbor-log        ... done
Removing harbor-jobservice ... done
Removing nginx             ... done
Removing harbor-core       ... done
Removing harbor-portal     ... done
Removing registry          ... done
Removing registryctl       ... done
Removing harbor-db         ... done
Removing redis             ... done
Removing harbor-log        ... done
Removing network harbor_harbor
```

## 二、修改 harbor 端口

然后修改 harbor安装目录下的 `harbor.yml` 配置文件

``` zsh
# 只修改 hostname 以及 http.port 即可
➜  vim harbor.yml
hostname: 192.168.189.182
http:
  port: 9999
```

然后执行 `prepare` 命令重新生成 `docker-compose.yml` 文件

``` zsh
➜  ./prepare
prepare base dir is set to /usr/local/harbor
WARNING:root:WARNING: HTTP protocol is insecure. Harbor will deprecate http protocol in the future. Please make sure to upgrade to https
Clearing the configuration file: /config/db/env
Clearing the configuration file: /config/portal/nginx.conf
Clearing the configuration file: /config/registryctl/config.yml
Clearing the configuration file: /config/registryctl/env
Clearing the configuration file: /config/jobservice/config.yml
Clearing the configuration file: /config/jobservice/env
Clearing the configuration file: /config/nginx/nginx.conf
Clearing the configuration file: /config/core/app.conf
Clearing the configuration file: /config/core/env
Clearing the configuration file: /config/log/logrotate.conf
Clearing the configuration file: /config/log/rsyslog_docker.conf
Clearing the configuration file: /config/registry/config.yml
Clearing the configuration file: /config/registry/root.crt
Clearing the configuration file: /config/registry/passwd
Generated configuration file: /config/portal/nginx.conf
Generated configuration file: /config/log/logrotate.conf
Generated configuration file: /config/log/rsyslog_docker.conf
Generated configuration file: /config/nginx/nginx.conf
Generated configuration file: /config/core/env
Generated configuration file: /config/core/app.conf
Generated configuration file: /config/registry/config.yml
Generated configuration file: /config/registryctl/env
Generated configuration file: /config/registryctl/config.yml
Generated configuration file: /config/db/env
Generated configuration file: /config/jobservice/env
Generated configuration file: /config/jobservice/config.yml
loaded secret from file: /data/secret/keys/secretkey
Generated configuration file: /compose_location/docker-compose.yml      # 重新生成了 docker-compose.yml
Clean up the input dir
```

可以打开查看 `docker-compose.yml` 文件内容，验证是否修改成功

``` zsh
➜  vim docker-compose.yml
  proxy:
    image: goharbor/nginx-photon:v2.3.3
    container_name: nginx
    restart: always
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
    volumes:
      - ./common/config/nginx:/etc/nginx:z
      - type: bind
        source: ./common/config/shared/trust-certificates
        target: /harbor_cust_cert
    networks:
      - harbor
    dns_search: .
    ports:
      - 9999:8080     # 可以观察到 port的端口映射已经修改好了
```

## 三、重启 harbor 服务

在 harbor安装目录 执行 docker-compose命令，重新启动即可

``` zsh
# 启动
➜  docker-compose up -d
Creating harbor-db ... done
Creating harbor-core ... done
Creating network "harbor_harbor" with the default driver
Creating nginx ... done
Creating redis ...
Creating registryctl ...
Creating registry ...
Creating harbor-portal ...
Creating harbor-db ...
Creating harbor-core ...
Creating harbor-jobservice ...
Creating nginx ...

# 查看 harbor进程
➜  docker-compose ps
      Name                     Command               State             Ports
--------------------------------------------------------------------------------------
harbor-core         /harbor/entrypoint.sh            Up
harbor-db           /docker-entrypoint.sh 96 13      Up
harbor-jobservice   /harbor/entrypoint.sh            Up
harbor-log          /bin/sh -c /usr/local/bin/ ...   Up      127.0.0.1:1514->10514/tcp
harbor-portal       nginx -g daemon off;             Up
nginx               nginx -g daemon off;             Up      0.0.0.0:9999->8080/tcp
redis               redis-server /etc/redis.conf     Up
registry            /home/harbor/entrypoint.sh       Up
registryctl         /home/harbor/start.sh            Up
```

## 四、docker 操作

①修改 `daemon.json`

如果harbor 配置了https 可以忽略此步骤

``` zsh
➜  vim /etc/docker/daemon.json
{
"insecure-registries": [
    "192.168.189.182:9999"
  ]
}
```

②重启 docker

``` zsh
➜  systemctl restart docker
```

③docker login

docker主机 需要重新登录 harbor的新地址

``` zsh
➜  docker login 192.168.189.182:9999
Username: admin
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

## 五、验证操作

将镜像重新打标签，尝试能否推送到 harbor仓库

``` zsh
➜  docker images
REPOSITORY                                          TAG       IMAGE ID       CREATED        SIZE
busybox                                             latest    16ea53ea7c65   5 weeks ago    1.24MB

➜  docker tag busybox:latest 192.168.189.182:9999/library/busybox:latest
➜  docker push 192.168.189.182:9999/library/busybox:latest
The push refers to repository [192.168.189.182:9999/library/busybox]
cfd97936a580: Pushed
latest: digest: sha256:febcf61cd6e1ac9628f6ac14fa40836d16f3c6ddef3b303ff0321606e55ddd0b size: 527
```

已经成功推送镜像到 harbor中了，非标准端口已经修改好了

> 参考文章：  
>
> - [安装Harbor并修改默认使用的80端口](https://www.cnblogs.com/linanjie/p/13912017.html)  
>