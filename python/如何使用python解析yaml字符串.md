---
title: "如何使用python解析yaml字符串？"
date: "2021-03-03"
categories:
    - "技术"
tags:
    - "Python"
toc: false
original: false
draft: false
---

在python中如何使用yaml我看到了许多API和示例，这些示例说明了如何解析yaml文件，但是字符串呢？

## 最佳答案

到目前为止，这是我所看到的最佳示例:

``` py
import yaml

dct = yaml.safe_load('''
name: John
age: 30
automobiles:
- brand: Honda
  type: Odyssey
  year: 2018
- brand: Toyota
  type: Sienna
  year: 2015
''')

assert dct['name'] == 'John'
assert dct['age'] == 30
assert len(dct["automobiles"]) == 2
assert dct["automobiles"][0]["brand"] == "Honda"
assert dct["automobiles"][1]["year"] == 2015
```

> 原文  
> [python - 如何使用python解析yaml字符串？](https://www.coder.work/article/1257286)
> 