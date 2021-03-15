#!/bin/bash

function Total(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $2}'
}

function Used(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $3}'
}

function Free(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $4}'
}

function Shared(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $5}'
}

function Buff_Cache(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $6}'
}

function Available(){
    /usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $7}'
}

function Swap_total(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $2}'
}

function Swap_userd(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $3}'
}

function Swap_free(){
    /usr/bin/free -m |sed -n '3p'|awk -F' ' '{print $4}'
}

function Usage(){
    total=$(/usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $2}')
    used=$(/usr/bin/free -m |sed -n '2p'|awk -F' ' '{print $3}')
    usage=$(awk 'BEGIN{printf "%.2f\n",('$used'/'$total')*100}')
    echo $usage
}

[ $# -ne 1 ] && echo "Total|Used|Free|Shared|Buff_Cache|Available|Swap_total|Swap_userd|Swap_free|Usage" && exit 1

#根据脚本参数执行对应函数
$1