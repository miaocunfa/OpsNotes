---
title: "SFCGAL之编译安装"
date: "2020-09-21"
categories:
    - "技术"
tags:
    - "boost"
toc: false
original: true
---

## 一、概述

[SFCGAL官网](http://www.sfcgal.org/)  
SFCGAL是一个围绕CGAL(Computational Geometry Algorithms Library - 计算几何算法库)的c++包装库，旨在支持ISO 19107:2013和OGC简单特性Access 1.2用于3D操作。  
SFCGAL提供了符合标准的几何类型和操作，可以通过其C或c++ api访问。PostGIS使用C API，在空间数据库中公开一些SFCGAL的功能(参见PostGIS手册)。

安装要求

Supported platforms
SFCGAL has been successfully compiled and tested on the following platforms :

- Linux 32 and 64 bits with gcc and clang-3.0
- Windows with mingw
- MacOSX with clang-4.0 (please note that a compilation error occures with clang-3.1)

Requirements

- A C++ compiler, see above for supported platforms
- CMake version ≥ 2.8.6
- [CGAL](https://www.cgal.org/index.html) version ≥ 4.3
- [Boost](https://www.boost.org/) version ≥ 1.54
- MPFR version ≥ 2.2.1
- GMP version ≥ 4.2

## 二、先决条件

``` zsh
# CGAL
# https://centos.pkgs.org/7/springdale-computational-x86_64/CGAL-devel-4.11.1-1.sdl7.x86_64.rpm.html
# ➜  wget http://springdale.princeton.edu/data/springdale/7/x86_64/os/Computational/CGAL-4.11.1-1.sdl7.x86_64.rpm
# ➜  wget http://springdale.princeton.edu/data/springdale/7/x86_64/os/Computational/CGAL-devel-4.11.1-1.sdl7.x86_64.rpm
# ➜  yum install CGAL-4.11.1-1.sdl7.x86_64.rpm CGAL-devel-4.11.1-1.sdl7.x86_64.rpm
# ➜  yum remove CGAL.x86_64 -y

➜  wget https://github.com/CGAL/cgal/archive/releases/CGAL-4.13.2.tar.gz
➜  tar -zxf CGAL-4.13.2.tar.gz
➜  mkdir -p build/release; cd build/release
➜  cmake3 -DCMAKE_BUILD_TYPE=Release ../..
➜  make && make install

# Boost
# ➜  wget https://dl.bintray.com/boostorg/release/1.74.0/source/boost_1_74_0.tar.gz
# ➜  tar -zxf boost_1_74_0.tar.gz
# ➜  cd boost_1_74_0/
# ➜  ./bootstrap.sh --with-libraries=all --with-toolset=gcc
# ➜  ./b2 install

# MPFR
➜  yum info mpfr
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
Installed Packages
Name        : mpfr
Arch        : x86_64
Version     : 3.1.1

# GMP
➜  yum info gmp
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
Installed Packages
Name        : gmp
Arch        : x86_64
Epoch       : 1
Version     : 6.0.0
```

## 三、编译

``` zsh
# SFCGAL
➜  wget https://gitlab.com/Oslandia/SFCGAL/-/archive/v1.3.8/SFCGAL-v1.3.8.tar.gz
➜  tar -zxf SFCGAL-v1.3.8.tar.gz

# 编译
➜  cd SFCGAL-v1.3.8
➜  cmake3 . && make && make install
```

## 四、错误汇总

### 4.1、cmake错误

发现官方已将项目[迁移至Gitlab](https://github.com/Oslandia/SFCGAL/issues/230)  
下载最新的1.3.8版本，最新的报错如下。

``` zsh
cmake .
-- The C compiler identification is GNU 4.8.5
-- The CXX compiler identification is GNU 4.8.5
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Setting build type to 'Release' as none was specified.
-- CGAL 4.11.1 found
CMake Error at CMakeLists.txt:59 (if):
  if given arguments:

    "4.11.1" "VERSION_GREATER_EQUAL" "5.0.0"

  Unknown arguments specified


-- Configuring incomplete, errors occurred!
See also "/root/postgis/SFCGAL-v1.3.8/CMakeFiles/CMakeOutput.log".
```

查看CMakeLists.txt文件，推荐4.13版本的CGAL

``` zsh
#-- find CGAL  ---------------------------------------------
option( CGAL_USE_AUTOLINK "disable CGAL autolink" OFF )
if( ${CGAL_USE_AUTOLINK} )
    add_definitions( "-DCGAL_NO_AUTOLINK" )
endif()

# 4.3 minimal
# 4.13 recommended
```

> 参考链接：  
> 1、[搜索libSFCGAL.so包](https://rpm.pbone.net/index.php3/stat/3/srodzaj/1/search/libSFCGAL.so.1%28%29%2864bit%29)  
> 2、[sfcgal官网](http://www.sfcgal.org/)  
>