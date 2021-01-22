---
title: "使用OpenVPN进行内网穿透与公网穿透"
date: "2019-12-23"
categories:
    - "技术"
tags:
    - "OpenVPN"
    - "内网穿透"
    - "公网穿透"
    - "加密隧道"
toc: true
indent: false
original: false
draft: false
---

首先讲一下使用OpenVPN能给我们带来什么  

1、内网穿透是说你回到家中，通过开辟一条加密隧道，直接在家里访问公司内网，跟你在公司访问内部服务一个效果。  

2、公网穿透是说使用加密隧道访问公司生产网络，这样做带来的好处是我们可以将暴露在互联网上的大部分端口封掉，使用内网的方式访问生产，可以保证我们的网络安全。  

以上说的穿透主要基于NAT网络地址转换。

我们在CentOS7下安装OpenVPN，OpenVPN使用以下版本

``` log
easy-rsa.noarch 0:3.0.6-1.el7
openvpn.x86_64 0:2.4.8-1.el7
```

## 一、部署 OpenVPN

### 1.1、关闭selinux

``` zsh
➜  setenforce 0
➜  sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config
```

### 1.2、添加EPEL扩展库

``` zsh
➜  /etc/yum.repos.d/aliyun.repo
[aliyun-epel]
name=aliyun-epel-CentOS$releasever
enabled=1
baseurl=http://mirrors.aliyun.com/epel/$releasever/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-7
```

### 1.3、安装所需依赖软件包

``` zsh
➜  yum install -y openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig
```

### 1.4、安装OpenVPN和Easy-Rsa

``` zsh
➜  yum -y install openvpn easy-rsa
```

### 1.5、将easy-rsa拷贝至openvpn下

``` zsh
➜  cp -r /usr/share/easy-rsa/ /etc/openvpn/
```

## 二、配置 OpenVPN

### 2.1、openvpn程序树状图

``` zsh
➜  tree openvpn
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

### 2.2、生成CA根证书

``` zsh
➜  cd /etc/openvpn/easy-rsa/3.0.6/
➜  vim vars
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

初始化环境变量

``` zsh
➜  source ./vars
```

生成服务器端CA证书根证书ca.crt和根密钥ca.key，由于在vars文件中做过缺省设置，在出现交互界面时，直接一路回车即可

``` zsh
➜  ./easyrsa init-pki
➜  ./easyrsa build-ca
```

为服务端生成证书和密钥(一路按回车，直到提示需要输入y/n时，输入y再按回车，一共两次)

``` zsh
➜  ./easyrsa build-server-full server nopass
```

### 2.3、生成 Diffie-Hellman 算法需要的密钥文件, 生成过程较慢

``` zsh
➜  ./easyrsa gen-dh
```

### 2.4、生成 tls-auth key

这个 key 主要用于防止 DoS 和 TLS 攻击，这一步其实是可选的，但为了安全还是生成一下，该文件在后面配置 open VPN 时会用到。

``` zsh
➜  openvpn --genkey --secret ta.key
```

### 2.5、证书整理

将上面生成的相关证书文件整理到 /etc/openvpn/server/certs

``` zsh
➜  mkdir /etc/openvpn/server/certs && cd /etc/openvpn/server/certs/
➜  cp /etc/openvpn/easy-rsa/3/pki/dh.pem ./               # SSL 协商时 Diffie-Hellman 算法需要的 key
➜  cp /etc/openvpn/easy-rsa/3/pki/ca.crt ./               # CA 根证书
➜  cp /etc/openvpn/easy-rsa/3/pki/issued/server.crt ./    # open VPN 服务器证书
➜  cp /etc/openvpn/easy-rsa/3/pki/private/server.key ./   # open VPN 服务器证书 key
➜  cp /etc/openvpn/easy-rsa/3/ta.key ./                   # tls-auth key
```

### 2.6、创建 open VPN 日志目录

``` zsh
➜  mkdir -p /var/log/openvpn/
➜  chown openvpn:openvpn /var/log/openvpn
```

### 2.7、配置 OpenVPN

