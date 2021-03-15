#!/bin/bash

#Server=`/sbin/pidof server`
PortNum=` netstat -lnt|grep 8080|wc -l`

if [ $PortNum -eq 1 ];
then
    echo "1"
else
    echo "2"
fi