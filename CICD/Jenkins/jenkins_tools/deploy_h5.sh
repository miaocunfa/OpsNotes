#/bin/sh

project=$1
host=$2
remote_dir="/var/www/$project"
pack_dir="/script/h5_pack/$project"

if [ "$1" == "" ]; then
    echo "project: is null"
    exit 0
fi

if [ "$2" == "" ]; then
    echo "host: is null"
    exit 0
fi

scp $pack_dir/prod.tar.gz  root@$host:$remote_dir/
ssh root@$host "tar xf $remote_dir/prod.tar.gz -C $remote_dir; rm -f $remote_dir/prod.tar.gz"

