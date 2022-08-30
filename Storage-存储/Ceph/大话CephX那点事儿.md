---
title: "大话CephX那点事儿"
date: "2020-03-20"
categories:
    - "技术"
tags:
    - "Ceph"
    - "分布式存储"
toc: false
original: false
draft: true
---

>《大话Ceph》系列文章通过通俗易懂的语言并结合基础实验，用最简单的描述描述解析Ceph中的重要概念。让读者对分布式存储系统有一个清晰的理解。

## 引言

简介文章主要介绍了Ceph中的一个重要系统– CephX认证系统。简要介绍了CephX的命名格式。并介绍了从重新启动到用户连接到这连接的流程中CephX所起的作用。最后通过实验操作讲解如何在使所有秘钥丢失的情况下将其完整恢复，以及在实际生产环境中使用CephX的一些注意事项。

## CephX是什么？

CephX理解起来很简单，就是整个Ceph系统的**用户名/密码**，而这个用户不单单指我们平时在终端敲ceph -s而生成的client，在这套认证系统中，还有一个特殊的用户群体，那就是**MON/OSD/MDS**，则，监视器，OSD，MDS也都需要一对账号密码来登陆Ceph系统。

## CephX的命名规则

而**用户名/密码**遵循着一定的命名规则：  

### 用户名

用户名总体惯例<TYPE.ID>的命名规则，这里的`TYPE`有三种：  `mon`，`osd`，`client`  
而`ID`根据不同的类型的用户而有所不同：  
- mon：ID为空。
- osd：ID为OSD的ID。
- client：ID为该客户端的名称，比如admin，cinder，nova。

### 密码

密码通常为包含40个字符的字符串，形如：AQBh1XlZAAAAABAAcVaBh1p8w4Q3oaGoPW0R8w==。

### 样式用户

想要和一个Ceph进行进行交互，我们通常需要知道最少四条信息，并且是缺一不可的：

- 发挥的fsid
- 启用了Monitor的IP地址，必须先连上MON之后才能获得获取信息
- 一个用于登陆的用户名
- 登陆用户对应的密码
  
其实，很多同学会发现，在我们日常和Ceph交互交互时，并不需要指定这些参数，就可以执行得到ceph -s转换的状态。实际上，我们已经使用了Ceph提供了几个替代参数，而ceph -s另外参数后的全称是：

``` zsh
    ceph -s   \
         --conf /etc/ceph/ceph.conf \
         --name client.admin        \
         --keyring /etc/ceph/ceph.client.admin.keyring
```

从上面的指令可以研磨，Ceph使用的**替代**用户为`client.admin`，而这个用户的秘钥文件通常是保存在`/etc/ceph/ceph.client.admin.keyring`中。如果这里，我们从`/etc/ceph`目录下删除这个秘钥文件，再次执行`ceph -s`，就会得到以下这个最最常见的错误：

``` zsh
2017-07-28 15：56：03.271139 7f142579c700 -1 auth：无法在/etc/ceph/ceph.client.admin.keyring、/etc/ceph/ceph.keyring、/etc/ceph/keyring上找到密钥环， /etc/ceph/keyring.bin：（2）没有这样的文件或目录
2017-07-28 15：56：03.271145 7f142579c700 -1 monclient（hunting）：错误：缺少密钥环，无法使用cephx进行身份验证
2017-07-28 15：56：03.271146 7f142579c700 0 librados：client.admin初始化错误（2）没有这样的文件或目录
连接到集群时出错：ObjectNotFound
```

从报错信息我们可以研磨一点，因为我们使用了替换用户client.admin，Ceph就会以下四个路径去寻找client.admin这个用户的密码：

/etc/ceph/ceph.client.admin.keyring：名义命名格式为：/etc/ceph/<$cluster>.<$type>.<$id>.keyring。
/etc/ceph/ceph.keyring：命名格式为：/etc/ceph/<$cluster>.keyring。
/etc/ceph/keyring。
/etc/ceph/keyring.bin。
如果不存在这四个文件，或者在这四个文件里面均没有保存用户client.admin的秘钥，那么就会报错：错误：缺少密匙环。因此，用户client.admin登陆Ceph系统失败！

