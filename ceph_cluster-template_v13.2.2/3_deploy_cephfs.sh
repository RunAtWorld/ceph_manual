#!/bin/bash
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')
cp ./5-ceph_fs/deploy_cephfs/* ~/ceph_cluster
cd  ~/ceph_cluster
sh deploy_cephfs.sh ${host_array[@]}