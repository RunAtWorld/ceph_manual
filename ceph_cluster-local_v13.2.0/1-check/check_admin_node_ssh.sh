#!/bin/bash
#centos7 dist

#生成ssh密钥并传公钥到各node上
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat id_rsa.pub >> authorized_keys && chmod 644 authorized_keys
#修改 ceph-deploy 管理节点上的 ~/.ssh/config 文件,无需每次执行 ceph-deploy 都要指定 --username {username} 
cat > ~/.ssh/config << EOF
Host ceph190
   Hostname 192.168.75.190
   User cephuser
Host ceph192
   Hostname 192.168.75.192
   User cephuser
Host ceph191
   Hostname 192.168.75.191
   User cephuser
Host ceph192
   Hostname 192.168.75.192
   User cephuser
EOF
chmod 644 ~/.ssh/config

ssh-copy-id -i ~/.ssh/id_rsa.pub cephuser@ceph191
ssh-copy-id -i ~/.ssh/id_rsa.pub cephuser@ceph192
ssh-copy-id -i ~/.ssh/id_rsa.pub cephuser@ceph185

# check whether cephuser is valid
ssh cephuser@ceph191
ssh cephuser@ceph192
ssh cephuser@ceph185