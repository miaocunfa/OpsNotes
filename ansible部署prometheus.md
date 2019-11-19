[root@master ~]# ansible all -m copy -a "src=/root/node_exporter-0.18.1.linux-amd64.tar.gz dest=/opt/"
192.168.100.225 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042903.16-250328596364126/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.223 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042903.13-265038975854959/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.221 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042903.11-158874524404719/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.222 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042903.11-85772601202289/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.224 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042903.15-13136838757231/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.229 | SUCCESS => {
    "changed": false, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "owner": "root", 
    "path": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "size": 8083296, 
    "state": "file", 
    "uid": 0
}
192.168.100.226 | SUCCESS => {
    "changed": true, 
    "checksum": "930ff2d3e931981b660df6a6f2d0c5d4b50eef7f", 
    "dest": "/opt/node_exporter-0.18.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "19f9d39cdad2448177ee02fbdd5e5ef4", 
    "mode": "0644", 
    "owner": "root", 
    "size": 8083296, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574042904.54-223071415034421/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~]#

[root@master ~]# ansible all -m shell -a "cd /opt; tar -zxvf node_exporter-0.18.1.linux-amd64.tar.gz; cd node_exporter-0.18.1.linux-amd64; nohup ./node_exporter &"
192.168.100.221 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:09+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:09+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:09+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:09+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"
time="2019-11-18T10:12:09+08:00" level=fatal msg="listen tcp :9100: bind: address already in use" source="node_exporter.go:172"

192.168.100.225 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:09+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:09+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:09+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:09+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"

192.168.100.223 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:09+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:09+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:09+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:09+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"

192.168.100.222 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:09+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:09+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:09+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:09+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:09+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"

192.168.100.226 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:10+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:10+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:10+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:10+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:10+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"

192.168.100.224 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-17T21:12:10-05:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-17T21:12:10-05:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-17T21:12:10-05:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-17T21:12:10-05:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-17T21:12:10-05:00" level=info msg="Listening on :9100" source="node_exporter.go:170"

192.168.100.229 | SUCCESS | rc=0 >>
node_exporter-0.18.1.linux-amd64/
node_exporter-0.18.1.linux-amd64/node_exporter
node_exporter-0.18.1.linux-amd64/NOTICE
node_exporter-0.18.1.linux-amd64/LICENSEtime="2019-11-18T10:12:11+08:00" level=info msg="Starting node_exporter (version=0.18.1, branch=HEAD, revision=3db77732e925c08f675d7404a8c46466b2ece83e)" source="node_exporter.go:156"
time="2019-11-18T10:12:11+08:00" level=info msg="Build context (go=go1.12.5, user=root@b50852a1acba, date=20190604-16:41:18)" source="node_exporter.go:157"
time="2019-11-18T10:12:11+08:00" level=info msg="Enabled collectors:" source="node_exporter.go:97"
time="2019-11-18T10:12:11+08:00" level=info msg=" - arp" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - bcache" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - bonding" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - conntrack" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - cpu" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - cpufreq" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - diskstats" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - edac" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - entropy" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - filefd" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - filesystem" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - hwmon" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - infiniband" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - ipvs" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - loadavg" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - mdadm" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - meminfo" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - netclass" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - netdev" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - netstat" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - nfs" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - nfsd" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - pressure" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - sockstat" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - stat" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - textfile" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - time" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - timex" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - uname" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - vmstat" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - xfs" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg=" - zfs" source="node_exporter.go:104"
time="2019-11-18T10:12:11+08:00" level=info msg="Listening on :9100" source="node_exporter.go:170"
time="2019-11-18T10:12:11+08:00" level=fatal msg="listen tcp :9100: bind: address already in use" source="node_exporter.go:172"

[root@master ~]#

[root@master ~]# ansible all -m shell -a "netstat -an|grep 9100"
192.168.100.225 | SUCCESS | rc=0 >>
tcp6       0      0 :::9100                 :::*                    LISTEN     

192.168.100.222 | SUCCESS | rc=0 >>
tcp6       0      0 :::9100                 :::*                    LISTEN     

192.168.100.223 | SUCCESS | rc=0 >>
tcp6       0      0 :::9100                 :::*                    LISTEN     

192.168.100.221 | SUCCESS | rc=0 >>
tcp        0      0 127.0.0.1:9100          0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:9100          127.0.0.1:37400         ESTABLISHED
tcp        0      0 127.0.0.1:37400         127.0.0.1:9100          ESTABLISHED

192.168.100.229 | SUCCESS | rc=0 >>
tcp        0      0 127.0.0.1:9100          0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:9100          127.0.0.1:37400         ESTABLISHED
tcp        0      0 127.0.0.1:37400         127.0.0.1:9100          ESTABLISHED

