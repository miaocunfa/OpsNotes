---
title: "Gitlab部署、恢复及升级"
date: "2020-06-01"
categories:
    - "技术"
tags:
    - "Gitlab"
    - "数据备份"
    - "灾备演练"
toc: false
indent: false
original: true
draft: false
---

## 一、环境

``` zsh
 GitLab:       11.11.3 (e3eeb779d72)
 GitLab Shell: 9.1.0
 PostgreSQL:   9.6.11
```

## 二、部署

``` zsh
# 获取rpm包，并安装
➜  wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-11.11.3-ce.0.el7.x86_64.rpm
➜  yum install gitlab-ce-11.11.3-ce.0.el7.x86_64.rpm

# 默认部署到 /opt/gitlab 下
➜  rpm -ql gitlab-ce | head -n 100
/opt
/opt/gitlab
/opt/gitlab/LICENSE
/opt/gitlab/LICENSES
/opt/gitlab/LICENSES/alertmanager-LICENSE
/opt/gitlab/LICENSES/awesome_print-LICENSE
```

### 2.2、启动

``` zsh
➜  cd /opt/gitlab/bin

➜  gitlab-ctl reconfigure

➜  gitlab-ctl start
➜  gitlab-ctl status
run: alertmanager: (pid 39212) 130s; run: log: (pid 38709) 155s
run: gitaly: (pid 38988) 134s; run: log: (pid 34872) 496s
run: gitlab-monitor: (pid 39064) 133s; run: log: (pid 38443) 173s
run: gitlab-workhorse: (pid 39023) 134s; run: log: (pid 37948) 202s
run: logrotate: (pid 38053) 193s; run: log: (pid 38089) 192s
run: nginx: (pid 37979) 199s; run: log: (pid 38025) 196s
run: node-exporter: (pid 39052) 133s; run: log: (pid 38317) 179s
run: postgres-exporter: (pid 39231) 130s; run: log: (pid 38811) 148s
run: postgresql: (pid 35267) 471s; run: log: (pid 35366) 468s
run: prometheus: (pid 39178) 132s; run: log: (pid 38615) 161s
run: redis: (pid 34753) 503s; run: log: (pid 34765) 502s
run: redis-exporter: (pid 39086) 133s; run: log: (pid 38531) 167s
run: sidekiq: (pid 37803) 207s; run: log: (pid 37881) 206s
run: unicorn: (pid 37724) 213s; run: log: (pid 37787) 210s
```

## 三、恢复

### 3.1、停止服务

恢复前需要先停掉数据连接服务  
如果是台空主机，没有任何操作，理论上不停这两个服务也可以。停这两个服务是为了保证数据一致性。

``` zsh
➜  gitlab-ctl stop unicorn
➜  gitlab-ctl stop sidekiq
```

### 3.2、准备备份

备份是通过备份脚本上传至备份服务器的

``` zsh
➜  cd /root/gitlab/backup
➜  ll
total 22607256
-rw------- 1 root root 3173406720 May 29 01:09 gitlab-221-backup-Fri.tar
-rw------- 1 root root 3173969920 Jun  1 01:11 gitlab-221-backup-Mon.tar
-rw------- 1 root root 3173969920 May 30 01:07 gitlab-221-backup-Sat.tar
-rw------- 1 root root 3173969920 May 31 01:09 gitlab-221-backup-Sun.tar
-rw------- 1 root root 3171891200 May 28 01:21 gitlab-221-backup-Thu.tar
-rw------- 1 root root 3168020480 May 26 01:21 gitlab-221-backup-Tue.tar
-rw------- 1 root root 3169587200 May 27 01:18 gitlab-221-backup-Wed.tar
-rw------- 1 root root  136847360 May 29 01:01 gitlab-229-backup-Fri.tar
-rw------- 1 root root  136878080 Jun  1 01:03 gitlab-229-backup-Mon.tar
-rw------- 1 root root  136878080 May 30 01:02 gitlab-229-backup-Sat.tar
-rw------- 1 root root  136878080 May 31 01:04 gitlab-229-backup-Sun.tar
-rw------- 1 root root  134625280 May 28 01:09 gitlab-229-backup-Thu.tar
-rw------- 1 root root  130611200 May 26 01:06 gitlab-229-backup-Tue.tar
-rw------- 1 root root  132280320 May 27 01:05 gitlab-229-backup-Wed.tar

➜  tar -xvf gitlab-229-backup-Mon.tar
1590980582_2020_06_01_11.11.3_gitlab_backup.tar

# 600权限是无权恢复的
➜  chmod 777 1590980582_2020_06_01_11.11.3_gitlab_backup.tar

➜  cp 1590980582_2020_06_01_11.11.3_gitlab_backup.tar /var/opt/gitlab/backups
```

### 恢复备份

``` zsh
➜  cd /opt/gitlab/bin

# BACKUP只需要指定_gitlab_backup.tar前面部分即可
➜  gitlab-rake gitlab:backup:restore BACKUP=1590980582_2020_06_01_11.11.3
```

### 启动服务

恢复完成后，启动刚刚的两个服务，或者重启所有服务

``` zsh
➜  gitlab-ctl start unicorn
➜  gitlab-ctl start sidekiq
或
➜  gitlab-ctl restart
```

## 四、错误

### 4.1、备份文件名

``` zsh
➜  gitlab-rake gitlab:backup:restore BACKUP=/root/gitlab/backup/gitlab-229-backup-Mon.tar
No backups found in /var/opt/gitlab/backups
Please make sure that file name ends with _gitlab_backup.tar
```

#### 错误解决

gitlab进行备份恢复包是在/var/opt/gitlab/backups目录下以_gitlab_backup.tar为后缀名命名的文件

``` zsh
# 进入备份目录
➜  cd /root/gitlab/backup/

# 将备份文件命名为{filename}_gitlab_backup.tar
➜  mv gitlab-229-backup-Mon.tar gitlab-229-Mon_gitlab_backup.tar

# 修改权限
➜  chmod 777 gitlab-229-Mon_gitlab_backup.tar

# cp至备份目录
➜  cp gitlab-229-Mon_gitlab_backup.tar /var/opt/gitlab/backups

# 恢复备份
➜  gitlab-rake gitlab:backup:restore BACKUP=gitlab-229-Mon
```
