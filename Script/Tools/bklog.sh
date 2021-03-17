#!/bin/bash

# Describe:     Log archive
# Create Date： 2020-08-31 
# Create Time:  11:15
# Author:       MiaoCunFa
#
# Usage:
# ➜  vim /etc/profile
# alias bklog='bklog(){ /opt/aihangxunxi/bin/bklog.sh $1; }; bklog';
# ➜  bklog
# ➜  bklog info-ahxx-service.log

#-------------------
# GLOBAL VARIABLES
#-------------------

EXITCODE=0
curDate=$(date +'%Y%m%d')
workDir="/opt/aihangxunxi/logs"

#-------------------
# Function
#-------------------

__exit_handler()
{
    exit $EXITCODE
}

__bklog()
{
    logfile=$1

    if [ -f ${logfile} ]
    then
        ${log_prefix}=$(echo ${logfile} | awk -F. '{print $1}')
    else
        echo "${logfile}: No such file or directory"
        __exit_handler
    fi

    if [ ! -d ${workDir}/oldlogs/${log_prefix}/${curDate} ]
    then
        mkdir -p ${workDir}/oldlogs/${log_prefix}/${curDate}
    fi
                
    SEQ=$((`ls -l ${workDir}/oldlogs/${log_prefix}/${curDate}/${log_prefix}.${curDate}.[0-9]* 2> /dev/null | wc -l`))
    OUTFILE="${workDir}/oldlogs/${log_prefix}/${curDate}/${log_prefix}.${curDate}.$SEQ"

    cp $logfile $OUTFILE
    
    # rm -f $logfile
    > $logfile
    
    zip -m $OUTFILE.zip $OUTFILE
}

#-----------------------------------------
# Log file archiving
#-----------------------------------------

cd ${workDir}

if [ ! -d oldlogs ]
then
    mkdir oldlogs
fi

logFileSpec=$1

if [ -n "${logFileSpec}" ]
then
    __bklog ${logFileSpec}
else
    for logfile in `ls *.log`
    do
        __bklog ${logfile}
    done
fi

__exit_handler