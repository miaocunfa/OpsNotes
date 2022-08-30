---
title: "shell如何解析json"
date: "2020-06-22"
categories:
    - "技术"
tags:
    - "运维"
    - "shell"
    - "python"
    - "json"
toc: false
original: true
draft: false
---

## 一、jq

使用外部解析器jq

``` zsh
# 安装jq
➜  yum install -y jq
```

### 解析json

``` zsh
➜  cat /home/miaocunfa/bin/version.json
{
    "version": "202006191435",
    "info-message-service.jar": {
        "version": "202006191435",
        "hosts": ["192.168.100.222"]
    }
}

➜  cat /home/miaocunfa/bin/version.json | jq '.version'
"202006191435"
➜  cat /home/miaocunfa/bin/version.json | jq '.info-message-service.jar'
jq: error: message/0 is not defined at <top-level>, line 1:
.info-message-service.jar
jq: error: service/0 is not defined at <top-level>, line 1:
.info-message-service.jar
jq: 2 compile errors
➜  cat /home/miaocunfa/bin/version.json | jq '."info-message-service.jar"'
{
  "version": "202006191435",
  "hosts": [
    "192.168.100.222"
  ]
}
```

## 二、python

``` zsh
➜  cat /home/miaocunfa/bin/version.json | python3 -c "import sys, json; print(json.load(sys.stdin)['version'])"
202006191435
```