``` zsh
➜  cat /etc/openvpn/server.conf
port 57678  # 监听的端口号
proto udp   # 服务端用的协议，udp 能快点，所以我选择 udp
dev tun

ca         /etc/openvpn/server/certs/ca.crt      # CA 根证书路径
cert       /etc/openvpn/server/certs/server.crt  # OpenVPN 服务器证书路径
key        /etc/openvpn/server/certs/server.key  # OpenVPN 服务器密钥路径，This file should be kept secret
dh         /etc/openvpn/server/certs/dh.pem      # Diffie-Hellman 算法密钥文件路径
tls-auth   /etc/openvpn/server/certs/ta.key 0    # tls-auth key，参数0可以省略，如果不省略，那么客户端配置相应的参数该配成 1。如果省略，那么客户端不需要 tls-auth 配置

server 10.8.0.0 255.255.255.0       # 该网段为 OpenVPN 虚拟网卡网段，不要和内网网段冲突即可。OpenVPN 默认为 10.8.0.0/24
push "dhcp-option DNS 8.8.8.8"      # DNS 服务器配置，可以根据需要指定其他 ns
push "dhcp-option DNS 8.8.4.4"
push "route 172.19.0.0 255.255.0.0" # 当客户端打开 OpenVPN 连接后，所有访问172.19.0.0/24网段的流量都会被代理转发
#push "redirect-gateway def1"       # 客户端所有流量都通过 OpenVPN 转发，类似于代理开全局
compress lzo

#duplicate-cn                       # 允许一个用户多个终端连接
#max-clients 1
keepalive 10 120
comp-lzo
persist-key
persist-tun

user openvpn                        # OpenVPN 进程启动用户，openvpn 用户在安装完 openvpn 后就自动生成了
group openvpn

log         /var/log/openvpn/server.log  # 指定 log 文件位置
log-append  /var/log/openvpn/server.log
status      /var/log/openvpn/status.log
verb 3
explicit-exit-notify 1
```

### 2.8、清理所有防火墙规则

``` zsh
➜  iptables -F
```

### 2.9、添加 SNAT

将OpenVPN的网络流量转发到公网

``` zsh
#➜  iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
➜  iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -p tcp -m multiport --dports 22,3306,4006,7777,6379,9100,9200,15672,28018 -j MASQUERADE
➜  iptables-save > /etc/sysconfig/iptables   # iptables 规则持久化保存

# 将iptables规则设置为开机自动导入
➜  vim /etc/rc.local
iptables -F -t nat
iptables -F
iptables-restore < /etc/sysconfig/iptables
```

### 2.10、Linux 服务器启用核心转发

``` zsh
# 启用核心转发
➜  echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
# 刷新内核
➜  sysctl -p
```

## 三、启动 OpenVPN

``` zsh
➜  systemctl start openvpn@server
```

## 四、连接 OpenVPN

以上过程已经将 OpenVPN 服务端搭建好了，现在我们需要使用客户端工具以及用户证书连接 OpenVPN服务端进行流量代理。  

在Mac下推荐使用 Tunnelblick，这是一个开源、免费的Mac版 OpenVPN客户端软件  
下载地址：<https://tunnelblick.net/downloads.html>

Windows下使用官方提供的客户端工具即可  
下载地址：<https://openvpn.net/community-downloads/>

### 4.1、增加一个用户

接下来在服务端创建一个OpenVPN用户：其实创建用户的过程就是通过服务端CA证书自签客户端证书的过程，然后将其他的证书文件、key、.ovpn(客户端配置文件)打包到一起供客户端使用。

由于创建一个用户的过程比较繁琐，所以在此将整个过程写成了一个脚本，脚本通过修改模板文件生成新的ovpn文件，以及一系列用户相关证书后打成压缩包。

#### 4.1.1、ovpn模板文件

``` zsh
➜  cat sample.ovpn
client
proto udp
dev tun
remote [换成你的公网地址，即OpenVPN服务端所在地址] 57678
ca ca.crt
cert admin.crt
key admin.key
tls-auth ta.key 1
remote-cert-tls server
persist-tun
persist-key
comp-lzo
verb 3
mute-replay-warnings
```

#### 4.1.2、ovpn_user.sh

