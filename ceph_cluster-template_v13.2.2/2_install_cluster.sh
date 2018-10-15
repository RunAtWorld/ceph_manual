#!/bin/bash
host_array=()
while read line
do
    host=`echo $line | awk '{print $1}'`
    host_array=("${host_array[*]}" $host)
    # for a in ${host_array[*]} ; do
    #     echo $a
    # done
    # echo ">>>>>>$host"
done < name_pwd
echo "---------------hosts:${host_array[*]}-------------"

sh ./1-check/admin_set_ssh.sh ${host_array[@]} #安装admin节点的ssh信息

#安装ceph-deploy
sh ./2-deploy/deploy_node.sh
if [ $? -eq 0 ];then
 echo '---------------deploy_node success---------------'
else
 echo 'deploy_node fail'
 exit 1
fi   

#初始化集群并收集各个节点的密钥
sh ./2-deploy/deploy_node_2.sh ${host_array[@]}
if [ $? -eq 0 ];then
 echo '---------------deploy_node_2 success---------------'
else
 echo 'deploy_node_2 fail'
 exit 1
fi

#在各个节点上安装osd
sh ./2-deploy/osd.sh ${host_array[@]}
if [ $? -eq 0 ];then
 echo '---------------osd success---------------'
else
 echo 'osd fail'
 exit 1
fi       

#安装mgr和dashboard
sh ./2-deploy/mgr.sh ${host_array[0]}
if [ $? -eq 0 ];then
 echo '---------------mgr success---------------'
else
 echo 'mgr fail'
 exit 1
fi

echo '---------------ceph cluster success---------------'
exit 0
