#!/bin/sh

job=$1
branch=$2
workdir='/var/lib/jenkins/workspace'
Add="$workdir/$job"

cd $Add
  git reset --hard $branch
