---
title: "OpenVPN的搭建与使用"
date: "2019-12-23"
categories:
    - "技术"
tags:
    - "OpenVPN"
toc: true
---

# OpenVPN的搭建与使用

我们在CentOS7下安装OpenVPN，OpenVPN使用以下版本
```
easy-rsa.noarch 0:3.0.6-1.el7
openvpn.x86_64 0:2.4.8-1.el7
```

## 关闭selinux
```
$ setenforce 0
$ sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config
```

## 安装EPEL扩展库

## 安装所需依赖软件包
```
$ yum install -y openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig
```

## 安装OpenVPN和Easy-Rsa
```
$ yum -y install openvpn easy-rsa   
```

## 将easy-rsa拷贝至openvpn下
```
$ cp -r /usr/share/easy-rsa/ /etc/openvpn/
```

## openvpn程序树状图
```
$ tree openvpn
openvpn
├── client
├── easy-rsa
│   ├── 3 -> 3.0.6
│   ├── 3.0 -> 3.0.6
│   └── 3.0.6
│       ├── easyrsa
│       ├── openssl-easyrsa.cnf
│       └── x509-types
│           ├── ca
│           ├── client
│           ├── code-signing
│           ├── COMMON
│           ├── server
│           └── serverClient
└── server
```

## 生成CA根证书
``` 
$ cd /etc/openvpn/easy-rsa/3.0.6/
$ vim vars
export CA_EXPIRE="3650"           # 定义CA证书的有效期，默认是3650天，即10年。
export KEY_EXPIRE="3650"          # 定义密钥的有效期，默认是3650天，即10年。
export KEY_COUNTRY="CN"           # 定义所在的国家。
export KEY_PROVINCE="ShanDong"    # 定义所在的省份。
export KEY_CITY="JiNan"           # 定义所在的城市。
export KEY_ORG="AiHangYun"        # 定义所在的组织。
export KEY_EMAIL="i@miaocf.com"   # 定义邮箱地址。
export KEY_OU="AH_OPS"            # 定义所在的单位。
export KEY_NAME="ZAX_Server"      # 定义openvpn服务器的名称。
```

```
$ source ./vars
```

```
$ ./easyrsa init-pki
$ ./easyrsa build-ca
```

```
$ ./easyrsa build-server-full server nopass
```

## 生成 Diffie-Hellman 算法需要的密钥文件, 生成过程较慢
```
$ ./easyrsa gen-dh
```

## 生成 tls-auth key，这个 key 主要用于防止 DoS 和 TLS 攻击，这一步其实是可选的，但为了安全还是生成一下，该文件在后面配置 open VPN 时会用到。
```
openvpn --genkey --secret ta.key
```

## 将上面生成的相关证书文件整理到 /etc/openvpn/server/certs
```
$ mkdir /etc/openvpn/server/certs && cd /etc/openvpn/server/certs/
$ cp /etc/openvpn/easy-rsa/3/pki/dh.pem ./               # SSL 协商时 Diffie-Hellman 算法需要的 key
$ cp /etc/openvpn/easy-rsa/3/pki/ca.crt ./               # CA 根证书
$ cp /etc/openvpn/easy-rsa/3/pki/issued/server.crt ./    # open VPN 服务器证书
$ cp /etc/openvpn/easy-rsa/3/pki/private/server.key ./   # open VPN 服务器证书 key
$ cp /etc/openvpn/easy-rsa/3/ta.key ./                   # tls-auth key
```

## 创建 open VPN 日志目录
```
$ mkdir -p /var/log/openvpn/
$ chown openvpn:openvpn /var/log/openvpn
```

## 配置 OpenVPN
```
$ vim /etc/openvpn/server.conf
port 57678   # 监听的端口号
proto udp   # 服务端用的协议，udp 能快点，所以我选择 udp
dev tun

ca         /etc/openvpn/server/certs/ca.crt      # CA 根证书路径
cert       /etc/openvpn/server/certs/server.crt  # open VPN 服务器证书路径
key        /etc/openvpn/server/certs/server.key  # open VPN 服务器密钥路径，This file should be kept secret
dh         /etc/openvpn/server/certs/dh.pem      # Diffie-Hellman 算法密钥文件路径
tls-auth   /etc/openvpn/server/certs/ta.key 0    # tls-auth key，参数0可以省略，如果不省略，那么客户端配置相应的参数该配成 1。如果省略，那么客户端不需要 tls-auth 配置

server 10.8.0.0 255.255.255.0   # 该网段为 open VPN 虚拟网卡网段，不要和内网网段冲突即可。open VPN 默认为 10.8.0.0/24
push "dhcp-option DNS 8.8.8.8"  # DNS 服务器配置，可以根据需要指定其他 ns
push "dhcp-option DNS 8.8.4.4"
push route "172.19.26.9 255.255.240.0"
compress lzo
duplicate-cn                    # 允许一个用户多个终端连接
keepalive 10 120
comp-lzo
persist-key
persist-tun

user openvpn                    # OpenVPN 进程启动用户，openvpn 用户在安装完 openvpn 后就自动生成了
group openvpn

log         /var/log/openvpn/server.log  # 指定 log 文件位置
log-append  /var/log/openvpn/server.log
status      /var/log/openvpn/status.log
verb 3
explicit-exit-notify 1
```

## 清理所有防火墙规则
```
iptables -F   
```

## 添加防火墙规则，将 openvpn 的网络流量转发到公网：snat 规则
```
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
iptables-save > /etc/sysconfig/iptables   # iptables 规则持久化保存
```

## Linux 服务器启用核心转发
```
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
# 刷新内核
sysctl -p 
```

## 启动 open VPN
```
$ systemctl start openvpn@server
```


[root@zax client]# systemctl start openvpn@server
[root@zax client]# 
Broadcast message from root@zax.aihangxunxi.com (Wed 2019-12-25 10:45:42 CST):

Password entry required for 'Enter Private Key Password:' (PID 438).
Please enter password with the systemd-tty-ask-password-agent tool!



