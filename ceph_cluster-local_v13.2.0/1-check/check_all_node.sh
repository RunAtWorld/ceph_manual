#!/bin/bash
#centos7 dist
sudo subscription-manager repos --enable=rhel-7-server-extras-rpms
#nstall and enable the Extra Packages for Enterprise Linux (EPEL) repository
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y remove yum-plugin-priorities
sudo yum -y remove ceph-deploy
sudo yum -y remove libcephfs2
sudo yum -y remove python-cephfs
mkdir ~/opt
cd ~/opt
wget -i -c http://download.ceph.com/rpm-mimic/el7/noarch/ceph-deploy-1.5.39-0.noarch.rpm  
sudo yum -y install ceph-deploy-1.5.39-0.noarch.rpm
sudo yum -y install ceph-deploy-1.5.39-0
ceph-deploy --version

sudo rm -rf /etc/yum.repos.d/ceph*
sudo cat << EOM > /etc/yum.repos.d/ceph.repo

[Ceph]
name=Ceph packages for \$basearch
baseurl=http://download.ceph.com/rpm-mimic/el7/\$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[Ceph-noarch]
name=Ceph noarch packages
baseurl=http://download.ceph.com/rpm-mimic/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1

[ceph-source]
name=Ceph source packages
baseurl=http://download.ceph.com/rpm-mimic/el7/SRPMS
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
priority=1
EOM

sudo cp /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph.repo.rpmnew
# sudo yum update -y

sudo useradd -d /home/cephuser -m cephuser
echo "ceph"| passwd --stdin cephuser 
echo "cephuser ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephuser
sudo chmod 0440 /etc/sudoers.d/cephuser

sudo yum install -y ntp ntpdate ntp-doc
sudo yum install -y openssh-server
sudo systemctl restart sshd.service
sudo systemctl enable sshd.service

sudo firewall-cmd --zone=public --add-port=6789/tcp --permanent
sudo firewall-cmd --zone=public --add-port=6800-7300/tcp --permanent
sudo firewall-cmd --reload

sudo setenforce 0
sudo yum install -y yum-plugin-priorities