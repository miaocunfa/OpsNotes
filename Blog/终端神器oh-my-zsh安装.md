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
---

## 一、安装

### 1.1、安装zsh

``` zsh
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
➜  themes git:(master) ls
3den.zsh-theme           cypher.zsh-theme      frisk.zsh-theme            jonathan.zsh-theme        mikeh.zsh-theme                 refined.zsh-theme       suvash.zsh-theme
adben.zsh-theme          dallas.zsh-theme      frontcube.zsh-theme        josh.zsh-theme            miloshadzic.zsh-theme           rgm.zsh-theme           takashiyoshida.zsh-theme
af-magic.zsh-theme       darkblood.zsh-theme   funky.zsh-theme            jreese.zsh-theme          minimal.zsh-theme               risto.zsh-theme         terminalparty.zsh-theme
afowler.zsh-theme        daveverwer.zsh-theme  fwalch.zsh-theme           jtriley.zsh-theme         mira.zsh-theme                  rixius.zsh-theme        theunraveler.zsh-theme
agnoster.zsh-theme       dieter.zsh-theme      gallifrey.zsh-theme        juanghurtado.zsh-theme    mlh.zsh-theme                   rkj-repos.zsh-theme     tjkirch_mod.zsh-theme
alanpeabody.zsh-theme    dogenpunk.zsh-theme   gallois.zsh-theme          junkfood.zsh-theme        mortalscumbag.zsh-theme         rkj.zsh-theme           tjkirch.zsh-theme
amuse.zsh-theme          dpoggi.zsh-theme      garyblessington.zsh-theme  kafeitu.zsh-theme         mrtazz.zsh-theme                robbyrussell.zsh-theme  tonotdo.zsh-theme
apple.zsh-theme          dstufft.zsh-theme     gentoo.zsh-theme           kardan.zsh-theme          murilasso.zsh-theme             sammy.zsh-theme         trapd00r.zsh-theme
arrow.zsh-theme          dst.zsh-theme         geoffgarside.zsh-theme     kennethreitz.zsh-theme    muse.zsh-theme                  simonoff.zsh-theme      wedisagree.zsh-theme
aussiegeek.zsh-theme     duellj.zsh-theme      gianu.zsh-theme            kiwi.zsh-theme            nanotech.zsh-theme              simple.zsh-theme        wezm.zsh-theme
avit.zsh-theme           eastwood.zsh-theme    gnzh.zsh-theme             kolo.zsh-theme            nebirhos.zsh-theme              skaro.zsh-theme         wezm+.zsh-theme
awesomepanda.zsh-theme   edvardm.zsh-theme     gozilla.zsh-theme          kphoen.zsh-theme          nicoulaj.zsh-theme              smt.zsh-theme           wuffers.zsh-theme
bira.zsh-theme           emotty.zsh-theme      half-life.zsh-theme        lambda.zsh-theme          norm.zsh-theme                  Soliah.zsh-theme        xiong-chiamiov-plus.zsh-theme
blinks.zsh-theme         essembeh.zsh-theme    humza.zsh-theme            linuxonly.zsh-theme       obraun.zsh-theme                sonicradish.zsh-theme   xiong-chiamiov.zsh-theme
bureau.zsh-theme         evan.zsh-theme        imajes.zsh-theme           lukerandall.zsh-theme     peepcode.zsh-theme              sorin.zsh-theme         ys.zsh-theme
candy-kingdom.zsh-theme  fino-time.zsh-theme   intheloop.zsh-theme        macovsky-ruby.zsh-theme   philips.zsh-theme               sporty_256.zsh-theme    zhann.zsh-theme
candy.zsh-theme          fino.zsh-theme        itchy.zsh-theme            macovsky.zsh-theme        pmcgee.zsh-theme                steeef.zsh-theme
clean.zsh-theme          fishy.zsh-theme       jaischeema.zsh-theme       maran.zsh-theme           pygmalion-virtualenv.zsh-theme  strug.zsh-theme
cloud.zsh-theme          flazz.zsh-theme       jbergantine.zsh-theme      mgutz.zsh-theme           pygmalion.zsh-theme             sunaku.zsh-theme
crcandy.zsh-theme        fletcherm.zsh-theme   jispwoso.zsh-theme         mh.zsh-theme              random.zsh-theme                sunrise.zsh-theme
crunch.zsh-theme         fox.zsh-theme         jnrowe.zsh-theme           michelebologna.zsh-theme  re5et.zsh-theme                 superjarin.zsh-theme
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

### 2.4、zsh 的插件
