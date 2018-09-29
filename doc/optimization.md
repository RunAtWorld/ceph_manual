# Ceph集群的性能调优参数
集群范围内的配置参数定义在Ceph的配置文件中，缺省的配置文件是ceph.conf，放在/etc/ceph目录下。这个配置文件有一个global部分和若干个服务类型部分。任何时候一个Ceph服务启动，都会应用[gloabl]部分，以及进程特定部分的配置。一个Ceph配置文件有多个部分:    
```
[global]
	fsid = 2402e2aa-2bff-48e1-926e-39f5df911d86
	mon_initial_members = micros-k8s-6
	mon_host = 172.31.33.109
	auth_cluster_required = cephx
	auth_service_required = cephx
	auth_client_required = cephx

	osd pool default size = 2
	public network = 172.31.33.109/16

[osd]
	osd 
	debug ms = 1
[osd.1]
	host = delta

[mon]
[mon.alpha]
	host = alpha
	mon addr = 172.31.33.109:6789

[mds]
[mds.alpha]
	host = alpha

[client]
	rbd cache = true
[client.radosgw.gateway]
	rgw frontends = civetweb port=7480
```

- Global部分：  
	global部分是以[global]关键字开始的。所有定义在下面的配置都将应用在Ceph的所有守护进程中。下面是一条定义在[global]部分中的参数例子。 
public network = 192.168.0.0/24 
- Monitor部分：  
	配置定义在[mon]部分下，应用于集群中所有Ceph monitor守护进程。定义在这个部分下的参数重载了定义在[global]下的参数。
	下面是一条常定义于[mon]部分的参数例子。 
	```
	mon initial members = ceph-mon1 
	```
- OSD 部分：配置定义在[osd]部分，应用于所有的Ceph OSD守护进程。定义在这个部分的配置重载了[global]部分的相同配置。
	下面是一条配置举例。 
	```
	osd mkfs type = xfs
	```
- MDS部分：配置定义在[mds]部分，应用于所有的Ceph MDS 守护进程。定义在这个部分的配置重载了[global]部分的相同配置。下面是一条配置举例。 
	```
	mds cache size = 250000 
	```
- Client 部分：配置定义在[client]部分下，应用于所有的Ceph客户端。定义在这个部分的配置重载了[global]部分的相同配置。下面是一条配置举例。 
	```
	rbd cache size = 67108864 
	```

## 全局集群调优
全局性参数定义在Ceph配置文件的[global]部分。 
- network：建议使用两个物理隔离的网络，分别作为Public Network（公共网络，即客户端访问网络）和Cluster Network（集群网络，即节点之间的网络）。
- Public Network：定义Public Network的语法：
	```
	Publicnetwork = {public network / netmask}
	public network = 192.168.100.0/24 
	```
- Cluster Network：定义Cluster Network的语法：
	```
	Cluster network = {cluster network / netmask}。 
	cluster network = 192.168.1.0/24 
	```
- max open files：如果这个参数被设置，那么Ceph集群启动时，就会在操作系统层面设置最大打开文件描述符。这就避免OSD进程出现与文件描述符不足的情况。参数的缺省值为0，可以设置成一个64位整数。 
	```
	max open files = 131072 
	```
- osd pool default min size：处于degraded状态的副本数。它确定了Ceph在向客户端确认写操作时，存储池中的对象必须具有的最小副本数目，缺省值为0。 
	```
	osd pool default min size = 1 
	```
- osd pool default pg和osd pool default pgp：确保集群有一个切实的PG数量。建议每个OSD的PG数目是100。使用这个公式计算PG个数：（OSD总数 * 100）／副本个数。 对于10个OSD和副本数目为3的情况，PG个数应该小于(10*100)/3 = 333。 
	```
	osd pool default pg num = 128 
	osd pool default pgp num = 128 
	```
如之前所解释的，PG和PGP的个数应该保持一致。PG和PGP的值很大程度上取决于集群大小。前面提到的这些值不会损害集群，但在采用这些值之前请慎重考虑。要知道这些参数不会改变已经存在的存储池的PG和PGP值。当你创建了一个新的存储池并没有指定PG和PGP的值时，它们才会生效。 
- osd pool default min size：这是处于degraded状态的副本数目，它应该小于osd pool default size的值，为存储池中的object设置最小副本数目来确认写操作。即使集群处于degraded状态。如果最小值不匹配，Ceph将不会确认写操作给客户端。 
	```
	osd pool default min size = 1 
	```
