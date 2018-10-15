#!/bin/bash
sh ./9-clear/purge_node.sh
ceph-deploy forgetkeys  #删除keys
yum remove -y ceph-deploy