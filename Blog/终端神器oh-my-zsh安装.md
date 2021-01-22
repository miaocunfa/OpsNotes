---
title: "终端神器oh-my-zsh安装"
date: "2020-09-02"
categories:
    - "技术"
tags:
    - "奇巧淫技"
    - "zsh"
    - "linux"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容     |
| ---------- | -------- |
| 2020-09-02 | 初稿     |
| 2020-09-03 | 增加插件 |

## 一、安装

### 1.1、安装zsh

``` zsh
# 安装zsh、git
➜  yum install zsh git -y

➜  zsh --version
zsh 5.0.2 (x86_64-redhat-linux-gnu)

➜  cat /etc/shells
/bin/sh
/bin/bash
/usr/bin/sh
/usr/bin/bash
/bin/tcsh
/bin/csh
/bin/zsh

# 切换默认shell
➜  chsh -s $(which zsh)

# 新开一个窗口, 验证当前shell
➜  echo $SHELL
/bin/zsh
```

### 1.2、安装ohmyzsh

Oh My Zsh 的安装方式非常简单, 可以使用以下方式安装

curl

``` zsh
➜  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

wget

``` zsh
➜  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

fetch

``` zsh
➜  sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

报错解决方式

``` zsh
curl: (7) Failed connect to raw.githubusercontent.com:443; Connection refused

# 浏览器打开
https://site.ip138.com/raw.githubusercontent.com/

# 获取 raw.githubusercontent.com 的IP
151.101.108.133

# 写入hosts文件
➜  vim /etc/hosts/
151.101.108.133 raw.githubusercontent.com
```

## 二、使用及配置

### 2.1、Oh My Zsh 目录结构

Oh My Zsh 的默认路径在 `$HOME/.oh-my-zsh`

既然都已经装好ohmyzsh了，这花里胡哨的配色，必须得上图  
![ohmyzsh目录结构](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/omz_20200902_01.png)

``` zsh
custom    个性化配置目录，自安装的插件和主题可放这里
lib       提供了核心功能的脚本库
plugins   自带插件的存在放位置
templates 自带模板的存在放位置
themes    自带主题文件的存在放位置
tools     提供安装、升级等功能的快捷工具
```

### 2.2、zsh 的配置文件

Zsh 的配置文件路径在 `$HOME/.zshrc`
里面配置了像主题、插件之类的东西

``` zsh
➜  ~ cat ~/.zshrc | grep -v ^# | grep -v ^$
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
```

### 2.3、zsh 的主题

Zsh 的主题都在 `$HOME/.oh-my-zsh/themes` 下

``` zsh
➜  ~ cd ~/.oh-my-zsh/themes
➜  themes git:(master) ll
total 580K
-rw-r--r--. 1 root root  325 Sep  2 17:17 3den.zsh-theme
-rw-r--r--. 1 root root 4.5K Sep  2 17:17 adben.zsh-theme
-rw-r--r--. 1 root root 1.5K Sep  2 17:17 af-magic.zsh-theme
-rw-r--r--. 1 root root  394 Sep  2 17:17 afowler.zsh-theme
-rw-r--r--. 1 root root 7.7K Sep  2 17:17 agnoster.zsh-theme
-rw-r--r--. 1 root root  943 Sep  2 17:17 alanpeabody.zsh-theme
-rw-r--r--. 1 root root  552 Sep  2 17:17 amuse.zsh-theme
-rw-r--r--. 1 root root  822 Sep  2 17:17 apple.zsh-theme
-rw-r--r--. 1 root root  504 Sep  2 17:17 arrow.zsh-theme
-rw-r--r--. 1 root root  325 Sep  2 17:17 aussiegeek.zsh-theme
-rw-r--r--. 1 root root 3.0K Sep  2 17:17 avit.zsh-theme
```

这些形如 *.zsh-theme的主题文件  
你可以在 zshrc 中选择使用哪个主题  

``` zsh
➜  vim ~/.zshrc
ZSH_THEME="robbyrussell"

