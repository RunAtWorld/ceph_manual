#!/bin/bash
#centos7 dist
#用 subscription-manager 注册你的目标机器，确认你的订阅， 并启用安装依赖包的“Extras”软件仓库
sudo yum install -y yum-utils && sudo yum-config-manager \
	--add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install \
	--nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
	sudo rm /etc/yum.repos.d/dl.fedoraproject.org*
#把软件包源加入软件仓库
sudo cat> /etc/yum.repos.d/ceph.repo <<EOF
[ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-infernalis/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
EOF
#更新软件库并安装 ceph-deploy 
sudo yum update -y && sudo yum install -y ceph-deploy 

sudo useradd -d /home/cephuser -m cephuser
#set password of ceph to "cephuser"
echo "ceph"| passwd --stdin cephuser 
# 确保各 Ceph 节点上新创建的用户都有 sudo 权限
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser
#安装 NTP 服务（特别是 Ceph Monitor 节点），以免因时钟漂移导致故障
sudo yum install -y ntp ntpdate ntp-doc
# Ceph 节点安装 SSH 服务
sudo yum install -y openssh-server
systemctl restart sshd.service
systemctl enable sshd.service

#启用Monitors 使用的 6789 端口
sudo firewall-cmd --zone=public --add-port=6789/tcp --permanent
#启用OSD 使用的 6800:7300 端口
sudo firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent

#把 SELinux 设置为 Permissive 或者完全禁用
sudo setenforce 0
sudo yum install yum-plugin-priorities


