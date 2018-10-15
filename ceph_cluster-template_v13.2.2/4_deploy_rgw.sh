#!/bin/bash
host_array=('ceph-test-1' 'ceph-test-2' 'ceph-test-3')
# 安装 rgw
sh ./2-deploy/rgw.sh ${host_array[1]}
if [ $? -eq 0 ];then
 echo '---------------rgw success---------------'
else
 echo 'rgw fail'
 exit 1
fi