---
title: "iptables详解之filter"
date: "2020-01-23"
categories: 
    - "技术"
tags: 
    - "linux"
    - "iptables"
    - "filter"
toc: false
original: true
---

# iptables详解之filter

iptables令很多小伙伴脑阔疼，下面我们来说说如何使用iptables。

## 一、iptables格式

### 1.1、iptables 帮助

通过`iptables --help`查看一下iptables用法

``` bash
[root@note1 ~]# iptables --help
iptables v1.4.21

Usage: iptables -[ACD] chain rule-specification [options]
       iptables -I chain [rulenum] rule-specification [options]
       iptables -R chain rulenum rule-specification [options]
       iptables -D chain rulenum [options]
       iptables -[LS] [chain [rulenum]] [options]
       iptables -[FZ] [chain] [options]
       iptables -[NX] chain
       iptables -E old-chain-name new-chain-name
       iptables -P chain target [options]
       iptables -h (print this help information)
```

### 1.2、iptables 格式
`iptables [-t table] COMMAND chain [-m matchname [per-match-options]] -j targetname [per-target-options]`

iptables命令由 `表 + 命令 + 链 + 匹配条件 + 处理动作` 组成

## 二、iptables表

iptables由四表五链组成。每个表分别实现不同的功能，每个表拥有不同的链，链代表规则实现的位置。

四表分别为：
+ filter ：过滤，防火墙；
+ nat ：用于源地址转换或目标地址转换；
+ mangle ：拆解报文，做出修改，并重新封装起来；
+ raw ：关闭nat表上启用的连接追踪机制；

五链分别为：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING。

不同表支持的链：
+ filter ：INPUT，FORWARD，OUTPUT
+ nat ：PREROUTING，INPUT，OUTPUT，POSTROUTING
+ mangle ：PREROUTING，INPUT，FORWARD，OUTPUT，POSTROUTING
+ raw ：OUTPUT，PREROUTING

添加规则时的考量点：
- 要实现哪种功能：判断添加到哪个表上；
- 报文流经的路径：判断添加到哪个链上；

链：链上的规则次序，即为检查的次序；因此，隐含一定的应用法则：
- 同类规则（访问同一应用），匹配范围小的放上面；
- 不同类的规则（访问不同应用），匹配到报文频率较大的放在上面；
- 将那些可由一条规则描述的多个规则合并起来；
- 设置默认策略；

使用iptables命令时若不使用`-t`指明操作哪张表，默认操作filter表。

## 三、iptables命令

iptables命令有三大类，查看，链管理，规则管理

### 3.1、查看iptables规则
-t ： 查看的表
-n ：不进行 IP 与 HOSTNAME 的反解
-v ：列出更多的信息，包括通过该规则的封包总位数、相关的网络接口等.
-L ：列出目前的 table 的规则.
-S ：查看规则定义，
--line-number用于查看规则号.

``` bash
#使用iptables查看规则
[root@note1 ~]# iptables -vnL --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1      467 29128 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 41 packets, 4276 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
[root@note1 ~]#

[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1      502 31476 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]# 

#使用-S选项查看iptables的规则定义
[root@note1 ~]# iptables -S
-P INPUT ACCEPT
-P FORWARD ACCEPT
-P OUTPUT ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
```

### 3.2、链管理
#### 3.2.1、-N 新建链
-N：new, 自定义一条新的规则链；

``` bash
iptables -N test
```

#### 3.2.2、-X 删除链
-X：delete，删除自定义的规则链；
​	   注意：仅能删除用户自定义的引用计数为0的空的链；

``` bash
iptables -X test
```

#### 3.2.3、-E 重命名
-E：重命名自定义链；引用计数不为0的自定义链不能够被重命名，也不能被删除；

``` bash
iptables -N testrn
iptables -E testrn testrename
```
#### 3.2.4、-P 默认策略
-P：Policy，设置默认策略；对filter表中的链而言，其默认策略有：

+ ACCEPT：接受
+ DROP：丢弃
+ REJECT：拒绝

