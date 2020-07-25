---
title: "Ceph对象存储"
date: "2020-05-13"
categories:
    - "技术"
tags:
    - "Ceph"
    - "对象存储"
    - "分布式存储"
toc: false
original: true
---

由于节点有限，仅仅测试对象存储服务，非典型安装规划
|       节点      |      属性                                         |
| --------------- | ------------------------------------------------ |
| 192.168.100.234 |    OSD节点                                        |
| 192.168.100.238 |    ceph-deploy节点、Mon节点、Mgr节点、radosgw节点  |

## 一、ceph存储集群

快速部署ceph存储集群，详细步骤请看我的[另一篇博客](https://github.com/miaocunfa/OpsNotes/blob/master/Storage/Ceph%E5%AD%98%E5%82%A8%E9%9B%86%E7%BE%A4.md)

``` bash
# 编辑hosts文件
vim /etc/hosts
192.168.100.234    node234
192.168.100.238    ceph-mon

# 192.168.100.238 ceph-deploy
➜  yum install ceph-deploy -y
➜  hostnamectl set-hostname ceph-mon

# repo地址
➜  export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
➜  export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

# 创建ceph-deploy目录
➜  mkdir /opt/ceph-cluster && cd /opt/ceph-cluster
➜  ceph-deploy new ceph-mon

# 修改ceph配置文件
➜  vim ceph.conf
[global]
fsid = 6ab7b319-0028-4032-9706-796962f06217
mon_initial_members = ceph-mon
mon_host = 192.168.100.238
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx

osd_pool_default_size = 2

# 安装ceph
➜  ceph-deploy install ceph-mon node234
➜  ceph --version

# 创建Mon、Mgr节点
➜  ceph-deploy mon create-initial
➜  ceph-deploy admin ceph-mon
➜  ceph-deploy mgr create ceph-mon
➜  ceph -s

# 推送配置文件
➜  ceph-deploy --overwrite-conf config push ceph-mon node234

# 准备磁盘
➜  parted -s /dev/sdb mklabel gpt
➜  parted -s /dev/sdb mkpart primary 0% 33%      # 创建/dev/sdb1
➜  parted -s /dev/sdb mkpart primary 34% 67%     # 创建/dev/sdb2
➜  parted -s /dev/sdb mkpart primary 68% 100%    # 创建/dev/sdb3
➜  partprobe                                     # 重读分区表
➜  chown -R ceph:ceph /dev/sdb1
➜  chown -R ceph:ceph /dev/sdb2
➜  chown -R ceph:ceph /dev/sdb3

# 添加OSD
➜  ceph-deploy osd create node234 --data /dev/sdb1    # 将/dev/sdb1添加为OSD
➜  ceph-deploy osd create node234 --data /dev/sdb2    # 将/dev/sdb2添加为OSD
➜  ceph-deploy osd create node234 --data /dev/sdb3    # 将/dev/sdb3添加为OSD
```

## 二、对象存储

### 2.1、部署radosgw

``` bash
# 已经安装radosgw
➜  yum list installed | grep ceph
ceph-radosgw.x86_64              2:13.2.10-0.el7                 @ceph
```

若没有安装radosgw，使用以下命令安装

``` bash
# 若你是先安装的ceph存储集群，切记使用ceph-deploy前要指定repo地址，否则先连接的国外repo会让你非常难受
➜  export CEPH_DEPLOY_REPO_URL=https://mirrors.aliyun.com/ceph/rpm-mimic/el7/
➜  export CEPH_DEPLOY_GPG_URL=https://mirrors.aliyun.com/ceph/keys/release.asc

# 先进入ceph-deploy目录
➜  cd /opt/ceph-cluster/
# 安装rgw
➜  ceph-deploy install --rgw ceph-mon
```

### 2.2、配置 && 启动

``` bash
#下面这个命令会同步配置和启动服务
➜  ceph-deploy --overwrite rgw create ceph-mon
[ceph-mon][INFO  ] Running command: systemctl enable ceph-radosgw@rgw.ceph-mon
[ceph-mon][WARNIN] Created symlink from /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.ceph-mon.service to /usr/lib/systemd/system/ceph-radosgw@.service.
[ceph-mon][INFO  ] Running command: systemctl start ceph-radosgw@rgw.ceph-mon
[ceph-mon][INFO  ] Running command: systemctl enable ceph.target
[ceph_deploy.rgw][INFO  ] The Ceph Object Gateway (RGW) is now running on host ceph-mon and default port 7480
```

### 2.3、验证  

ceph-gw 默认使用自带 Civetweb 提供服务，在浏览器输入`host:7480`, 可以看到服务运行正常

``` xml
# 浏览器访问
http://192.168.100.238:7480

# 返回
<ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<Owner>
<ID>anonymous</ID>
<DisplayName/>
</Owner>
<Buckets/>
</ListAllMyBucketsResult>
```

### 2.4、配置网关

``` bash
# 获得网关的秘钥
➜  ceph auth get client.rgw.ceph-mon
exported keyring for client.rgw.ceph-mon
[client.rgw.ceph-mon]
    key = AQDco7xeCwtIFRAAR5HOnozguXEO1LhKnjY+Zg==
    caps mon = "allow rw"
    caps osd = "allow rwx"

# 将秘钥重定向至文件
➜  ceph auth get client.rgw.ceph-mon > /etc/ceph/ceph.client.radosgw.keyring

# 将以下配置追加至ceph.conf
➜  vim /opt/ceph-cluster/ceph.conf
[client.rgw.ceph-mon]
rgw_frontends = "civetweb port=8899"
host = ceph-mon
keyring = /etc/ceph/ceph.client.radosgw.keyring
rgw socket path = /var/run/ceph/ceph-client.rgw.ceph-mon.asok
rgw content length compat = true

# 推送配置文件
➜  ceph-deploy --overwrite-conf config push ceph-mon node234
```

### 2.5、重启服务

``` bash
➜  systemctl restart ceph-radosgw@rgw.ceph-mon
```

### 2.6、pool

由于RGW要求专门的pool存储数据，使用脚本创建这些pool

``` bash
# 创建pool脚本
➜  vim ceph-rgw-pool.sh
#!/bin/bash

PG_NUM=10
PGP_NUM=10
SIZE=3

pool='.rgw
.rgw.root
.rgw.control
.rgw.gc
.rgw.buckets
.rgw.buckets.index
.rgw.buckets.extra
.log
.intent-log
.usage
.users
.users.email
.users.swift
.users.uid'

for i in $(echo $pool)
do
    ceph osd pool create $i $PG_NUM

    sleep 1

    ceph osd pool set $i size    $SIZE
    ceph osd pool set $i pgp_num $PGP_NUM
done

# 创建pool
➜  chmod u+x ceph-rgw-pool.sh
➜  ./ceph-rgw-pool.sh

# 列出rados的所有pool
➜  rados lspools
```

## 三、S3cmd

RGW为应用程序提供了一个兼容 RESTful S3 和 swift的API接口

### 3.1、创建用户

``` bash
➜  radosgw-admin user create --uid=radosgw --display-name="radosgw"
{
    "user_id": "radosgw",
    "display_name": "radosgw",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "radosgw",
            "access_key": "V0SCT2TXULJ01JEI0CH6",
            "secret_key": "czbC6PYYz8jBNfMZNW2eHnhxaXMP0HH2zKfVrS5w"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

### 3.2、部署客户端

``` bash
➜  yum install -y s3cmd
```

### 3.3、配置客户端

``` bash
➜  s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: V0SCT2TXULJ01JEI0CH6                         # 用户 Access Key
Secret Key: czbC6PYYz8jBNfMZNW2eHnhxaXMP0HH2zKfVrS5w     # 用户 Secret Key
Default Region [US]: ZH                                  # 国别 ZH

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: 192.168.100.238:8899     # 地址 192.168.100.238:8899

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: 192.168.100.238:8899/%(bucket)  # DNS

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:                                     # 跳过
Path to GPG program [/usr/bin/gpg]:                      # 跳过

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no                             # no

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:                                  # 跳过

New settings:
  Access Key: V0SCT2TXULJ01JEI0CH6
  Secret Key: czbC6PYYz8jBNfMZNW2eHnhxaXMP0HH2zKfVrS5w
  Default Region: ZH
  S3 Endpoint: 192.168.100.238:8899
  DNS-style bucket+hostname:port template for accessing a bucket: 192.168.100.238:8899/%(bucket)
  Encryption password:
  Path to GPG program: /usr/bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] n           # 是否测试 no