谁才是CephX中的鼻祖？
隐藏老板之门。

一段对话：client.admin：当然是我！用我的账户密码登陆Ceph后可以执行任何指令！
星期一 ：哦。
client.admin：你谁我这有所有账户密码（悄悄得查了下头孢AUTH列表），怎么没看到你？
周一 ：嗯
client.admin：哎呀，哪个二货把我的秘钥文件删了，我不能连接集群了！
周一
client.admin：你？确定？
mon . ：让一让，我来帮你把秘钥找回来。：嗯。

一直以为自己权限很大的client.admin，忽然因为丢失了保存密码的秘钥文件而无法访问了。而从未露面的mon.却号称能够找回client.admin的秘钥，难道说mon.才是真正的鼻祖？！

现在我们回到故事最初的起点，也就是合并建构之初，我们使用ceph-deploy new NodeA NodeB NodeC后，生成了三个文件：

1个
2
3
ceph.conf 
ceph.mon.keyring
ceph-deploy-ceph.log
除了ceph.conf，还ceph.mon.keyring重组生成了一个文件，不出意外的话，这个文件几乎是不会在后面的转移交互中使用的，因为在ceph-deploy mon create-initial之后，会生成client.admin用户，而后面的交互一般都会使用这个用户了。但是生成的第一个用户却是<mon。>，对应的秘钥文件保存在部署目录下的ceph.mon.keyring。

查看ceph-deloy的LOG，可以看到在步骤ceph-deploy mon create-initial时，有一段日志记录如下：

1个
2
3
4
5
6
7
[2017-07-28 16：49：53,468] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --admin-daemon = / var / run / ceph / ceph-mon.centos7.asok mon_status
[2017-07-28 16：49：53,557] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取client.admin
[2017-07-28 16：49：53,761] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取client.bootstrap-mds
[2017-07-28 16：49：54,046] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取client.bootstrap-mgr
[2017-07-28 16：49：54,255] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取或创建client.bootstrap-mgr mon允许配置文件bootstrap-mgr
[2017-07-28 16：49：54,452] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取client.bootstrap-osd
[2017-07-28 16：49：54,658] [centos7] [INFO]运行命令：/ usr / bin / ceph --connect-timeout = 25 --cluster = ceph --name mon。--keyring = / var / lib / ceph / mon / ceph-centos7 / keyring auth获取client.bootstrap-rgw
实际上，秘这些文件钥都是通过用户mon.创建³³的，包括client.admin用户及其秘钥。所以在整个CephX的历史中，mon.才是第一个生成的用户，其他而用户的均由mon.用户生成或者依次向下生成。

用一张图来表明秘钥的生成关系：



通过这张图，我们可以很容易理解bootstrap的几个用户的用处了，就是用作引导生成对应类用户的用户，用来bootstrap-osd引导所有osd.N用户。

CephX使用场景
聊完了各个用户的生成时间，我们来看看这些用户是在什么时候使用了它们的账户和密码的！

MON
在整个初始化启动的时候，首先是Monitor启动，再然后是OSD启动。在Monitor启动的时候，Monitor会携带自己的秘钥文件启动进程，从而，Monitor启动的时候，是不需要向任何进程进行秘钥认证的，通俗点讲，监视器的秘钥键怕被修改过了，也不会影响Monitor的启动，这里通过一个小实验来具体说明：

