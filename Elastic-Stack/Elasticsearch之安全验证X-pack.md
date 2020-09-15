---
title: "Elasticsearch 之安全验证 X-pack"
date: "2020-09-15"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "X-pack"
toc: false
original: true
---

## 一、启用 X-pack

修改配置文件并重启es

``` zsh
➜  vim elasticsearch.yml
# 开启x-pack安全验证
xpack.security.enabled: true
xpack.security.audit.enabled: true
xpack.license.self_generated.type: basic
# 如果是basic license的话需要加入下面这一行，不然的话restart elasticsearch之后会报错
xpack.security.transport.ssl.enabled: true
```

重启服务后，可以从日志中观察到X-pack插件已经加载成功

``` log
[2020-09-15T09:38:15,479][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-ccr]
[2020-09-15T09:38:15,479][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-core]
[2020-09-15T09:38:15,479][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-deprecation]
[2020-09-15T09:38:15,480][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-graph]
[2020-09-15T09:38:15,480][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-ilm]
[2020-09-15T09:38:15,480][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-logstash]
[2020-09-15T09:38:15,480][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-ml]
[2020-09-15T09:38:15,481][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-monitoring]
[2020-09-15T09:38:15,481][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-rollup]
[2020-09-15T09:38:15,481][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-security]
[2020-09-15T09:38:15,481][INFO ][o.e.p.PluginsService     ] [es-log-1] loaded module [x-pack-sql]

[2020-09-15T09:10:15,778][INFO ][o.e.l.LicenseService     ] [es-log-1] license [5a95974a-3df4-4082-9333-03fd27ff7707] mode [basic] - valid
```

## 二、设置密码

``` zsh
# 自动设置密码
➜  elasticsearch-setup-passwords auto

# 手动设置密码
➜  elasticsearch-setup-passwords interactive
```

## 三、kibana && head 访问

### 3.1、kibana

修改配置文件

``` zsh
# 将elastic用户密码写入配置文件
➜  vim /opt/kibana-7.1.1-linux-x86_64/config/kibana.yml
elasticsearch.username: "elastic"
elasticsearch.password: "123456"

# 启动服务
➜  nohup ./kibana serve &
```

打开<http://192.168.100.235:5601>，使用elastic用户登录

### 3.2、head

修改配置文件并重启es

``` zsh
➜  vim elasticsearch.yml
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: Authorization,X-Requested-With,Content-Length,Content-Type
```

访问head时，url如下所示：  
<http://192.168.100.213:9100/?auth_user=elastic&auth_password=123456>

使用head访问es如下图：

![head 访问开启 X-pack安全插件的 es](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/es_20200915_01.png)  

## 四、常用接口

### 4.1、添加角色

接口为：`POST /_xpack/security/role/`

下面添加一个超级管理员角色为例：

``` zsh
➜  curl -XPOST -u elastic:123456 'localhost:9200/_xpack/security/role/admin?pretty' -H 'Content-type: application/json' -d '
{
    "run_as": ["elastic"],
    "cluster": ["all"],
    "indices": [{
        "names": ["*"],
        "privileges": ["all"]
    }]
}
'

# return
{
    "role": {
        "created": true
    }
}

```

### 4.2、添加用户

接口为：`POST /_xpack/security/user/`

下面以添加一个test用户并添加至admin角色为例：

> 注：这里要注意的是用户密码最好不要有"$" "!"之类的字符，这样有可能会导致密码认证不成功

``` zsh
➜  curl -XPOST -u elastic:123456 'localhost:9200/_xpack/security/user/test?pretty' -H 'Content-type: application/json' -d '
{
    "password": "Test123456%",
    "full_name": "test",
    "roles": ["admin"],
    "email": "test@test.com"
}
'

# return
{
    "user": {
        "created": true
    }
}
```

### 4.3、修改密码

修改密码需要使用超级管理员权限即 elastic用户

接口为：`POST /_xpack/security/user/要修改密码的用户名/_password`

curl参数含义如下：

-X POST 使用 post方法传递参数
-H      指定http协议的header信息
-u      指定用于认证的用户信息，用户名与密码使用冒号分隔
-d      指定具体要传递的参数信息

例如：修改martin用户的密码为:dxm1234%

``` zsh
➜  curl -XPOST -u elastic:123456 'localhost:9200/_xpack/security/user/martin/_password?pretty' -H 'Content-type: application/json'  -d '
{
    "password": "dxm1234%"
}
'
```

## 五、错误

### 5.1、X-Pack Security is disabled by configuration

错误信息

``` zsh
➜  ./elasticsearch-setup-passwords auto

Unexpected response code [500] from calling GET http://192.168.100.235:9200/_security/_authenticate?pretty
It doesn't look like the X-Pack security feature is enabled on this Elasticsearch node.
Please check if you have enabled X-Pack security in your elasticsearch.yml configuration file.

ERROR: X-Pack Security is disabled by configuration.

➜  vim es-log.log
org.elasticsearch.ElasticsearchException: Security must be explicitly enabled when using a [basic] license. Enable security by setting [xpack.security.enabled] to [true] in the elasticsearch.yml file and restart the node.
```

错误解决

``` zsh
➜  vim elasticsearch.yml
xpack.security.enabled: true
```

### 5.2、无法获取信息

``` zsh
➜  curl -s localhost:9200 | jq .
{
  "error": {
    "root_cause": [
      {
        "type": "security_exception",
        "reason": "missing authentication credentials for REST request [/]",
        "header": {
          "WWW-Authenticate": "Basic realm=\"security\" charset=\"UTF-8\""
        }
      }
    ],
    "type": "security_exception",
    "reason": "missing authentication credentials for REST request [/]",
    "header": {
      "WWW-Authenticate": "Basic realm=\"security\" charset=\"UTF-8\""
    }
  },
  "status": 401
}
```

``` zsh
# 设置密码
➜  elasticsearch-setup-passwords interactive

# 获取信息
➜  curl localhost:9200 -u elastic:123456
{
  "name" : "es-log-1",
  "cluster_name" : "es-log",
  "cluster_uuid" : "JNqtrjbBTw-a5EQOrCtcvA",
  "version" : {
    "number" : "7.1.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "7a013de",
    "build_date" : "2019-05-23T14:04:00.380842Z",
    "build_snapshot" : false,
    "lucene_version" : "8.0.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

> 参考链接：  
> 1、[Elasticsearch之权限验证(Basic)](https://www.cnblogs.com/xingxia/p/elasticsearch_privileges.html)  
> 2、[elasticsearch 6.2.4添加用户密码认证](https://www.cnblogs.com/liangyou666/p/10597093.html)  
>