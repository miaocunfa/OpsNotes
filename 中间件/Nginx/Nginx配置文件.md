---
title: "Nginx配置文件"
date: "2019-12-03"
categories:
    - "技术"
tags:
    - "Nginx"
    - "配置文件"
toc: false
indent: false
original: true
draft: false
---

## nginx.conf

``` conf
worker_processes  4;
error_log  logs/error.log  warn;
pid        logs/nginx.pid;
events {
    worker_connections  4096;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  logs/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    client_max_body_size 8m;
    client_header_buffer_size 3m;
    gzip  on;
    include /usr/local/nginx/conf/conf.d/*.conf;
}
```

## ssl配置文件

```
    server {
        listen 443 ssl;
        server_name dev.aihangcloud.cn;
        ssl_certificate_key cert/dev.aihangcloud.cn.key;
        ssl_certificate cert/dev.aihangcloud.cn.pem;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        location / {
             proxy_pass http://localhost:9999;
        }
    }
```

## php配置文件

``` conf
    server {
        listen       80;
        server_name  zbx.yigaosu.com;
        access_log  /usr/local/nginx/logs/host.access.log;

        location / {
            root   html;
            index  index.php;
        }

            location ~ \.php(.*)$ {
            fastcgi_pass 127.0.0.1:9000; 
            fastcgi_index index.php;
            fastcgi_split_path_info ^((?U).+\.php)(/?.+)$;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
            include fastcgi_params;
        }

        # error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    } 
```  

## java 配置文件

``` conf
server {
        listen       80;
        server_name  www.ysyfhsp.com;
        root /home/ysyf/apache-tomcat-7.0.21/webapps/ysyf;
        index index.jsp;

        location ~ \.(jsp|do)$ {
            proxy_pass http://127.0.0.1:1080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout       100;
            proxy_read_timeout          100;
            proxy_send_timeout          100;
        }

        location ~ .*\.(js|css|png|jpg|gif)$ {
          root /home/ysyf/apache-tomcat-7.0.21/webapps/ysyf;
          if (-f $request_filename) {
           expires 1d;
           break;
           }
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        location ~ /nginx_status {
          stub_status on;
          access_log  off;
          allow 127.0.0.1;
          allow 172.16.100.187;
          allow 118.31.70.170;
          allow 123.112.194.205;
          deny all;
        }

    }
```
