# nginx编译安装

## 一、环境准备

``` bash
yum -y install gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel
```

## 二、下载源码包
``` bash
wget http://nginx.org/download/nginx-1.16.1.tar.gz
```

## 三、编译安装
``` bash
# 解压源码包
tar -zxvf nginx-1.16.1.tar.gz

cd nginx-1.16.1/

# 配置编译参数
./configure --prefix=/usr/local/nginx-1.16.1 \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_realip_module

# 编译
make && make install
```

## 四、查看nginx版本号
``` bash
[root@localhost /usr/local/nginx-1.16.1/sbin]#./nginx -V
nginx version: nginx/1.16.1
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx-1.16.1 --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module
```

## 五、创建软连接
将nginx可执行文件链接至/usr/bin下，可以在系统任意路径执行nginx
```
ln -s /usr/local/nginx-1.16.1/sbin/nginx /usr/bin/nginx
```
