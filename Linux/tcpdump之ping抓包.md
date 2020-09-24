---
title: "tcpdump之ping抓包"
date: "2020-09-17"
categories:
    - "技术"
tags:
    - "tcpdump"
toc: false
original: true
---

## 一、iptables

### 1.1、允许其他机器ping通

``` zsh
# 允许其他机器的ping请求入
➜  iptables -A INPUT  -p icmp --icmp-type echo-request -j ACCEPT

# 允许给其他机器的ping回复出
➜  iptables -A OUTPUT -p icmp --icmp-type echo-reply   -j ACCEPT
```

### 1.2、能ping通回环地址

``` zsh
➜  iptables -A INPUT  -i lo -p all -j ACCEPT
➜  iptables –A OUTPUT –o lo –p all –j ACCEPT
```

### 1.3、能ping通域名

``` zsh
➜  iptables -A INPUT  -p udp --sport 53 -j ACCEPT
➜  iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
```

## 二、抓包

### 2.1、正常抓包

``` zsh
# 我们首先在ty-es1加入 允许ping请求，和允许ping回复的规则。
# ty-es1
➜  iptables -A INPUT  -p icmp --icmp-type echo-request -j ACCEPT
➜  iptables -A OUTPUT -p icmp --icmp-type echo-reply   -j ACCEPT

# 之后我们在ty-ng1 ping ty-es1
# ty-ng1
➜  ping ty-es1
PING ty-es1 (192.168.0.188) 56(84) bytes of data.
64 bytes from ty-es1 (192.168.0.188): icmp_seq=1 ttl=64 time=7.24 ms
64 bytes from ty-es1 (192.168.0.188): icmp_seq=2 ttl=64 time=0.393 ms
64 bytes from ty-es1 (192.168.0.188): icmp_seq=3 ttl=64 time=0.233 ms
^C
--- ty-es1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 0.233/2.622/7.240/3.266 ms

# ty-es1抓到的包
# 可以看到 ty-ng1 > ty-es1 的ping请求
#      与 ty-es1 > ty-ng1 的ping回复
➜  tcpdump -i eth0 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes

15:25:00.829846 IP ty-ng1 > ty-es1: ICMP echo request, id 57875, seq 1, length 64
15:25:00.829868 IP ty-es1 > ty-ng1: ICMP echo reply, id 57875, seq 1, length 64
15:25:01.826158 IP ty-ng1 > ty-es1: ICMP echo request, id 57875, seq 2, length 64
15:25:01.826176 IP ty-es1 > ty-ng1: ICMP echo reply, id 57875, seq 2, length 64
15:25:02.826620 IP ty-ng1 > ty-es1: ICMP echo request, id 57875, seq 3, length 64
15:25:02.826642 IP ty-es1 > ty-ng1: ICMP echo reply, id 57875, seq 3, length 64
```

### 2.2、设置不方通