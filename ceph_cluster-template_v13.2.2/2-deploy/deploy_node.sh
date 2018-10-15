#!/bin/bash
#使用局域网源的方式 ceph-deploy-2.0.1-0
yum -y install http://ec2-52-82-8-82.cn-northwest-1.compute.amazonaws.com.cn:81/ceph/ceph-deploy/ceph-deploy-2.0.1-0.noarch.rpm
ceph-deploy --version
# 使用官方源的方式安装 ceph-deploy-2.0.1-0
# yum install -y https://download.ceph.com/rpm-mimic/el7/noarch/ceph-release-1-0.el7.noarch.rpm
# yum -y install ceph-deploy-2.0.1-0

exit 0