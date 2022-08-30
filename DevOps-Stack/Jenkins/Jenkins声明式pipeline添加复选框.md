---
title: "Jenkins 声明式pipeline 添加复选框"
date: "2022-04-26"
categories:
    - "技术"
tags:
    - "Jenkins"
toc: false
indent: false
original: true
draft: false 
---

## 更新记录

| 时间       | 内容          |
| ---------- | ------------ |
| 2022-04-26 | 初稿         |

## 楔子

因为

## 安装插件

jenkins 自带的参数化不支持多选框，不过有插件支持：Extended Choice Parameter
插件地址： https://plugins.jenkins.io/extended-choice-parameter

![安装插件](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_01.jpg)

## 设置 pipeline参数

![pipeline参数-01](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_02.jpg)

![pipeline参数-02](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_03.jpg)

![pipeline参数-03](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_04.jpg)

## 获取复选框值

``` groovy
pipeline{
    agent any
    parameters {
        extendedChoice name: 'sub_item', defaultValue: 'shop-index', description: '子项目', multiSelectDelimiter: ',', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_CHECKBOX', value: 'shop-index, shop-item, shop-log, shop-member, shop-order, shop-shop, shop-web-admin, shop-web-mobile, shop-web-pc, shop-web-seller', visibleItemCount: 10
    }

    stages{
        stage("代码打包"){
            steps{
                echo "$sub_item"
            }
        }
    }
}
```

![获取复选框值-01](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_05.jpg)

![获取复选框值-02](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220426_06.jpg)

> 参考文章：  
>
> - [jenkins参数化构建过程（添加多选框）](https://blog.csdn.net/e295166319/article/details/54017231)  
>