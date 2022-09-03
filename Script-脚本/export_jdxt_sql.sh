#!/bin/bash

curDate=`date +'%Y%m%d'`

cd /home/miaocunfa

echo
echo "exporting..."
mysqldump -uroot -B jdxt_db > jdxt_db_${curDate}.sql
echo "export successfully!"
echo "SQL File: "
ls -lh /home/miaocunfa/jdxt_db_${curDate}.sql

echo
echo "Taring..."
tar -zcvf jdxt_db_${curDate}.tgz ./jdxt_db_${curDate}.sql
echo "Tar successfully!"

echo
echo "remove SQL File!"
rm jdxt_db_${curDate}.sql

echo
echo "Tar File: "
ls -lh /home/miaocunfa/jdxt_db_${curDate}.tgz
echo 