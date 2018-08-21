#!/bin/bash
#centos7 dist

#安装 CEPH
#内核版本
lsb_release -a
uname -r
# 在管理节点上，通过 ceph-deploy 把 Ceph 安装到 ceph-client 节点
ceph-deploy install micros-k8s-1
#在管理节点上，用 ceph-deploy 把 Ceph 配置文件
#和 ceph.client.admin.keyring 拷贝到 ceph-client 。
ceph-deploy admin micros-k8s-1
#密钥环文件有读权限
ssh micros-k8s-1 sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#配置块设备
rbd create test_image --size 4096 -m micros-k8s-3 -k /etc/ceph/ceph.client.admin.keyring  #在 ceph-client 节点上创建一个块设备 image 。
rbd map test_image --name client.admin -m micros-k8s-5 -k /etc/ceph/ceph.client.admin.keyring  #在 ceph-client 节点上，把 image 映射为块设备。
#在 ceph-client 节点上，创建文件系统后就可以使用块设备了。
sudo mkfs.ext4 -m0 /dev/rbd/rbd/test_image

ceph auth get-or-create client.lpf mon 'profile rbd' osd 'profile rbd pool=mytest, profile rbd-read-only pool=test_image'
sudo rbd device map mytest/test_image --id lpf --keyring /path/to/keyring