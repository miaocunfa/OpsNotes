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

## 二、抓包

``` zsh
# 226 --> 211
ping 192.168.100.211
PING 192.168.100.211 (192.168.100.211) 56(84) bytes of data.
^C
--- 192.168.100.211 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms

# 211 抓到了226上来的ping包，但是没有返回
tcpdump -i eth0 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
14:25:15.744331 IP n226 > n211: ICMP echo request, id 19378, seq 47, length 64
14:25:16.112571 IP n235 > n211: ICMP host n235 unreachable - admin prohibited, length 68
14:25:16.744327 IP n226 > n211: ICMP echo request, id 19378, seq 48, length 64
14:25:17.744400 IP n226 > n211: ICMP echo request, id 19378, seq 49, length 64
14:25:18.744383 IP n226 > n211: ICMP echo request, id 19378, seq 50, length 64
14:25:19.744303 IP n226 > n211: ICMP echo request, id 19378, seq 51, length 64
14:25:20.744315 IP n226 > n211: ICMP echo request, id 19378, seq 52, length 64

# 211 --> 226
ping 192.168.100.226
PING 192.168.100.226 (192.168.100.226) 56(84) bytes of data.
ping: sendmsg: No buffer space available
^C
--- 192.168.100.226 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 19022ms

# 211 自己抓自己的ping包都抓不到
# tcpdump -i eth0 icmp

ping 192.168.100.227
PING 192.168.100.227 (192.168.100.227) 56(84) bytes of data.
64 bytes from 192.168.100.227: icmp_seq=1 ttl=64 time=0.368 ms
64 bytes from 192.168.100.227: icmp_seq=2 ttl=64 time=0.246 ms
^C
--- 192.168.100.227 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1024ms
rtt min/avg/max/mdev = 0.246/0.307/0.368/0.061 ms

15:08:10.694631 IP n211 > n227: ICMP echo request, id 30403, seq 1, length 64
15:08:10.694982 IP n227 > n211: ICMP echo reply, id 30403, seq 1, length 64
15:08:11.718935 IP n211 > n227: ICMP echo request, id 30403, seq 2, length 64
15:08:11.719154 IP n227 > n211: ICMP echo reply, id 30403, seq 2, length 64
15:08:16.623383 IP n235 > n211: ICMP host n235 unreachable - admin prohibited, length 68
```