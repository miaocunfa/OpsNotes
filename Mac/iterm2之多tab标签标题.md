---
title: "iterm2 之多tab标签标题"
date: "2020-09-29"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
    - "X-pack"
    - "数据迁移"
toc: false
original: true
---

## 概述

最近从 Windows 系统迁移到 Mac系统，原先用的 Xshell 在多个标签时很容易分辨是哪个主机。

Mac系统的 iterm2 的默认tab标签标题就很分辨了。

![iterm2混淆](http://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/iterm_20200929_01.png)

## 解决方案

在网上查了查，到时有几种解决方案

1、使用

``` zsh
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}\007"'

echo $PROMPT_COMMAND
printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"
```

``` zsh
vim append_prompt.yaml
- name: profile prompt_command
     shell: /bin/echo {{ item }} >> /etc/profile
     with_items:
       - export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}\007"'
```

### 2、iterm2 插件

[badges插件](https://www.iterm2.com/documentation-badges.html)

### 3、iterm2 触发器

> 参考文档：  
> 1、[iterm2 - 会话标题](https://iterm2.com/documentation-session-title.html)  
> 2、[gitlab issues - Trigger to change window title](https://gitlab.com/gnachman/iterm2/-/issues/4698)  
> 3、[iterm2 - 触发器](https://iterm2.com/documentation-triggers.html)  
> 4、[怎样修改iterm/terminal窗口顶层显示的title?](https://jingyan.baidu.com/article/d45ad1485cc29b69542b804b.html)
> 5、[iTerm2-清爽主题界面配置](https://zhuanlan.zhihu.com/p/75798519)
>