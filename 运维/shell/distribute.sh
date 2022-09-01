#!/bin/bash

#===================================================================
ENVFILE="/etc/profile"
EXITCODE=0
curDate=`date +'%Y%m%d'`
curTime=`date +'%H%M%S'`

service_name=${service_name:-default}
host1=${host1:-default}
host2=${host2:-default}

#===================================================================
service_deploy=(
    'service-name                      host1        host2'
    'info-gateway.jar                  s1           s4'
    'info-consumer-service.jar         s2           null'
    'info-cms.jar                      ng1          null'
    'info-org-hotel.jar                ng2          null'
    'info-agent-service.jar            s2           s3'
    'info-ad-service.jar               s2           s3'
    'info-auth-service.jar             s2           s3'
    'info-community-service.jar        s2           s3'
    'info-groupon-service.jar          s2           s3'
    'info-hotel-service.jar            s2           s3'
    'info-message-service.jar          s2           s3'
    'info-nearby-service.jar           s2           s3'
    'info-news-service.jar             s2           s3'
    'info-payment-service.jar          s2           s3'
    'info-scheduler-service.jar        s2           s3'
    'info-uc-service.jar               s2           s3'
    'info-store-service.jar            s3           s3'
)

cd /home/wangchaochao/

for i in "${service_deploy[@]}"; 
do
    sub_array=($i)

    for jar in $(ls *.jar)
    do
        echo $i | grep -wq "$jar" && isExist="0" || isExist="1"

        if [ $isExist == "0" ];
        then
            service_name=${sub_array[0]}
            host1=${sub_array[1]}
            host2=${sub_array[2]}

            echo "jarName: $jar"
            echo "Host1: $host1"
            echo "Host2: $host2"

            scp /home/wangchaochao/$jar miaocunfa@${host1}:~

            if [ host2 != "null" ]
            then
                scp /home/wangchaochao/$jar miaocunfa@${host2}:~
            fi
        fi
    done
done