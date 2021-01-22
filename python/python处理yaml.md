---
title: "python处理yaml"
date: "2020-06-12"
categories:
    - "技术"
tags:
    - "python"
    - "json"
    - "yaml"
toc: false
indent: false
original: false
draft: false
---

> 作者：可优  
> 链接：<https://www.cnblogs.com/keyou1/p/11510975.html>

## 一、python模块

pyyaml

- 应用最广泛
- 封装的api不够简单
- 不支持YAML 1.2最新版

ruamel.yaml

- 是pyyaml的衍生版
- 封装的api简单
- 支持YAML 1.2最新版

## 二、安装ruamel.yaml

使用官方pypi源来安装

``` zsh
➜  pip install ruamel.yaml
```

使用豆瓣pypi源来安装（推荐）

``` zsh
➜  pip install -i https://pypi.douban.com/simple ruamel.yaml
```

## 三、基本用法

### 3.1、yaml转JSON

原始yaml

``` yaml
➜  vim user_info.yaml
# 外号
user:
  - 可优
  - keyou
  - 小可可
  - 小优优

# 爱人
lovers:
  - 柠檬小姐姐
  - 橘子小姐姐
```

使用python进行处理

``` zsh
➜  vim yaml_json.py
from ruamel.yaml import YAML

# 第一步: 创建YAML对象
yaml = YAML(typ='safe')

# typ: 选择解析yaml的方式
#  'rt'/None -> RoundTripLoader/RoundTripDumper(默认)
#  'safe'    -> SafeLoader/SafeDumper,
#  'unsafe'  -> normal/unsafe Loader/Dumper
#  'base'    -> baseloader

# 第二步: 读取yaml格式的文件
with open('user_info.yaml', encoding='utf-8') as file:
    data = yaml.load(file)  # 为JSON

print(f"data:\n{data}")
```

输出结果

``` zsh
➜  python3 yaml_json.py
data:
{'user': ['可优', 'keyou', '小可可', '小优优'], 'lovers': ['柠檬小姐姐', '橘子小姐姐']}
```

### 3.2、JSON转yaml

将Python中的字典或者列表转化为yaml格式的数据

``` zsh
➜  vim json_yaml.py
from ruamel.yaml import YAML

# 第一步: 创建YAML对象
# yaml = YAML(typ='safe')
yaml = YAML()

# 第二步: 将Python中的字典类型数据转化为yaml格式的数据
src_data = {'user': {'name': '可优', 'age': 17, 'money': None, 'gender': True},
            'lovers': ['柠檬小姐姐', '橘子小姐姐', '小可可']
            }

with open('new_user_info.yaml', mode='w', encoding='utf-8') as file:
    yaml.dump(src_data, file)
```

生成的new_user_info.yaml文件:

``` zsh
➜  cat new_user_info.yaml
user:
  name: 可优
  age: 17
  money:
  gender: true
lovers:
- 柠檬小姐姐
- 橘子小姐姐
- 小可可
```

### 3.3、对象转yaml

1.将Python中的对象转化为yaml格式数据

``` zsh
➜  vim object_yaml.yaml
from ruamel.yaml import YAML

# 第一步: 创建需要保存的User类
class User:
    """
    定义用户类
    """
    def __init__(self, name, age, gender):
        self.name, self.age, self.gender = name, age, gender
        self.lovers = []

    def loved(self, user):
        self.lovers.append(user)


# 第二步: 创建YAML对象
yaml = YAML()

# 第三步: 注册用户类
yaml.register_class(User)

# 第四步: 保存用户对象
keyou = User("可优", 17, "油腻男")
lemon_little_girl = User("柠檬小姐姐", 16, "素颜小仙女")
orange_little_girl = User("橘子小姐姐", 18, "不会PS的靓妹")
keyou.loved(lemon_little_girl)
keyou.loved(orange_little_girl)

with open('lovers.yaml', mode='w', encoding='utf-8') as file:
    yaml.dump([keyou], file)
```

生成的lovers.yaml文件:

``` zsh
➜  cat lovers.yaml
- !User
  name: 可优
  age: 17
  gender: 油腻男
  lovers:
  - !User
    name: 柠檬小姐姐
    age: 16
    gender: 素颜小仙女
    lovers: []
  - !User
    name: 橘子小姐姐
    age: 18
    gender: 不会PS的靓妹
    lovers: []
```
