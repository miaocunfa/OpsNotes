#!/bin/sh
#Created by:郭志敏
#Create Date:2018/8/17
#Function:check mysql master-slave replication is ok or not ok.

declare -a  slave_is  
slave_is=($(/usr/local/mysql/bin/mysql -h 192.168.1.189  -ugzm -p'gzm' -e "show slave status \G"|grep Running |awk '{print $2}'))  

	if [ "${slave_is[0]}" = "Yes" -a "${slave_is[1]}" = "Yes" ]       
        then      
                echo '2'   #代表正常两个yes     
        else      
                echo '-1'  #代表不正常      
	fi