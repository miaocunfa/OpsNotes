# ansible报错汇总

## 1、host_key_checking
``` ansible
172.31.194.114 | FAILED! => {
    "msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."
}
```

问题解决
``` bash
[root@master01 ansible]# vi /etc/ansible/ansible.cfg
host_key_checking = False
```

