---
title: "Zabbix告警邮件模板"
date: "2021-03-18"
categories:
    - "技术"
tags:
    - "zabbix"
toc: false
original: true
draft: true
---

## 更新记录

| 时间       | 内容       |
| ---------- | ---------- |
| 2021-03-18 | 初稿       |
| 2021-03-29 | 修改后样式 |

## 引言

现在的邮件是这样式儿的。实在太丑~

![告警原样式](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_mail_20210318.jpg)

## 修改动作

点击 '配置' --> '动作' --> 找到对应的动作

点击'操作'选项卡  
在'消息内容'一栏 填入下列信息

``` zsh
{TRIGGER.STATUS}: {TRIGGER.NAME}
告警主机: {HOST.NAME}
主机地址: {HOST.IP}
告警时间: {EVENT.DATE} {EVENT.TIME}
告警等级: {TRIGGER.SEVERITY}
告警信息: {TRIGGER.NAME}
问题详情: {ITEM.NAME}:{ITEM.VALUE}
事件代码: {EVENT.ID}
```

点击'恢复操作'选项卡  
在'消息内容'一栏 填入下列信息

``` zsh
{TRIGGER.STATUS}: {TRIGGER.NAME}
告警主机: {HOST.NAME}
主机地址: {HOST.IP}
恢复时间: {EVENT.DATE} {EVENT.TIME}
恢复等级: {TRIGGER.SEVERITY}
恢复信息: {TRIGGER.NAME}
问题详情: {ITEM.NAME}:{ITEM.VALUE}
事件代码: {EVENT.ID}
```

## 修改后样式

![修改后样式](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/zabbix_mail_20210329.jpg)

> 参考文档:  
> [1] [zabbix 告警信息模板](https://blog.csdn.net/weixin_30872733/article/details/96707764)  
>