192.168.100.226 | SUCCESS | rc=0 >>
tcp6       0      0 :::9100                 :::*                    LISTEN     
tcp6       0      0 192.168.100.226:59100   192.168.100.212:3306    ESTABLISHED

192.168.100.224 | SUCCESS | rc=0 >>
tcp6       0      0 :::9100                 :::*                    LISTEN     

[root@master ~]#


[root@master ~]# ansible redis -m copy -a "src=/root/redis_exporter-v1.3.4.linux-amd64.tar.gz dest=/opt"
192.168.100.212 | SUCCESS => {
    "changed": true, 
    "checksum": "17a53b4e98d87452e97956cb3f109ae3c95e7ebc", 
    "dest": "/opt/redis_exporter-v1.3.4.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "2d101cbc0e1e910864c12b03b5d4c66c", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 3376474, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574063816.42-198769967179829/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.211 | SUCCESS => {
    "changed": true, 
    "checksum": "17a53b4e98d87452e97956cb3f109ae3c95e7ebc", 
    "dest": "/opt/redis_exporter-v1.3.4.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "2d101cbc0e1e910864c12b03b5d4c66c", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 3376474, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574063816.41-13682335283525/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~]# 
[root@master ~]# 
[root@master ~]# ansible redis -m shell -a "cd /opt; tar -zxvf redis_exporter-v1.3.4.linux-amd64.tar.gz; cd redis_exporter-v1.3.4.linux-amd64; nohup ./redis_exporter &"
192.168.100.212 | SUCCESS | rc=0 >>
redis_exporter-v1.3.4.linux-amd64/
redis_exporter-v1.3.4.linux-amd64/redis_exporter
redis_exporter-v1.3.4.linux-amd64/README.md
redis_exporter-v1.3.4.linux-amd64/LICENSEtime="2019-11-18T15:58:09+08:00" level=info msg="Redis Metrics Exporter v1.3.4    build date: 2019-11-15-19:34:34    sha1: e15c7d22b9151c3681c60b5df5cd552584bef10d    Go: go1.13.4    GOOS: linux    GOARCH: amd64"
time="2019-11-18T15:58:09+08:00" level=info msg="Providing metrics at :9121/metrics"

192.168.100.211 | SUCCESS | rc=0 >>
redis_exporter-v1.3.4.linux-amd64/
redis_exporter-v1.3.4.linux-amd64/redis_exporter
redis_exporter-v1.3.4.linux-amd64/README.md
redis_exporter-v1.3.4.linux-amd64/LICENSEtime="2019-11-18T15:58:09+08:00" level=info msg="Redis Metrics Exporter v1.3.4    build date: 2019-11-15-19:34:34    sha1: e15c7d22b9151c3681c60b5df5cd552584bef10d    Go: go1.13.4    GOOS: linux    GOARCH: amd64"
time="2019-11-18T15:58:09+08:00" level=info msg="Providing metrics at :9121/metrics"

[root@master ~]#


[root@master ~]# ansible mysql -m copy -a "src=/root/mysqld_exporter-0.12.1.linux-amd64.tar.gz dest=/opt"
192.168.100.213 | SUCCESS => {
    "changed": true, 
    "checksum": "a42bb9e8568eb8f02dd41bebd230be4c57da3e73", 
    "dest": "/opt/mysqld_exporter-0.12.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "2faf715337138db991d5747e86ad09c4", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 7121565, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574068354.45-206561821873176/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.212 | SUCCESS => {
    "changed": true, 
    "checksum": "a42bb9e8568eb8f02dd41bebd230be4c57da3e73", 
    "dest": "/opt/mysqld_exporter-0.12.1.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "2faf715337138db991d5747e86ad09c4", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 7121565, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574068354.44-39798213344247/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~]# 
[root@master ~]# ll -lh
total 67M
-rw-------.  1 root root 1.4K May 31 09:17 anaconda-ks.cfg
-rw-r--r--.  1 root root 1.3K Sep 11 13:24 dashboard-controller.yaml
-rw-r--r--.  1 root root 1.1K Sep 16 14:29 dashboard-dev.yaml
-rw-r--r--.  1 root root 1.3K Sep 11 16:00 dashboard-rc.yaml
-rw-r--r--.  1 root root  388 Sep 10 16:50 dashboard-service.yaml
-rw-r--r--.  1 root root  406 Sep 11 13:18 dashboard-sv.yaml
drwxr-xr-x. 10 root root 4.0K Nov 12 10:05 iKubernetes
-rwxr-xr-x.  1 root root  330 Sep  9 14:51 image.sh
drwxr-xr-x.  9 root root 4.0K Sep 27 17:56 k8s-log
-rw-r--r--.  1 root root  13K Sep 19 09:11 kube-flannel.yml
-rwxr-xr-x.  1 root root  35M Nov  2 22:35 kube-prompt
-rw-r--r--.  1 root root  15M Nov  2 22:38 kube-prompt_v1.0.9_linux_amd64.zip
-rw-r--r--.  1 root root 3.5K Sep 16 18:05 kubernetes-dashboard-1.yaml
-rw-r--r--.  1 root root 5.8K Sep 17 11:34 kubernetes-dashboard.yaml
-rw-r--r--.  1 root root 6.8M Nov 18 17:11 mysqld_exporter-0.12.1.linux-amd64.tar.gz
-rw-r--r--.  1 root root  921 Sep 11 11:36 mysql-rc.yaml
-rw-r--r--.  1 root root  203 Sep 19 14:49 mysql-sv.yaml
-rw-r--r--.  1 root root  997 Sep 19 15:56 mytom-rc.yaml
-rw-r--r--.  1 root root  152 Sep 19 15:58 mytom-sv.yaml
-rw-r--r--.  1 root root 7.8M Nov 18 10:03 node_exporter-0.18.1.linux-amd64.tar.gz
-rw-r--r--.  1 root root  975 Nov 13 17:48 node-exporter.yaml
-rw-r--r--.  1 root root    0 Sep 11 15:25 openssl
-rw-r--r--.  1 root root 7.5K Sep 17 17:08 recommended.yaml
-rw-r--r--.  1 root root 7.0K Sep 17 15:15 recommended.yaml.bak
-rw-r--r--.  1 root root 6.6K Sep 17 15:19 recommended.yaml.now
-rw-r--r--.  1 root root 3.3M Nov 18 15:56 redis_exporter-v1.3.4.linux-amd64.tar.gz
[root@master ~]# ansible mysql -m shell -a "cd /opt; tar -zxvf mysqld_exporter-0.12.1.linux-amd64.tar.gz; cd mysqld_exporter-0.12.1.linux-amd64; nohup ./mysqld_exporter &"
192.168.100.212 | SUCCESS | rc=0 >>
mysqld_exporter-0.12.1.linux-amd64/
mysqld_exporter-0.12.1.linux-amd64/NOTICE
mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter
mysqld_exporter-0.12.1.linux-amd64/LICENSEtime="2019-11-18T17:17:06+08:00" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2019-11-18T17:17:06+08:00" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2019-11-18T17:17:06+08:00" level=fatal msg="failed reading ini file: open /root/.my.cnf: no such file or directory" source="mysqld_exporter.go:264"

192.168.100.213 | SUCCESS | rc=0 >>
mysqld_exporter-0.12.1.linux-amd64/
mysqld_exporter-0.12.1.linux-amd64/NOTICE
mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter
mysqld_exporter-0.12.1.linux-amd64/LICENSEtime="2019-11-18T17:17:09+08:00" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2019-11-18T17:17:09+08:00" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2019-11-18T17:17:09+08:00" level=fatal msg="failed reading ini file: open /root/.my.cnf: no such file or directory" source="mysqld_exporter.go:264"

[root@master ~]#

[root@DB2 ~]# cd /etc/my.cnf.d
[root@DB2 my.cnf.d]# cat server.cnf > /root/.my.cnf
[root@DB2 my.cnf.d]# pwd
/etc/my.cnf.d
[root@DB2 my.cnf.d]#

[root@DB2 ~]# cd /etc/my.cnf.d
[root@DB3 my.cnf.d]# cat server.cnf > /root/.my.cnf
[root@DB3 my.cnf.d]# pwd
/etc/my.cnf.d

[root@master ~]# ansible mysql -m shell -a "cd /opt; tar -zxvf mysqld_exporter-0.12.1.linux-amd64.tar.gz; cd mysqld_exporter-0.12.1.linux-amd64; nohup ./mysqld_exporter &"
192.168.100.212 | SUCCESS | rc=0 >>
mysqld_exporter-0.12.1.linux-amd64/
mysqld_exporter-0.12.1.linux-amd64/NOTICE
mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter
mysqld_exporter-0.12.1.linux-amd64/LICENSEtime="2019-11-18T17:31:16+08:00" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2019-11-18T17:31:16+08:00" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2019-11-18T17:31:16+08:00" level=info msg="Enabled scrapers:" source="mysqld_exporter.go:269"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.global_status" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.global_variables" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.slave_status" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.innodb_cmp" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.innodb_cmpmem" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.query_response_time" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg="Listening on :9104" source="mysqld_exporter.go:283"

192.168.100.213 | SUCCESS | rc=0 >>
mysqld_exporter-0.12.1.linux-amd64/
mysqld_exporter-0.12.1.linux-amd64/NOTICE
mysqld_exporter-0.12.1.linux-amd64/mysqld_exporter
mysqld_exporter-0.12.1.linux-amd64/LICENSEtime="2019-11-18T17:31:16+08:00" level=info msg="Starting mysqld_exporter (version=0.12.1, branch=HEAD, revision=48667bf7c3b438b5e93b259f3d17b70a7c9aff96)" source="mysqld_exporter.go:257"
time="2019-11-18T17:31:16+08:00" level=info msg="Build context (go=go1.12.7, user=root@0b3e56a7bc0a, date=20190729-12:35:58)" source="mysqld_exporter.go:258"
time="2019-11-18T17:31:16+08:00" level=info msg="Enabled scrapers:" source="mysqld_exporter.go:269"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.global_status" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.global_variables" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.slave_status" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.innodb_cmp" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.innodb_cmpmem" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg=" --collect.info_schema.query_response_time" source="mysqld_exporter.go:273"
time="2019-11-18T17:31:16+08:00" level=info msg="Listening on :9104" source="mysqld_exporter.go:283"

[root@master ~]# 


[root@ansible prometheus-2.13.1.linux-amd64]# ps -ef|grep prom
root      1181 11541  8 14:53 pts/2    00:01:46 ./prometheus
root     26748 19953  0 15:14 pts/0    00:00:00 grep --color=auto prom
[root@ansible prometheus-2.13.1.linux-amd64]# kill -9 1181
[root@ansible prometheus-2.13.1.linux-amd64]# nohup ./prometheus --storage.tsdb.retention=180d --web.enable-admin-api &
[1] 27359
[root@ansible prometheus-2.13.1.linux-amd64]# nohup: ignoring input and appending output to ‘nohup.out’

[root@ansible prometheus-2.13.1.linux-amd64]# 

[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.211:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.212:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.213:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.214:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.215:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.216:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.217:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.218:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.221:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.222:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.223:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.224:9100"}'

[root@ansible prometheus-2.13.1.linux-amd64]# 
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.225:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="192.168.100.226:9100"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node-21"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node-22"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node-23"}'
[root@ansible prometheus-2.13.1.linux-amd64]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={job="node1"}'


[es]
192.168.100.211 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.212 ansible_ssh_user='root' ansible_ssh_pass='test123'
192.168.100.213 ansible_ssh_user='root' ansible_ssh_pass='test123'

[root@master ~]# ansible es -m copy -a "src=/root/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz dest=/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz"
192.168.100.213 | SUCCESS => {
    "changed": true, 
    "checksum": "0eb0fdce41a37ff743c8ae8487fde507c824f247", 
    "dest": "/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "6afa88587ed483d1622cbf2d2b8e12e1", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 3632462, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574150457.83-268994438501575/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.211 | SUCCESS => {
    "changed": true, 
    "checksum": "0eb0fdce41a37ff743c8ae8487fde507c824f247", 
    "dest": "/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "6afa88587ed483d1622cbf2d2b8e12e1", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 3632462, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574150457.81-76690472830602/source", 
    "state": "file", 
    "uid": 0
}
192.168.100.212 | SUCCESS => {
    "changed": true, 
    "checksum": "0eb0fdce41a37ff743c8ae8487fde507c824f247", 
    "dest": "/opt/elasticsearch_exporter-1.1.0.linux-amd64.tar.gz", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "6afa88587ed483d1622cbf2d2b8e12e1", 
    "mode": "0644", 
    "owner": "root", 
    "secontext": "system_u:object_r:usr_t:s0", 
    "size": 3632462, 
    "src": "/root/.ansible/tmp/ansible-tmp-1574150457.82-142426720627491/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~]# 
[root@master ~]# 
[root@master ~]# tar -tvf elasticsearch_exporter-1.1.0.linux-amd64.tar.gz 
drwxr-xr-x chris/chris       0 2019-08-07 20:53 elasticsearch_exporter-1.1.0.linux-amd64/
-rw-rw-r-- chris/chris   49620 2019-02-26 17:16 elasticsearch_exporter-1.1.0.linux-amd64/dashboard.json
-rw-rw-r-- chris/chris   22319 2019-08-07 20:45 elasticsearch_exporter-1.1.0.linux-amd64/README.md
-rw-r--r-- chris/chris   11357 2017-12-11 21:17 elasticsearch_exporter-1.1.0.linux-amd64/LICENSE
-rw-rw-r-- chris/chris    1636 2019-06-03 23:42 elasticsearch_exporter-1.1.0.linux-amd64/deployment.yml
-rwxr-xr-x chris/chris 9524672 2019-08-07 20:49 elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch_exporter
-rw-r--r-- chris/chris     979 2018-08-13 22:38 elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch.rules
-rw-r--r-- chris/chris    4073 2019-08-07 20:43 elasticsearch_exporter-1.1.0.linux-amd64/CHANGELOG.md
[root@master ~]# 

[root@master ~]# ansible es -m shell -a "cd /opt; tar -zxvf elasticsearch_exporter-1.1.0.linux-amd64.tar.gz; cd elasticsearch_exporter-1.1.0.linux-amd64; nohup ./elasticsearch_exporter &"
192.168.100.213 | SUCCESS | rc=0 >>
elasticsearch_exporter-1.1.0.linux-amd64/
elasticsearch_exporter-1.1.0.linux-amd64/dashboard.json
elasticsearch_exporter-1.1.0.linux-amd64/README.md
elasticsearch_exporter-1.1.0.linux-amd64/LICENSE
elasticsearch_exporter-1.1.0.linux-amd64/deployment.yml
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch_exporter
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch.rules
elasticsearch_exporter-1.1.0.linux-amd64/CHANGELOG.md
level=info ts=2019-11-19T08:05:42.231840203Z caller=clusterinfo.go:200 msg="triggering initial cluster info call"
level=info ts=2019-11-19T08:05:42.232024914Z caller=clusterinfo.go:169 msg="providing consumers with updated cluster info label"
level=info ts=2019-11-19T08:05:42.24220619Z caller=main.go:148 msg="started cluster info retriever" interval=5m0s
level=info ts=2019-11-19T08:05:42.242365892Z caller=main.go:188 msg="starting elasticsearch_exporter" addr=:9114

192.168.100.211 | SUCCESS | rc=0 >>
elasticsearch_exporter-1.1.0.linux-amd64/
elasticsearch_exporter-1.1.0.linux-amd64/dashboard.json
elasticsearch_exporter-1.1.0.linux-amd64/README.md
elasticsearch_exporter-1.1.0.linux-amd64/LICENSE
elasticsearch_exporter-1.1.0.linux-amd64/deployment.yml
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch_exporter
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch.rules
elasticsearch_exporter-1.1.0.linux-amd64/CHANGELOG.md
level=info ts=2019-11-19T08:05:42.231332829Z caller=clusterinfo.go:200 msg="triggering initial cluster info call"
level=info ts=2019-11-19T08:05:42.231497405Z caller=clusterinfo.go:169 msg="providing consumers with updated cluster info label"
level=info ts=2019-11-19T08:05:42.238625962Z caller=main.go:148 msg="started cluster info retriever" interval=5m0s
level=info ts=2019-11-19T08:05:42.238772028Z caller=main.go:188 msg="starting elasticsearch_exporter" addr=:9114

192.168.100.212 | SUCCESS | rc=0 >>
elasticsearch_exporter-1.1.0.linux-amd64/
elasticsearch_exporter-1.1.0.linux-amd64/dashboard.json
elasticsearch_exporter-1.1.0.linux-amd64/README.md
elasticsearch_exporter-1.1.0.linux-amd64/LICENSE
elasticsearch_exporter-1.1.0.linux-amd64/deployment.yml
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch_exporter
elasticsearch_exporter-1.1.0.linux-amd64/elasticsearch.rules
elasticsearch_exporter-1.1.0.linux-amd64/CHANGELOG.md
level=info ts=2019-11-19T08:05:42.346858866Z caller=clusterinfo.go:200 msg="triggering initial cluster info call"
level=info ts=2019-11-19T08:05:42.347049111Z caller=clusterinfo.go:169 msg="providing consumers with updated cluster info label"
level=info ts=2019-11-19T08:05:42.375887258Z caller=main.go:148 msg="started cluster info retriever" interval=5m0s
level=info ts=2019-11-19T08:05:42.376833804Z caller=main.go:188 msg="starting elasticsearch_exporter" addr=:9114

[root@master ~]# ansible es -m shell -a "netstat -an|grep 9114"
192.168.100.213 | SUCCESS | rc=0 >>
tcp6       0      0 :::9114                 :::*                    LISTEN     

192.168.100.211 | SUCCESS | rc=0 >>
tcp6       0      0 :::9114                 :::*                    LISTEN     

192.168.100.212 | SUCCESS | rc=0 >>
tcp6       0      0 :::9114                 :::*                    LISTEN     

[root@master ~]#
