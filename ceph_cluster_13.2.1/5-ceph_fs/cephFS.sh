#!/bin/bash

# ADD A METADATA SERVER
ceph-deploy mds create micros-k8s-5

#CREATING POOLS
ceph osd pool create cephfs_data 160
ceph osd pool create cephfs_metadata 30

#CREATING A FILESYSTEM
ceph fs new cephfs cephfs_metadata cephfs_data

ceph fs ls
ceph mds stat
#USING ERASURE CODED POOLS WITH CEPHFS
# ceph osd pool set my_ec_pool allow_ec_overwrites true

#MOUNT CEPH FS WITH THE KERNEL DRIVER
sudo mkdir /mnt/ceph_kernel

# sudo mount -t ceph micros-k8s-6:6789:/ /mnt/ceph_kernel -o name=admin,secret=AQA0qGlbiRSPDRAALdqWHkWrOhmPwaCUY5nA2Q==  #使用密钥环字符串方式
sudo mount -t ceph micros-k8s-6:6789:/ /mnt/ceph_kernel  -o name=admin,secretfile=/etc/ceph/admin.secret ##使用指定密钥环文件的方式，admin.secret文件中是一个base64编码的字符串

sudo umount /mnt/ceph_kernel #卸载

#MOUNT CEPH FS USING FUSE
sudo mkdir -p /etc/ceph
sudo scp ceph@micros-k8s-6:/etc/ceph/ceph.conf /etc/ceph/ceph.conf  # 从集群中拉取keyring, Client 默认读 /etc/ceph/ceph.conf 
sudo scp ceph@micros-k8s-6:/etc/ceph/ceph.client.admin.keyring /etc/ceph/keyring  # 从集群中拉取keyring, Client 默认读/etc/ceph/ceph.client.admin.keyring,
																			#/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin
																			#4个文件只要有一个就可
sudo yum -y install ceph-fuse
#mount a CephFS as fuse 
sudo mkdir /mnt/ceph_fuse
sudo chown ceph: /mnt/ceph_fuse
sudo ceph-fuse -m micros-k8s-6:6789 /mnt/ceph_fuse
# sudo systemctl start ceph-fuse@/mnt.service  #开启ceph-fuse服务
# sudo systemctl enable ceph-fuse@/mnt.service  #设置ceph-fuse服务开机启动
# sudo systemctl enable ceph-fuse.target  #设置ceph-fuse服务开机启动
sudo umount /mnt/ceph_fuse

#mount a second CephFS as fuse 
sudo mkdir /mnt/ceph_fuse2
sudo chown ceph: /mnt/ceph_fuse2
sudo ceph-fuse -m micros-k8s-6:6789 /mnt/ceph_fuse2



# using fstab in kernel
sudo cat <<EOM >> /etc/fstab
#{ipaddress}:{port}:/ {mount}/{mountpoint} {filesystem-name}     [name=username,secret=secretkey|secretfile=/path/to/secretfile],[{mount.options}]
micros-k8s-6:6789:/     /mnt/ceph    ceph    name=admin,secretfile=/etc/ceph/secret.key,noatime,_netdev    0       2
EOM

# using fstab with fuse
sudo cat <<EOM >> /etc/fstab
#DEVICE PATH       TYPE      OPTIONS
#none    /mnt/ceph  fuse.ceph ceph.id={user-ID}[,ceph.conf={path/to/conf.conf}],_netdev,defaults  0 0
none    /mnt/ceph  fuse.ceph ceph.id=admin,_netdev,defaults  0 0
none    /mnt/ceph  fuse.ceph ceph.id=foo,ceph.conf=/etc/ceph/foo.conf,_netdev,defaults  0 0
EOM

setfattr -n ceph.quota.max_bytes -v 9000000 /mnt/ceph_fuse_bar   # set space to 100 MB
setfattr -n ceph.quota.max_files -v 10000 /mnt/ceph_fuse_bar  # set files number to 10,000 files

getfattr -n ceph.quota.max_bytes /mnt/ceph_fuse_bar    # get attributes:ceph.quota.max_bytes
getfattr -n ceph.quota.max_files /mnt/ceph_fuse_bar    # get attributes:ceph.quota.max_files

setfattr -n ceph.quota.max_bytes -v 0 /mnt/ceph_fuse_bar  # remove attributes:ceph.quota.max_bytes
setfattr -n ceph.quota.max_files -v 0 /mnt/ceph_fuse_bar  # remove attributes:ceph.quota.max_files

sudo umount /mnt/ceph_fuse_bar