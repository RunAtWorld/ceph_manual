#!/bin/bash
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')
sh ./9-clear/purge_node.sh ${host_array[@]}