使用需**谨慎**，由于我测试时，没有先增加一条放行ssh的规则，所以在我将filter的INPUT链默认策略改为DROP后，我已经无法通过Xshell链接虚拟机了，需要进入VMware放行ssh。
``` bash
iptables -P INPUT DROP
```

增加了放行规则后，我们已经成功使用Xshell重新连上了主机
``` bash
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
```
使用命令添加默认策略
``` bash
#先放行ssh，INPUT链及OUTPUT链都要放行。
iptables -A INPUT -d 176.16.128.1 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -s 176.16.128.1 -p tcp --sport 22 -j ACCEPT
#添加新规则的时候要插入在默认拒绝规则前，除这些规则外的都将拒绝。
iptables -A INPUT -d 176.16.128.1 -j REJECT
iptables -A OUTPUT -s 176.16.128.1 -j REJECT
#设置链上的默认策略为允许。
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
```

### 3.3、规则管理
#### 3.3.1、-A 追加规则
-A：append，在已有规则后追加规则；

``` bash
# 在note1节点增加一条拒绝80端口的规则
[root@note1 local]# iptables -A INPUT -p tcp --dport 80 -j REJECT

# 我们可以看到由于是使用追加命令追加的规则，这条规则的位置为2
[root@note1 local]# iptables -vnL --line-numbers
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1     4208  225K ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        2   120 REJECT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 reject-with icmp-port-unreachable

# 在主机点访问note1节点的80端口
[root@master ~]# curl note1:80
curl: (7) Failed connect to note1:80; 拒绝连接
[root@master ~]#
```

#### 3.3.2、-R 替换规则
-R：replace，替换指定链上的指定规则；

``` bash
# 使用-R命令修改拒绝80端口的规则为接受访问
[root@note1 local]# iptables -R INPUT 2 -p tcp --dport 80 -j ACCEPT

# 查看iptables
[root@note1 local]# iptables -vnL --line-numbers
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1     4881  271K ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80

# 在master节点访问80端口，可以看到网页的内容了。
[root@master ~]# curl note1:80
<h1>I'm Note1</h1>
[root@master ~]#
```

#### 3.3.3、-I 插入规则
-I：insert, 插入，要指明位置，省略时表示第一条；

```bash
# 使用iptables -I不指定位置插入规则。
[root@note1 ~]# iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
# 查看iptables，显示新增加的规则为第一条。
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:3306
2      616 38140 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
3        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]#

#使用iptables -I指定在第二条插入规则。
[root@note1 ~]# iptables -I INPUT 2 -p tcp --dport 443 -j ACCEPT
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:3306
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443
3      810 50540 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
4        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]#
```

#### 3.3.4、-D 删除规则
-D：delete，删除规则按照规则序号或规则本身

##### 3.3.4.1、指明规则序号

```bash
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:3306
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:443
3      835 52340 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
4        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]# iptables -D INPUT 2
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:3306
2      882 55100 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
3        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]#
```

##### 3.3.4.2、 指明规则本身

```
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:3306
2      882 55100 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
3        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]# iptables -D INPUT -p tcp --dport 3306 -j ACCEPT
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1     1016 62940 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]#
```

#### 3.3.5、-Z 置零
iptables的每条规则都有两个计数器：
- (1) 匹配到的报文的个数；pkts
- (2) 匹配到的所有报文的大小之和；bytes

```bash
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 11 packets, 774 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1     1028 63752 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]# iptables -Z INPUT
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1        6   364 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]#
```

#### 3.3.6、-F 清空规则链

```bash
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 5 packets, 180 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
1       46  2728 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:22
2        0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80
[root@note1 ~]# iptables -F INPUT
[root@note1 ~]# iptables -vnL INPUT --line-number
Chain INPUT (policy ACCEPT 6 packets, 364 bytes)
num   pkts bytes target     prot opt in     out     source               destination         
[root@note1 ~]#
```

## 四、iptables匹配条件
### 4.1、基本匹配条件
无需加载任何模块，由iptables/netfilter自行提供；

