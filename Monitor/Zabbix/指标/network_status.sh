#!/bin/bash
eth=$1
io=$2
net_file="/proc/net/dev"
if [ $2 == "in" ]
then
    n_new=`grep "$eth" $net_file|awk '{print $2}'`
    n_old=`tail -1 /tmp/neti.log`
    n=`echo "$n_new-$n_old"|bc`
    d_new=`date +%s`
    d_old=`tail -2 /tmp/neti.log|head -1`
    d=`echo "$d_new-$d_old"|bc`
    if_net=`echo "$n/$d"|bc`
    echo $if_net
    date +%s>>/tmp/neti.log
    grep "$eth" $net_file|awk '{print $2}'>>/tmp/neti.log
elif [ $2 == "out" ]
then
    n_new=`grep "$eth" $net_file|awk '{print $10}'`
    n_old=`tail -1 /tmp/neto.log`
    n=`echo "$n_new-$n_old"|bc`
    d_new=`date +%s`
    d_old=`tail -2 /tmp/neto.log|head -1`
    d=`echo "$d_new-$d_old"|bc`
    if_net=`echo "$n/$d"|bc`
    echo $if_net
    date +%s>>/tmp/neto.log
    grep "$eth" $net_file|awk '{print $10}'>>/tmp/neto.log
else
    echo 0
fi