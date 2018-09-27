#!/bin/bash
#在服务端admin节点执行
ceph auth get-or-create client.foo mon 'allow r' osd 'allow rwx pool=cephfs_data'
#ceph fs authorize *filesystem_name* client.*client_name* /*specified_directory* rw
ceph fs authorize cephfs client.foo / rw  # 为 foo 客户端设置对 / 目录的 rw 权限并生成密钥环

client quota df = true  #设置客户端只能查看被限额的容量