# Ceph 常见问题列表
1. **Ceph 安装源下载慢？**   
答： 下载rpm包，自建一个临时的Ceph镜像源或者将Ceph安装包后，使用 `yum localinstall {rpm包命}` 安装

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

1. **运行启动服务的时候显示警告 "warning: unable to create /var/run/ceph: (13) Permission denied"**
安装过程顺利，运行启动服务的时候显示警告
```
	Started Ceph cluster monitor daemon.
	warning: unable to create /var/run/ceph: (13) Permission denied	
```
尝试运行  
```
	chmod 775 -R /var/run/
```
再起重启服务时，没有权限报警，但是当服务器重启后，这个告警依旧还是会出现
答： 更改 `ceph-mon@.service` 文件，把启动用户更改为root

1. **运行 ceph -s 命令，集群无响应?**    
答：ceph -s 阻塞了，可能此时 monitors 全部都 down 掉了或只有部分在运行（但数量不足以形成法定人数）。

1. **恢复 Monitor 损坏的 monmap?**
monmap 通常看起来是下面这样：
```
epoch 3
fsid 5c4e9d53-e2e1-478a-8061-f543f8be4cf8
last_changed 2013-10-30 04:12:01.945629
created 2013-10-29 14:14:41.914786
0: 127.0.0.1:6789/0 mon.a
1: 127.0.0.1:6790/0 mon.b
2: 127.0.0.1:6795/0 mon.c
```
答：   
方法1：只有在确定不会丢失保存在该 monitor 上的数据时，才能够采用这个方法。也就是说，集群中还有其他运行正常的 monitors，以便新 monitor 可以和其他 monitors 达到同步。请谨记，销毁一个 monitor 时，如果没有其上数据的备份，可能会丢失数据。   
方法2：给 monitor 手动注入 monmap。这通常最安全的做法。应该从剩余的 monitor 中抓取 monmap，然后手动注入 monmap 有问题的 monitor 节点。基本步骤：  
1、是否已形成法定人数？如果是，从法定人数中抓取 monmap ：
```
ceph mon getmap -o /tmp/monmap
```
2、没有形成法定人数？直接从其他 monitor 节点上抓取 monmap （这里假定你抓取 monmap 的 monitor 的 id 是 ID-FOO 并且守护进程已经停止运行）：
```
ceph-mon -i ID-FOO --extract-monmap /tmp/monmap
```
3、停止你想要往其中注入 monmap 的 monitor。
4、注入 monmap 。
```
ceph-mon -i ID --inject-monmap /tmp/monmap
```
5、启动 monitor 。    
注意：能够注入 monmap 是一个很强大的特性，如果滥用可能会对 monitor 造成大破坏，因为这样做会覆盖 monitor 持有的最新 monmap 。

1. **客户端无法连接或挂载?**     
检查 IP 过滤表。某些操作系统安装工具会给 iptables 增加一条 REJECT 规则。这条规则会拒绝所有尝试连接该主机的客户端（除了 ssh ）。如果 monitor 主机设置了这条防火墙 REJECT 规则，客户端从其他节点连接过来时就会超时失败。需要定位出拒绝客户端连接 Ceph 守护进程的那条 iptables 规则。比如，需要对类似于下面的这条规则进行适当处理：
```
REJECT all -- anywhere anywhere reject-with icmp-host-prohibited
```
还需要给 Ceph 主机的 IP 过滤表增加规则，以确保客户端可以访问 Ceph monitor （默认端口 6789 ）和 Ceph OSD （默认 6800 ~ 7300 ）的相关端口。
```
iptables -A INPUT -m multiport -p tcp -s {ip-address}/{netmask} --dports 6789,6800:7300 -j ACCEPT
```
或者，如果环境允许，也可以直接关闭主机的防火墙。

1. **单台 Ceph 节点宕机如何处理？**   
答：   
(1)单台 Ceph 节点宕机处理  
登陆 ceph monitor 节点，查询 ceph 状态：
```
ceph health detail
```
将故障节点上的所有 osd 设置成 out，该步骤会触发数据 recovery, 需要等待数据迁移完成, 同时观察虚拟机是否正常：
```
ceph osd out osd_id
```
从 crushmap 将 osd 移除，该步骤会触发数据 reblance，等待数据迁移完成，同时观察虚拟机是否正常：
```
ceph osd crush remove osd_name
```

	删除 osd 的认证： `ceph auth del osd_name`   
	删除 osd ：`ceph osd rm osd_id`    
(2)恢复后检查步骤：
	检查 ceph 集群状态正常；=>
	检查虚拟机状态正常；=>
	检查虚拟机业务是否正常；=>
	检查平台服务正常：nova、cinder、glance；=>
	创建新卷正常；=>
	创建虚拟机正常。