# 比如你可以使用 ys这个主题
ZSH_THEME="ys"

# 也可以使用随机主题, 每次打开shell 都不一样
ZSH_THEME="random"

# 直到遇到你喜欢的主题, 然后你可以查看这个主题, 再把它设置为默认主题
➜  echo $ZSH_THEME
```

如果这些默认主题还不能满足你的需要，我们还可以到这里找到更多的主题
><https://github.com/robbyrussell/oh-my-zsh/wiki/Themes>  
><https://github.com/robbyrussell/oh-my-zsh/wiki/External-themes>  
><https://github.com/unixorn/awesome-zsh-plugins#themes>

## 三、zsh 的插件

zsh 有很多超级强大的插件，启用后你会发现  

``` log
Your terminal never felt this good before
```

### 3.1、默认插件

zsh 有很多的默认插件在  `$HOME/.oh-my-zsh/plugins` 下

zsh 默认只启用了git插件，如需启用更多插件，可加入需启用插件的名称

#### 3.1.1、z

提供一个 z 命令，在常用目录之间跳转。类似 autojump，但是不需要额外安装。

``` zsh
# 启用插件
➜  vim ~/.zshrc
plugins=(z)
➜  source ~/.zshrc

# 演示效果
➜  cd ~/.oh-my-zsh/plugins
➜  cd ~; pwd
/root
➜  z plugins; pwd
/root/.oh-my-zsh/plugins
```

#### 3.1.2、extract

提供一个 extract 命令，以及它的别名 x。实现一键解压功能

``` zsh
# 启用插件
➜  vim ~/.zshrc
plugins=(extract)
➜  source ~/.zshrc
```

#### 3.1.3、vi-mode

按esc键，以vim模式编辑命令

``` zsh
# 启用插件
➜  vim ~/.zshrc
plugins=(vi-mode)
➜  source ~/.zshrc
```

### 3.2、需要安装的插件

zsh 还有很多功能特别强大的插件需要安装才能用，但这绝对物超所值。

#### 3.2.1、zsh-autosuggestions

在输入命令的过程中根据你的历史记录显示你可能想要输入的命令，按向右箭头补全。

``` zsh
➜  git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

➜  vim ~/.zshrc
plugins=(zsh-autosuggestions)
➜  source ~/.zshrc
```

#### 3.2.2、zsh-syntax-highlighting

shell 命令的代码高亮。你没有理由拒绝高亮。

特性：正确路径自带下划线

``` zsh
➜  git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

➜  vim ~/.zshrc
plugins=(zsh-syntax-highlighting)
➜  source ~/.zshrc
```

#### 3.2.3、zsh-history-substring-search

历史命令搜索

``` zsh
➜  git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search

