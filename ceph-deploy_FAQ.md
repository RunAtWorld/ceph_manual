# Ceph 常见问题列表
1. **Ceph 安装源下载慢？**

1. **Ceph 安装OSD时执行 `zap` 命令报错？**   
答： 挂载一个块设备的步骤为：(假设主机为 `micros-k8s-6`,硬盘为`xvdb`)

	```
	ceph-deploy disk list micros-k8s-6 #查看HOST上有哪些Disk
	ceph-deploy disk zap micros-k8s-6 /dev/xvdb   #清空Disk,注意只能是未使用的Disk  如果报错应使用 wipefs --all /dev/xvdb
	ceph-deploy osd create --data /dev/xvdb micros-k8s-6  #创建文件系统
	```  
	如果在执行  `ceph-deploy disk zap k8s-6 /dev/xvdb` 报错：
	```
	[micros-k8s-6][DEBUG ]  stderr: wipefs: error: /dev/xvdb: probing initialization failed: Device or resource busy
	[micros-k8s-6][ERROR ] RuntimeError: command returned non-zero exit status: 1
	[ceph_deploy][ERROR ] RuntimeError: Failed to execute command: /usr/sbin/ceph-volume lvm zap /dev/xvdb
	```
	(1) 执行 `fuser -m -v /dev/xvdb` 查看占用此硬盘的pid, `kill -9 {pid}` 删除掉占用此硬盘的进程  
	(2) 执行 `pvdisplay -m` 查看 Ceph 使用的逻辑卷名   
	(3) 执行 `lvremove {logic_volume_name}`  删除对应的逻辑卷。
	> 更多关于 Linux 磁盘的理解：[https://blog.csdn.net/RunAtWorld/article/details/81536055](https://blog.csdn.net/RunAtWorld/article/details/81536055)
1. **CephFS只能启动一个，为什么？**   
答： 该功能为实验特性，和其他功能兼容性问题未验证 。 http://docs.ceph.com/docs/mimic/cephfs/experimental-features/#multiple-filesystems-within-a-ceph-cluster

1. **如何设置合适的PG数？PG有总数吗？**   
详细查找资料后发现，Ceph集群的PG总数有上限，理论为限额为 200 * osd数。因此创建池时最好根据实际需要设置pg数，建议公式为 
``` 
pg数 = (osd数 * 100 * 期望空间百分比) / 副本数
```
取得 pg数 后取一个最接近2的N次方的值。比如OSD数量是160，复制份数3，期望空间百分比是33.3%，那么按上述公式计算出的结果是1777.7。取跟它接近的2的N次方是2048，那么每个pool分配的PG数量就是2048。
也可使用pg计算器： [https://ceph.com/pgcalc](https://ceph.com/pgcalc)

> PG指定存储池存储对象的目录有多少个，PGP是存储池PG的OSD分布组合个数。PG的增加会引起PG内数据的分裂，分裂到相同的OSD上。新生成的PG当中PGP的增加会引起部分PG的分布变化，但是不会引起PG内对象的变动。PG和PGP数量一定要根据OSD的数量进行调整，调整PGP不会引起PG内的对象的分裂，但是会引起PG的分布的变动。
> 在更改pool的PG数量时，需同时更改PGP的数量。PGP是为了管理placement而存在的专门的PG，它和PG的数量应该保持一致。如果你增加pool的pg_num，就需要同时增加pgp_num，保持它们大小一致，这样集群才能正常rebalancing。[如何修改pg_num和pgp_num：(https://www.cnblogs.com/kuku0223/p/8214412.html](https://www.cnblogs.com/kuku0223/p/8214412.html)


```

```
