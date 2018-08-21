sudo cat << EOM >> /etc/yum.repos.d/CentOS-Base.repo

[base]
name=CentOS-7.5.1804 - Base - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=7.5.1804&arch=$basearch&repo=os
baseurl=http://mirrors.163.com/centos/7.5.1804/os/x86_64/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7

#released updates
[updates]
name=CentOS-7.5.1804 - Updates - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=7.5.1804&arch=$basearch&repo=updates
baseurl=http://mirrors.163.com/centos/7.5.1804/updates/x86_64/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7

#additional packages that may be useful
[extras]
name=CentOS-7.5.1804 - Extras - 163.com
#mirrorlist=http://mirrorlist.centos.org/?release=7.5.1804&arch=$basearch&repo=extras
baseurl=http://mirrors.163.com/centos/7.5.1804/extras/x86_64/$basearch/
gpgcheck=1
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-7.5.1804 - Plus - 163.com
baseurl=http://mirrors.163.com/centos/7.5.1804/centosplus/x86_64/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.163.com/centos/RPM-GPG-KEY-CentOS-7
EOM


sudo cat << EOM >> /etc/yum.repos.d/ceph.repo
[ceph]
name=Ceph noarch packages
baseurl=http://mirrors.163.com/ceph/rpm-mimic/el7/x86_64/
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=http://mirrors.163.com/ceph/keys/release.asc
EOM

yum clean all && yum makecache
yum clean metadata
yum update

