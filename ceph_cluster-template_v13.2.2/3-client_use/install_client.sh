#!/bin/bash
#内核版本
lsb_release -a
uname -r
# 安装repo源
# sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#创建repo源
sudo rm -rf /etc/yum.repos.d/ceph*
sudo cat << EOM > /etc/yum.repos.d/ceph.repo
[Ceph-13.2.1]
name=Ceph-13.2.1
baseurl=http://ec2-52-82-8-82.cn-northwest-1.compute.amazonaws.com.cn/ceph/rpm-mimic/el7/x86_64
gpgcheck=0
enabled=1
EOM
sudo yum install -y ceph-common  #安装ceph文件系统基础库