1. **全局Ceph节点宕机如何处理？**   
答：全部节点断电，造成 Ceph 存储集群全局宕机，可以按照本节所示流程进行 Ceph 集群上电恢复操作。   
(1) 手动上电执行步骤
如为 Ceph 集群上电，monitor server 应最先上电；集群上电前确认使用 Ceph 之前端作业服务已停止。
使用 IPMI 或于设备前手动进行上电。
确认 NTP 服务及系统时间已同步，命令如下：
```
ps-ef | grep ntp
date
ntpq -p
```
登入上电之 ceph server 确认 ceph service 已正常运行，命令如下：
```
ps -ef | grep ceph
```
登入集群 monitor server 查看状态，OSD 全都 up 集群仍为 noout flag(s) set
```
ceph -s
ceph osd tree
```
登入 monitor server 解除 stopping w/out rebalancing，命令如下：
```
ceph osd unset noout
ceph -w
```
使用 ceph-w 可查看集群运作输出，同步完毕后集群 health 应为HEALTH_OK 状态。
(2) 恢复后检查步骤
确认设备上电状态，以 IPMI 或 于设备前确认电源为开启上电状态。
ping ceph monitor server，检查 monitor server 可以 ping 通。
系统时间和校时服务器时间同步。
```
ceph -s 状态为HEALTH_OK
ceph osd tree OSD 状态皆为UP
```
(3) 恢复使用指令及其说明
```
ceph -s ： 确认 ceph cluster status
ceph -w ： 查看集群运作输出
ceph osd tree ： 查看ceph cluster上osd排列及状态
start ceph-all ： 启动 所有 ceph service
start ceph-osd-all ： 启动 所有 osd service
start ceph-mon-all ： 启动 所有 mon service
start ceph-osd id={id} ： 启动指定 osd id service
start ceph-mon id={hostname} ： 启动指定 ceph monitor host
ceph osd set noout ： ceph stopping w/out rebalancing
ceph osd unset noout ： 解除ceph stopping w/out rebalancing
```

1. **如何备份Monitor 的数据?**   
答：每个 MON 的数据都是保存在数据库内的，这个数据库位于 /var/lib/ceph/mon/$cluster-$hostname/store.db ，这里的 $cluster 是集群的名字， $hostname 为主机名，MON 的所有数据即目录 /var/lib/ceph/mon/$cluster-$hostname/ ，备份好这个目录之后，就可以在任一主机上恢复 MON 了。
基本思路就是，停止一个 MON，然后将这个 MON 的数据库压缩保存到其他路径，再开启 MON。文中提到了之所以要停止 MON 是要保证 levelDB 数据库的完整性。然后可以做个定时任务一天或者一周备份一次。
另外最好把 /etc/ceph/ 目录也备份一下。
这个备份路径最好是放到其他节点上，不要保存到本地，因为一般 MON 节点要坏就坏一台机器。备份方法：
```
service ceph stop mon
tar czf /var/backups/ceph-mon-backup_$(date +'%a').tar.gz /var/lib/ceph/mon
service ceph start mon
#for safety, copy it to other nodes
scp /var/backups/* someNode:/backup/
```
1. **Monitor 的恢复?**    
假如有一个 Ceph 集群，包含 3 个 monitors： ceph-1 、ceph-2 和 ceph-3 。
```
[root@ceph-1 cluster]# ceph -s
    cluster 844daf70-cdbc-4954-b6c5-f460d25072e0
      health HEALTH_OK
      monmap e2: 3 mons at {ceph-1=192.168.56.101:6789/0,ceph-2=192.168.56.102:6789/0,ceph-3=192.168.56.103:6789/0}
            election epoch 8, quorum 0,1,2 ceph-1,ceph-2,ceph-3
      osdmap e13: 3 osds: 3 up, 3 in
        pgmap v20: 64 pgs, 1 pools, 0 bytes data, 0 objects
            101 MB used, 6125 GB / 6125 GB avail
                    64 active+clean
```
	答：
	假设发生了某种故障，导致这 3 台 MON 节点全都无法启动，这时 Ceph 集群也将变得不可用。可以通过前面备份的数据库文件来恢复 MON。当某个集群的所有的 MON 节点都挂掉之后，我们可以将最新的备份的数据库解压到其他任意一个节点上，新建 monmap，注入，启动 MON，推送 config，重启 OSD就好了。
	将 ceph-1 的 `/var/lib/ceph/mon/ceph-ceph-1/` 目录的文件拷贝到新节点 ceph-4 的 `/var/lib/ceph/mon/ceph-ceph-4/` 目录下（或者从备份路径拷贝到 ceph-4 节点），一定要注意目录的名称！这里 ceph-1 的 IP 为 172.23.0.101， ceph-4 的 IP 为 192.168.56.104 。ceph-4 节点为一个只安装了 ceph 程序的干净节点。注意下面指令执行的节点。
	```
	[root@ceph-1 ~]# ip a |grep 172
	    inet 172.23.0.101/24 brd 172.23.0.255 scope global enp0s8
	[root@ceph-1 ~]# ping ceph-4
	PING ceph-4 (192.168.56.104) 56(84) bytes of data.
	64 bytes from ceph-4 (192.168.56.104): icmp_seq=1 ttl=63 time=0.463 ms

	[root@ceph-4 ~]# mkdir /var/lib/ceph/mon/ceph-ceph-4
	[root@ceph-1 ~]# scp -r /var/lib/ceph/mon/ceph-ceph-1/*  ceph-4:/var/lib/ceph/mon/ceph-ceph-4/
	done                                                             100%    0     0.0KB/s   00:00    
	keyring                                                          100%   77     0.1KB/s   00:00    
	LOCK                                                             100%    0     0.0KB/s   00:00    
	LOG                                                              100%   21KB  20.6KB/s   00:00    
	161556.ldb                                                       100% 2098KB   2.1MB/s   00:00    
	......
	MANIFEST-161585                                                  100%  709     0.7KB/s   00:00    
	CURRENT                                                          100%   16     0.0KB/s   00:00    
	sysvinit                                                         100%    0     0.0KB/s   00:00    
	```

	同时，将 /etc/ceph 目录文件也拷贝到 ceph-4 节点，然后将 ceph.conf 中的 mon_initial_members 修改为 ceph-4。
	```
	[root@ceph-1 ~]# scp /etc/ceph/* ceph-4:/etc/ceph/
	ceph.client.admin.keyring                                                         100%   63     0.1KB/s   00:00    
	ceph.conf                                                                         100%  236     0.2KB/s   00:00  

	[root@ceph-4 ~]# vim /etc/ceph/ceph.conf 
	[root@ceph-4 ~]# cat /etc/ceph/ceph.conf 
	[global]
	fsid = 844daf70-cdbc-4954-b6c5-f460d25072e0
	mon_initial_members = ceph-4
	mon_host = 192.168.56.104
	```

	新建一个 monmap，使用原来集群的 fsid，并且将 ceph-4 加入到这个 monmap，然后将 monmap 注入到 ceph-4 的 MON 数据库中，最后启动 ceph-4 上的 MON 进程。

	```
	[root@ceph-4 ~]# monmaptool --create --fsid 844daf70-cdbc-4954-b6c5-f460d25072e0 --add ceph-4 192.168.56.104 /tmp/monmap 
	[root@ceph-4 ~]# ceph-mon -i ceph-4 --inject-monmap /tmp/monmap 
	[root@ceph-4 ~]# ceph-mon -i ceph-4
	[root@ceph-4 ~]# ceph -s
	    cluster 844daf70-cdbc-4954-b6c5-f460d25072e0
	      health HEALTH_ERR
	            64 pgs are stuck inactive for more than 300 seconds
	            64 pgs degraded
	            64 pgs stuck inactive
	            64 pgs undersized
	      monmap e6: 1 mons at {ceph-4=192.168.56.104:6789/0}
	            election epoch 13, quorum 0 ceph-4
	      osdmap e36: 3 osds: 1 up, 1 in
	        pgmap v58: 64 pgs, 1 pools, 0 bytes data, 0 objects
	            34296 kB used, 2041 GB / 2041 GB avail
	                    64 undersized+degraded+peered
	```
	好消息是，ceph -s 有了正确的输出，坏消息就是 HEALTH_ERR 了。不过不用担心，这时候将 ceph-4 的 ceph.conf 推送到其他所有节点上，再重启 OSD 集群就可以恢复正常了。

