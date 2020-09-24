---
title: "PostgreSQL 扩展之 PostGIS"
date: "2020-09-18"
categories:
    - "技术"
tags:
    - "PostgreSQL"
    - "PostGIS"
toc: false
original: true
---

## 更新记录

| 时间       | 内容                                    |
| ---------- | --------------------------------------- |
| 2020-09-18 | 初稿                                    |
| 2020-09-21 | 依赖安装                                |
| 2020-09-22 | 依赖安装 && 参考链接 && PostGIS主体安装 |
| 2020-09-23 | PostGIS 插件启用 && 报错解决            |

## 版本信息

| Server  | Version |
| ------- | ------- |
| CentOS  | 7.6     |
| geos    | 3.8.1   |
| proj    | 7.1.0   |
| sqlite  | 3.33    |
| gdal    | 3.1.3   |
| SFCGAL  | 1.3.8   |
| CGAL    | 4.13    |
| libxml2 | 2.9.1   |
| postgis | 3.0.2   |

## 一、安装依赖

这四个依赖最好不要换顺序，有的包依赖前一个包。gdal --> proj

### 1.1、geos

安装说明查看源代码主目录下的INSTALL文件

``` zsh
# 下载源码
➜  wget http://download.osgeo.org/geos/geos-3.8.1.tar.bz2
➜  tar jxvf geos-3.8.1.tar.bz2

# 升级cmake --> cmake3
➜  yum install -y cmake3

# 编译
➜  mkdir build && cd build && cmake3 -DCMAKE_BUILD_TYPE=Release ..
➜  make && make install
```

### 1.2、SFCGAL

