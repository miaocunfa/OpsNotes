#!/bin/bash

#===================================================================
ENVFILE="/etc/profile"
EXITCODE=0
curDate=$(date +'%Y%m%d')
curTime=$(date +'%H%M%S')

workPath=/opt/aihangxunxi
worklibPath=$workPath/lib

tcpMessagePort=":8555"
tcpMessageSock=":9666"
tcpMessagePortNum=1
tcpMessageSocktNum=1
messagelib=info-message-service.jar

deployPath=/home/miaocunfa
deploy_ps_num=1
deploy_ps_file=$workPath/bin/.deploy.ps.service

total_service_file=$workPath/bin/.total.service
total_service_ps_file=$workPath/bin/.total.service.ps
total_service_logfile=$workPath/bin/.total.service.log
total_service=${total_service:-default}
service_num=0
success_num=0
failed_num=0

#===================================================================
cd $deployPath

total_service=$(ls *.jar)
echo $total_service >> $total_service_file

#---------------------------------------
echo $total_service | grep -wq "$messagelib" && isMessage="0" || isMessage="1"

if [ $isMessage == "0" ]
then
    cd $workPath/bin
    cur_datetime=$(date +'%Y%m%d%H%M%S')

    ./stop.sh $messagelib
    
    mv $worklibPath/$messagelib    $worklibPath/$messagelib.$cur_datetime
    mv $deployPath/$messagelib     $worklibPath/$messagelib

    echo
    echo -e "\tWaiting for MessageService Port Connection Close!"
    echo

    while ( [ $tcpMessagePortNum -ge 1 ] || [ $tcpMessageSocktNum -ge 1 ] )
    do
        sleep 1
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
        tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)
    done
    
    sleep 2
    ./start.sh $messagelib
fi

#---------------------------------------
total_service=$(ls $deployPath/*.jar)

for i in $(ls $deployPath/*.jar)
do
    cd $workPath/bin
    cur_datetime=$(date +'%Y%m%d%H%M%S')

    ./stop.sh $i

    mv $worklibPath/$i    $worklibPath/$i.$cur_datetime
    mv $deployPath/$i     $worklibPath/$i

    while [ $deploy_ps_num -ge 1 ]
    do
        sleep 1
        deploy_ps_num=$(ps -ef | grep $i | grep -v "grep" | wc -l)
    done

    ./start.sh $i
done

#---------------------------------------
for i in $(cat $total_service_file)
do
    ps -ef| grep $i | grep -v "grep" >> $total_service_ps_file

    service_prefix=$(echo $i | awk -F'.' '{print $1}')
    service_log=$service_prefix.log
    echo -e "\t\ttail -f $workPath/logs/$service_log" >> $total_service_logfile

    if [ -s $total_service_ps_file ]
    then
        success_num=$(( $success_num + 1 ))
    else
        failed_num=$(( $failed_num + 1 ))
    fi

    echo
    cat $total_service_ps_file
    echo
    >$total_service_ps_file
done

service_num=$(awk '{print NF}' $total_service_file)

echo
printf "\tTotal [%02i] Service are Deploy\n" $service_num
printf "\tSuccessfully [%02i], Failed [%02i]\n" $success_num $failed_num
printf "\tHave a good Day, see you Next time!\n"
echo

echo -e "\tIf you want to See logfile! Please execute this Command: "
echo 
cat $total_service_logfile
echo

>$total_service_ps_file
>$total_service_logfile
>$total_service_file
>$deploy_ps_file