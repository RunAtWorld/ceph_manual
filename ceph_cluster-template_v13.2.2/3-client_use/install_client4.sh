#!/bin/bash
sudo yum install -y yum-utils && \
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && \
yum install --nogpgcheck -y epel-release && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
rm -f /etc/yum.repos.d/dl.fedoraproject.org*

sudo yum -y install ceph-common