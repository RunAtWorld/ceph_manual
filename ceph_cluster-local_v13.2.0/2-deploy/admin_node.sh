#!/bin/bash
#创建目录
mkdir my-cluster
cd my-cluster
#创建集群
ceph-deploy new ceph190
#把 Ceph 配置文件里的默认副本数从 3 改成 2
echo "osd pool default size = 2">>ceph.conf
cat ceph.conf 
#有多个网卡，可以把 public network 写入 Ceph 配置文件的 [global] 段下
echo "public network = 192.168.75.190/24" >> ceph.conf

# sudo yum -y remove ceph-release
#安装ceph
ceph-deploy install ceph190 ceph191 ceph192

#配置初始 monitor(s)、并收集所有密钥 --overwrite-conf参数覆盖配置
ceph-deploy mon create-initial
# ceph-deploy --overwrite-conf mon create-initial
#用 ceph-deploy 把配置文件和 admin 密钥拷贝到管理节点和 Ceph 节点
ceph-deploy admin ceph190 ceph191 ceph192

#Deploy a manager daemon. (Required only for luminous+ builds): i.e >= 12.x builds*
ceph-deploy mgr create ceph190  

#添加两个 OSD ,挂载到硬盘
# ceph-deploy osd create --data /dev/vdb ceph191
# ceph-deploy --overwrite-conf osd create --data /dev/sda1 ceph192
ssh ceph191 sudo mkdir -p /data/osd-1 && ssh ceph191 sudo chown ceph: /data/osd-1
ssh ceph192 sudo mkdir -p /data/osd-2 && ssh ceph192 sudo chown ceph: /data/osd-2
ceph-deploy --overwrite-conf osd prepare ceph191:/data/osd-1 ceph192:/data/osd-2
ceph-deploy osd activate ceph191:/data/osd-1 ceph192:/data/osd-2


ssh ceph192 sudo mkdir -p /var/local/osd4 && ssh ceph192 sudo chown ceph: /var/local/osd4
ceph-deploy --overwrite-conf osd prepare ceph192:/var/local/osd4
ceph-deploy osd activate ceph192:/var/local/osd4
#检查集群的健康状况
ceph health
ceph -s

#对 ceph.client.admin.keyring 设置操作权限
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
ssh ceph191 sudo chmod +r /etc/ceph/ceph.client.admin.keyring
ssh ceph192 sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#添加元数据服务器
##至少需要一个元数据服务器才能使用 CephFS ，执行下列命令创建元数据服务器
ceph-deploy mds create ceph190

#添加 MONITORS
##新增一个监视器到 Ceph 集群
ceph-deploy mon add ceph191 
ceph-deploy mon add ceph192
# ceph-deploy --overwrite-conf mon add ceph191 
# ceph-deploy --overwrite-conf mon add ceph192
##检查法定人数状
ceph quorum_status --format json-pretty

#添加新的mgr
ceph-deploy mgr create ceph191
#查看输出
ssh ceph190 sudo ceph -s

#添加 RGW 例程
echo "[client]">>ceph.conf
echo "rgw frontends = civetweb port=7480" >>ceph.conf
ceph-deploy rgw create ceph190
# ceph-deploy --overwrite-conf rgw create ceph190

#Locate an Object
# Specify an object name, a path to a test file containing some object data and a pool name
echo 'Test-data' > testfile.txt
ceph osd pool create mytest 8
# rados put {object-name} {file-path} --pool=mytest
rados put test-object-1 testfile.txt --pool=mytest
#verify that the Ceph Storage Cluster stored the object,
rados -p mytest ls
#identify the object location:
# ceph osd map {pool-name} {object-name}
ceph osd map mytest test-object-1

# remove the test object
rados rm test-object-1 --pool=mytest
# delete the mytest pool
ceph osd pool rm mytest