- osd pool default crush rule：当创建一个存储池时，缺省被使用的CRUSH ruleset。 
	```
	osd pool default crush rule = 0 
	```
- Disable In-Memory Logs：每一个Ceph子系统有自己的输出日志等级，并记录在内存中。通过给debug logging（调试日志）设置一个log文件等级和内存等级，我们可以给这些子系统设置范围在1～20的不同值，其中1是轻量级的，20是重量级的。第一个设置是日志等级，第二个配置是内存等级。必须用一个正斜杠（/）隔离他们：debug = /。 
缺省的日志级别能够满足你的集群的要求，除非你发现内存级别日志影响了性能和内存消耗。在这个例子中，你可以尝试关闭in-memory logging功能。要禁用in-memory logging的默认值，可以添加的参数如下。 
	```
	debug_lockdep = 0/0 
	debug_context = 0/0 
	debug_crush = 0/0 
	debug_buffer = 0/0 
	debug_timer = 0/0 
	debug_filer = 0/0 
	debug_objecter = 0/0 
	debug_rados = 0/0 
	debug_rbd = 0/0 
	debug_journaler = 0/0 
	debug_objectcatcher = 0/0 
	debug_client = 0/0 
	debug_osd = 0/0 
	debug_optracker = 0/0 
	debug_objclass = 0/0 
	debug_filestore = 0/0 
	debug_journal = 0/0 
	debug_ms = 0/0 
	debug_monc = 0/0 
	debug_tp = 0/0 
	debug_auth = 0/0 
	debug_finisher = 0/0 
	debug_heartbeatmap = 0/0 
	debug_perfcounter = 0/0 
	debug_asok = 0/0 
	debug_throttle = 0/0 
	debug_mon = 0/0 
	debug_paxos = 0/0 
	debug_rgw = 0/0
	```

## Monitor调优

Monitor调优参数定义在Ceph集群配置文件的[mon]部分下。 
- mon osd down out interval：指定Ceph在OSD守护进程的多少秒时间内没有响应后标记其为“down”或“out”状态。当你的OSD节点崩溃、自行重启或者有短时间的网络故障时，使用这个选项。
	```
	mon_osd_down_out_interval = 600 
	```
- mon allow pool delete：要避免Ceph 存储池的意外删除，请设置这个参数为false。当有很多管理员管理这个Ceph集群，而又不想为客户数据承担任何风险时，可以用这个参数。 
	```
	mon_allow_pool_delete = false 
	```
- mon osd min down reporters：如果Ceph OSD守护进程监控的OSD down了，它就会向MON报告；缺省值为1，表示仅报告一次。使用这个选项，可以改变Ceph OSD进程需要向Monitor报告一个down掉的OSD的最小次数。在一个大集群中，建议使用一个比缺省值大的值，3是一个不错的值。 
	```
	mon_osd_min_down_reporters = 3
	```

## OSD调优
下面的设置允许Ceph OSD进程设定文件系统类型、挂载选项，以及一些其他有用的配置。 
- osd mkfs options xfs：创建OSD的时候，Ceph将使用这些xfs选项来创建OSD的文件系统： 
	```
	osd_mkfs_options_xfs = “-f -i size=2048” 
	```
- osd mount options xfs：设置挂载文件系统到OSD的选项。当Ceph挂载一个OSD时，下面的选项将用于OSD文件系统挂载。 
	```
	osd_mount_options_xfs = "rw,noatime,inode64,logbufs=8,logbsize=256k, delaylog,allocsize=4M"
	```
- osd max write size：OSD单次写的最大大小，单位是MB。 
	```
	osd_max_write_size = 256 
	```
- osd client message size cap：内存中允许的最大客户端数据消息大小，单位是字节。 
	```
	osd_client_message_size_cap = 1073741824 
	```
- osd map dedup：删除OSD map中的重复项。 
	```
	osd_map_dedup = true 
	```
- osd op threads：服务于Ceph OSD进程操作的线程个数。设置为0可关闭它。调大该值会增加请求处理速率。 
	```
	osd_op_threads = 16 
	```
- osd disk threads：用于执行像清理（scrubbing）、快照裁剪（snap trimming）这样的后台磁盘密集性OSD操作的磁盘线程数量。 
	```
	osd_disk_threads = 1 
	```
