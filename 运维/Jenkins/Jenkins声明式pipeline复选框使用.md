---
title: "Jenkins 声明式pipeline 复选框使用"
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
| 2022-04-27 | 初稿         |

## for循环输出 复选框的选择项

``` pipeline
pipeline{
    agent any

    parameters {
        extendedChoice name: 'sub_item', defaultValue: 'shop-index', description: '选择编译项目', multiSelectDelimiter: ',', quoteValue: false, saveJSONParameterToFile: false, type: 'PT_CHECKBOX', value: 'shop-index, shop-item, shop-log, shop-member, shop-order, shop-shop, shop-web-admin, shop-web-mobile, shop-web-pc, shop-web-seller', visibleItemCount: 10
    }

    stages{
        stage("构建镜像"){
            steps {
                script {
                    for (item in sub_item.tokenize(',')) {
                        echo "$item"
                    }
                }
            }
        }
    }

}

```

![for循环输出-01](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220427_01.jpg)

![for循环输出-02](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins_20220427_02.jpg)
