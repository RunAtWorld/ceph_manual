#!/bin/bash
hosts=($@) #接收参数为数组
host_num=$#
echo "There are ${host_num} Servers in the cluster"
echo "ceph-deploy mds create ${hosts[(`expr ${host_num} - 1`)]}"
ceph-deploy --overwrite-conf mds create ${hosts[(`expr ${host_num} - 1`)]}  # 添加一个mds
# ceph-deploy mds create ${hosts[(`expr ${host_num} - 2`)]}
# ceph quorum_status --format json-pretty

#创建PG
ceph osd pool create cephfs_data 128 128
ceph osd pool create cephfs_metadata 64
#创建一个cephfs
ceph fs new cephfs cephfs_metadata cephfs_data

ceph fs ls
ceph mds stat
#USING ERASURE CODED POOLS WITH CEPHFS
# ceph osd pool set my_ec_pool allow_ec_overwrites true

# 为客户端授权
client_dir=$(cd $(dirname $0); pwd)
chmod a+x "$client_dir/client_authorization.sh"
sh -c "$client_dir/client_authorization.sh"