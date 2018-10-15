#!/bin/bash
hosts=$@
# ceph-deploy purge ${hosts[@]} #清理文件
# ceph-deploy purgedata ${hosts[@]} #清理数据
# ceph-deploy forgetkeys  #删除keys
{
    for h in $hosts; do
     echo "----------$h------------"
     ceph-deploy purge $h #清理文件
     echo "ceph-deploy purge $h"
     ceph-deploy purgedata $h #清理数据
     echo "ceph-deploy purgedata $h"
     ssh $h rm -rf ceph.*    #清理残余包
     ssh $h rm -rf /etc/ceph/*
     ssh $h lvremove -y $(lvdisplay | grep -i "VG Name" | awk '{print $3}') #清除osd占用的逻辑卷
    done 
}&

ceph-deploy forgetkeys  #删除keys
yum remove -y ceph-deploy
exit 0