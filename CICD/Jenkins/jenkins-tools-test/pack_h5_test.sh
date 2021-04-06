#!/bin/bash

# Describe:     package test H5
# Update Date:  2021-04-06
# Update Time:  16:32
# Version:      v0.0.6

Job=$1
project=$2

workdir="/var/lib/jenkins/workspace"
Add="$workdir/$Job"

NodejsBin="/usr/local/node-v12.16.1-linux-x64/bin"
html="/var/www/h5"
tarball="test.tar.gz"

if [ "$1" == "" ]; then
    echo "Job_Name: is null!"
    exit 0
fi

if [ "$2" == "" ]; then
    echo "project: is null!"
    exit 0
fi

if [ ! -d $Add ]; then
    echo "Jenkins: workspace: $Add: No such file or directory!"
    exit 0
fi

if [ ! -d $html/$project ]; then
    echo "html: $html/$project: No such file or directory!"
    exit 0
fi

if [ ! -d /script/h5-pack/$project ]; then
    echo "h5-pack: /script/h5-pack/$project : No such file or directory!"
    exit 0
fi

cd $Add
sudo $NodejsBin/npm install
sudo $NodejsBin/npm run test

cd $Add/test
rm -f $tarball
tar -zcvf $tarball *
cp  -rf $tarball /script/h5-pack/$project/

rm -rf $html/$project/*
cp /script/h5-pack/$project/$tarball  $html/$project
tar xf $html/$project/$tarball -C $html/$project
rm -f $html/$project/$tarball