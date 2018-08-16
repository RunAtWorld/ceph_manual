# 一. 操作CephFS
1. ## 建立CephFS
	1. 建立CephFS  
	```
	# ADD A METADATA SERVER
	ceph-deploy mds create micros-k8s-5

	#CREATING POOLS
	ceph osd pool create cephfs_data 160
	ceph osd pool create cephfs_metadata 30

	#CREATING A FILESYSTEM
	ceph fs new cephfs cephfs_metadata cephfs_data

	ceph fs ls
	ceph mds stat	
	```

	1. CephFS 读写过程 
  	
	> 当一个或多个客户端打开一个文件时，客户端向MDS发送请求，MDS向OSD定位该文件所在的文件索引节点（File Inode），该索引节点包含一个唯一的数字、文件所有者、大小和权限等其他元数据，MDS会赋予Client读和缓存文件内容的权限。访问被授权后向客户端返回 File Inode值、Layout（Layout可以定义文件内容如何被映射到Object）和文件大小，客户端根据MDS返回的信息定位到要访问的文件，然后直接与OSD执行File IO交互。
	> 同样，当客户端对文件执行写操作时，MDS赋予Client带有缓冲区的写权限，Client对文件写操作后提交给MDS，MDS会将该新文件的信息重新写入到OSD中的Object中。
	
1. ## 使用 kernel 驱动挂载 CephFS
	```
	#MOUNT CEPH FS WITH THE KERNEL DRIVER
	sudo mkdir /mnt/ceph_kernel
	# sudo mount -t ceph micros-k8s-6:6789:/ /mnt/ceph_kernel -o name=admin,secret=AQA0qGlbiRSPDRAALdqWHkWrOhmPwaCUY5nA2Q==  #使用密钥环字符串方式
	sudo mount -t ceph micros-k8s-6:6789:/ /mnt/ceph_kernel  -o name=admin,secretfile=/etc/ceph/admin.secret ##使用指定密钥环文件的方式，admin.secret文件中是一个base64编码的字符串
	```
1. ## 使用 fuse 挂载 CephFS
	```
	#MOUNT CEPH FS USING FUSE
	sudo mkdir -p /etc/ceph
	sudo scp cephuser@micros-k8s-6:/etc/ceph/ceph.conf /etc/ceph/ceph.conf  # 从集群中拉取keyring, Client 默认读 /etc/ceph/ceph.conf 
	sudo scp cephuser@micros-k8s-6:/etc/ceph/ceph.client.admin.keyring /etc/ceph/keyring  # 从集群中拉取keyring, Client 默认读/etc/ceph/ceph.client.admin.keyring,
																				#/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin
																				#4个文件只要有一个就可
	sudo yum -y install ceph-fuse
	#mount a CephFS as fuse 
	sudo mkdir /mnt/ceph_fuse
	sudo chown cephuser: /mnt/ceph_fuse
	sudo ceph-fuse -m micros-k8s-6:6789 /mnt/ceph_fuse
	# sudo systemctl start ceph-fuse@/mnt.service  #开启ceph-fuse服务
	# sudo systemctl enable ceph-fuse@/mnt.service  #设置ceph-fuse服务开机启动
	# sudo systemctl enable ceph-fuse.target  #设置ceph-fuse服务开机启动
	sudo umount /mnt/ceph_fuse
	```
1. ## 使用 fstab 使 CephFS 挂载开机启动
	```
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
	```

1. ## CephFS 的 Cient 权限
	```
	#在服务端admin节点执行
	#ceph fs authorize *filesystem_name* client.*client_name* /*specified_directory* rw
	ceph fs authorize cephfs client.foo / r /bar rw  # 为 foo 客户端设置对 /bar 目录的 rw 权限，对/ 目录的r 权限，并生成密钥环

	client quota df = true  #设置客户端只能查看被限额的容量

	#在 Client 执行
	#Specify a path
	sudo scp cephuser@micros-k8s-6:/etc/ceph/ceph.conf /etc/ceph/ceph.conf 
	sudo scp cephuser@micros-k8s-6:/etc/ceph/client.foo.keyring /etc/ceph/client.foo.keyring 
	sudo mkdir /mnt/ceph_fuse_bar
	sudo chown cephuser: /mnt/ceph_fuse_bar

	sudo ceph-fuse -n client.foo /mnt/ceph_fuse_bar -r /bar   #只能挂载 Client 有权限的目录 
	```

