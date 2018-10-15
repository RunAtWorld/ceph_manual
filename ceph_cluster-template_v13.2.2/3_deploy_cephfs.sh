#!/bin/bash
host_array=('ceph-test-1' 'ceph-test-2' 'ceph-test-3')
sh ./5-ceph_fs/deploy_cephfs/deploy_cephfs.sh ${host_array[@]}