[SFCGAL安装文档](https://github.com/miaocunfa/OpsNotes/blob/master/Deploy/SFCGAL%E4%B9%8B%E7%BC%96%E8%AF%91%E5%AE%89%E8%A3%85.md)

### 1.3、proj

[proj安装文档](https://github.com/miaocunfa/OpsNotes/blob/master/Deploy/Proj%E4%B9%8B%E7%BC%96%E8%AF%91%E3%80%81%E5%AE%89%E8%A3%85.md)

### 1.4、gdal

[gdal官网](http://gdal.org/)

``` zsh
➜  wget https://github.com/OSGeo/gdal/releases/download/v3.1.3/gdal-3.1.3.tar.gz
➜  tar zxf gdal-3.1.3.tar.gz

# 编译
➜  cd gdal-3.1.3
➜  ./configure && make && make install
```

### 1.5、libxml2

``` zsh
➜  yum install -y libxml2.x86_64 libxml2-devel.x86_64
```

### 1.6、postgresql-devel

``` zsh
➜  yum install -y postgresql10-devel.x86_64
```

## 二、安装PostGIS

### 2.1、编译源码

打开[PostGIS官网下载界面](http://www.postgis.net/source/)

要从源代码构建，需要先安装PostgreSQL，对于Linux用户，这意味着安装postgresql-devel或postgresql-dev软件包以及基本软件包。

还需要安装或构建[GEOS](http://trac.osgeo.org/geos), [Proj](https://proj.org/), [GDAL](http://gdal.org/), [LibXML2](http://www.xmlsoft.org/)和[JSON-C](https://github.com/json-c/json-c)

``` zsh
➜  wget https://download.osgeo.org/postgis/source/postgis-3.0.2.tar.gz
➜  tar xvzf postgis-3.0.2.tar.gz
➜  cd postgis-3.0.2

# 编译
➜  ./configure --with-pgconfig=/usr/pgsql-10/bin/pg_config

  PostGIS is now configured for x86_64-pc-linux-gnu

 -------------- Compiler Info -------------
  C compiler:           gcc -std=gnu99 -g -O2 -fno-math-errno -fno-signed-zeros
  CPPFLAGS:              -I/usr/local/include -I/usr/local/include    -I/usr/include/libxml2 -I/usr/local/include
  SQL preprocessor:     /usr/bin/cpp -traditional-cpp -w -P

 -------------- Additional Info -------------
  Interrupt Tests:   DISABLED use: --with-interrupt-tests to enable

 -------------- Dependencies --------------
  GEOS config:          /usr/local/bin/geos-config
  GEOS version:         3.8.1
  GDAL config:          /usr/local/bin/gdal-config
  GDAL version:         3.1.3
  SFCGAL config:        /usr/local/bin/sfcgal-config
  SFCGAL version:       1.3.8
  PostgreSQL config:    /usr/pgsql-10/bin/pg_config
  PostgreSQL version:   PostgreSQL 10.14
  PROJ4 version:        71
  Libxml2 config:       /usr/bin/xml2-config
  Libxml2 version:      2.9.1
  JSON-C support:       no
  protobuf support:     no
  PCRE support:         no
  Perl:                 /usr/bin/perl
  Wagyu:                no

 --------------- Extensions ---------------
  PostGIS Raster:                     enabled
  PostGIS Topology:                   enabled
  SFCGAL support:                     enabled
  Address Standardizer support:       disabled

 -------- Documentation Generation --------
  xsltproc:             /usr/bin/xsltproc
  xsl style sheets:
  dblatex:
  convert:
  mathml2.dtd:          http://www.w3.org/Math/DTD/mathml2/mathml2.dtd

➜  make && make install
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

> DO NOT INSTALL it in the database called postgres  
> 不要将扩展安装的postgres库上

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

### 4.1、依赖

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

错误解决

``` zsh
# 下载依赖包，并安装。

# geos
➜  wget http://download.osgeo.org/geos/geos-3.8.1.tar.bz2

# proj
➜  wget https://download.osgeo.org/proj/proj-7.1.0.tar.gz

# gdal
➜  wget https://github.com/OSGeo/gdal/releases/download/v3.1.3/gdal-3.1.3.tar.gz

# SFCGAL
➜  wget https://gitlab.com/Oslandia/SFCGAL/-/archive/v1.3.8/SFCGAL-v1.3.8.tar.gz
```

### 4.2、geos

``` zsh
# 编译
➜  cd geos-3.8.1
➜  mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
CMake Error at CMakeLists.txt:14 (cmake_minimum_required):
  CMake 3.8 or higher is required.  You are running version 2.8.12.2


-- Configuring incomplete, errors occurred!
```

错误解决

``` zsh
# 升级cmake
➜  yum install -y cmake3

➜  mkdir build && cd build && cmake3 -DCMAKE_BUILD_TYPE=Release ..
```

### 4.3、with-pgconfig

``` zsh
checking for pg_config... no
configure: error: could not find pg_config within the current path. You may need to re-run configure with a --with-pgconfig parameter.
```

错误解决

``` zsh
➜  ./configure --with-pgconfig=/usr/pgsql-10/bin/pg_config
Using user-specified pg_config file: /usr/pgsql-10/bin/pg_config
configure: error: the PGXS Makefile /usr/pgsql-10/lib/pgxs/src/makefiles/pgxs.mk cannot be found. Please install the PostgreSQL server development packages and re-run configure.

➜  yum install -y postgresql10-devel.x86_64
```

### 4.4、libxml2

``` zsh
configure: error: Package requirements (libxml-2.0) were not met:

No package 'libxml-2.0' found

Consider adjusting the PKG_CONFIG_PATH environment variable if you
installed software in a non-standard prefix.

Alternatively, you may set the environment variables LIBXML2_CFLAGS
and LIBXML2_LIBS to avoid the need to call pkg-config.
See the pkg-config man page for more details.
```

错误解决

``` zsh
➜  yum install -y libxml2.x86_64 libxml2-devel.x86_64
```

### 4.5、启用postgis插件 --> postgis-3.so

``` zsh
# PSQL
CREATE EXTENSION postgis
> ERROR:  could not load library "/usr/pgsql-10/lib/postgis-3.so": libgeos_c.so.1: cannot open shared object file: No such file or directory

➜  ldd postgis-3.so
    linux-vdso.so.1 =>  (0x00007ffefe314000)
    libgeos_c.so.1 => not found
    libproj.so.19 => not found
    libxml2.so.2 => /lib64/libxml2.so.2 (0x00007f38605e3000)
    libz.so.1 => /lib64/libz.so.1 (0x00007f38603cd000)
    libm.so.6 => /lib64/libm.so.6 (0x00007f38600cb000)
    libdl.so.2 => /lib64/libdl.so.2 (0x00007f385fec7000)
    libSFCGAL.so.1 => not found
    libc.so.6 => /lib64/libc.so.6 (0x00007f385fafa000)
    liblzma.so.5 => /lib64/liblzma.so.5 (0x00007f385f8d4000)
    /lib64/ld-linux-x86-64.so.2 (0x00007f3860c31000)
    libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f385f6b8000)
```

问题解决

``` zsh
➜  find / -name "libgeos_c.so.1" -print
/root/postgis/geos-3.8.1/build/lib/libgeos_c.so.1
/usr/local/lib/libgeos_c.so.1
➜  cp /usr/local/lib/libgeos_c.so.1 /usr/lib64/

➜  find / -name "libproj.so.19" -print
/root/postgis/proj-7.1.0/src/.libs/libproj.so.19
/usr/local/lib/libproj.so.19
➜  cp /usr/local/lib/libproj.so.19 /usr/lib64/

➜  find / -name "libSFCGAL.so.1" -print
/root/postgis/SFCGAL-v1.3.8/src/libSFCGAL.so.1
/usr/local/lib64/libSFCGAL.so.1
➜  cp /usr/local/lib64/libSFCGAL.so.1 /usr/lib64/

➜  ldd postgis-3.so
    libgeos.so.3.8.1 => not found

➜  find / -name "libgeos.so.3.8.1" -print
/root/postgis/geos-3.8.1/build/lib/libgeos.so.3.8.1
/usr/local/lib/libgeos.so.3.8.1
➜  cp /usr/local/lib/libgeos.so.3.8.1 /usr/lib64
```

### 4.6、启用postgis_raster插件 --> postgis_raster-3.so

``` zsh
➜  ldd postgis_raster-3.so
    libgdal.so.27 => not found

➜  find / -name "libgdal.so.27" -print
/root/postgis/gdal-3.1.3/.libs/libgdal.so.27
/usr/local/lib/libgdal.so.27
➜  cp /usr/local/lib/libgdal.so.27 /usr/lib64
```

> 参考链接：  
> 1、[pkg - 官网](https://pkgs.org/)  
> 2、[sfcgal - 官网](http://www.sfcgal.org/)  
> 3、[gdal - 下载中心](https://gdal.org/download.html#current-releases)  
> 4、[PostGIS - 官网](http://www.postgis.org/)  
> 5、[PostGIS - 官方二进制编译手册](http://www.postgis.net/source/)  
> 6、[PostGIS - 官方安装手册](http://www.postgis.net/install/)  
> 7、[PostGIS 如何通过dnf包管理工具安装在CentOS8上](https://people.planetpostgresql.org/devrim/index.php?/archives/102-Installing-PostGIS-3.0-and-PostgreSQL-12-on-CentOS-8.html)  
> 8、[搜索libSFCGAL.so包](https://rpm.pbone.net/index.php3/stat/3/srodzaj/1/search/libSFCGAL.so.1%28%29%2864bit%29)  
> 9、[boost的编译、安装](https://www.cnblogs.com/smallredness/p/9245127.html)  
> 10、[centos-7-postgis-upgrade.md](https://gist.github.com/pramsey/2e6d140837c37e936cb501fec0922cd2)  
> 11、[PostGIS教程一：PostGIS介绍](https://blog.csdn.net/qq_35732147/article/details/85158177)  
> 12、[centos 升级cmake from 2.* to 3.*](https://www.cnblogs.com/jj1118/p/8028989.html)  
> 13、[centos7下升级cmake，很简单](https://blog.csdn.net/u013714645/article/details/77002555)  
> 14、[The install of the last version of postgis on RedHat 7U1 fails with "Error: Package: SFCGAL-libs-1.2.2-1.rhel7.x86_64 (Postgres_9.5) Requires: libboost_date_time-mt.so.1.53.0()(64bit)"](https://trac.osgeo.org/postgis/ticket/3442)  
> 15、[PostGIS 错误汇总](http://blog.sina.com.cn/s/blog_8acf1be10101lbfc.html)  
> 16、[手动安装postgis时遇到的坑](https://blog.csdn.net/u011170540/article/details/52248751?utm_source=blogxgwz2)  
>