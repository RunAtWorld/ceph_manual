#!/bin/bash
host_array=$@
ceph-deploy purge ${host_array[*]} #清理文件
ceph-deploy purgedata ${host_array[*]} #清理数据
ceph-deploy forgetkeys  #删除keys
for h in $host_array; do   #清理残余包
 ssh $h rm -rf ceph.*
 ssh $h rm -rf /etc/ceph/*
 ssh $h yum remove -y ceph-deploy
 ssh $h lvremove  -y `lvdisplay | grep -i "VG Name" | awk '{print $3}'` #清除osd占用的逻辑卷
done 

exit 0