```bash
[!] -s, --source  
address[/mask][,...]：检查报文中的源IP地址是否符合此处指定的地址或范围；

[!] -d, --destination 
address[/mask][,...]：检查报文中的目标IP地址是否符合此处指定的地址或范围；所有地址：0.0.0.0/0

[!] -p, --protocol 
protocol: tcp, udp, udplite, icmp, icmpv6,esp, ah, sctp, mh or  "all"
最常用的协议tcp、udp、icmp；

[!] -i, --in-interface 
数据报文流入的接口；只能应用于数据报文流入的环节，只能应用于PREROUTING，INPUT和FORWARD链；

[!] -o, --out-interface 
数据报文流出的接口；只能应用于数据报文流出的环节，只能应用于FORWARD、OUTPUT和POSTROUTING链；
```
> [!]中的叹号表示取反的意思

### 4.2、扩展匹配条件

#### 4.2.1、隐式扩展
隐式扩展：不需要手动加载扩展模块；因为它们是对协议的扩展，所以在使用-p选项指明了特定的协议时，就表示已经指明了要扩展的模块，无需再同时使用-m选项指明扩展模块的扩展机制。

##### 4.2.1.1、tcp
```
[!] --source-port, --sport port[:port]：
匹配报文的源端口；可以是端口范围；

[!] --destination-port, --dport port[:port]：
匹配报文的目标端口；可以是端口范围；

[!] --tcp-flags mask comp
mask是我们应该检查的标志，以逗号分隔，例如 SYN,ACK,FIN,RST
comp是必须设置的标志，例如SYN
例如：“--tcp-flags  SYN,ACK,FIN,RST  SYN”表示，要检查的标志位为SYN,ACK,FIN,RST四个，其中SYN必须为1，余下的必须为0；

[!] --syn：用于匹配第一次握手，相当于”--tcp-flags  SYN,ACK,FIN,RST  SYN“；	
```
> [!]叹号表示取反的意思							

##### 4.2.1.2、udp 
``` bash
[!] --source-port, --sport port[:port]：
匹配报文的源端口；可以是端口范围；

[!] --destination-port, --dport port[:port]：
匹配报文的目标端口；可以是端口范围；
```
> [!]叹号表示取反的意思

##### 4.2.1.3、icmp 
```bash
[!] --icmp-type {type[/code]|typename}
```
> [!]叹号表示取反的意思

###### icmp type 

类型为8：请求回送echo-request(Ping 请求) 

类型为0：回送应答echo-reply(Ping 应答)

我们设置INPUT放行icmp-type类型为0的报文，OUTPUT放行icmp-type类型为8的报文，默认规则设置为拒绝，这样就可以只允许我们ping其他主机，不允许其他主机ping我们。

