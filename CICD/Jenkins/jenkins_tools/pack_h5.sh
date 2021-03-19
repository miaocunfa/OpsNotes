#!/bin/bash

Job=$1
project=$2
workdir="/var/lib/jenkins/workspace"
Add="$workdir/$Job"

if [ "$1" =="" ]; then
    echo "Job_Name: is null!"
    exit 0
fi

if [ "$2" =="" ]; then
    echo "project: is null!"
    exit 0
fi

cd $Add
sudo /usr/local/node-v12.16.1-linux-x64/bin/npm install
sudo /usr/local/node-v12.16.1-linux-x64/bin/npm run prod

cd $Add/prod
rm -f prod.tar.gz
tar -zcvf prod.tar.gz *
\cp -rf  prod.tar.gz /script/h5_pack/$project

