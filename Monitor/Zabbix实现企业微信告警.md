---
title: "Zabbix实现企业微信告警"
date: "2020-09-02"
categories:
    - "技术"
tags:
    - "zabbix"
    - "告警"
toc: false
original: true
---

| 时间       | 内容             |
| ---------- | ---------------- |
| 2020-09-02 | 初稿             |
| 2020-09-14 | 文档优化 && 图片 |

## 一、企业微信

``` zsh
➜  chown zabbix:zabbix wechat.py
```

AgentId
1000003
Secret
9Ul8PVA3iaCBp7B1lx3LQxUqasQ78b_5mF7_7Nq6S7U
企业ID
wwf9e09da7812a4d37

{
    u'invaliduser': u'',
    u'errcode': 0,
    u'errmsg': u'ok. Warning: wrong json format. '
}

## 二、Zabbix 配置 && 告警脚本

``` zsh
# 测试脚本时，提示警告信息
➜  python2 ./wechat.py miaocunfa test "test error push"
/usr/lib/python2.7/site-packages/requests/__init__.py:91: RequestsDependencyWarning: urllib3 (1.24.1) or chardet (2.2.1) doesn't match a supported version!
  RequestsDependencyWarning)
{u'invaliduser': u'', u'errcode': 0, u'errmsg': u'ok. Warning: wrong json format. '}

# 卸载 urllib3 与 chardet
➜  pip uninstall urllib3 -y
DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
Found existing installation: urllib3 1.24.1
Uninstalling urllib3-1.24.1:
  Successfully uninstalled urllib3-1.24.1
➜  pip uninstall chardet -y
DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
Found existing installation: chardet 3.0.4
Uninstalling chardet-3.0.4:
  Successfully uninstalled chardet-3.0.4

# 安装 requests
➜  pip install requests
DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support
Looking in indexes: http://mirrors.cloud.aliyuncs.com/pypi/simple/
Requirement already satisfied: requests in /usr/lib/python2.7/site-packages (2.24.0)
Requirement already satisfied: idna<3,>=2.5 in /usr/lib/python2.7/site-packages (from requests) (2.8)
Collecting chardet<4,>=3.0.2
  Downloading http://mirrors.cloud.aliyuncs.com/pypi/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl (133 kB)
     |████████████████████████████████| 133 kB 16.5 MB/s 
Requirement already satisfied: urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1 in /usr/lib/python2.7/site-packages/urllib3-1.22-py2.7.egg (from requests) (1.22)
Requirement already satisfied: certifi>=2017.4.17 in /usr/lib/python2.7/site-packages (from requests) (2018.11.29)
Installing collected packages: chardet
  Attempting uninstall: chardet
    Found existing installation: chardet 2.2.1
    Uninstalling chardet-2.2.1:
      Successfully uninstalled chardet-2.2.1
Successfully installed chardet-3.0.4

➜  python2 ./wechat.py miaocunfa test "test error push"
{u'invaliduser': u'', u'errcode': 0, u'errmsg': u'ok. Warning: wrong json format. '}
```

## 三、Zabbix 告警媒介 && 触发告警
