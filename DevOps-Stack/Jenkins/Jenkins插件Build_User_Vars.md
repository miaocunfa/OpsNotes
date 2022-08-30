---
title: "Jenkins 插件 Build User Vars"
date: "2022-07-26"
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

| 时间       | 内容                 |
| ---------- | ------------------- |
| 2022-07-26 | 初稿                |

## 流水线示例

``` zsh
pipeline{
    agent any

    stages{
        stage("test"){
            steps{
                sh "echo $BUILD_USER"
            }
        }
    }

}
```

![Build User Vars](https://cdn.jsdelivr.net/gh/miaocunfa/imghosting/img/jenkins-2.249.3-20220519-01.png)

> 参考文章：  
>
> - [【Jenkins学习 】Jenkins安装 Build User Vars Plugin插件来获取jenkins用户相关信息](https://blog.csdn.net/ouyang_peng/article/details/102949834)  
> - [build-user-vars-plugin 语法](https://plugins.jenkins.io/build-user-vars-plugin/)  