1. **如何调整pg数量？**    
答：   
(1)计算合适的pg数   
关于pg数值的合理值的计算参考 http://ceph.com/pgcalc/ 。但是在真正还是调整pg前，要确保集群状态是健康的。   
(2)调整前确保状态ok    
如果 ceph -s 命令显示的集群状态是OK的，此时就可以动态的增大pg的值。    
注意： 增大pg有几个步骤，同时必须比较平滑的增大，不能一次性调的太猛。对于生产环境格外注意。
**一次性的将pg调到一个很大的值会导致集群大规模的数据平衡，因而可能导致集群出现问题而临时不可用。**    
(3)调整数据同步参数，减少数据同步时对业务的影响    
当调整 PG/PGP 的值时，会引发ceph集群的 backfill 操作，数据会以最快的数据进行平衡，因此可能导致集群不稳定。 因此首先设置 backfill ratio 到一个比较小的值，通过下面的命令设置：
```
ceph tell osd.* injectargs '--osd-max-backfills 1'
ceph tell osd.* injectargs '--osd-recovery-max-active 1'
```
还包括下面这些：
```
osd_backfill_scan_min = 4 
osd_backfill_scan_max = 32 
osd recovery threads = 1 
osd recovery op priority = 1 
```
(4)调整pg
先增长pg的值，我们推荐的增长幅度是按照 2的幂进行增长，如原来是 64个，第一次调整先增加到128个， 设置命令如下：
```
ceph osd pool set <poolname> pg_num <new_pgnum>
```
通过 ceph -w 查看集群的变化。
5.等到状态再次恢复正常再调整pgp
在pg增长之后，通过下面的命令增加pgp，pgp的值需要与pg的值一致：
```
ceph osd pool set <poolname> pgp_num <new_pgnum>
```
此时，通过 ceph -w 可以看到集群状态的详细信息，可以看到数据的再平衡过程。