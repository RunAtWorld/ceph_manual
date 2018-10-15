#!/bin/bash
host_rgw=$1
#部署 rgw 服务
echo "[client]">>ceph.conf
echo "rgw frontends = civetweb port=7480" >>ceph.conf
if [ -d /etc/ceph ];then
    echo "/etc/ceph exist"
     ceph-deploy --overwrite-conf rgw create $host_rgw   
else
    ceph-deploy rgw create $host_rgw   
fi

exit 0