#!/bin/bash

# ps -ef| grep yum| grep -v grep|cut -c 9-15|xargs kill -9 
# sudo yum -y remove ceph-release
# ssh micros-k8s-2 sudo yum -y remove ceph-release
ceph-deploy install --release mimic micros-k8s-3
ceph-deploy install --release mimic micros-k8s-5
ceph-deploy install --release mimic micros-k8s-6

#创建目录
mkdir my-cephcluster
cd my-cephcluster
#创建集群信息
ceph-deploy new micros-k8s-6
echo "osd pool default size = 2">>ceph.conf
echo "public network = 172.31.33.109/16" >> ceph.conf
cat ceph.conf

#初始化集群信息
sudo ceph-deploy mon create-initial
# ceph-deploy --overwrite-conf mon create-initial

sudo ceph-deploy gatherkeys micros-k8s-6 micros-k8s-3 micros-k8s-5
sudo ceph-deploy admin micros-k8s-6
sudo ceph-deploy admin micros-k8s-5
sudo ceph-deploy admin micros-k8s-3

sudo chown ceph: /etc/ceph/*
ssh micros-k8s-3 sudo chown ceph: /etc/ceph/*
ssh micros-k8s-5 sudo chown ceph: /etc/ceph/*

# ceph-deploy --overwrite-conf osd prepare micros-k8s-6:/mnt/osd2 micros-k8s-3:/mnt/osd3
# ceph-deploy osd activate micros-k8s-6:/mnt/osd2 micros-k8s-3:/mnt/osd3
ceph-deploy disk list micros-k8s-6  #查看HOST上有哪些Disk
ceph-deploy disk zap micros-k8s-6 /dev/xvdb #清空Disk,注意只能是未使用的Disk  如果报错应使用 wipefs --all /dev/xvdb
sudo ceph-deploy osd create --data /dev/xvdb micros-k8s-6
# ceph-deploy disk list micros-k8s-3 
ceph-deploy disk zap micros-k8s-3 /dev/xvdp
sudo ceph-deploy osd create --data /dev/xvdp  micros-k8s-3
# ceph-deploy disk list micros-k8s-5
ceph-deploy disk zap micros-k8s-5 /dev/xvdf
sudo ceph-deploy osd create --data /dev/xvdf micros-k8s-5
ceph-deploy disk zap micros-k8s-5 /dev/xvdp
sudo ceph-deploy osd create --data /dev/xvdp micros-k8s-5

ceph -s
sudo ceph-deploy mgr create micros-k8s-6
sudo ceph-deploy mds create micros-k8s-3
sudo ceph-deploy mds create micros-k8s-5
sudo ceph-deploy mon add micros-k8s-3
# ceph-deploy --overwrite-conf mon add micros-k8s-2 
# ceph quorum_status --format json-pretty
sudo ceph-deploy mon add micros-k8s-5 
sudo ceph-deploy mon create micros-k8s-5 
ceph -s

echo "[client]">>ceph.conf
echo "rgw frontends = civetweb port=7480" >>ceph.conf
ceph-deploy rgw create micros-k8s-6
# ceph-deploy --overwrite-conf rgw create micros-k8s-1
sudo chown  ceph:ceph /etc/ceph/*

#Locate an Object
echo 'Test-data' > testfile.txt
ceph osd pool create mytest 8
rados put test-object-1 testfile.txt --pool=mytest

rados -p mytest ls
rados get test-object-1 download.txt --pool=mytest

#identify the object location:
# ceph osd map {pool-name} {object-name}
ceph osd map mytest test-object-1

# remove the test object
rados rm test-object-1 --pool=mytest
# delete the mytest pool
ceph osd pool rm mytest