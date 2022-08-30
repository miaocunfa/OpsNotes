#!/bin/bash

#===================================================================
workPath=/opt/aihangxunxi
worklibPath=$workPath/lib

tcpMessagePort=8555
tcpMessagePortNum=1
tcpMessageSock=9666
tcpMessageSocktNum=1
tcpConsulPort=8500
tcpConsulPortNum=1
tcpGatewayPort=9999
tcpGatewayPortNum=1

#===================================================================
function __checkConsulRunning()
{
    isConsulRun=$(ps -ef | grep consul | grep -v "grep" | wc -l)
    if [ $isConsulRun -lt 1 ]
    then
        cd /opt
        nohup ./consul agent -dev -advertise 127.0.0.1 -enable-local-script-checks -client=0.0.0.0 &
    else
        return 0
    fi

    echo
    echo "Waiting for Consul Port Listening!"
    echo 

    tcpConsulPortNum=$(ss -an | grep $tcpConsulPort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    while [ $tcpConsulPortNum -lt 1 ]
    do
        sleep 1
        tcpConsulPortNum=$(ss -an | grep $tcpConsulPort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    done
}

function __checkGatewayRunning()
{
    isGatewayRun=$(ps -ef | grep gateway | grep -v "grep" | wc -l)
    if [ $isGatewayRun -lt 1 ]
    then
        cd $workPath/bin
        ./start.sh info-gateway.jar
    fi

    echo 
    echo "Waiting for GATEWAY Port Listening!"
    echo 

    tcpGatewayPortNum=$(ss -an | grep $tcpGatewayPort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    while [ $tcpGatewayPortNum -lt 1 ]
    do
        sleep 1
        tcpGatewayPortNum=$(ss -an | grep $tcpGatewayPort | awk '$1 == "tcp" && $2 == "LISTEN" {print $0}' | wc -l)
    done
}

function __checkServiceStopping()
{
    isServiceRun=$(ps -ef | grep info | grep -v "grep" | wc -l)

    # judge service is running?
    if [ $isServiceRun -eq 0 ]
    then
        # If the service is not running, Exit function 
        return 0
    fi

    echo "Waiting for All Service Stop!"

    # Until the process is all killed
    while [ $isServiceRun -ge 1 ]
    do
        # kill all service
        ps -ef| grep info | grep -v "grep" | awk '{print $2}' | xargs kill

        sleep 1
        isServiceRun=$(ps -ef | grep info | grep -v "grep" | wc -l)
    done 
}

function __checkMessagePortStopping()
{
    echo "Waiting for MessageService Port Connection Close!"

    tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
    tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)

    while ( [ $tcpMessagePortNum -ge 1 ] || [ $tcpMessageSocktNum -ge 1 ] )
    do
        sleep 1
        tcpMessagePortNum=$(ss -an | grep $tcpMessagePort | wc -l)
        tcpMessageSocktNum=$(ss -an | grep $tcpMessageSock | wc -l)
    done
}

function __checkOtherServiceRunning()
{
    cd $worklibPath

    echo 
    echo "Waiting for All Service Start!"
    echo 

    for i in $(ls info*.jar)
    do
        isRun=$(ps -ef | grep $i | grep -v "grep" | wc -l)
        if [ $isRun -lt 1 ]
        then
            cd $workPath/bin
            ./start.sh $i
        fi
    done
}

#===================================================================
# Stop All Service
__checkServiceStopping
__checkMessagePortStopping

# Check The Consul Service, If it is not Running! Run it!
__checkConsulRunning

# Check The Gateway Service, If it is not Running! Run it!
__checkGatewayRunning

# Check The Other Service, If it is not Running! Run it!
__checkOtherServiceRunning