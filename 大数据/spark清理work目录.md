---
title: "spark 清理 work 目录"
date: "2022-08-11"
categories:
    - "技术"
tags:
    - "spark"
    - "运维管理"
toc: false
indent: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2022-08-11 | 初稿 |

## 楔子

阿里云大数据节点最近一直报警空间超过80%，登上服务器看了一下

``` zsh
# 先查看所有数据盘空间
➜  df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        40G   31G  7.2G  81% /
devtmpfs         32G     0   32G   0% /dev
tmpfs            32G     0   32G   0% /dev/shm
tmpfs            32G  940K   32G   1% /run
tmpfs            32G     0   32G   0% /sys/fs/cgroup
/dev/vdb1       1.8T  514G  1.2T  30% /data
tmpfs           6.3G     0  6.3G   0% /run/user/0

# 查看系统盘空间占用
➜  du / -h -d 2 --exclude=/proc --exclude=/data > 1; grep G 1
22G     /usr/local
24G     /usr
4.6G    /var/log
5.2G    /var
1.1G    /root
31G     /

# 查看 /usr/local 空间占用
➜  cd /usr/local; du . -h -d 2 > 1; grep G 1
1.3G    ./mysql/bin
1.2G    ./mysql/lib
2.5G    ./mysql
12G     ./spark/spark-2.4.7-bin-hadoop2.7
12G     ./spark
1.6G    ./kafka_2.11-2.2.2/logs
1.7G    ./kafka_2.11-2.2.2
2.2G    ./hadoop-2.8.5/logs
2.8G    ./hadoop-2.8.5
22G     .

# 查看 spark 空间占用
➜  cd spark/spark-2.4.7-bin-hadoop2.7; du . -h -d 2 > 1; grep G 1
2.0G    ./work/app-20210329121912-0013
1.1G    ./work/app-20210329121902-0012
12G     ./work
12G     .
```

## 解决

修改 ${spark}/conf/spark-env.sh 文件 SPARK_WORKER_OPTS 属性

SPARK_WORKER_OPTS支持以下属性：

| 参数                                             | 默认参数                     | 说明                                                                                                                                                                                                                                                                                                                                        |
| ------------------------------------------------ | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| spark.worker.cleanup.enabled                     | false                        | 启用定期清除worker /应用程序目录。仅清除已停止的应用程序的目录。                                                                                                                                                                                                                                                                            |
| spark.worker.cleanup.interval                    | 1800 (30 minutes)            | 控制worker清理本地计算机上旧的应用程序工作目录的时间间隔（以秒为单位）。                                                                                                                                                                                                                                                                    |
| spark.worker.cleanup.appDataTtl                  | 604800 (7 days, 7 *24* 3600) | 在每个工作程序上保留应用程序工作目录的秒数。 这是生存时间，应取决于您拥有的可用磁盘空间量。 应用程序日志和jars被下载到每个应用程序工作目录。 随着时间的推移，工作目录会迅速填满磁盘空间，尤其是如果您非常频繁地运行作业时。                                                                                                                 |
| spark.storage.cleanupFilesAfterExecutorExit      | true                         | 在执行程序退出后，启用工作目录的清理非混洗文件（例如临时混洗块，缓存的RDD /广播块，溢出文件等）。 请注意，这与spark.worker.cleanup.enabled不重叠，因为这可以清除死掉执行者的本地目录中的非随机文件，而spark.worker.cleanup.enabled则可以清除所有文件。 /停止和超时应用程序的子目录。 这仅影响独立模式，将来可以添加对其他集群管理员的支持。 |
| spark.worker.ui.compressedLogFileLengthCacheSize | 100                          | 对于压缩日志文件，只能通过解压缩文件来计算未压缩文件。 Spark缓存压缩日志文件的未压缩文件大小。 此属性控制缓存大小。                                                                                                                                                                                                                         |

``` zsh
➜  vim spark-env.sh
SPARK_WORKER_OPTS="-Dspark.worker.cleanup.enabled=true -Dspark.worker.cleanup.interval=259200 -Dspark.worker.cleanup.appDataTtl=259200"
```

> 参考文章
>
> - [Spark性能优化](https://blog.csdn.net/weixin_43735682/article/details/103852103)
>