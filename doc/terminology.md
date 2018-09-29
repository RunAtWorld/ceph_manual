# 术语
## 基本概念

**RADOS** , Ceph Storage Cluster , RADOS Cluster , Reliable Autonomic Distributed Object Store : Ceph 存储集群 , RADOS 集群 , 可靠自主的分布式对象存储  
> 注：The core set of storage software which stores the user’s data (MON+OSD).

**Ceph Cluster Map** , Ceph 集群运行图 , 集群运行图
> 注：The set of maps comprising the monitor map, OSD map, PG map, MDS map and CRUSH map.

**Ceph Object Storage** , Ceph 对象存储
> 注：The object storage product service or capabilities, which consists essentially of a Ceph Storage Cluster and a Ceph Object Gateway.

**RBD** ，Ceph Block Device , Ceph 块设备
**Ceph Block Storage** , Ceph 块存储
> 注：The block storage products, service or capabilities when used in conjunction with librbd, a hypervisor such as QEMU or Xen, and a hypervisor abstraction layer such as libvirt.  

**Node**, Ceph Node,Host : Ceph 节点 ,节点 , 主机 , Ceph 系统内的任意单体机器或服务器。   
**OSD** , Object Storage Device , 对象存储设备  
> 注：A physical or logical storage unit (e.g., LUN). Sometimes, Ceph users use the term “OSD” to refer to Ceph OSD Daemon, though the proper term is “Ceph OSD”.  

**Pool** ，Pools ，存储池  
> 注：池是对象存储的逻辑部分。
**PG** , placement group :归置组  
**pgp**

## 进程
**Ceph OSD** ，Ceph OSD Daemon ， Ceph 对象存储守护进程
**MON** , Ceph Monitor , Ceph 监视器
**MDS** , the Ceph Metadata Server , Ceph 元数据服务器  
**Client** , Ceph Client , Ceph 客户端  
> 注：The collection of Ceph components which can access a Ceph Storage Cluster. These include the Ceph Object Gateway, the Ceph Block Device, the Ceph Filesystem, and their corresponding libraries, kernel modules, and FUSEs.

**RGW** , Ceph Object Gateway , RADOS Gateway , Ceph 对象网关 , RADOS 网关 , The S3/Swift gateway component of Ceph.
**Cephx** : Ceph 的认证协议， Cephx 的运行机制类似 Kerberos ，但它没有单故障点。  
**CephFS** , Ceph Filesystem , Ceph 文件系统
> 注：The POSIX filesystem components of Ceph.

## 其他术语

**CRUSH** ， CRUSH算法
> 注：Controlled Replication Under Scalable Hashing. It is the algorithm Ceph uses to compute object storage locations.

**ruleset** ，规则集
> 注：A set of CRUSH data placement rules that applies to a particular pool(s).

**Ceph Kernel Modules** , Ceph 内核模块
> 注：The collection of kernel modules which can be used to interact with the Ceph System (e.g,. ceph.ko, rbd.ko).
**Ceph Client Libraries** , Ceph 客户端库
> 注：The collection of libraries that can be used to interact with components of the Ceph System.

**Ceph Test Framework** , Teuthology , Ceph 测试框架 , 测试方法学
> 注：The collection of software that performs scripted tests on Ceph.

**Cloud Platforms** , Cloud Stacks , 云平台 , 云软件栈
> 注：Third party cloud provisioning platforms such as OpenStack, CloudStack, OpenNebula, ProxMox, etc.

## 参考
1. CEPH 术语 . http://docs.ceph.org.cn/glossary/