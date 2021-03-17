#!/bin/bash

#innodb缓冲池的read命中率是什么？

#缓冲池的read命中率是从缓冲池中读取数据的命中率
innodb_hite_rate() {

   #从硬盘中读取的次数
   Read_disk=`mysqladmin -uroot -pZeng1978 extended-status | awk '/\<Innodb_buffer_pool_reads\>/{print $4}'`

   #总的读取次数
   Read_total=`mysqladmin -uroot -pZeng1978 extended-status | awk '/\<Innodb_buffer_pool_read_requests\>/{print $4}'`

   #命中率
   awk 'BEGIN{printf "%.4f\n",'$(($Read_total-$Read_disk))'/'$Read_total'}'

}

$1