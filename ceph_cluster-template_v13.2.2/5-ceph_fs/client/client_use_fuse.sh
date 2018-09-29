#!/bin/bash
#在 Client 执行
#Specify a path
sudo scp ceph@ceph-rc-1:/etc/ceph/ceph.conf /etc/ceph/ceph.conf 
sudo scp ceph@ceph-rc-1:/etc/ceph/client.foo.keyring /etc/ceph/ceph.client.foo.keyring 
sudo mkdir /mnt/ceph_fuse_bar
sudo chown ceph: /mnt/ceph_fuse_bar

sudo ceph-fuse -n client.foo /mnt/ceph_fuse_bar -r /bar   #只能挂载 Client 有权限的目录
# sudo umount /mnt/ceph_fuse_bar #取消挂载