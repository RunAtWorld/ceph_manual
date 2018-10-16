#!/bin/bash
set -e
#清理节点数据和安装包
while read line
do
    host=`echo $line | awk '{print $1}'`
    echo "----------$host------------"
    echo "ceph-deploy purge $host"
    ceph-deploy purge $host #清理文件
    echo "ceph-deploy purgedata $host"
    ceph-deploy purgedata $host #清理数据
done < name_pwd

#清理osd占用的卷和ceph-deploy
if [ $? -eq 0 ];then
    echo '---------succeed to clear cluster ---------------'
    {
        while read line
        do
            host=`echo $line | awk '{print $1}'`
            ssh $host lvremove -y $(lvdisplay | grep -i "VG Name" | awk '{print $3}') #清除osd占用的逻辑卷
        done < name_pwd        
    }&
    ceph-deploy forgetkeys  #删除keys
    yum remove -y ceph-deploy
else
    echo '---------fail to clear cluster ---------------'
    exit 1
fi
