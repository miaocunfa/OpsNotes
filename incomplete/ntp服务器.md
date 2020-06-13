## ntp服务器

yum info ntp

yum install ntp

vi /etc/ntp.conf

server  时间服务器地址

restrict 允许谁来同步时间

systemctl start ntpd



centos7使用chrony取代ntp服务

优势

更快的同步，只需要数分钟而非数小时

能够更好地响应时钟频率的快速变化

在初始同步后，它不会停止时钟，以防对需要系统时间保持单调的应用程序造成影响。

在应对临时非对称延迟时提供了更好地稳定性。

无需对服务器进行定期轮询，因此具备间歇性网络连接的系统仍然可以快速同步时钟。



chrony是兼容ntp服务的

监听123、323两个端口

传统ntp服务使用123为端口

chrony 323监听的端口

启用chrony后使用ntp、chrony当客户端都可以。



安装

无论是ntp还是chrony都是守护以进程运行。

yum info chrony

yum install chrony -y

/etc/chrony.conf    主配置文件

/usr/bin/chronyc    工具程序

/usr/sbin/chronyd  服务端或客户端守护进程



/etc/chrony.conf

server time_server_ip iburst #配置时间服务器

重启服务

systemctl start chronyd.service

设置开机自启

systemctl enable chronyd



配置自己为时间服务器

/etc/chrony.conf

allow 172.16/16 #授权172.16网络可以同步本地时间。

allow NETADD/NETMASK

allow all 允许所有

deny NETADD/NETMASK   #没有allow的默认都deny

deny all不允许

local stratum 10 #即使本地时间未能通过网络时间服务器同步时间，也允许将本地时间作为标准时间授时给其他客户端，一般情况下禁用。

bindcmdaddress #设置监听chronyc的地址

keyfile /etc/chrony.keys #判断连接的chrony是否合法

logdir /var/log/chrony #设置log文件位置



客户端连接时间服务器。

ntpdate server_ip #使用ntp连接chrony

chronyc交互模式

sources 时间服务器

sourcestats时间同步状态

chronyc非交互模式

chronyc sources [-v]





