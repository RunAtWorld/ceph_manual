#!/bin/bash
# 安装ceph的依赖
yum install -y yum-utils && \
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && \
yum install --nogpgcheck -y epel-release && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
rm -f /etc/yum.repos.d/dl.fedoraproject.org*
sudo rm -rf /etc/yum.repos.d/ceph*
# 安装repo源
# sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#创建repo源
# sudo cat << EOM > /etc/yum.repos.d/ceph.repo
# [Ceph-13.2.1]
# name=Ceph-13.2.1
# baseurl=http://ec2-52-82-8-82.cn-northwest-1.compute.amazonaws.com.cn/ceph/rpm-mimic/el7/x86_64
# gpgcheck=0
# enabled=1
# EOM
#如果使用官方源，注释掉上面的，使用下面命令
sudo cd `dirname $0` && sudo cp ../repos/ceph.repo /etc/yum.repos.d/
sudo yum clean all && yum makecache
sudo yum install -y ceph-common  #安装ceph文件系统基础库
sudo ceph -v

