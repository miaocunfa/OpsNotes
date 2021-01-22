---
title: "OpenVPN使用tcp协议"
date: "2020-08-17"
categories:
    - "技术"
tags:
    - "OpenVPN"
toc: false
indent: false
original: true
draft: false
---

## 1、复制 conf

``` zsh
# openvpn 的 systemd Unit
➜  cat /usr/lib/systemd/system/openvpn@.service
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application On %I
After=network.target

[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf    # 只要在/etc/openvpn/目录下编辑好配置文件，启动时指定配置文件名即可启动。

[Install]
WantedBy=multi-user.target

➜  cd /etc/openvpn
➜  cp server.conf server-tcp.conf

➜  vim server-tcp.conf
port 57678
proto tcp    # 需修改为tcp
dev tun

ca         /etc/openvpn/server/certs/ca.crt
cert       /etc/openvpn/server/certs/server.crt
key        /etc/openvpn/server/certs/server.key
dh         /etc/openvpn/server/certs/dh.pem
tls-auth   /etc/openvpn/server/certs/ta.key 0
crl-verify /etc/openvpn/easy-rsa/3/pki/crl.pem

server 10.8.0.0 255.255.255.0
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route 172.19.0.0 255.255.0.0"
compress lzo
keepalive 10 120
comp-lzo
persist-key
persist-tun

user openvpn
group openvpn

log         /var/log/openvpn/server-tcp.log    # 需与 udp 区分
log-append  /var/log/openvpn/server-tcp.log    # 需与 udp 区分
status      /var/log/openvpn/status-tcp.log    # 需与 udp 区分
verb 3
# explicit-exit-notify 1    # 需禁用
```

## 2、启动 tcp server

``` zsh
# 启动服务 && 查看状态
➜  systemctl start openvpn@server-tcp
➜  systemctl status openvpn@server-tcp
● openvpn@server-tcp.service - OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-08-17 10:15:31 CST; 4s ago
 Main PID: 6501 (openvpn)
   Status: "Initialization Sequence Completed"
   CGroup: /system.slice/system-openvpn.slice/openvpn@server-tcp.service
           └─6501 /usr/sbin/openvpn --cd /etc/openvpn/ --config server-tcp.conf

Aug 17 10:15:31 zax.aihangxunxi.com systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp...
Aug 17 10:15:31 zax.aihangxunxi.com systemd[1]: Started OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp.

# 同时启动 tcp、udp
➜  ss -nlp|grep 57678
udp    UNCONN     0      0         *:57678                 *:*                   users:(("openvpn",pid=5437,fd=5))
tcp    LISTEN     0      32        *:57678                 *:*                   users:(("openvpn",pid=6501,fd=5))
```

## 3、客户端 ovpn文件

``` windows
# 配置ovpn文件连接 tcp协议
D:\Program Files\OpenVPN\config\miaocunfa-tcp.ovpn
client
proto tcp
dev tun
remote [公网IP] 57678
ca ca.crt
cert miaocunfa.crt
key miaocunfa.key
tls-auth ta.key 1
remote-cert-tls server
persist-tun
persist-key
comp-lzo
verb 3
mute-replay-warnings
```

## 4、报错

``` zsh
# 没禁用 explicit-exit-notify 选项
# 启动报错
➜  systemctl start openvpn@server-tcp
Job for openvpn@server-tcp.service failed because the control process exited with error code. See "systemctl status openvpn@server-tcp.service" and "journalctl -xe" for details.
➜  systemctl status openvpn@server-tcp
● openvpn@server-tcp.service - OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp
   Loaded: loaded (/usr/lib/systemd/system/openvpn@.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2020-08-17 10:11:34 CST; 7s ago
  Process: 5749 ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf (code=exited, status=1/FAILURE)
 Main PID: 5749 (code=exited, status=1/FAILURE)

Aug 17 10:11:34 zax.aihangxunxi.com systemd[1]: Starting OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp...
Aug 17 10:11:34 zax.aihangxunxi.com systemd[1]: openvpn@server-tcp.service: main process exited, code=exited, status=1/FAILURE
Aug 17 10:11:34 zax.aihangxunxi.com systemd[1]: Failed to start OpenVPN Robust And Highly Flexible Tunneling Application On server/tcp.
Aug 17 10:11:34 zax.aihangxunxi.com systemd[1]: Unit openvpn@server-tcp.service entered failed state.
Aug 17 10:11:34 zax.aihangxunxi.com systemd[1]: openvpn@server-tcp.service failed.

# 查看日志
➜  cat server-tcp.log
Options error: --explicit-exit-notify can only be used with --proto udp
Use --help for more information.
```
