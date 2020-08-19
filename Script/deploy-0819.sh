#!/bin/bash

#===================================================================
cur_datetime=$(date +'%Y%m%d.%H%M')
workPath=/opt/aihangxunxi
worklibPath=$workPath/lib

messagelib=AitalkServer.jar
tcpMessagePort=":8080 "
tcpMessageSock=":9666 "
tcpMessagePortNum=1
tcpMessageSocktNum=1

deployPath=/home/miaocunfa/deployJar
tailServiceLogFile=$workPath/bin/tail.service.log
checkExceptionFile=$workPath/bin/checkException.sh

#===================================================================

function __checkMessagePortStopping()
{
    echo
    echo "Waiting for MessageService Port Connection Close!"
    echo

    tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
    tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)

    while ( [ $tcpMessagePortNum -ge 1 ] || [ $tcpMessageSocktNum -ge 1 ] )
    do
        sleep 1
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
        tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)
    done
}

function __tailServiceLog()
{
    tailService=$(echo $1 | awk -F'.' '{print $1".log"}')
    echo -e "\t\ttail -f -n 200 $workPath/logs/$tailService" >> $tailServiceLogFile
}

function __checkException()
{
    checkException=$(echo $1 | awk -F'.' '{print $1".log"}')
    echo "echo" >> $checkExceptionFile
    echo "grep Exception $workPath/logs/$checkException" >> $checkExceptionFile
    echo "echo" >> $checkExceptionFile
}

#===================================================================
# reset
> $tailServiceLogFile
> $checkExceptionFile

for i in $(ls $deployPath)
do
    cd $workPath/bin

    ./stop.sh $i

    if [ $i == "messagelib" ]
    then
        # Waiting for MessageService Port Connection Close
        __checkMessagePortStopping
    fi

    mv $worklibPath/$i    $worklibPath/$i.$cur_datetime
    mv $deployPath/$i     $worklibPath/$i

    sleep 1
    ./start.sh $i
    __tailServiceLog $i
    __checkException $i
done

echo
echo -e "Wait For Service Running!"
echo
sleep 5
chmod u+x $checkExceptionFile
sh $checkExceptionFile

echo
echo -e "\tIf you want to See logfile! Please execute this Command: "
echo 
cat $tailServiceLogFile
echo