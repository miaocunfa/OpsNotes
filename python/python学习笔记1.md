---
title: "Python学习笔记之变量(一)"
date: "2020-04-29"
categories:
    - "技术"
tags:
    - "Python"
toc: false
original: true
---

## 一、命名规范

## 1.1、文件命名  
文件名和文件夹名，最好使用小写字母，并使用下划线来表示空格

## 1.2、变量命名
- 变量名只能包含字母、数字和下划线。变量名可以字母或下划线打头。但不能以数字打头。
- 变量名不能包含空格，但可使用下划线来分隔其中的单词。
- 不要将Python关键字和函数名用作变量名。
- 变量名应既简短又具有描述性
- 慎用小写字母l和大写字母O，因为它们可能被人错看成数字1和0

### 1.2.1、NameError  
名称错误通常意味着两种情况
- 要么是使用变量前忘记了给它赋值
- 要么是输入变量名时拼写不正确

## 2、字符串
```
    用引号括起的都是字符串，其中的引号可以是单引号，也可以是双引号。
```

### 2.1、字符串方法

#### 2.2.1、字符串大小写
``` python
>>> name = "ada lovelace"

>>> name.title()             # 以首字母大写的方式显示每个单词
'Ada Lovelace'

>>> name.upper()             # 将字符串改为全大写
'ADA LOVELACE'

>>> name.lower()             # 将字符串改为全小写
'ada lovelace'
```

#### 2.1.4、拼接
Python 使用加号(+)来合并字符串
``` python
>>> first_name = "ada"
>>> last_name = "lovelace"
>>> full_name = first_name + " " + last_name

>>> print(full_name)
ada lovelace
```

#### 2.1.5、去空格
``` python
>>> favorite_language = '  python  '
>>> favorite_language.lstrip()    # 字符串开头去空白
'python  '
>>> favorite_language.rstrip()    # 字符串结尾去空白
'  python'
>>> favorite_language.strip()     # 字符串开头结尾去空格
'python'
```

## 三、数值

### 3.1、整数
Python可对整数执行加 (+) 减 (-) 乘 (*) 除 (/) 运算  
Python使用两个乘号表示乘方运算  
Python还支持运算次序，可以使用括号来修改运算次序  
空格不影响Python计算表达式的方式  

### 3.2、浮点数
Python将带小数点的数字都称为浮点数

### 3.3、str()
调用函数str(), 将非字符串值表示为字符串
``` python
>>> age = 23
>>> message = "Happy " + str(age) + "rd Birthday!"

>>> print(message)
Happy 23rd Birthday!
```

## 四、注释
注释用井号 (#) 标识，井号后面的内容都会被Python解释器忽略