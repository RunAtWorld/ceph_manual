#!/bin/bash
host_array=()
while read line
do
    host=`echo $line | awk '{print $1}'`
    host_array=("${host_array[*]}" $host)
done < name_pwd
echo "---------------hosts:${host_array[*]}-------------"
sh ./5-ceph_fs/deploy_cephfs/deploy_cephfs.sh ${host_array[@]}