Save settings? [y/N] y                                   # 是否保存 yes
Configuration saved to '/root/.s3cfg'                    # 配置保存至/root/.s3cfg文件中
```

### 3.4、创建桶 && 放入文件

``` bash
# 创建bucket
➜  s3cmd mb s3://first-bucket
Bucket 's3://first-bucket/' created

# 列出bucket
➜  s3cmd ls
2020-05-14 07:14  s3://first-bucket

# 将文件放入桶中
➜  s3cmd put /etc/hosts s3://first-bucket
upload: '/etc/hosts' -> 's3://first-bucket/hosts'  [1 of 1]
 1198 of 1198   100% in    3s   331.02 B/s  done

# 查看桶中的文件
➜  s3cmd ls s3://first-bucket
2020-05-14 07:17         1198  s3://first-bucket/hosts
```

## 四、swift

### 4.1、创建子用户

创建 swift子用户

``` bash
➜  radosgw-admin subuser create --uid=radosgw --subuser=radosgw:swift --access=full
{
    "user_id": "radosgw",
    "display_name": "radosgw",
    "email": "",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "radosgw:swift",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "radosgw",
            "access_key": "V0SCT2TXULJ01JEI0CH6",
            "secret_key": "czbC6PYYz8jBNfMZNW2eHnhxaXMP0HH2zKfVrS5w"
        }
    ],
    "swift_keys": [
        {
            "user": "radosgw:swift",
            "secret_key": "0VeCOwnCWDRw9dW8mucXUjCCEBixeBn4GQ4ngI5T"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

### 4.2、部署客户端

``` bash
➜  yum install python3-pip -y
➜  pip3 install --upgrade python-swiftclient
```

### 4.3、swift语法

``` bash
➜  swift -h
usage: swift

Positional arguments:
  <subcommand>
    delete               Delete a container or objects within a container.
    download             Download objects from containers.
    list                 Lists the containers for the account or the objects
                         for a container.
    post                 Updates meta information for the account, container,
                         or object; creates containers if not present.

optional arguments:
    -A=AUTH, --auth=AUTH  URL for obtaining an auth token.
    -U=USER, --user=USER  User name for obtaining an auth token.
    -K=KEY, --key=KEY     Key for obtaining an auth token.
```

### 4.3、查看bucket

``` bash
# 列出bucket
➜  swift -A http://192.168.100.238:8899/auth/1.0 -U radosgw:swift -K 0VeCOwnCWDRw9dW8mucXUjCCEBixeBn4GQ4ngI5T list
first-bucket
```

### 4.4、新增bucket

``` bash
# 新增bucket
➜  swift -A http://192.168.100.238:8899/auth/1.0 -U radosgw:swift -K 0VeCOwnCWDRw9dW8mucXUjCCEBixeBn4GQ4ngI5T post second-bucket

# 列出bucket
➜  swift -A http://192.168.100.238:8899/auth/1.0 -U radosgw:swift -K 0VeCOwnCWDRw9dW8mucXUjCCEBixeBn4GQ4ngI5T list
first-bucket
second-bucket

# 使用S3cmd验证
➜  s3cmd ls
2020-05-14 07:14  s3://first-bucket
2020-05-14 07:41  s3://second-bucket
```

## 五、常用命令

``` bash
➜  rados lspools                                                # 列出所有的存储池
➜  rados ls -p .rgw.root                                        # 列出.rgw.root存储池的所有对象
➜  rados get zone_info.default obj.txt -p .rgw.root             # 将.rgw.root存储池的zone_info.default对象内容保存到obj.txt文件
➜  rados rm region_info.default -p .us.rgw.root                 # 删除.us.rgw.root存储池的region_info.default对象
➜  radosgw-admin region list --name client.radosgw.us-east-1    # 列出client.radosgw.us-east-1实例的所有辖区
➜  radosgw-admin region get --name client.radosgw.us-east-1     # 查看client.radosgw.us-east-1实例的主辖区
➜  radosgw-admin zone list --name client.radosgw.us-east-1      # 列出client.radosgw.us-east-1实例的所有域
➜  radosgw-admin zone get --name client.radosgw.us-east-1       # 查看client.radosgw.us-east-1实例的主域
```

> 参考列表:  
> 1、<https://blog.csdn.net/xx496146653/java/article/details/89248275>
> 2、<https://www.cnblogs.com/flytor/p/11380026.html>