- osd disk thread ioprio class：和osd_disk_thread_ioprio_priority一起使用。这个可调参数能够改变磁盘线程的I/O调度类型，且只工作在Linux内核CFQ调度器上。可用的值为idle、be或者rt。 
- idle：磁盘线程的优先级比OSD的其他线程低。当你想放缓一个忙于处理客户端请求的OSD上的清理（scrubbing）处理时，它是很有用的。 
- be：磁盘线程有着和OSD其他进程相同的优先级。 
	- rt：磁盘线程的优先级比OSD的其他线程高。当清理（scrubbing）被迫切需要时，须将它配置为优先于客户端操作，此时该参数是很有用的。 
		```osd_disk_thread_ioprio_class = idle ```
	- osd disk thread ioprio priority：和osd_disk_thread_ioprio_ class一起使用。这个可调参数可以改变磁盘线程的I/O调度优先级，范围从0（最高）到7（最低）。如果给定主机的所有OSD都处于优先级 idle，它们都在竞争I/O，而且没有太多操作。这个参数可以用来将一个OSD的磁盘线程优先级降为7，从而让另一个优先级为0的OSD尽可能更快地做清理（scrubbing）。和osd_disk_thread_ioprio_ class一样，它也工作在Linux内核CFQ调度器上。 
		```osd_disk_thread_ioprio_priority = 0```

### OSD日志设置 
Ceph OSD守护进程支持下列日志配置。 
- osd journal size：缺省值为0。你应该使用这个参数来设置日志大小。日志大小应该至少是预期磁盘速度和filestore最大同步时间间隔的两倍。如果使用了SSD日志，最好创建大于10GB的日志，并调大filestore的最小、最大同步时间间隔。 
	```
	osd_journal_size = 20480 
	```
- journal max write byte：单次写日志的最大比特数。 
	```
	journal_max_write_bytes = 1073714824 
	```
- journal max write entries：单次写日志的最大条目数。 
	```
	journal_max_write_entries = 10000 
	```
- journal queue max ops：给定时间里，日志队列允许的最大operation数。 
	```
	journal_queue_max_ops = 50000 
	```
- journal queue max bytes：给定时间里，日志队列允许的最大比特数。 
	```
	journal_queue_max_bytes = 10485760000 
	```
- journal dio：启用direct i/o到日志。需要将journal block align配置为true。 
	```
	journal_dio = true 
	```
- journal aio：启用libaio异步写日志。需要将journal dio配置为true。 
	```
	journal_aio = true 
	```
- journal block align：日志块写操作对齐。需要配置了dio和aio。 
	```
	journal_block_align = true
	```

### OSD filestore设置 
下面是一些OSD filestore的配置项。 
- Filestore merge threshold：将libaio用于异步写日志。需要journal dio被置为true。 
	```
	filestore_merge_threshold = 40 
	```
- Filestore spilt multiple：子目录在分裂成二级目录之前最大的文件数。 
	```
	filestore_split_multiple = 8 
	```
- Filestore op threads：并行执行的文件系统操作线程个数。 
	```
	filestore_op_threads = 32 
	```
- Filestore xattr use omap：给XATTRS（扩展属性）使用object map。在ext4文件系统中要被置为true。 
	```
	filestore_xattr_use_omap = true 
	```
- Filestore sync interval：为了创建一个一致的提交点（consistent commit point），filestore需要停止写操作来执行syncfs()，也就是从日志中同步数据到数据盘，然后清理日志。更加频繁地同步操作，可以减少存储在日志中的数据量。这种情况下，日志就能充分得到利用。配置一个越小的同步值，越有利于文件系统合并小量的写，提升性能。下面的参数定义了两次同步之间最小和最大的时间周期。 
	```
	filestore_min_sync_interval = 10 
	filestore_max_sync_interval = 15 
	```
- Filestore queue max ops：在阻塞新operation加入队列之前，filestore能接受的最大operation数。 
	```
	filestore_queue_max_ops = 2500 
	```
- Filestore queue max bytes：一个operation的最大比特数。 
	```
	filestore_queue_max_bytes = 10485760 
	```
- Filestore queue committing max ops：filestore能提交的operation的最大个数。 
	```
	filestore_queue_committing_max_ops = 5000 
	```
- Filestore queue committing max bytes：filestore能提交的operation的最大比特数。 
	```
	filestore_queue_committing_max_bytes = 10485760000
	```