1个
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18岁
19
20
21
[root @ blog群集]＃cat / var / lib / ceph / mon / ceph-blog / keyring 
[mon。]
键= AQAr1H1ZAAAAABAAWItgjm4dOKPJx + FX9lVk4Q ==
caps mon =“允许*”
[root @ blog群集]＃ceph auth get mon。
导出了星期一的密钥环。
[mon。]
键= AQAr1H1ZAAAAABAAWItgjm4dOKPJx + FX9lVk4Q ==
caps mon =“允许*”
[root @ blog集群]＃vim / var / lib / ceph / mon / ceph-blog / keyring 
#####将秘钥文件内容的一部分改成B，再重启Monitor
[root @ blog群集]＃cat / var / lib / ceph / mon / ceph-blog / keyring 
[mon。]
键= AQAr1H1ZBBBBBBAAWItgjm4dOKPJx + FX9lVk4Q ==
caps mon =“允许*”
[root @ blog群集]＃systemctl重新启动ceph-mon.target
[root @ blog群集]＃ceph auth get mon。
导出了星期一的密钥环。
[mon。]
键= AQAr1H1ZBBBBBBAAWItgjm4dOKPJx + FX9lVk4Q ==
caps mon =“允许*”
Monitor的数据库里面，记录着除了其他mon.所有用户密码，在Monitor启动之后，才真正开启了认证这个步骤，之后所有用户想要连接到该，必须先要通过fsid和MON IP连上Ceph进行，通过了认证之后，就可以正常访问移植了，下面继续介绍下OSD的启动认证过程。

OSD
OSD在启动的时候，首先要log_to_monitors，也就是持有自己的账户密码去登陆的，这个账户密码在Monitor的数据库里有记录，所以如果相互匹配，那么OSD就可以正常启动，否则，就会报下面的错：

