#!/bin/bash
host_array=('ceph-test-1' 'ceph-test-2' 'ceph-test-3')

sh ./1-check/admin_set_ssh.sh ${host_array[@]} #安装admin节点的ssh信息
mkdir ~/ceph_cluster
cp -f ./2-deploy/* ~/ceph_cluster 

sh ~/ceph_cluster/deploy_node.sh ${host_array[@]}
if [ $? -eq 0 ];then
 echo '---------------deploy_node success---------------'
else
 echo 'deploy_node fail'
 exit 1
fi   

sh ~/ceph_cluster/deploy_node_2.sh ${host_array[@]}
if [ $? -eq 0 ];then
 echo '---------------deploy_node_2 success---------------'
else
 echo 'deploy_node_2 fail'
 exit 1
fi

sh ~/ceph_cluster/osd.sh ${host_array[@]}
if [ $? -eq 0 ];then
 echo '---------------osd success---------------'
else
 echo 'osd fail'
 exit 1
fi       

sh ~/ceph_cluster/mgr.sh ${host_array[0]}
if [ $? -eq 0 ];then
 echo '---------------mgr success---------------'
else
 echo 'mgr fail'
 exit 1
fi

sh ~/ceph_cluster/rgw.sh ${host_array[1]}
if [ $? -eq 0 ];then
 echo '---------------rgw success---------------'
else
 echo 'rgw fail'
 exit 1
fi

echo '---------------ceph cluster success---------------'
exit 0