```bash
#因为要增加默认拒绝规则，所以先放行ssh
[root@note1 ~]# iptables -A INPUT -d 176.16.128.1 -p tcp --dport 22 -j ACCEPT
[root@note1 ~]# iptables -A OUTPUT -s 176.16.128.1 -p tcp --sport 22 -j ACCEPT
#增加默认拒绝规则
[root@note1 ~]# iptables -A INPUT -d 176.16.128.1 -j REJECT
[root@note1 ~]# iptables -A OUTPUT -s 176.16.128.1 -j REJECT
[root@note1 ~]# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  299 19206 ACCEPT     tcp  --  *      *       0.0.0.0/0            176.16.128.1         tcp dpt:22
    0     0 REJECT     all  --  *      *       0.0.0.0/0            176.16.128.1         reject-with icmp-port-unreachable

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  165 15559 ACCEPT     tcp  --  *      *       176.16.128.1         0.0.0.0/0            tcp spt:22
    0     0 REJECT     all  --  *      *       176.16.128.1         0.0.0.0/0            reject-with icmp-port-unreachable
#现在我们尝试ping，由于ping未在iptables中设置所以ping请求无法发送。
[root@note1 ~]# ping 176.16.128.8
PING 176.16.128.8 (176.16.128.8) 56(84) bytes of data.
ping: sendmsg: 不允许的操作
ping: sendmsg: 不允许的操作
ping: sendmsg: 不允许的操作
^C
--- 176.16.128.8 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 1999ms

#现在我们在OUTPUT链上增加一条允许发送ping请求的规则
[root@note1 ~]# iptables -I OUTPUT 2 -s 176.16.128.1 -p icmp --icmp-type 8 -j ACCEPT

#尝试ping，发现请求可以发送了，但是未有响应回来
[root@note1 ~]# ping 176.16.128.8
PING 176.16.128.8 (176.16.128.8) 56(84) bytes of data.

#我们使用tcpdump抓包，发现ping请求是有响应回来的。是INPUT链没有放行。
[root@note1 ~]# tcpdump -i eno16777736 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eno16777736, link-type EN10MB (Ethernet), capture size 262144 bytes
20:45:00.605683 IP note1 > master: ICMP echo request, id 4276, seq 64, length 64
20:45:00.605962 IP master > note1: ICMP echo reply, id 4276, seq 64, length 64
20:45:01.606935 IP note1 > master: ICMP echo request, id 4276, seq 65, length 64
20:45:01.607533 IP master > note1: ICMP echo reply, id 4276, seq 65, length 64
^C
8 packets captured
8 packets received by filter
0 packets dropped by kernel
[root@note1 ~]#

#我们在iptables的INPUT链放行ping请求的响应。
[root@note1 ~]# iptables -I INPUT 2 -d 176.16.128.1 -p icmp --icmp-type 0 -j ACCEPT

#至此我们已经ping通了其他主机。
[root@note1 ~]# ping 176.16.128.8
PING 176.16.128.8 (176.16.128.8) 56(84) bytes of data.
64 bytes from 176.16.128.8: icmp_seq=228 ttl=64 time=0.687 ms
64 bytes from 176.16.128.8: icmp_seq=229 ttl=64 time=0.432 ms
^C
--- 176.16.128.8 ping statistics ---
231 packets transmitted, 4 received, 98% packet loss, time 230101ms
rtt min/avg/max/mdev = 0.432/0.804/1.443/0.382 ms
[root@note1 ~]#

```

若要允许其他主机也能ping我们。在INPUT链中追加一条放行icmp-type类型为8的报文，OUTPUT放行icmp-type类型为0的报文，这样就都可以ping通了。


#### 4.2.2、显式扩展
显式扩展：必须使用-m选项指明要调用的扩展模块的扩展机制； 	

> 使用`man iptables-extensions`来查看显示扩展的用法。			

#### 4.2.2.1、multiport
以离散或连续的方式定义多端口匹配条件，最多15个；

```bash
[!]--source-ports, --sports port[,port|,port:port]...：指定多个源端口；
[!]--destination-ports, --dports port[,port|,port:port]...：指定多个目标端口；
```

> [!]叹号表示取反的意思

我们说过iptables要尽量将那些可由一条规则描述的多个规则合并起来，不但可以更简洁，这样也可以提高报文通过的效率。

```bash
#使用iptables放行21,22,23,80,139,443,445,3306等端口。
iptables -A INPUT -p tcp -m multiport --dports 21:23,80,139,443,445,3306 -j ACCEPT
```

#### 4.2.2.2、iprange
以连续地址块的方式来指明多IP地址匹配条件；

```
[!] --src-range from[-to] #源地址区间
[!] --dst-range from[-to] #目标地址区间
```

> [!]叹号表示取反的意思

设置放行176.16.128.5-176.16.128.10区间的IP可以访问主机

```bash
[root@note1 init.d]#iptables -I INPUT 2 -p icmp --icmp-type 8 -m iprange --src-range 176.16.128.5-176.16.128.10 -j ACCEPT
[root@note1 init.d]#iptables -I OUTPUT 2 -p icmp --icmp-type 0 -s 176.16.128.1 -j ACCEPT

#使用176.16.128.2 Ping主机，是没有回应的。
[root@note2 ~]# ping 176.16.128.1
PING 176.16.128.1 (176.16.128.1) 56(84) bytes of data.
^C
--- 176.16.128.1 ping statistics ---
11 packets transmitted, 0 received, 100% packet loss, time 10076ms

[root@note2 ~]#

#使用176.16.128.8 Ping主机，在ip区间内是可以收到回复的。
[root@master ~]# ping 176.16.128.1
PING 176.16.128.1 (176.16.128.1) 56(84) bytes of data.
64 bytes from 176.16.128.1: icmp_seq=1 ttl=64 time=0.539 ms
64 bytes from 176.16.128.1: icmp_seq=2 ttl=64 time=0.922 ms
^C
--- 176.16.128.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1020ms
rtt min/avg/max/mdev = 0.539/0.730/0.922/0.193 ms
[root@master ~]#
```

