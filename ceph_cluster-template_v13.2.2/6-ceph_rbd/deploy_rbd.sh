#!/bin/bash
#on Admin Node
ceph osd pool create kube2 32 32   #创建一个池
rbd pool init kube2  #未创建块设备初始化池

#创建client:lpf
ceph auth get-or-create client.lpf
# ceph auth get-or-create client.lpf mon 'profile rbd' osd 'profile rbd pool=kube2, profile rbd-read-only pool=kube2'
ceph-deploy lpf ceph-rc-4  #分发client.lpf的密钥
ssh ceph-rc-4 sudo chmod +r /etc/ceph/ceph.client.lpf.keyring  #使密钥环文件有读权限
