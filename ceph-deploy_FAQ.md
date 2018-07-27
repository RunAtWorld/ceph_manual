# Ceph FAQ 
`以 ceph mimic(ceph v13.2.0),ceph-deploy v1.5.39为例([官方手册请看：https://github.com/ceph/ceph/blob/mimic/doc/](https://github.com/ceph/ceph/tree/mimic/doc))`
## 1 ceph-deploy配置文件
### 1.1 节点
1. ceph启动时，会配置初始 monitor(s)、并收集所有密钥。将在以下文件目录写入初始化的配置文件（**如果不存在的话，写入；如果存在，则以这些配置文件的配置启动Ceph集群**） ： `/var/lib/ceph` 。
这些文件在管理节点上执行命令  `$ ceph-deploy mon create-initial`  时产生：

	>	
		.
		├── bootstrap-mds
		│   └── ceph.keyring
		├── bootstrap-mgr
		│   └── ceph.keyring
		├── bootstrap-osd
		├── bootstrap-rbd
		├── bootstrap-rgw
		│   └── ceph.keyring
		├── mds
		│   └── ceph-ceph190
		│       ├── done
		│       ├── keyring
		│       └── systemd
		├── mgr
		│   └── ceph-ceph190
		│       ├── done
		│       ├── keyring
		│       └── systemd
		├── mon
		│   └── ceph-ceph190
		│       ├── done
		│       ├── keyring
		│       ├── kv_backend
		│       ├── store.db
		│       │   ├── 000568.log
		│       │   ├── 000570.sst
		│       │   ├── CURRENT
		│       │   ├── IDENTITY
		│       │   ├── LOCK
		│       │   ├── MANIFEST-000564
		│       │   ├── OPTIONS-000552
		│       │   └── OPTIONS-000567
		│       └── systemd
		├── osd
		├── radosgw
		│   └── ceph-rgw.ceph190
		│       ├── done
		│       ├── keyring
		│       └── systemd
		└── tmp
    >	

1. 用 ceph-deploy 把配置文件和 admin 密钥拷贝到管理节点和 Ceph 节点时，将在目录 ： `/etc/ceph` 产生ceph全局配置文件。这些文件在在管理节点执行命令  `$ ceph-deploy admin {admin-node} {node-1} {node-2}`  执行时产生：
	- ceph.client.admin.keyring  

		>	
			[client.admin]
	        key = AQDkW1lbw/F9NRAA3BhG907qFryTBqwsMcN/wg==
	        caps mds = "allow *"
	        caps mgr = "allow *"
	        caps mon = "allow *"
	        caps osd = "allow *"
	    >

	- ceph.conf

		>	
			[global]
			fsid = b7645a36-edf2-4849-a8e6-db6dbabeecca
			mon_initial_members = k8s001
			mon_host = 10.27.20.7
			auth_cluster_required = cephx
			auth_service_required = cephx
			auth_client_required = cephx
			osd pool default size = 2
			public network =  10.27.20.7/24
			[client]
			rgw frontends = civetweb port=7480
	    >

	- rbdmap

		>	
			# RbdDevice             Parameters
			#poolname/imagename     id=client,keyring=/etc/ceph/ceph.client.keyring
	    >	

1. ceph 会将主要的执行文件放在 `/usr/bin/` 和  `/usr/sbin/` 中。    
	`/usr/bin/` 有：

	>	
		ceph                 ceph-clsinfo   ceph-deploy       cephfs-journal-tool  ceph-mds  ceph-monstore-tool     ceph-osdomap-tool  ceph-run
		ceph-authtool        ceph-conf      ceph-detect-init  cephfs-table-tool    ceph-mgr  ceph-objectstore-tool  ceph-post-file     ceph-syn
		ceph-bluestore-tool  ceph-dencoder  cephfs-data-scan  ceph-kvstore-tool    ceph-mon  ceph-osd               ceph-rbdnamer
    >

	`/usr/sbin/` 有:

	>	
		ceph-create-keys  ceph-disk  ceph-volume  ceph-volume-systemd
    >
       
1. ceph日志文件在各节点的目录 ： `/var/log/ceph` , 目录下主要有

	- ceph.audit.log              
	- ceph.log             
	- ceph-mgr.k8s001.log  
	- ceph-mon.k8s001.log-20180726.gz  
	- ceph-volume.log
	- ceph-client.rgw.k8s001.log  
	- ceph-mds.k8s001.log  
	- ceph-mon.k8s001.log  
	- ceph-osd.1.log

## 2 组件相关配置
### 2.1 osd
在节点ceph191，节点ceph192上添加两个 OSD 

	```
	ssh ceph191 sudo mkdir -p /data/osd-1 && ssh ceph191 sudo chown ceph: /data/osd-1
	ssh ceph192 sudo mkdir -p /data/osd-2 && ssh ceph192 sudo chown ceph: /data/osd-2
	ceph-deploy --overwrite-conf osd prepare ceph191:/data/osd-1 ceph192:/data/osd-2
	ceph-deploy osd activate ceph191:/data/osd-1 ceph192:/data/osd-2
	```
以上明亮将在 节点ceph191 上创建目录 `/data/osd-1` 和 节点ceph192 上创建目录 `/data/osd-2` 并将产生相关文件：

>	
	.
	├── activate.monmap
	├── active
	├── block
	├── bluefs
	├── ceph_fsid
	├── fsid
	├── keyring
	├── kv_backend
	├── magic
	├── mkfs_done
	├── ready
	├── systemd
	├── type
	└── whoami
>

### 2.2 ceph-mgr
1. **配置文件**  
	- mgr module 默认路径为 `<library dir>/mgr`  
	- mgr data 的默认路径为 `/var/lib/ceph/mgr/ceph-{mgr_node_hostname}` 下面，主要的文件有：
		- keyring  

			>	
				[mgr.k8s001]
				        key = AQD9W1lbl1QBOBAAVgPafomuYNZvaGGyaocxmw==
		    >

		- done 
		- systemd

	- mgr tick period ： 每隔多少秒和监视器通信一次  
	- mon mgr beacon grace : 持续多少秒无响应认为当前 mgr 死掉  

2. **常用命令**  
`ceph mgr module ls`  查看哪些模块是可用的，哪些模块是启用的，哪些模块是未启用的。  
`ceph mgr module enable {module-name}`  启用模块    
`ceph mgr module disable {module-name}` 禁用模块   
`ceph mgr services`  查看模块提供的服务  

	>	
		$ ceph mgr module ls
		{
		        "enabled_modules": [
		                "restful",
		                "status"
		        ],
		        "disabled_modules": [
		                "dashboard"
		        ]
		}
	>	
		$ ceph mgr module enable dashboard
		$ ceph mgr module ls
		{
		        "enabled_modules": [
		                "restful",
		                "status",
		                "dashboard"
		        ],
		        "disabled_modules": [
		        ]
		}
	>	
		$ ceph mgr services
		{
		        "dashboard": "http://myserver.com:7789/",
		        "restful": "https://myserver.com:8789/"
		}
    >

	注：集群启动前，可以将下面的配置写入ceph.conf, 使用 mgr_initial_modules 配置程序来完成集群启动，使得集群启动时启用某些 ceph-mgr 的模块。
		
	>	
		[mon]
		    mgr initial modules = dashboard balancer
    >
