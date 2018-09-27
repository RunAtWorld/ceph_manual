#!/bin/bash

# on Client
sudo scp root@ceph-rc-1:/etc/ceph/ceph.conf /etc/ceph/ceph.conf   #从远程复制conf文件
sudo scp root@ceph-rc-1:/etc/ceph/ceph.client.lpf.keyring /etc/ceph/ceph.client.lpf.keyring  #从远程复制keyring文件
sudo chown -R ceph: /etc/ceph #文件和目录ceph具有读权限

#创建块设备
sudo rbd create test_image -p kube2 --size 1G  \
--image-feature layering -m ceph-rc-2:6789 -k /etc/ceph/ceph.client.admin.keyring   #create a block device image test_image
#rbd feature disable kube2/test_image object-map fast-diff deep-flatten # 临时关闭内核不支持的特性,如果挂载不成功，系统会有提示执行本条命令
sudo rbd device map kube2/test_image --name client.admin -m ceph-rc-2:6789 -k /etc/ceph/ceph.client.admin.keyring  #map the image to a block device，/dev/rbd0
rbd showmapped #查看块设备映像信息
sudo mkfs.ext4 -m0 /dev/rbd0 在 ceph-client 节点上，创建文件系统后就可以使用块设备了。

#访问
sudo mkdir /mnt/ceph-block-device   
sudo mount /dev/rbd0 /mnt/ceph-block-device  
cd /mnt/ceph-block-device