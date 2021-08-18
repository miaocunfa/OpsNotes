#!/bin/bash

# Describe:     Compile && image build or push
# Create Date： 2021-08-12
# Create Time:  09:19
# Update Date:  2021-08-18
# Update Time:  13:42
# Author:       MiaoCunFa
# Version:      v0.0.3

#===================================================================

programm=$(basename $0)

if [ "$port" == "" ];
then
    echo "$programm: port: is null! please check!"
    exit 0
fi

if [ "$service" == "" ];
then
    echo "$programm: service: is null! please check!"
    exit 0
fi

if [ "$host" == "" ];
then
    echo "$programm: host: is null! please check!"
    exit 0
fi

workdir="/var/lib/jenkins/workspace/$JOB_NAME"

harbor="harbor.test.local"
script_base="/script/test/$service"
target="$script_base/target"

#===================================================================

# 替换环境变量
cd $script_base && ./$service.sh

# 编译jar包
cd $workdir

/usr/local/maven/bin/mvn clean -U package  -am -Ptest -DskipTests

if [ $? -ne 0 ];
then
    echo -e  "Compile $JOB_NAME Error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi

#===================================================================

# 编译镜像
cp $workdir/$service/target/*.jar $target
docker build -t $harbor/$service:$BUILD_TAG .

if [ $? -ne 0 ];
then
    echo -e  "docker build error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi

#===================================================================

# 推送镜像
docker push $harbor/$service:$BUILD_TAG

if [ $? -eq 0];
then
    ssh root@$host "/bin/bash /script/test/docker-run.sh $harbor $service $BUILD_TAG $port"
else
    echo -e  "docker push error! \n        Please contact Ops or check the log for resolution"
    exit 1
fi
