#!/bin/bash
#centos7 dist
subscription-manager repos --enable=rhel-7-server-extras-rpms
#nstall and enable the Extra Packages for Enterprise Linux (EPEL) repository
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y remove yum-plugin-priorities  \
	ceph-deploy \
	libcephfs2 \
	python-cephfs
 
#添加用户 ceph
useradd -d /home/ceph -m ceph
echo "cephuser"| passwd --stdin ceph 
sed -i "/^root/a\ceph ALL = (ALL:ALL) NOPASSWD:ALL" /etc/sudoers
yum install -y ntp ntpdate ntp-doc  #安装时间同步服务
ntpdate -u cn.pool.ntp.org     #设置系统时间与网络时间同步
hwclock --systohc    #系统时间写入硬件时间
hwclock -w     #强制系统时间写入CMOS中防止重启失效

#安装sshd
yum install -y openssh-server
systemctl restart sshd.service
systemctl enable sshd.service
#开防火墙相关端口
firewall-cmd --zone=public --add-port=6789/tcp --permanent
firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
firewall-cmd --reload
#关闭selinux
setenforce 0 #暂时关闭Selinux
sed -i "s/^SELINUX=.*/SELINUX=disable/" /etc/selinux/config  #永久关闭Selinux
yum install -y yum-plugin-priorities
yum provides '*/applydeltarpm'
yum install -y deltarpm
yum install -y sshpass

rm -rf /etc/yum.repos.d/ceph*
# 安装ceph需要的系统动态链接库
yum install -y yum-utils && \
yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && \
yum install --nogpgcheck -y epel-release && \
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
rm -f /etc/yum.repos.d/dl.fedoraproject.org*
yum update  -y

#设置ceph的局域网的yum源
cat << EOM > /etc/yum.repos.d/ceph.repo  
[Ceph-13.2.1]
name=Ceph-13.2.1
baseurl=http://ec2-52-82-8-82.cn-northwest-1.compute.amazonaws.com.cn:81/ceph/rpm-mimic/
# baseurl=file:///nfs_mirrors/ceph/rpm-mimic/el7/x86_64
gpgcheck=0
enabled=1
priority=1
EOM
#使用官方源，注释掉上面的，使用下面命令
# cd `dirname $0` && cp ../repos/ceph.repo /etc/yum.repos.d/

yum clean all && yum makecache
yum install -y ceph ceph-radosgw

exit 0