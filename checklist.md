1. 多租户完全隔离  
sudo mount -t ceph micros-k8s-6:6789:/u1 /mnt/ceph_kernel  -o name=u1,secretfile=/etc/ceph/admin.secret
sudo mount -t ceph micros-k8s-6:6789:/u2 /mnt/ceph_kernel  -o name=u2,secretfile=/etc/ceph/admin.secret
sudo mount -t ceph micros-k8s-6:6789:/ /mnt/ceph_kernel  -o name=admin,secretfile=/etc/ceph/admin.secret

1. 用户读写过程，client config  

1. client cache 怎样使用  

1. ceph非 sudo 挂载  
```
	[cephuser@micros-k8s-2 ~]$ ceph-fuse -m micros-k8s-6:6789 /mnt/ceph_fuse2
	ceph-fuse[4278]: starting ceph client
	2018-08-10 07:18:23.298 7f83a4d52cc0 -1 init, newargv = 0x5649649b7800 newargc=7
	fusermount: option allow_other only allowed if 'user_allow_other' is set in /etc/fuse.conf
	ceph-fuse[4278]: fuse failed to start
	2018-08-10 07:18:23.315 7f83a4d52cc0 -1 fuse_mount(mountpoint=/mnt/ceph_fuse2) failed.  
```  
1. cephfs 容量计算  

修改文件系统容量
```
ceph osd pool set cephfs_metadata target_max_bytes 20000000000
``` 
1. 1.2 pool 大概可以理解为命名空间  


# 其他
1. Ceph monitor map包括OSD Map、PG Map、MDS Map和CRUSH等，这些Map被统称为集群Map。
```
ceph osd dump

```  