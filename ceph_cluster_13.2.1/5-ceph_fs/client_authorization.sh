#!/bin/bash
#在服务端admin节点执行
#ceph fs authorize *filesystem_name* client.*client_name* /*specified_directory* rw
ceph fs authorize cephfs client.foo / r /bar rw  # 为 foo 客户端设置对 /bar 目录的 rw 权限，对/ 目录的r 权限，并生成密钥环

client quota df = true  #设置客户端只能查看被限额的容量


#在 Client 执行
#Specify a path
sudo scp ceph@micros-k8s-6:/etc/ceph/ceph.conf /etc/ceph/ceph.conf 
sudo scp ceph@micros-k8s-6:/etc/ceph/client.foo.keyring /etc/ceph/client.foo.keyring 
sudo mkdir /mnt/ceph_fuse_bar
sudo chown ceph: /mnt/ceph_fuse_bar

sudo ceph-fuse -n client.foo /mnt/ceph_fuse_bar -r /bar   #只能挂载 Client 有权限的目录
  