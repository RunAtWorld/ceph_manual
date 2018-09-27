#!/bin/bash
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')

sh ./1-check/admin_set_ssh.sh ${host_array[*]} #安装admin节点的ssh信息
mkdir ~/ceph_cluster
cp -f ./2-deploy/* ~/ceph_cluster 

cd ~/ceph_cluster
sh deploy_node.sh ${host_array[*]}
if [ $? -eq 0 ];then
 echo '---------------deploy_node success---------------'
else
 echo 'deploy_node fail'
 exit 1
fi   

cd ~/ceph_cluster
sh deploy_node_2.sh ${host_array[*]}
if [ $? -eq 0 ];then
 echo '---------------deploy_node_2 success---------------'
else
 echo 'deploy_node_2 fail'
 exit 1
fi

cd ~/ceph_cluster
sh osd.sh ${host_array[*]}
if [ $? -eq 0 ];then
 echo '---------------osd success---------------'
else
 echo 'osd fail'
 exit 1
fi       


cd ~/ceph_cluster
sh mgr.sh ${host_array[0]}
if [ $? -eq 0 ];then
 echo '---------------mgr success---------------'
else
 echo 'mgr fail'
 exit 1
fi

cd ~/ceph_cluster
sh rgw.sh ${host_array[1]}
if [ $? -eq 0 ];then
 echo '---------------rgw success---------------'
else
 echo 'rgw fail'
 exit 1
fi

echo '---------------ceph cluster success---------------'
exit 0
