---
title: "自动生成k8s-yaml解决方案"
date: "2020-09-23"
categories:
    - "技术"
tags:
    - "Kubernetes"
    - "容器化"
    - "解决方案"
toc: false
indent: false
original: true
draft: false
---

## 概述

考虑到以后微服务越来越多，如果每次更新微服务都需要修改每一个Deployment YAML的话，工作量会非常巨大。

## 版本

所以特意花了一点时间研究出了自动生成YAML，我用python做了三版自动生成脚本:  
1、[替换版](https://github.com/miaocunfa/OpsNotes/blob/master/python/Auto-Create-K8S-YAML/replace/auto_create_deploy_yaml.py)  
2、[YAML转JSON版](https://github.com/miaocunfa/OpsNotes/blob/master/Kubernetes-stack/Application/templating-kubernetes-yaml.py)  
3、[模板渲染版](https://github.com/miaocunfa/OpsNotes/blob/master/Kubernetes-stack/Application/templating-k8s-with-jinja2.py)  

## 为什么更新

1、在第一版替换版考虑到，只靠替换无法生成数组那种形式的内容，替换给你留的位置只有一个，如果你想更新多个内容就无法实现了  
2、所以进入了第二版的更新，将YAML模板读取成为JSON，根据代码修改好所有内容后，再转为JSON，这一版更新将上一版遗留的无法更新多个内容解决掉了，同时通过代码来控制内容带来的结果就是，代码量巨大，每次增加一个新属性更新起来巨费劲，代码可读性、可维护性差！  
3、柳暗花明又一村，在这个时候了解到了模板渲染jinja2，这个有点像GO模板也有点像HELM，而且上述所有功能都能实现，使用模板渲染的好处就是代码可读性和可维护性都上来了。

## 思考

1、也许在不远的未来我还会对这一部分进行更新，在我研究HELM的时候，我就发现可以创建自己的Chart，我还没有深入研究，但我感觉应该比我所写的自动生成脚本更完善。  
