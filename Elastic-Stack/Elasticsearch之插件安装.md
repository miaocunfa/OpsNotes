---
title: "Elasticsearch之插件安装"
date: "2020-09-16"
categories:
    - "技术"
tags:
    - "Elasticsearch"
    - "搜索引擎"
toc: false
original: true
draft: false
---

## 一、插件管理工具

elasticsearch 自带了插件管理工具 `elasticsearch-plugin`，程序在 `$es-WorkDir/bin` 下

``` zsh
# 使用 -h选项，elasticsearch-plugin有三个选项。
➜  bin ./elasticsearch-plugin -h
A tool for managing installed elasticsearch plugins

Commands
--------
list - Lists installed elasticsearch plugins    # 查看已经安装的插件列表
install - Install a plugin                      # 安装es插件
remove - removes a plugin from Elasticsearch    # 卸载es插件
```

## 二、列表

``` zsh
➜  bin ./elasticsearch-plugin list
analysis-hanlp
elasticsearch
```

## 三、安装插件

以安装[ik分词器](https://github.com/medcl/elasticsearch-analysis-ik)为例

``` zsh
# 两种安装方式
# 1、网络url - elasticsearch-plugin install 是支持网络url位置的
➜  ./elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.1/elasticsearch-analysis-ik-7.1.1.zip

# 2、本地file
➜  cd /opt/elasticsearch-7.1.1
➜  wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.1/elasticsearch-analysis-ik-7.1.1.zip

# file:// 是指本地的文件，前面两个//是协议，第三个/是根路径。
➜  bin/elasticsearch-plugin install file:///opt/elasticsearch-7.1.1/elasticsearch-analysis-ik-7.1.1.zip


# 安装完之后查看列表
➜  ./elasticsearch-plugin list
analysis-hanlp
analysis-ik
```

## 四、错误

### 4.1、无法安装，重复插件

``` zsh
➜  ./elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.1/elasticsearch-analysis-ik-7.1.1.zip
-> Downloading https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.1/elasticsearch-analysis-ik-7.1.1.zip
[=================================================] 100%
Exception in thread "main" java.lang.IllegalStateException: duplicate plugin: - Plugin information:
Name: analysis-ik
Description: IK Analyzer for Elasticsearch
Version: 7.1.1
Elasticsearch Version: 7.1.1
Java Version: 1.8
Native Controller: false
Extended Plugins: []
 * Classname: org.elasticsearch.plugin.analysis.ik.AnalysisIkPlugin
    at org.elasticsearch.plugins.PluginsService.readPluginBundle(PluginsService.java:405)
    at org.elasticsearch.plugins.PluginsService.findBundles(PluginsService.java:386)
    at org.elasticsearch.plugins.PluginsService.getPluginBundles(PluginsService.java:379)
    at org.elasticsearch.plugins.InstallPluginCommand.jarHellCheck(InstallPluginCommand.java:756)
    at org.elasticsearch.plugins.InstallPluginCommand.loadPluginInfo(InstallPluginCommand.java:728)
    at org.elasticsearch.plugins.InstallPluginCommand.installPlugin(InstallPluginCommand.java:793)
    at org.elasticsearch.plugins.InstallPluginCommand.install(InstallPluginCommand.java:776)
    at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:231)
    at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:216)
    at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86)
    at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124)
    at org.elasticsearch.cli.MultiCommand.execute(MultiCommand.java:77)
    at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124)
    at org.elasticsearch.cli.Command.main(Command.java:90)
    at org.elasticsearch.plugins.PluginCli.main(PluginCli.java:47)
```

问题解决

``` zsh
# 在plugins目录下发现 有一个elasticsearch目录
➜  cd plugins
➜  ll
total 4.0K
drwxr-xr-x. 3 zyes zyes 4.0K Dec 13  2019 analysis-hanlp
drwxr-xr-x. 3 zyes zyes  286 Jun  4  2019 elasticsearch

# 在这个目录中发现有ik插件
➜  cd elasticsearch
➜  ll
total 5.7M
-rw-r--r--. 1 zyes zyes 258K May  7  2018 commons-codec-1.9.jar
-rw-r--r--. 1 zyes zyes  61K May  7  2018 commons-logging-1.2.jar
drwxr-xr-x. 2 zyes zyes 4.0K May 31  2019 config
-rw-r--r--. 1 zyes zyes  54K May 31  2019 elasticsearch-analysis-ik-7.1.1.jar
-rw-r--r--. 1 zyes zyes 4.3M May 30  2019 elasticsearch-analysis-ik-7.1.1.zip
-rw-r--r--. 1 zyes zyes 720K May  7  2018 httpclient-4.5.2.jar
-rw-r--r--. 1 zyes zyes 320K May  7  2018 httpcore-4.4.4.jar
-rw-r--r--. 1 zyes zyes 1.8K May 31  2019 plugin-descriptor.properties
-rw-r--r--. 1 zyes zyes  125 May 31  2019 plugin-security.policy

# 使用插件管理器卸载，无法成功
➜  bin/elasticsearch-plugin remove elasticsearch
-> removing [elasticsearch]...
ERROR: bin dir for elasticsearch is not a directory

# 直接进入plugins路径，rm掉。
➜  cd plugins
➜  plugins ll
total 4.0K
drwxr-xr-x. 3 zyes zyes 4.0K Dec 13  2019 analysis-hanlp
drwxr-xr-x. 3 zyes zyes  286 Jun  4  2019 elasticsearch
➜  rm -rf elasticsearch
➜  plugins ll
total 4.0K
drwxr-xr-x. 3 zyes zyes 4.0K Dec 13  2019 analysis-hanlp
```

> 参考链接：
> 1、[ik分词器](https://github.com/medcl/elasticsearch-analysis-ik)  
>