#### 4.2.2.3、time
指定数据包到达时间/日期范围的匹配条件。

``` bash
--timestart hh:mm[:ss]
--timestop hh:mm[:ss]
[!] --weekdays day[,day...]
[!] --monthdays day[,day...]

--datestart YYYY[-MM[-DD[Thh[:mm[:ss]]]]]
--datestop YYYY[-MM[-DD[Thh[:mm[:ss]]]]]

--kerneltz：使用内核配置的时区而非默认的UTC；
```

> [!]叹号表示取反的意思
>
> 一般时间或与周几联用，或时间与每月几号联用。日期一般不常用。

```
#INPUT链放行工作区域176.16.128.5-176.16.128.10的主机在周一至周五的早9点到晚5点可以访问telnet服务。
iptables -I INPUT 2 -d 176.16.128.1 -p tcp --dport 23 -m iprange --src-range 176.16.128.5-176.16.128.10 -m time --timestart 9:00:00 --timestop 17:00:00 --weekdays 1,2,3,4,5 --kerneltz -j ACCEPT

#OUTPUT链放行telnet服务。
iptables -I OUTPUT 2 -s 176.16.128.1 -p tcp --sport 23 -j ACCEPT
```

#### 4.2.2.4、string

该模块使用某种模式匹配策略来匹配给定的字符串。

``` bash
--algo {bm|kmp}           #匹配算法
[!] --string pattern      #要过滤的字符串
[!] --hex-string pattern  #要检查的字符串的十六进制编码
--from offset             #从报文的哪个位置开始检查
--to offset               #从报文的哪个位置结束检查
```

> [!]叹号表示取反的意思。
>
> 只对明文编码的协议生效。

```
# 出栈报文中包含字符串gay拒绝访问。
iptables -I OUTPUT -m string --algo bm --string "gay" -j REJECT
```

#### 4.2.2.5、connlimit 
允许您限制每个客户端地址与服务器的并行连接数。

```bash
--connlimit-upto n   #上限 小于等于
--connlimit-above n  #下限 大于等于
```

> 取决于默认规则是什么，默认规则是拒绝，使用upto,设置低于就允许，不低于就被默认规则所匹配。

```bash
# 设置每个客户端ssh的连接不大于2个。
iptables -I INPUT -p tcp -d 176.16.128.1 --dport 22 -m connlimit --connlimit-upto 2 -j ACCEPT
```

#### 4.2.2.6、limit 

此模块使用令牌桶限制请求的速率。

```bash
--limit rate[/second|/minute|/hour|/day]  #每秒、每分、每小时、每天多少个。
--limit-burst number #一批最多个数、峰值（桶大小）
```

> 限制本机某tcp服务接收新请求的速率：--syn, -m limit