``` zsh
➜  vim ovpn_user.sh
# ! /bin/bash

set -e

OVPN_USER_KEYS_DIR=/etc/openvpn/client/keys
EASY_WorkDir=/etc/openvpn/easy-rsa/3
PKI_DIR=$EASY_WorkDir/pki

for user in "$@"
do

  if [ -d "$OVPN_USER_KEYS_DIR/$user" ];
  then
    rm -rf $OVPN_USER_KEYS_DIR/$user
    rm -rf  $PKI_DIR/reqs/$user.req
    sed -i '/'"$user"'/d' $PKI_DIR/index.txt
  fi

  cd $EASY_WorkDir

  # 生成客户端 ssl 证书文件
  ./easyrsa build-client-full $user

  # 整理下生成的文件
  mkdir -p  $OVPN_USER_KEYS_DIR/$user

  cp $PKI_DIR/ca.crt $OVPN_USER_KEYS_DIR/$user/                            # CA 根证书
  cp $PKI_DIR/issued/$user.crt $OVPN_USER_KEYS_DIR/$user/                  # 客户端证书
  cp $PKI_DIR/private/$user.key $OVPN_USER_KEYS_DIR/$user/                 # 客户端证书密钥
  cp /etc/openvpn/server/certs/ta.key $OVPN_USER_KEYS_DIR/$user/ta.key     # auth-tls 文件
  cp /etc/openvpn/client/sample.ovpn $OVPN_USER_KEYS_DIR/$user/$user.ovpn  # 客户端配置文件
  
  # 替换模板文件中的用户
  sed -i 's/admin/'"$user"'/g' $OVPN_USER_KEYS_DIR/$user/$user.ovpn
  
  # 生成压缩包
  cd $OVPN_USER_KEYS_DIR
  zip -r $user.zip $user

  # 拷贝压缩包至用户目录以下载
  cp $user.zip /home/miaocunfa
  chown miaocunfa:miaocunfa /home/miaocunfa/$user.zip
done

exit 0
```

#### 4.1.3、脚本使用语法

``` zsh
➜  ./ovpn_user.sh <username>
```

#### 4.1.4、生成压缩包

使用后在/etc/openvpn/client/keys文件夹下生成一个以username命名的zip文件，将此压缩包下载使用。

``` zsh
# 压缩包中存在下列文件
.
├── ca.crt
├── username.crt
├── username.key
├── username.ovpn
└── ta.key
```

#### 4.1.5、使用客户端

当我们在windows上使用OpenVPN GUI时，此客户端需要默认安装，我们需要将刚才下载的压缩包中的所有文件拷贝至C:\Program Files\OpenVPN\config中，然后即可使用客户端连接OpenVPN服务端了。

### 4.2、删除一个用户

上面我们知道了如何添加一个用户，那么如果公司员工离职了或者其他原因，想删除对应用户 OpenVPN 的使用权，该如何操作呢？其实很简单，OpenVPN 的客户端和服务端的认证主要通过 SSL 证书进行双向认证，所以只要吊销对应用户的 SSL 证书即可。

#### 4.2.1、吊销用户证书，假设要吊销的用户名为 username

``` zsh
➜  cd /etc/openvpn/easy-rsa/3/
➜  ./easyrsa revoke username
Revocation was successful. You must run gen-crl and upload a CRL to your     # 吊销证书后必须执行gen-crl生成crl文件
infrastructure in order to prevent the revoked cert from being accepted.

# 每次执行revoke，都要重新生成crl.pem文件
➜  ./easyrsa gen-crl
An updated CRL has been created.
CRL file: /etc/openvpn/easy-rsa/3/pki/crl.pem     # CRL文件路径
```

#### 4.2.2、编辑 OpenVPN 服务端配置 server.conf 添加如下配置

``` zsh
➜  vim server.conf
# 添加 crl文件
crl-verify /etc/openvpn/easy-rsa/3/pki/crl.pem
```

#### 4.2.3、重启 OpenVPN 服务端使其生效

``` zsh
➜  systemctl start openvpn@server
```

#### 4.2.4、一键删除用户

为了方便，也将上面步骤整理成了一个脚本 `del_ovpn_user.sh`

``` zsh
➜  vim del_ovpn_user.sh
# ! /bin/bash

set -e
OVPN_USER_KEYS_DIR=/etc/openvpn/client/keys
EASY_WorkDir=/etc/openvpn/easy-rsa/3

for user in "$@"
do
  cd $EASY_WorkDir

  echo -e 'yes\n' | ./easyrsa revoke $user
  ./easyrsa gen-crl

  # 吊销掉证书后清理客户端相关文件
  if [ -d "$OVPN_USER_KEYS_DIR/$user" ];
  then
    rm -rf $OVPN_USER_KEYS_DIR/${user}*
  fi

  systemctl restart openvpn@server
done

exit 0
```

#### 4.2.5、脚本使用语法

``` zsh
➜  ./del_ovpn_user.sh <username>
```

> 参考列表：  
> 1、<https://qhh.me/2019/06/16/Cenos7-%E4%B8%8B%E6%90%AD%E5%BB%BA-OpenVPN-%E8%BF%87%E7%A8%8B%E8%AE%B0%E5%BD%95/>
> 2、<https://www.hi-linux.com/posts/43594.html>
>