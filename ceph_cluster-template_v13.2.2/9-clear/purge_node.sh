#!/bin/bash
# ceph-deploy purge ${hosts[@]} #清理文件
# ceph-deploy purgedata ${hosts[@]} #清理数据
# ceph-deploy forgetkeys  #删除keys

while read line
do
    host=`echo $line | awk '{print $1}'`
    echo "----------$host------------"
    ceph-deploy purge $host #清理文件
    echo "ceph-deploy purge $host"
    ceph-deploy purgedata $host #清理数据
    echo "ceph-deploy purgedata $host"
    ssh $host rm -rf ceph.*    #清理残余包
    ssh $host rm -rf /etc/ceph/*
    echo "$host lvremove -y $(lvdisplay | grep -i 'VG Name' | awk '{print $3}')"
    ssh $host lvremove -y $(lvdisplay | grep -i "VG Name" | awk '{print $3}') #清除osd占用的逻辑卷
done < name_pwd

exit 0