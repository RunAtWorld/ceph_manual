#!/bin/bash
#创建目录
mkdir my-cluster
cd my-cluster

#创建集群
ceph-deploy new ceph190

#把 Ceph 配置文件里的默认副本数从 3 改成 2
echo "osd pool default size = 1">>ceph.conf
cat ceph.conf 
#有多个网卡，可以把 public network 写入 Ceph 配置文件的 [global] 段下
echo "public network = 192.168.75.190/24" >> ceph.conf

sudo yum -y remove ceph-release
#rpm -e ceph-release
#安装ceph
# ceph-deploy install ceph190 ceph191 ceph192
ceph-deploy install ceph190 
ceph-deploy install ceph191
ceph-deploy install ceph192


#配置初始 monitor(s)、并收集所有密钥 --overwrite-conf参数覆盖配置
ceph-deploy mon create-initial
# ceph-deploy --overwrite-conf mon create-initial

#添加两个 OSD 
##登录到 Ceph 节点、并给 OSD 守护进程创建一个目录
ssh root@ceph191
sudo mkdir /var/local/osd0
sudo chown ceph: /var/local/osd0
exit

ssh root@ceph192
sudo mkdir /var/local/osd1
sudo chown ceph: /var/local/osd1
exit
##从管理节点执行 ceph-deploy 来准备 OSD
ceph-deploy osd prepare ceph191:/var/local/osd0 ceph192:/var/local/osd1
# ceph-deploy --overwrite-conf osd prepare ceph191:/var/local/osd0 ceph192:/var/local/osd1
##激活 OSD 
ceph-deploy osd activate ceph191:/var/local/osd0 ceph192:/var/local/osd1

#用 ceph-deploy 把配置文件和 admin 密钥拷贝到管理节点和 Ceph 节点
ceph-deploy admin ceph190 ceph191 ceph192

#对 ceph.client.admin.keyring 设置操作权限
sudo chmod +r /etc/ceph/ceph.client.admin.keyring

#检查集群的健康状况
ceph health


#添加元数据服务器
##至少需要一个元数据服务器才能使用 CephFS ，执行下列命令创建元数据服务器
ceph-deploy mds create ceph190

#添加 RGW 例程
echo "[client]">>ceph.conf
echo "rgw frontends = civetweb port=7480" >>ceph.conf
ceph-deploy --overwrite-conf  rgw create ceph190


#添加 MONITORS
##新增两个监视器到 Ceph 集群
ceph-deploy --overwrite-conf mon add ceph191 
ceph-deploy --overwrite-conf mon add ceph192
##检查法定人数状
ceph quorum_status --format json-pretty