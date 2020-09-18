---
title: "PostgreSQL 扩展之 PostGIS"
date: "2019-12-03"
categories:
    - "技术"
tags:
    - "PostgreSQL"
    - "PostGIS"
toc: false
original: true
---

## 版本信息

| Server  | Version |
| ------- | ------- |
| geos    | 3.8.1   |
| proj    | 7.1.0   |
| gdal    | 3.1.3   |
| SFCGAL  | 1.3.8   |
| postgis | 30_10   |

## 一、安装依赖

### 1.1、

``` zsh

```

## 二、安装PostGIS

### 2.1、编译源码

打开[PostGIS官网下载界面](http://www.postgis.net/source/)

要从源代码构建，需要先安装PostgreSQL，对于Linux用户，这意味着安装postgresql-devel或postgresql-dev软件包以及基本软件包。

还需要安装或构建[GEOS](http://trac.osgeo.org/geos), [Proj](https://proj.org/), [GDAL](http://gdal.org/), [LibXML2](http://www.xmlsoft.org/)和[JSON-C](https://github.com/json-c/json-c)

``` zsh
➜  tar xvzf postgis-3.0.2.tar.gz
➜  cd postgis-3.0.2
➜  ./configure
➜  make
➜  make install
```

### 2.2、使用yum包

``` zsh
➜  yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# 前面是postgis的版本后面对应postgre的版本
➜  yum search postgis
postgis23_10.x86_64 : Geographic Information Systems Extensions to PostgreSQL
postgis24_10.x86_64 : Geographic Information Systems Extensions to PostgreSQL
postgis25_10.x86_64 : Geographic Information Systems Extensions to PostgreSQL
postgis30_10.x86_64 : Geographic Information Systems Extensions to PostgreSQL

➜  yum install -y postgis30_10.x86_64
```

## 三、启用扩展

``` zsh
-- Enable PostGIS (as of 3.0 contains just geometry/geography)
CREATE EXTENSION postgis;
-- enable raster support (for 3+)
CREATE EXTENSION postgis_raster;
-- Enable Topology
CREATE EXTENSION postgis_topology;
-- Enable PostGIS Advanced 3D
-- and other geoprocessing algorithms
-- sfcgal not available with all distributions
CREATE EXTENSION postgis_sfcgal;
-- fuzzy matching needed for Tiger
CREATE EXTENSION fuzzystrmatch;
-- rule based standardizer
CREATE EXTENSION address_standardizer;
-- example rule data set
CREATE EXTENSION address_standardizer_data_us;
-- Enable US Tiger Geocoder
CREATE EXTENSION postgis_tiger_geocoder;
```

## 四、错误

``` zsh
--> Finished Dependency Resolution
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: proj71 >= 7.1.0                          # proj 7.1.0
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: libproj.so.19()(64bit)
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: libSFCGAL.so.1()(64bit)                  # SFCGAL
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: libgdal.so.27()(64bit)
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: geos38 >= 3.8.1                          # geos 3.8.1
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: SFCGAL
Error: Package: postgis30_10-3.0.2-1.rhel7.x86_64 (pgdg10)
           Requires: gdal31-libs >= %{gdalminorversion}       # gdal 3.1 以上版本
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
```

安装依赖

``` zsh
➜  wget http://download.osgeo.org/geos/geos-3.8.1.tar.bz2
➜  tar jxvf geos-3.8.1.tar.bz2

➜  wget https://download.osgeo.org/proj/proj-7.1.0.tar.gz
➜  tar zxf proj-7.1.0.tar.gz

➜  wget https://github.com/OSGeo/gdal/releases/download/v3.1.3/gdal-3.1.3.tar.gz
➜  tar zxf gdal-3.1.3.tar.gz

# SFCGAL
➜  wget https://gitlab.com/Oslandia/SFCGAL/-/archive/v1.3.8/SFCGAL-v1.3.8.tar.gz
➜  tar zxf SFCGAL-v1.3.8.tar.gz
```

> 参考链接：
> 1、[PostGIS - 官方二进制编译手册](http://www.postgis.net/source/)  
> 2、[PostGIS - 官方安装手册](http://www.postgis.net/install/)  
> 3、[PostGIS官网](http://www.postgis.org/)  
> 4、[PostGIS 如何通过dnf包管理工具安装在CentOS8上](https://people.planetpostgresql.org/devrim/index.php?/archives/102-Installing-PostGIS-3.0-and-PostgreSQL-12-on-CentOS-8.html)  
> 5、[搜索libSFCGAL.so包](https://rpm.pbone.net/index.php3/stat/3/srodzaj/1/search/libSFCGAL.so.1%28%29%2864bit%29)
> 6、[sfcgal官网](http://www.sfcgal.org/)
>