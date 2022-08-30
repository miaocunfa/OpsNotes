---
title: "OpenVPN吊销证书不生效"
date: "2020-06-23"
categories:
    - "技术"
tags:
    - "OpenVPN"
toc: false
indent: false
original: true
draft: false
---

## 1、查看哪些证书被吊销

``` zsh
➜  cd /etc/openvpn/easy-rsa/3/pki
➜  openssl crl -in crl.pem -text -noout
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /CN=OpenVPN
        Last Update: Jun 23 03:09:23 2020 GMT
        Next Update: Dec 20 03:09:23 2020 GMT
        CRL extensions:
            X509v3 Authority Key Identifier:
                keyid:0B:FC:91:BF:E1:6E:F6:C7:57:73:1C:2B:75:2B:92:92:03:34:67:D5
                DirName:/CN=OpenVPN
                serial:B1:B4:E0:A6:AC:A2:46:B2

Revoked Certificates:    # 已吊销证书
    Serial Number: 44CB5112DF5B2506DAD198ACC0E34642
        Revocation Date: May 17 02:08:44 2020 GMT
    Serial Number: 54911ECB78462C7F0A05D8E727FFF9A1
        Revocation Date: May 17 02:13:38 2020 GMT
    Serial Number: A1043A93E4CEDCB501447E173CDE80B4
        Revocation Date: May 17 02:11:15 2020 GMT
    Serial Number: B263F59B7EA19DD2930D0E9B8A7FFAEA
        Revocation Date: May 17 02:13:26 2020 GMT
    Serial Number: C4DE65A0079E8B25FF13758BA1222418
        Revocation Date: Jun 23 03:08:10 2020 GMT
    Signature Algorithm: sha256WithRSAEncryption
         04:e6:e9:d5:13:f4:1d:0e:8b:87:5a:35:16:49:53:9a:7e:90:
         dc:bb:09:49:c8:69:cc:56:40:96:e9:0a:f9:c3:56:19:25:a5:
         c7:ed:16:d3:0d:a4:26:a2:56:c4:ed:e3:6c:f4:56:e8:e3:eb:
         9d:ff:a8:31:eb:3b:7a:9f:b2:af:c0:96:ce:9b:46:08:3c:2e:
         cc:5e:63:59:e4:e9:72:bb:3e:e2:cf:9e:b4:40:f9:80:e2:d0:
         41:b3:91:ab:fb:0d:1d:75:f8:7a:1c:5c:ba:dc:95:0a:bb:42:
         19:8b:d4:51:89:19:c5:4b:93:07:e5:3c:c1:1a:fd:06:7b:b7:
         d6:13:af:3b:ce:13:42:7f:1f:d9:b9:0a:5d:5c:d4:73:c8:1a:
         b0:0a:1d:00:b0:02:70:b8:6e:6d:a7:b4:79:6a:e8:5e:1f:fe:
         f2:2c:5a:da:eb:8e:f0:bf:95:86:0d:6b:85:b5:30:f7:99:bb:
         d6:74:a5:4a:7e:8c:48:20:63:9b:af:21:00:ba:55:0d:3a:59:
         14:60:d0:05:e9:25:07:fd:53:22:05:fc:b0:4b:7b:32:2a:e9:
         0a:eb:57:7d:c9:17:d5:fd:20:71:61:6b:03:28:ba:b9:0d:fe:
         d3:5b:72:1d:21:75:e7:52:8a:a6:fc:81:8c:31:ea:42:ff:0d:
         46:51:16:84
```

## 2、pki/index.txt文件

可理解为openvpn客户端的数据库  
所有生成的openvpn客户端证书记录(可用、吊销)  

文件中通过第一列标志识别是否为注销状态  
V为可用  
R为注销  

``` zsh
➜  cat index.txt
V    221209013920Z        4046594A6432AD1597EE47EB6E00DD8F    unknown    /CN=server
V    221209023107Z        A82D845FF707408BB05049D4BF9CAF41    unknown    /CN=wangshuxian
V    221209052534Z        4661B64B6B934B2C6EE94C55FF5CDF47    unknown    /CN=server
V    221209070724Z        601EDFDA6E1FE245D92CC0C881416FE1    unknown    /CN=test
V    221209070729Z        55CE3FD4A111C086840FDC6776EBCBC9    unknown    /CN=test2
V    221209070733Z        7924CC116FAE0D7BC90C93E51D102E3E    unknown    /CN=test3
V    221209092037Z        2922DD807C81B72B48BFD400E253958B    unknown    /CN=chenqingze
V    221210013225Z        EE173E515FA302F75067F2BFC070FD25    unknown    /CN=wangchaochao
R    221210075931Z    200517021326Z    B263F59B7EA19DD2930D0E9B8A7FFAEA    unknown    /CN=zhangyan
V    221210081023Z        401455EFD27C8187923032FA09D78DB0    unknown    /CN=chujiao
R    221210092059Z    200517021115Z    A1043A93E4CEDCB501447E173CDE80B4    unknown    /CN=liuzhangbin
V    221210145608Z        E2BFFD9921752954394D799AF91426E5    unknown    /CN=wanghongchao
R    230103065628Z    200517021338Z    54911ECB78462C7F0A05D8E727FFF9A1    unknown    /CN=liuzhangbin2
R    230222082718Z    200517020844Z    44CB5112DF5B2506DAD198ACC0E34642    unknown    /CN=zhangliling
V    230608031249Z        732FF079AA63D180070E91326F9550E2    unknown    /CN=miaocunfa
```

## 3、crl.pem说明

该文件为吊销证书的名单，配合 `pki/index.txt` 识别客户端是否可用。  
若未在 `server.conf` 中配置该文件，即使吊销客户端证书后客户端仍可以正常连接。  

``` zsh
➜  vim /etc/openvpn/server.conf
crl-verify /etc/openvpn/easy-rsa/3/pki/crl.pem
```

## 4、吊销过程

``` zsh
# 1、使用./easyrsa注销证书
# 此时只是更新index.txt标识为R(注销)，但经实践后发现标识为R的客户端，仍可以正常连接服务端。
➜  ./easyrsa revoke $USER

# 2、更新crl.pem文件
# 并将该文件配置在server.conf中
➜  ./easyrsa gen-crl

# 3、重启openvpn server
➜  systemctl restart openvpn@server
```

## 5、几个常见问题

### 5.1、吊销证书仍可连接

使用`./easyrsa revoke $USER` 吊销客户端证书后，客户端仍可以连上服务端

解决方法

``` zsh
➜  vim /etc/openvpn/server.conf
crl-verify /etc/openvpn/easy-rsa/3/pki/crl.pem
➜  ./easyrsa gen-crl
```

### 5.2、无法读取crl.pem

服务端日志报错，无法读取crl.pem内容

解决方法：

``` zsh
➜  chmod 600 /etc/openvpn/easy-rsa/3/pki/crl.pem
```

> 参考文章:  
> 1、<http://www.wallcopper.com/linux/3197.html>
>