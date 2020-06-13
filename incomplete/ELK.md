下载rpm包
```bash
wget -b https://artifacts.elastic.co/downloads/logstash/logstash-7.3.2.tar.gz

wget -b https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.3.2-linux-x86_64.tar.gz

wget -b https://artifacts.elastic.co/downloads/kibana/kibana-7.3.2-linux-x86_64.tar.gz

wget -b https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.3.2-linux-x86_64.tar.gz
```

准备工作
```
useradd elk
cp ~/elk/*.rpm /home/elk
chown elk:elk /home/elk/*.rpm
echo "elk2019" | passwd --stdin elk
```

修改环境变量
```
vi .bash_profile
export JAVA_HOME=/home/elk/elasticsearch-7.3.2/jdk
export PATH=$PATH:$JAVA_HOME/bin:/home/elk/elasticsearch-7.3.2/bin:/home/elk/logstash-7.3.2/bin:/home/elk/kibana-7.3.2-linux-x86_64/bin:/home/elk/filebeat-7.3.2-linux-x86_64
```

elasticsearch配置文件
```bash
vi /home/elk/elasticsearch-7.3.2/config/elasticsearch.yml
cluster.name: es-log
node.name: ${HOSTNAME}
path.data: /home/elk/elasticsearch-7.3.2/data
path.logs: /home/elk/elasticsearch-7.3.2/logs
network.host: ["_local_", "_site_"]
http.port: 9200
```

kibana配置文件
```bash
[elk@jiexian ~/kibana-7.3.2-linux-x86_64/config]$cat kibana.yml
server.port: 5601
server.host: "localhost"
elasticsearch.hosts: ["http://localhost:9200"]
pid.file: /home/elk/kibana-7.3.2-linux-x86_64/logs/kibana.pid
logging.dest: /home/elk/kibana-7.3.2-linux-x86_64/logs
```

filebeat配置文件
```
[elk@jiexian ~/filebeat-7.3.2-linux-x86_64]$cat filebeat.yml
filebeat.inputs:

- type: log
  enabled: true 
  paths:
    - /usr/local/nginx-1.12.1/logs/access.log 
  fields:
    topic: nginx_log

- type: log
  enabled: false 
  paths:
    - /usr/local/nginx-1.12.1/logs/access.log 
  fields:
    topic: tomcat_log

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

#setup.kibana:

output.elasticsearch:
  hosts: ["localhost:9200"]

#output.console:
#  pretty: true

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
[elk@jiexian ~/filebeat-7.3.2-linux-x86_64]$
```



