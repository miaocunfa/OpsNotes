#!/bin/bash

# Describe:     package Prod H5
# Update Date:  2021-03-24
# Update Time:  14:33
# Version:      v0.0.1

Job=$1
project=$2

workdir="/var/lib/jenkins/workspace"
Add="$workdir/$Job"

NodejsBin="/usr/local/node-v12.16.1-linux-x64/bin"

if [ "$1" == "" ]; then
    echo "Job_Name: is null!"
    exit 0
fi

if [ "$2" == "" ]; then
    echo "project: is null!"
    exit 0
fi

cd $Add
sudo $NodejsBin/npm install
sudo $NodejsBin/npm run prod

cd $Add/prod
rm -f prod.tar.gz
tar -zcvf prod.tar.gz *
\cp -rf  prod.tar.gz /script/h5_pack/$project
