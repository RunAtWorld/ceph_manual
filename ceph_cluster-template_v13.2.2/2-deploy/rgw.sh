#!/bin/bash
host_rgw=$1
#部署 rgw 服务
echo "[client]">>ceph.conf
echo "rgw frontends = civetweb port=7480" >>ceph.conf
ceph-deploy rgw create $host_rgw