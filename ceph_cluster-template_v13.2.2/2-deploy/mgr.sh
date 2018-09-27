#!/bin/bash
host_mgr=$1
#在节点上安装mgr
ceph-deploy mgr create $host_mgr
sleep 2s
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert
sleep 2s
# ceph config set mgr mgr/dashboard/server_addr $IP
ceph config set mgr mgr/dashboard/server_port 8092

# ceph mgr fail mgr
ceph mgr module disable dashboard
ceph mgr module enable dashboard
ceph dashboard set-login-credentials ceph admin

exit 0