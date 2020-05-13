---
title: "PostgreSQL常用命令"
date: "2020-04-20"
categories:
    - "技术"
tags:
    - "postgre"
toc: false
indent: false
original: true
---

# PostgreSQL常用命令

## 元命令
```
	\d
```

```
	SELECT pu.usename, pc.tbl, pc.privilege_typ
		   FROM pg_user pu JOIN (
			    SELECT oid::regclass tbl, (aclexplode(relacl)).grantee,
					(aclexplode(relacl)).privilege_type FROM pg_class
				WHERE
				relname='emp'
		   ) pc ON pc.grantee=pu.usesysid;
```



location /app/ {
            alias /ahdata/www/apk/;
            autoindex on;
            default_type application/octet-stream;
        }


		location /apk/ {
            alias /data/app/apks/;
            autoindex on;
            default_type application/octet-stream;
        }


	location ~* .*\.(apk)$ {
		root /ahdata/www/apk;
   }