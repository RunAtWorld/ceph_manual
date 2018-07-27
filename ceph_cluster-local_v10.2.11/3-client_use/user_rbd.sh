#!/bin/bash
#centos7 dist

#安装 CEPH
#内核版本
lsb_release -a
uname -r
# 在管理节点上，通过 ceph-deploy 把 Ceph 安装到 ceph-client 节点
ceph-deploy install ceph185
#在管理节点上，用 ceph-deploy 把 Ceph 配置文件
#和 ceph.client.admin.keyring 拷贝到 ceph-client 。
ceph-deploy admin ceph185
#密钥环文件有读权限
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#配置块设备
#在 ceph-client 节点上创建一个块设备 image 。
rbd create foo --size 4096 -m 192.168.75.190 -k /etc/ceph/ceph.client.admin.keyring
# rbd create foo --size 4096

#在 ceph-client 节点上，把 image 映射为块设备。
sudo rbd map foo --name client.admin -m 192.168.75.190 -k /etc/ceph/ceph.client.admin.keyring
# sudo rbd map foo --name client.admin

#在 ceph-client 节点上，创建文件系统后就可以使用块设备了。
sudo mkfs.ext4 -m0 /dev/rbd/rbd/foo
