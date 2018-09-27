#!/bin/bash
cp ./5-ceph_fs/deploy_cephfs/* ~/ceph_cluster
cd  ~/ceph_cluster
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')
sh deploy_cephfs.sh ${host_array[@]}