### OSD Recovery设置 
如果相比数据恢复（recovery），你更加在意性能，可以使用这些配置，反之亦然。如果Ceph集群健康状态不正常，处于数据恢复状态，它就不能表现出正常性能，因为OSD正忙于数据恢复。如果你仍然想获得更好的性能，可以降低数据恢复的优先级，使数据恢复占用的OSD资源更少。如果想让OSD更快速地做恢复，从而让集群快速恢复其状态，你也可以设置以下这些值。 
- osd recovery max active：某个给定时刻，每个OSD上同时进行的所有PG的恢复操作（active recovery）的最大数量。 
	```
	osd_recovery_max_active = 1 
	```
- osd recovery max single start：和osd_recovery_max_active一起使用，要理解其含义。假设我们配置osd_recovery_max_single_start为1，osd_recovery_max_active为3，那么，这意味着OSD在某个时刻会为一个PG启动一个恢复操作，而且最多可以有三个恢复操作同时处于活动状态。 
	```
	osd_recovery_max_single_start = 1 
	```
- osd recovery op priority：用于配置恢复操作的优先级。值越小，优先级越高。 
	```
	osd_recovery_op_priority = 50 
	```
- osd recovery max chunk：数据恢复块的最大值，单位是字节。 
	```
	osd_recovery_max_chunk = 1048576 
	```
- osd recovery threads：恢复数据所需的线程数。 
	```
	osd_recovery_threads = 1
	```

### OSD backfilling（回填）设置 
OSD backfilling设置允许Ceph配置回填操作（backfilling operation）的优先级比请求读写更低。 
- osd max backfills：允许进或出单个OSD的最大backfill数。 
	```
	osd_max_backfills = 2 
	```
- osd backing scan min：每个backfill扫描的最小object数。 
	```
	osd_backfill_scan_min = 8 
	```
- osd backfill scan max：每个backfill扫描的最大object数。 
	```
	osd_backfill_scan_max = 64
	```

### OSD scrubbing（清理）设置 
OSD scrubbing对维护数据完整性来说是非常重要的，但是也会降低其性能。你可以采用以下配置来增加或减少scrubbing操作。 
- osd max scrube：一个OSD进程最大的并行scrub操作数。 
	```
	osd_max_scrubs = 1 
	```
- osd scrub sleep：两个连续的scrub之间的scrub睡眠时间，单位是秒。
	``` 
	osd_scrub_sleep = .1 
	```
- osd scrub chunk min：设置一个OSD执行scrub的数据块的最小个数。 
	```
	osd_scrub_chunk_min = 1 
	```
- osd scrub chunk max：设置一个OSD执行scrub的数据块的最大个数。 
	```
	osd_scrub_chunk_max = 5 
	```
- osd deep scrub stride：深层scrub时读大小，单位是字节。 
	```
	osd_deep_scrub_stride = 1048576 
	```
- osd scrub begin hour：scrub开始的最早时间。和osd_scrub_end_hour一起使用来定义scrub时间窗口。 
	```
	osd_scrub_begin_hour = 19 
	```
- osd scrub end hour：scrub执行的结束时间。和osd_scrub_begin_hour一起使用来定义scrub时间窗口。 
	```
	osd_scrub_end_hour = 7
	```

## 客户端（Client）调优

客户端调优参数应该定义在配置文件的[client]部分。通常[client]部分存在于客户端节点的配置文件中。 
- rbd cache：启用RBD（RAPOS Block Device）缓存。 
	```
	rbd_cache = true 
	```
- rbd cache writethrough until flush：一开始使用write-through模式，在第一次flush请求被接收后切换到writeback模式。 
	```
	rbd_cache_writethrough_until_flush = true 
	```
- rbd concurrent management：可以在rbd上执行的并发管理操作数。 
	```
	rbd_concurrent_management_ops = 10 
	```
- rbd cache size：rbd缓存大小，单位为字节。 
	```
	rbd_cache_size = 67108864 #64M 
	```
- rbd cache max dirty：缓存触发writeback时的上限字节数。配置该值要小于rbd_cache_size。 
	```
	rbd_cache_max_dirty = 50331648 #48M 
	```
- rbd cache target dirty：在缓存开始写数据到后端存储之前，脏数据大小的目标值。 
	```
	rbd_cache_target_dirty = 33554432 #32M 
	```
- rdb cache max dirty age：在writeback开始之前，脏数据在缓存中存在的秒数。 
	```
	rbd_cache_max_dirty_age = 2 
	```

# 参考
1. Ceph Cookbook 中文版