```bash
# 限制主机Ping请求每分钟20次，峰值发三次。
[root@note1 sysconfig]# iptables -I INPUT 2 -p icmp --icmp-type 8 -m limit --limit 20/minute --limit-burst 3 -j ACCEPT
[root@note1 sysconfig]# iptables -I OUTPUT 2 -p icmp --icmp-type 0 -j ACCEPT
[root@note1 sysconfig]# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  893 57538 ACCEPT     tcp  --  *      *       0.0.0.0/0            176.16.128.1         tcp dpt:22 #conn src/32 <= 2
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 8 limit: avg 20/min burst 3
    0     0 ACCEPT     tcp  --  *      *       0.0.0.0/0            176.16.128.1         multiport dports 80,443,3306
    2   104 REJECT     all  --  *      *       0.0.0.0/0            176.16.128.1         reject-with icmp-port-unreachable

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
  547 39791 ACCEPT     tcp  --  *      *       176.16.128.1         0.0.0.0/0            multiport sports 22,80,443,3306
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0            icmptype 0
   10   848 REJECT     all  --  *      *       176.16.128.1         0.0.0.0/0            reject-with icmp-port-unreachable
[root@note1 sysconfig]#

#Ping主机，观察应答的时间，得出已经成功限制Ping请求速率。
[root@master ~]# ping 176.16.128.1
PING 176.16.128.1 (176.16.128.1) 56(84) bytes of data.
64 bytes from 176.16.128.1: icmp_seq=1 ttl=64 time=0.692 ms
64 bytes from 176.16.128.1: icmp_seq=2 ttl=64 time=0.684 ms
64 bytes from 176.16.128.1: icmp_seq=3 ttl=64 time=0.722 ms
64 bytes from 176.16.128.1: icmp_seq=4 ttl=64 time=0.706 ms
64 bytes from 176.16.128.1: icmp_seq=7 ttl=64 time=1.10 ms
64 bytes from 176.16.128.1: icmp_seq=10 ttl=64 time=1.89 ms
64 bytes from 176.16.128.1: icmp_seq=13 ttl=64 time=0.983 ms
^C
--- 176.16.128.1 ping statistics ---
14 packets transmitted, 7 received, 50% packet loss, time 13093ms
rtt min/avg/max/mdev = 0.684/0.969/1.893/0.409 ms
[root@master ~]#
```

#### 4.2.2.7、state

state模块允许访问此数据包的连接跟踪状态。

```bash
#仅放行哪些连接的状态。
[!] --state state 
INVALID, ESTABLISHED, NEW, RELATED or UNTRACKED.
```

NEW: 新连接请求；
ESTABLISHED：已建立的连接；
INVALID：无法识别的连接；
RELATED：相关联的连接，当前连接是一个新请求，但附属于某个已存在的连接；
UNTRACKED：未追踪的连接；

state扩展：
内核模块装载：
nf_conntrack
nf_conntrack_ipv4

手动装载：
nf_conntrack_ftp 

追踪到的连接：
/proc/net/nf_conntrack

调整可记录的连接数量最大值：
/proc/sys/net/nf_conntrack_max

超时时长：
/proc/sys/net/netfilter/*timeout*

## 五、处理动作

-j targetname [per-target-options]

### 5.1、基本处理动作
ACCEPT 允许
DROP     丢弃

### 5.2、扩展处理动作
#### 5.2.1、REJECT 拒绝
--reject-with type

#### 5.2.2、LOG 日志
--log-level
--log-prefix

默认日志保存于/var/log/messages

#### 5.2.3、RETURN 返回
返回调用者；

### 5.3、自定义链作为target
自定义链做为target：

## 六、保存、重载
保存：`iptables-save > /PATH/TO/SOME_RULE_FILE`

重载：`iptabls-restore < /PATH/FROM/SOME_RULE_FILE`
            `-n, --noflush`：不清除原有规则
            `-t, --test`：仅分析生成规则集，但不提交
			

### CentOS6
保存规则：
`service iptables save`
保存规则于`/etc/sysconfig/iptables`文件，覆盖保存；

重载规则：
`service iptables restart`
默认重载`/etc/sysconfig/iptables`文件中的规则 

配置文件：`/etc/sysconfig/iptables-config`

### CentOS7
(1) 自定义Unit File，进行`iptables-restore`
(2) firewalld服务；
(3) 自定义脚本；

## 七、规则优化
1. 使用自定义链管理特定应用的相关规则，模块化管理规则；
2. 优先放行双方向状态为ESTABLISHED的报文；
3. 服务于不同类别的功能的规则，匹配到报文可能性更大的放前面；
4. 服务于同一类别的功能的规则，匹配条件较严格的放在前面；
5. 设置默认策略：白名单机制
    iptables -P，不建议；
    建议在规则的最后定义规则做为默认策略；