#!/bin/bash

# Describe:     third-service replace
# Create Date： 2021-08-17
# Create Time:  13:58 
# Author:       MiaoCunFa

properties="$workdir/src/main/resources/application-test.properties"
application="$workdir/src/main/resources/application.yml"

sed -i 's@^server.po.*@server.port=8811@g'                             $properties
sed -i 's@^spring.redis.database.*@spring.redis.database=13@g'         $properties
sed -i 's@^spring.redis.host.*@spring.redis.host=172.31.229.139@g'     $properties
sed -i 's@^spring.redis.port.*@spring.redis.port=60808@g'              $properties
sed -i 's@^spring.redis.password.*@spring.redis.password=123456@g'     $properties
sed -i "s@eureka.client.serviceUrl.defaultZone.*@eureka.client.serviceUrl.defaultZone=http://172.31.229.141:8089/eureka/@g" $properties
sed -i 's@active: .*@active: test@g'                                   $application
