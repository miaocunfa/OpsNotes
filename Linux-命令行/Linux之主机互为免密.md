---
title: "Linux主机互为免密"
date: "2020-08-17"
categories:
    - "技术"
tags:
    - "openssl"
toc: false
indent: false
original: true
draft: false
---

## 1、ssh免密

主机生成私钥id_rsa与公钥id_rsa.pub
将公钥放至要免密登录的主机$HOME/.ssh下，
第一次登录该主机时，输入正确密码成功登录后，会生成认证文件authorized_keys，同时本地主机也会在$HOME/.ssh/known_hosts文件中添加一条记录。
这样以后再登录该主机，就不用再输入密码了。

## 2、生成秘钥

``` zsh
# 在ng1 主机下生成公钥私钥
# 一路回车，生成默认秘钥, 生成的默认秘钥路径在$HOME/.ssh下
➜  ssh-keygen -t rsa -P ''

# 生成私钥id_rsa和公钥id_rsa.pub
➜  ls -rtl ~/.ssh
total 8
-rw-r--r-- 1 miaocunfa miaocunfa  411 Aug 17 14:24 id_rsa.pub
-rw------- 1 miaocunfa miaocunfa 1679 Aug 17 14:24 id_rsa
```

## 3、拷贝公钥

将公钥拷贝至其他主机

``` zsh
# 此步骤其实就是将生成的id_rsa.pub 拷贝至 ng2主机下的$HOME/.ssh
# 并通过 ssh ng2 登录 ng2
➜  ssh-copy-id ng2

# 并生成 $HOME/.ssh/known_hosts
➜  cat known_hosts
ng2,172.19.64.4 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk

# 而 ng2主机下生成了$HOME/.ssh/authorized_keys文件
➜  cat authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM+G2Z9+YQ+MZm7Am+kETMUHqXUuZAwcEfXUYOwHmzJ73eyE2HNff0Ns4jZg6hRRU0GTjdbX9z+a+nxzflMPkqv2man6YE9g1sqmCz08O/7WonbvznzNGx2PjlM3RfeCuZ+Mh2WIxg86ouSTlG32YJFg1/JTBR8SDJcrxoV2/2VqH30G5w4oppA8+/d+1IRevZ+YAu1BqUboqwJOIO9hoRxOHGMG6HTQCSrPpBcZF7iu+5R/cG/Fdga71YRNIlU9O/3ioVuPSupx5yWsm3phiRawFbMtoSNafCBy4UkOHt7Y/HLe81Zszfe516O5X+S3NHV+yLH74njO7sloeSMuip miaocunfa@ng1.aihangxunxi.com

# 现在已经可以不输入密码登录 ng2了
➜  ssh ng2
```

## 4、互为免密

要想做到所有主机间互为免密，每一个主机生成一组公钥私钥，再把公钥发到每一台主机上，会非常麻烦，而且也不方便管理。

简单方法就是使用一组公钥秘钥，并根据这组公钥秘钥生成的known_hosts记录，以及authorized_keys认证文件，拷贝至每一台主机上，

这样就做到了，在每一台主机都可以免密登录其他主机的效果。

``` zsh
# 首先登录一台主机，其他记录都可以根据第一条记录生成。仅修改主机名及主机地址即可。
➜  vim known_hosts
ng1,172.19.64.3 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
ng2,172.19.64.4 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
db1,172.19.26.3 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
db2,172.19.26.6 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
db3,172.19.26.4 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
msg,172.19.26.7 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
s1,172.19.26.2 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
s2,172.19.26.9 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
s3,172.19.26.10 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
s4,172.19.26.5 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
pg1,172.19.26.11 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
pg2,172.19.26.12 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk
zax,172.19.26.8 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGO+byy5PXFqkGaD1oW7ayNrgxgOlI7iET9q4XglU6Jpn8pT7Xl/R1La5/6Q+8f0lnQAuaZJVHSBYzu3fKgO2xk

# 这个文件，所有主机保持一致即可。
➜  vim authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM+G2Z9+YQ+MZm7Am+kETMUHqXUuZAwcEfXUYOwHmzJ73eyE2HNff0Ns4jZg6hRRU0GTjdbX9z+a+nxzflMPkqv2man6YE9g1sqmCz08O/7WonbvznzNGx2PjlM3RfeCuZ+Mh2WIxg86ouSTlG32YJFg1/JTBR8SDJcrxoV2/2VqH30G5w4oppA8+/d+1IRevZ+YAu1BqUboqwJOIO9hoRxOHGMG6HTQCSrPpBcZF7iu+5R/cG/Fdga71YRNIlU9O/3ioVuPSupx5yWsm3phiRawFbMtoSNafCBy4UkOHt7Y/HLe81Zszfe516O5X+S3NHV+yLH74njO7sloeSMuip miaocunfa@ng1.aihangxunxi.com

# id_rsa.pub、id_rsa用ng1生成的即可。

# 将这四个文件拷贝至每一个主机
➜  cd $HOME/.ssh
➜  scp * db1:~/.ssh
➜  scp * db2:~/.ssh
➜  ...
```
