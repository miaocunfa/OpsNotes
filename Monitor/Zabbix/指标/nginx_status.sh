#!/bin/bash
############################################################
# @Name:         nginx_status.sh
# @Version:      v1.1
# @Function:     Nginx Status
# @Author:       guozhimin
# @organization: www.xuliangwei.com
# @Create Date:  2018-06-23
# @Update Date:  2021-03-09
# @Description:  Monitor Nginx Service Status
############################################################

NGINX_COMMAND=$1
NGINX_PORT=80

nginx_ping() {
    /sbin/pidof nginx | wc -l
}

nginx_active(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk '/Active/ {print $NF}'
}

nginx_reading(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk '/Reading/ {print $2}'
}

nginx_writing(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk '/Writing/ {print $4}'
}

nginx_waiting(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk '/Waiting/ {print $6}'
}

nginx_accepts(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk 'NR==3 {print $1}'
}

nginx_handled(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk 'NR==3 {print $2}'
}

nginx_requests(){
    /usr/bin/curl -s "http://localhost:"$NGINX_PORT"/nginx_status/" |awk 'NR==3 {print $3}'
}


  case $NGINX_COMMAND in
    ping)
        nginx_ping;
        ;;
        active)
                nginx_active;
                ;;
        reading)
                nginx_reading;
                ;;
        writing)
                nginx_writing;
                ;;
        waiting)
                nginx_waiting;
                ;;
        accepts)
                nginx_accepts;
                ;;
        handled)
                nginx_handled;
                ;;
        requests)
                nginx_requests;
                ;;
        *)
                echo $"USAGE:$0 {ping|active|reading|writing|waiting|accepts|handled|requests}"
        esac