➜  vim ~/.zshrc
plugins=(zsh-history-substring-search)
➜  source ~/.zshrc
```

#### 3.2.4、zsh-navigation-tools

一组工具，例如

- n-aliases - 浏览别名，relegates编辑到 vared
- n-cd - 浏览dirstack和书签目录，允许输入所选目录
- n-functions - 浏览函数，relegates编辑到 zed 或者 vared
- n-history 浏览历史，允许编辑和运行命令
- n-kill - 浏览进程列表，允许向所选进程发送信号
- n-env - 浏览环境，relegates编辑到 vared
- n-options - 浏览选项，允许切换它的状态
- n-panelize - 将给定命令的输出加载到列表中以便浏览

功能亮点包括增量多词搜索，近似匹配，ANSI着色，主题，唯一模式，水平滚动，grepping，高级历史记录管理以及与的各种集成Zsh。

所有工具都支持带有 `< >` `{ }` `H l` 或者左和右光标的水平滚动。 其他快捷键是：

H，? ( 从n 历史) - 运行帮助
Ctrl-R - 开始n 个历史，增量的多关键字历史搜索器( Zsh绑定)
Ctrl-A - 旋转输入的单词( 1+2+3 -> 3 +1+2 )
Ctrl-F - 固定模式( 近似匹配)
Ctrl-L - 整个显示的重绘
Ctrl-T - 浏览主题( 下一个主题)
Ctrl-G - 浏览主题( 上一个主题)
Ctrl-U - 半页面
Ctrl-D - 半页面
Ctrl-P - 前一元素( 也使用vim的k 进行)
Ctrl-N - 下一个元素( 也是用vim做的)
[，] - 在n-光盘中跳转目录书签和中的典型信号
g，g - 列表的开始和结束
/ - 显示渐进式搜索
F3 - 显示/隐藏渐进式搜索
Esc - 退出渐进式搜索，清除过滤器
Ctrl-W ( 在渐进式搜索中) - 删除整个单词
Ctrl-K ( 在渐进式搜索中) - 删除整个行
Ctrl-O，o - 输入uniq模式( 无重复行)
Ctrl-E，e - 编辑 private 历史记录( 在 private 历史视图中时)
F1 - ( 在历史中) - switch 视图
F2，Ctrl-X，Ctrl-/ - 搜索预定义关键字( 在配置文件中定义)

``` zsh
➜  git clone https://github.com/psprint/zsh-navigation-tools $ZSH_CUSTOM/plugins/zsh-navigation-tools

➜  git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search

```

#### 3.2.5、incr

自动补全插件

``` zsh
➜  wget http://mimosa-pudica.net/src/incr-0.2.zsh -P $ZSH_CUSTOM/plugins/incr

➜  vim ~/.zshrc
source $ZSH_CUSTOM/plugins/incr/incr*.zsh
➜  source ~/.zshrc
```

## 四、更新zsh

设置自动更新oh-my-zsh

默认情况下，当oh-my-zsh有更新时，都会给你提示。如果希望让oh-my-zsh自动更新，在 ~/.zshrc 中添加下面这句

``` zsh
DISABLE_UPDATE_PROMPT=true
```

要手动更新，可以执行

``` zsh
➜  upgrade_oh_my_zsh
```

## 五、卸载

卸载oh my zsh, 执行命令

``` zsh
➜  uninstall_oh_my_zsh
```

> 参考链接：
> 1、[利用Oh-My-Zsh打造你的超级终端](https://mp.weixin.qq.com/s?__biz=MzI3MTI2NzkxMA==&mid=2247483784&idx=1&sn=60aa4c40e12b0d64bf373d5606f8e2e9&chksm=eac520a1ddb2a9b70ce515e9ee6f290842ef2276d0b52f620f05280b8e30f7f3c7591802ca5f&mpshare=1&scene=1&srcid=0902mAQRlr8XD2dBih5WORYG&sharer_sharetime=1599025557489&sharer_shareid=84509455e791b9103670fc35d3df3fe2&key=72c3d5049afd48cd55464d955ce5fd8e9669dd9e36d7ca8764d9601d42b3734033d73f900e6b80d33b56993cb474d550116f9875b7eba0ce6d4c025e030e44c670016a6711c38bc01103b741958aeec759cf2b11c0697ea7ee77aa5eb431ecb8cc594fb778189994ee5b989e57fd88746af3e02933cc8c95b6b935ebd6dcfbb4&ascene=1&uin=NjAwMjI3MTM2&devicetype=Windows+10+x64&version=62090529&lang=zh_CN&exportkey=A8YpMivm07HpVurRWMom860%3D&pass_ticket=kNr9jBeaLtB7eCDJgTKaJqX3jMNIc5JufLHFS4y%2FBWfr%2Bzx%2FIf2E18oWu%2Bn2luNc&wx_header=0)  
> 2、[自动补全插件incr](https://mimosa-pudica.net/zsh-incremental.html)  
> 3、[oh-my-zsh,让你的终端从未这么爽过](https://www.jianshu.com/p/d194d29e488c)  
>
