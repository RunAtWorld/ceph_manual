#!/bin/bash
#centos7 dist

ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys
cat > ~/.ssh/config << EOF
Host micros-k8s-1
   Hostname  172.31.39.148
   User ceph
Host micros-k8s-3
   Hostname  172.31.25.125
   User ceph
Host micros-k8s-5
   Hostname  172.31.21.32
   User ceph
Host micros-k8s-6
   Hostname  172.31.33.109
   User ceph
EOF
chmod 644 ~/.ssh/config
ssh-copy-id -i ~/.ssh/id_rsa.pub ceph@micros-k8s-1
ssh-copy-id -i ~/.ssh/id_rsa.pub ceph@micros-k8s-2
ssh-copy-id -i ~/.ssh/id_rsa.pub ceph@micros-k8s-3
ssh-copy-id -i ~/.ssh/id_rsa.pub ceph@micros-k8s-5

ssh ceph@micros-k8s-1
ssh ceph@micros-k8s-2
ssh ceph@micros-k8s-3
ssh ceph@micros-k8s-5

