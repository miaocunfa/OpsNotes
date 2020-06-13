---
title: "主机间ssh免密"
date: "2020-03-25"
categories:
    - "技术"
tags:
    - "ssh"
    - "linux"
toc: false
original: true
---

# 主机间ssh免密

## 一、免密试验

### 1.1、生成秘钥
``` bash
$ ssh-keygen
```

一路回车，生成默认秘钥，生成的默认秘钥路径在/root/.ssh下
生成私钥id_rsa和公钥id_rsa.pub

### 1.2、拷贝公钥
将公钥拷贝至其他主机
``` bash
$ ssh-copy-id 192.168.100.211
```

## 1.3、免密登录
```

```