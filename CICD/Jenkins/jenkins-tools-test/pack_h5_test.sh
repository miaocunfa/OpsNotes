#!/bin/bash

# Describe:     package test H5
# Update Date:  2021-03-24
# Update Time:  14:30
# Version:      v0.0.2

Job=$1
project=$2

workdir="/var/lib/jenkins/workspace"
Add="$workdir/$Job"

NodejsBin="/usr/local/node-v12.16.1-linux-x64/bin"
html="/var/www/h5"

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
sudo $NodejsBin/npm run test

cd $Add/dist
rm -f dist.tar.gz
tar -zcvf dist.tar.gz *
\cp -rf  dist.tar.gz /script/h5/$project/pack

 cp /script/h5/$project/pack/dist.tar.gz  $html/$project
 tar xf $html/$project/dist.tar.gz -C $html/$project
 rm -f $html/$project/dist.tar.gz