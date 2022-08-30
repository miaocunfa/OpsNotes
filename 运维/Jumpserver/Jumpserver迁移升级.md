---
title: "Jumpserver 迁移升级"
date: "2022-05-11"
categories:
    - "技术"
tags:
    - "Jumpserver"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-05-11 | 初稿 |

## 软件版本

| soft       | Version             |
| ---------- | ------------------- |
| CentOS     | 7.7                 |
| Jumpserver | 1.5.4-2 --> v2.21.3 |

## 备份

在旧机器上将 SECRET_KEY 和 BOOTSTRAP_TOKEN 记下来

``` zsh
➜  cat /opt/jumpserver/config.yml | egrep "SECRET_KEY|BOOTSTRAP_TOKEN"
SECRET_KEY: ATbXo8RQAkxGJYXYDG9AqwsEC2KNQgujO2QLA52f7IYRJ4RNI8
BOOTSTRAP_TOKEN: 2xr0xUNoR6WQKROM
```

备份旧版本数据库

``` zsh
# 从 jumpserver/config.yml 获取数据库信息
DB_ENGINE: mysql
DB_HOST: 127.0.0.1
DB_PORT: 3306
DB_USER: jumpserver
DB_PASSWORD: qawsEDRF@@@123
DB_NAME: jumpserver

# 备份数据库
➜  mysqldump -u'jumpserver' -p'qawsEDRF@@@123' jumpserver > /opt/jumpserver_20220511.sql

# 查看备份数据库 字符集是否正确
if grep -q 'COLLATE=utf8_bin' /opt/jumpserver_20220511.sql; 
then
    cp /opt/jumpserver_20220511.sql{,.bak}
    sed -i 's@ COLLATE=utf8_bin@@g' /opt/jumpserver_20220511.sql
    sed -i 's@ COLLATE utf8_bin@@g' /opt/jumpserver_20220511.sql
else
    echo "备份数据库字符集正确";
fi
```

## 部署新服务

① 下载 jumpserver-installer

``` zsh
➜  cd /opt
➜  wget https://github.com/jumpserver/installer/releases/download/v2.21.3/jumpserver-installer-v2.21.3.tar.gz
➜  tar -xf jumpserver-installer-v2.21.3.tar.gz
➜  cd jumpserver-installer-v2.21.3
```

② 修改 配置文件

``` zsh
➜  vi config-example.txt

# 修改下面选项, 其他保持默认
### 数据持久化目录, 安装完成后请勿随意更改, 可以使用其他目录如: /data/jumpserver
VOLUME_DIR=/opt/jumpserver

### 注意: SECRET_KEY 与旧版本不一致, 加密的数据将无法解密

# Core 配置
### 启动后不能再修改，否则密码等等信息无法解密
SECRET_KEY=                           # 从旧版本的配置文件获取后填入 (*)
BOOTSTRAP_TOKEN=                      # 从旧版本的配置文件获取后填入 (*)
LOG_LEVEL=ERROR
# SESSION_COOKIE_AGE=86400
SESSION_EXPIRE_AT_BROWSER_CLOSE=true  # 关闭浏览器后 session 过期
```

③ 开始安装

``` zsh
# 执行命令后，按照提示一步一步操作
➜ ./jmsctl install
```

④ 查看服务状态

``` zsh
# 启动 Jumpserver
➜ ./jmsctl.sh start
jms_redis is up-to-date
Creating jms_core ... done
Creating jms_lion   ... done
Creating jms_koko   ... done
Creating jms_magnus ... done
Creating jms_web    ... done
Creating jms_celery ... done

# docker-compose 状态
➜ docker ps
CONTAINER ID   IMAGE                       COMMAND                  CREATED              STATUS                            PORTS                                                                              NAMES
7fef7ab39d91   jumpserver/core:v2.21.3     "./entrypoint.sh sta…"   9 seconds ago        Up 8 seconds (health: starting)   8070/tcp, 8080/tcp                                                                 jms_celery
fc91543d873f   jumpserver/web:v2.21.3      "/docker-entrypoint.…"   9 seconds ago        Up 8 seconds (health: starting)   0.0.0.0:8888->80/tcp, :::8888->80/tcp                                              jms_web
6758bef2c307   jumpserver/lion:v2.21.3     "./entrypoint.sh"        9 seconds ago        Up 8 seconds (health: starting)   4822/tcp                                                                           jms_lion
69336d6a9eaa   jumpserver/magnus:v2.21.3   "./entrypoint.sh"        9 seconds ago        Up 8 seconds (health: starting)   0.0.0.0:33060-33061->33060-33061/tcp, :::33060-33061->33060-33061/tcp, 54320/tcp   jms_magnus
6e51b6d6fbd1   jumpserver/koko:v2.21.3     "./entrypoint.sh"        9 seconds ago        Restarting (1) 2 seconds ago                                                                                         jms_koko
b2ddb44b5915   jumpserver/core:v2.21.3     "./entrypoint.sh sta…"   35 seconds ago       Up 34 seconds (healthy)           8070/tcp, 8080/tcp                                                                 jms_core
4096a905858a   jumpserver/redis:6-alpine   "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)       6379/tcp                                                                           jms_redis                                                                          jms_redis
```

⑤ 浏览器访问

打开浏览器访问 Jumpserver服务，验证服务状态

## 数据恢复

``` zsh
# 停止 Jumpserver 服务
➜ ./jmsctl.sh stop

# 清空 Jumpserver 数据库
使用 Navicat 等工具清空

# 恢复数据
# 拷贝旧数据至新服务器
➜ scp jumpserver_20220511.sql root@192.168.189.181:/opt/jumpserver
# 使用 jmsctl工具 恢复
➜ ./jmsctl.sh restore_db /opt/jumpserver/jumpserver_20220511.sql
Start restoring database: /opt/jumpserver/jumpserver_20220511.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
[SUCCESS] Database recovered successfully!


# 重启服务
➜ ./jmsctl.sh start
```

> 参考文章：  
>
> - [迁移文档](https://docs.jumpserver.org/zh/v2.21.3/install/migration/)   
>
