#!/bin/bash
hosts=$@
# 下载 ceph-deploy-2.0.1-0 的rpm
yum install -y https://download.ceph.com/rpm-mimic/el7/noarch/ceph-release-1-0.el7.noarch.rpm
#以下为使用局域网源的方式
# curl -o ceph-deploy-2.0.1-0.noarch.rpm http://ec2-52-82-8-82.cn-northwest-1.compute.amazonaws.com.cn/ceph/rpm-mimic/el7/noarch/ceph-deploy-2.0.1-0.noarch.rpm 
# yum -y install ceph-deploy-2.0.1-0.noarch.rpm
# 安装 ceph-deploy-2.0.1-0
yum -y install ceph-deploy-2.0.1-0
ceph-deploy --version

for h in $hosts; do
     {
        echo "============================================"
        echo "====exec: install ceph: version=mimic @$h==="
        echo "============================================"
        # ceph-deploy install --release mimic $h 
        ssh $h yum install -y ceph ceph-radosgw
     }&   
     wait 
done 
   
exit 0