1个
2
3
4
5
6
2017-08-01 16：54：51.515541 7f21ea978800 -1 osd.0 30 log_to_monitors {default = true}
2017-08-01 16：54：51.991263 7f21ea978800 1日志关闭/ var / lib / ceph / osd / ceph-0 / journal
2017-08-01 16：54：51.999674 7f21ea978800 -1 ^ [[0; 31m **错误：osd初始化失败：（1）不允许操作^ [[0m
2017-08-01 16：54：52.006620 7f21ea978800 -1 common / HeartbeatMap.cc：在函数'ceph :: HeartbeatMap ::〜HeartbeatMap（）'线程7f21ea978800时间2017-08-01 16：54：52.001569
common / HeartbeatMap.cc：44：未通过声明（m_workers.empty（））
日志里面的Operation not permitted也就是认证不通过的意思，说明这个osd.0携带的秘钥文件和监视器所记录的内容替换，导致OSD的启动失败。这时候，需要比对下osd.0的秘钥内容和Monitor的是否一致：

1个
2
3
4
5
6
7
8
9
[root @ blog〜]＃cat / var / lib / ceph / osd / ceph-0 / keyring 
[osd.0]
键= AQA81H5Zh05jDxAAkvaHBs07K9HYF1uGSPh + rA ==
[root @ blog〜]＃ceph auth获取osd.0
导出osd.0的密钥环
[osd.0]
键= AQBH1H5Z6pBvDhAAul364EZsRjDy / NqTQh07Yw ==
caps mon =“允许配置文件osd”
caps osd =“允许*”
的确，内容不一样，这时候用得到的键值替换ceph auth get osd.0秘keyring钥文件的键部分即可正常启动OSD。

客户
通常我们执行ceph -s时，就相当于开启了一个客户端，连接到Ceph转移，而该客户端替换是使用client.admin的帐户密码登陆连接变为的，所以平时执行的ceph -s相当于执行了ceph -s --name client.admin --keyring /etc/ceph/ceph.client.admin.keyring。需要注意的是，每次我们在命令行执行Ceph的指令，都相当于开启一个客户端，并且可以交互，再关闭客户端。

现在举一个很常见的报错，这在刚接触Ceph时，很容易遇到：

1个
2
3
[root @ blog〜]＃ceph -s
2017-08-03 02：22：27.352516 7fbd157b7700 0 librados：client.admin身份验证错误（1）不允许操作
连接集群时出错：PermissionError
报错信息很好理解，操作不被允许，也就是认证未通过，由于这里我们使用的是替换的client.admin用户和它的秘钥，说明秘钥内容和Ceph大量记录的替代，因此/etc/ceph/ceph.client.admin.keyring内容很可能是之前提交留下的，或者是记录了错误的秘钥内容，这时，只需要使用mon.用户来执行ceph auth list就可以查看到正确的秘钥内容：

1个
2
3
4
5
6
7
[root @ blog〜]＃ceph auth获取client.admin --name mon。--keyring / var / lib / ceph / mon / ceph-blog / keyring
导出client.admin的密钥环
[client.admin]
键= AQD7F4JZIs9DJxAAZms / NQQQ1YhUpCHRtjygJA ==
caps mds =“允许*”
caps mon =“允许*”
caps osd =“允许*”
细说帽子
仔细查看ceph auth list输出，除了用户名和对应的秘钥内容外，还有一个个以caps开头的内容，这就是CephX中对各个用户的权限的划分，除非：读，写，执行等：

1个
2
3
caps mds =“允许*”
caps mon =“允许*”
caps osd =“允许*”
而针对不同的应用（mds / mon / osd），同样的读权限或写权限的作用是不同的，下面依次对这三个应用的r/w/x权限进行分析。

MON
权限
那么问题来了，想要执行ceph -s的最低权限是什么呢？那就是caps mon ="allow r"，也就是MON的r权限。那么这个读权限到底读了什么呢？首先要突出的一点，这里读的数据都是从MON来的，和OSD无关。

MON作为拥有状态维护者，其数据库（/var/lib/ceph/mon/ceph-$hostname/store.db）内部保存着被替换的这两个状态图（群集地图），这些地图包含但不包含：

粉碎地图
OSD地图
MON地图
MDS地图
PG地图
而这里的读权限，就是读取这些Map的权限，但是这些Map的真实内容读取出来没有多大意义，所以以比较友好的指令输出形式展示出来，而这些指令包含但不限于：

1个
2
3
4
5
ceph -s
ceph osd美眉转储
ceph osd树
ceph pg转储 
ceph osd转储
只要有了MON的r权限，那么就可以从集成读取所有MON维护的地图，数据的宏观来看，就是可以读取转换的状态信息（但是不能修改）。

这里简单介绍下验证流程，我们通过生成一个只包含MON的r权限的秘钥，来访问权限：

1个
2
3
4
5
6
7
8
ceph auth获取或创建client.mon_r mon'allow r'>> / root / key
ceph --name client.mon_r --keyring / root / key -s ## OK
ceph --name client.mon_r --keyring / root / key osd dump ## OK
ceph --name client.mon_r --keyring / root / key pg dump ## OK
ceph --name client.mon_r --keyring / root / key osd out 0 ##错误错误：访问被拒绝
ceph --name client.mon_r --keyring / root / key osd set noout ##错误错误：访问被拒绝
权限
w权限比较有趣，必须具备r权限才能有效力，否则，单独w权限执行指令时，是会一直access denied的。所以我们在测试w权限时，需要附加上r权限才行：

1个
ceph auth获取或创建client.mon_rw mon'allow rw'>> / root / key
这时，假象被占据的各个地图，摆在你的面前，你可以清楚地得到读取每个OSD的状态，每个PG的状态，但是，如果赋予了你w权限之后，你就可以对这些实体进行操作，比如踢掉一个OSD（ ceph osd rm），修复一个PG（ ceph pg repair），修改CRUSH结构（ceph osd setcrushmap），删除一个MON（ ceph mon rm），而这些操作，如果在仅有ř权限时，是不能执行的（access denied）。

由于这里可以执行的指令实在太多了，我唯一对r，w权限做一个简单的总结：

r：可读的各个组件（MON / OSD / MDS / CRUSH / PG）的状态，但是不能修改。
rw：读取并可以修改扩展的各个组件的状态，可以执行对组件的各个动作指令。
注意：
目前讨论的组件读写权限，均不包含包含对象的读写权限的，也就是说，你单凭MON的rw权限，是不能从识别对象的。

权限
MON的x权限也比较有趣，因为这个权限完全和auth相关。因此，如果你想要执行ceph auth list，ceph auth get之类的所有和auth相关的指令，那么拥有x权限就能执行了。但是和w权限类似，也需要r权限组合在一起才能有效力：

1个
2
ceph auth获取或创建client.mon_rx mon'allow rx'>> / root / key
ceph --name client.mon_rw --keyring / root / key认证列表
*权限
一句话说明： * = rwx

提示
可以通过将多个用户秘钥写入同一个文件中，例如上面的/root/key中，就包含了：

1个
2
3
4
5
6
> [root @ blog〜]＃cat / root / key
> [client.mon_r]
>键= AQBtLIJZScuLARAAPQS9ahvU1oZh1Ha / fYhUhQ ==
> [client.mon_w]
>键= AQD5LYJZJO2 / AxAAWgbuPPUNJ0ugxsqdDD3 + sw ==
>
在指令指定--name后，Ceph就会到--keyring后面的文件中找寻对应的用户名section下的秘钥。

osd权限
官方的解释是：给用户以一个OSD的身份连接到其他OSD / MON的权限。给OSD授予此权限，以便OSD能够处理副本心跳和状态汇报。暂时没找到比较通俗的理解〜

OSD
在MON的各个权限中列出，OSD的rw比较简单理解一下，r权限就是读取对象的权限，w权限就是写对象的权限，x权限比较有趣，可以调用任何class-read/class-write的权限，这里引用Ceph CookBook上的一段话来介绍class-read/class-write：

可以通过创建称为Ceph类的共享对象类来扩展Ceph。Ceph可以加载存储在OSD类目录中的.so类。对于一个类，您可以创建能够调用Ceph对象存储中本机方法的新对象方法，例如，您在类中定义的对象可以调用本地Ceph方法，例如读写。

举个例子，你可以实现一些自定义的方法，通过调用这些方法，可以理解为具有标题类特征的对象，通常都是以rbd_data开头的对象。目前只能调用librados层才能使用自定义类方法，而上层RBD，RGW之类的是不能使用的。

*权限除包含了rwx，还包含了ceph tell osd.*类别管理员指令的权限。

官网的这个页面（http://docs.ceph.com/docs/kraken/man/8/ceph-authtool/）比较好的介绍了几个实例，这里简单介绍下一个比较长的指令的意义：

1个
osd =“允许类读取object_prefix rbd_children，允许池模板r类读取，允许池vms rwx”
第一个权限：object_prefix是一个类方法，这个而方法的作用英文的英文给予所有以rbd_children为名开头和结尾的对象的class-read也。就是读权限只能读，不能写。

第二templates，客户除可以读这个池的对象外，还能自己实现形如obejct_prefix这种系统自带的类方法来读取对象，尽可能重新整合某些类别特征的对象。

第三个权限：给予池vms的读写以及执行class-read / class-write方法的权限。

丢失所有秘钥的恢复流程
讲了这么多理论知识，某个二货运维同学不耐烦了，一口气把所有的秘钥全部删除了，这些秘钥包含：

MON：/ var / lib / ceph / mon / ceph- hostname/ keyring
OSD：/ var / lib / ceph / osd / ceph-0 / keyring
客户端：/etc/ceph/ceph.client.admin.keyring
总而言之，所有包含秘钥内容的文件都被删除了，并且/etc/ceph/加上目录都删除了的干干净净。这时候能否将所有的秘钥文件恢复出来吗？？答案是：可以！

在管理秘钥方面，Ceph做了一个比较有趣的设置：所有其他mon.用户的帐户密码都保存在MON的数据库级别db中，但是mon.用户的信息并没有保存在数据库里，而是在MON启动时重新读取因此keyring，我们甚至可以随便keyring伪造一个，放置到MON目录下去。然后同步到各个MON实例，然后重新设置三个MON。这时候，MON就被人造的keyring启动体现了。有。了mon.用户的帐户密码，我们很容易的可以使用ceph auth list --name mon. --keyring /var/lib/ceph/mon/ceph-$hostname/keyring指令来得到所有的秘钥内容！

等等，如果真的删除了/etc/ceph/目录的话，上面的这个指令是无法执行的，因为没有/etc/ceph/ceph.conf去指定命名，这时候，我们可以从任意一个OSD目录下的/var/lib/ceph/osd/ceph-0/ceph_fsid得到的fsid，MON的IP信息也很容易恢复。简单得改造了ceph.conf后，使用mon.的用户密码就可以得到正确的ceph auth list的信息啦〜。

再等等，现在的ceph.conf内容太精简了，比删除之前少了很多东东，这些东东还能恢复吗？答案是，能！

找寻任何一个未重启的OSD，执行ceph daemon osd.0 config diff，这样，就可以看到这个OSD启动加载的配置项和替换的配置项的不一样的地方，通过仔细比对很容易恢复成删除之前的配置文件样〜。

疑问：
相信这里就会有同学有疑问了，不为什么直接把ceph.conf里面的cephx对划线none后直接重启集群呢，首先这样做的成本较高，因为要重启OSD（必须重启OSD，否则OSD会在MON重启一段如此全部的方法只重启了MON，影响范围小。

CephX实际使用中的注意事项
ZABBIX使用
在部署zabbix-agent后，服务器通过拉取agent的指令输出得到返回值，但是却会报：

1个
2
zabbix_get -s 1.2.3.4 -k ceph.ops
ZBX_NOTSUPPORTED：不支持的项目密钥
前往agent官员执行脚本，却能得到正常的输出。

这里查看zabbix_agent的LOG发现，日志里面总是报：

1个
librados：client.admin身份验证错误（1）不允许操作
原来是，zabbix_agent对/etc/ceph/ceph.client.admin.keyring没有chmod a+r读取权限，将秘钥之后，可以正常读取数据了。

所以，在我们的日常使用中，一定要注意/etc/ceph/ceph.client.admin.keyring的读权限，很多不是运行在root用户上的应用读取不到秘钥内容后，就会连接不上造成，造成比较奇怪的现象。

cephx - >无
在关闭CephX功能时，要遵守一定的顺序：

关闭：重启MON->重启OSD
开启：重启MON->重启OSD
如果关闭CephX后未重启OSD，过一段时间，OSD会随机挂掉。

密匙环的分布
通常我们可以在MON上执行ceph -s，但是到了OSD中断，就会因为client.admin缺少的秘钥文件而无法执行 ceph -s。

MON的秘钥保存路径为：/var/lib/ceph/mon/ceph-$hostname/keyring。
OSD的秘钥保存路径为：/var/lib/ceph/osd/ceph-$osd_id/keyring。
client.admin的秘钥保存路径为：/etc/ceph/ceph.client.admin.keyring。

实际上，我们甚至可以在OSD例程（没有client.admin.keyring），通过执​​行：

1个
ceph -s --name osd.0 --keyring / var / lib / ceph / osd / ceph-0 / keyring
来重新生成的状态。

配置只能访问一个RBD的用户权限
具体介绍可以参考这篇文章（https://blog-fromsomedude.rhcloud.com/2016/04/26/Allowing-a-RBD-client-to-map-only-one-RBD/）

这里主要说下秘钥的创建指令的意义：

1个
2
3
4
5
6
7
8
ceph auth获取或创建client.myclient 
周一
'允许r'
OSD 
'允许rwx object_prefix rbd_data.103d2ae8944a; 
允许rwx object_prefix rbd_header.103d2ae8944a; 
允许接收object_prefix rbd_id.myimage' 
-o /etc/ceph/ceph.client.myclient.keyring
这里通过object_prefix预先方法，赋予了用户对和某个RBD所有相关的对象的读写权限，是一个比较有实用价值的应用。

总结
本文介绍了CephX在Ceph系统中的生成过程以及彼此之间的依赖生成关系。详细介绍了各个权限在不同应用中的作用和使用场景。最后通过秘钥丢失的例子来将理论应用到实际生产环境中，使大家对CephX的使用游刃有余。