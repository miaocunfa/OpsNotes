#!/bin/bash

# Describe:     Compile && image build or push
# Create Date： 2021-08-12
# Create Time:  09:19
# Update Date:  2021-08-13
# Update Time:  18:11
# Author:       MiaoCunFa
# Version:      v0.0.1

#===================================================================

tag="test"
service="third-service"
port=""

workspace="/var/lib/jenkins/workspace"
JOB_dir="$workspace/$JOB_NAME"

properties="$JOB_dir/$service/src/main/resources/application-test.properties"
application="$JOB_dir/$service/src/main/resources/application.yml"

harbor="harbor.$tag.local"
target="/script/$tag/$service/target"

#===================================================================

cd $JOB_dir
        
sed -i 's@^server.po.*@server.port=8811@g'                             $properties
sed -i 's@^spring.redis.database.*@spring.redis.database=13@g'         $properties
sed -i 's@^spring.redis.host.*@spring.redis.host=172.31.229.139@g'     $properties
sed -i 's@^spring.redis.port.*@spring.redis.port=60808@g'              $properties
sed -i 's@^spring.redis.password.*@spring.redis.password=123456@g'     $properties
sed -i "s@eureka.client.serviceUrl.defaultZone.*@eureka.client.serviceUrl.defaultZone=http://172.31.229.141:8089/eureka/@g" $properties
sed -i 's@active: .*@active: test@g'                                   $application

/usr/local/maven/bin/mvn clean -U package  -am -Ptest -DskipTests

if [ $? -ne 0 ]; 
then
    echo -e  "Compile $JOB_NAME Error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi

#===================================================================

cp $JOB_dir/$service/target/*.jar $target
docker build -t $harbor/$service:$BUILD_TAG .

if [ $? -ne 0 ];
then
    echo -e  "docker build error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi

#===================================================================

docker push $harbor/$service:$BUILD_TAG

if [ $? -eq 0];
then
    ssh root@docker02 "/bin/bash /script/test/docker-run.sh $harbor $service $BUILD_TAG $port"
else
    echo -e  "docker push error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi
