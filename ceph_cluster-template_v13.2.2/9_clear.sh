#!/bin/bash
set -e
host_array=()
while read line
do
    host=`echo $line | awk '{print $1}'`
    host_array=("${host_array[*]}" $host)
done < name_pwd
# echo "---------------hosts:${host_array[*]}-------------"

#清理节点数据和安装包
for host in ${host_array[*]} ; do
    echo "----------purge @ $host------------"
    echo "ceph-deploy purge $host"
    ceph-deploy purge $host #清理文件
    echo "ceph-deploy purgedata $host"
    ceph-deploy purgedata $host #清理数据
done

#清理osd占用的卷和ceph-deploy
if [ $? -eq 0 ];then
    echo '---------succeed to clear cluster---------------'
    for host in ${host_array[*]} ; do
        echo "------------------$host-----------------------"
        lv_name=`ssh $host lvdisplay | grep -i "LV Path" | awk '{print $3}'`
        ssh $host lvremove -y $lv_name  #清除osd占用的逻辑卷
        echo "removed $lv_name @ $host "
        if [ $? -eq 0 ]; then
            continue
        fi
    done    
    ceph-deploy forgetkeys  #删除keys
    yum remove -y ceph-deploy
    echo '---------succeed to clear ceph-deploy---------------'
else
    echo '---------fail to clear cluster ---------------'
    exit 1
fi