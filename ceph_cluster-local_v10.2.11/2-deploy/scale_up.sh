#!/bin/bash
#centos7 dist
#添加 OSD
ssh ceph192
sudo mkdir /var/local/osd2
exit
##从 ceph-deploy 节点准备 OSD
ceph-deploy osd prepare ceph192:/var/local/osd2
##激活 OSD
ceph-deploy osd activate ceph192:/var/local/osd2
##观察：Ceph 集群就开始重均衡，把归置组迁移到新 OSD 
ceph -w

