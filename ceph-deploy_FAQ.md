# Ceph 常见问题列表
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
答： 该功能为试验功能，和其他功能兼容性问题未验证 。 http://docs.ceph.com/docs/mimic/cephfs/experimental-features/#multiple-filesystems-within-a-ceph-cluster