1. ## CephFS 的资源配额
	```
	setfattr -n ceph.quota.max_bytes -v 9000000 /mnt/ceph_fuse_bar   # set space to 100 MB
	setfattr -n ceph.quota.max_files -v 10000 /mnt/ceph_fuse_bar  # set files number to 10,000 files

	getfattr -n ceph.quota.max_bytes /mnt/ceph_fuse_bar    # get attributes:ceph.quota.max_bytes
	getfattr -n ceph.quota.max_files /mnt/ceph_fuse_bar    # get attributes:ceph.quota.max_files

	setfattr -n ceph.quota.max_bytes -v 0 /mnt/ceph_fuse_bar  # remove attributes:ceph.quota.max_bytes
	setfattr -n ceph.quota.max_files -v 0 /mnt/ceph_fuse_bar  # remove attributes:ceph.quota.max_files

	sudo umount /mnt/ceph_fuse_bar
	```

CephFS 允许给系统内的任意目录设置配额，这个配额可以限制目录树中这一点以下的字节数或者文件数。

局限性
 - 配额是合作性的、非对抗性的。 CephFS 的配额功能依赖于挂载它的客户端的合作，在达到上限时要停止写入；无法阻止篡改过的或者对抗性的客户端，它们可以想写多少就写多少。在客户端完全不可信时，用配额防止多占空间是靠不住的。
 - 配额是不准确的。 在达到配额限制一小段时间后，正在写入文件系统的进程才会被停止。很难避免它们超过配置的限额、多写入一些数据。会超过配额多大幅度主要取决于时间长短，而非数据量。一般来说，超出配置的限额之后 10 秒内，写入会被停掉。
 - 内核客户端的配额功能需要操作系统内核版本在4.17以上。 用户空间客户端（ libcephfs 、 ceph-fuse ）已经支持配额了。
 - 基于路径限制挂载时必须谨慎地配置配额。 客户端必须能够访问配置了配额的那个目录的索引节点，这样才能执行配额管理。如果某一客户端被 MDS 能力限制成了只能访问一个特定路径（如 /home/user ），并且它们无权访问配置了配额的父目录（如 /home ），这个客户端就不会按配额执行。所以，基于路径做访问控制时，最好在限制了客户端的那个目录（如 /home/user ）、或者它下面的子目录上配置配额。

与通用文件系统quota对比
 - CephFS quota是针对目录的，可限制目录下存放的文件数量和容量
 - CephFS没有一个统一的UID/GID机制，传统的基于用户和组的配额管理机制很难使用
 - CephFS一般与应用配合使用，应用自己记录用户信息，将用户关联到对应的CephFS目录


> **多租户配额实现思路**
>  1. 使用 setfattr 在文件夹上做限额配置[[引用]](http://docs.ceph.com/docs/mimic/cephfs/quota/)，这种配额管理不是严格的。
>  1. 建立 CephFS 文件系统时，为每个 Client 设置单独的数据池，并指定数据池的大小，这个配额限制更加严格。

# 二. CephFS应用场景
1. ## 提供可靠、稳定、方便的网络数据存储

1. ## 为kubernetes提供pv后端存储
1. ## 在应用级别实现配额管理


# 参考
1. CephFS quota的支持 . https://blog.csdn.net/younger_china/article/details/78163279
1. Kubernetes添加带Quota限额的CephFS StorageClass . https://www.cnblogs.com/ltxdzh/p/9173706.html
1. QUOTAS . http://docs.ceph.com/docs/mimic/cephfs/quota/
1. Ceph 分布式存储实战