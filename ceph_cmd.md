# 1.Ceph集群运维命令
## 1.1 查看监控集群状态:
```
    ceph health   #查看集群健康状况   
    ceph status   #查看集群状态   
    ceph -s       #查看集群状态   
    ceph -w       #查看集群正在发生的事件   
    ceph osd stat  #查看OSD状态   
    ceph osd dump  #查看OSD详细信息   
    ceph osd tree  #树状OSD详细信息      
    ceph osd lspools  #查看已经存在的pools   
    ceph mon stat  #查看Monitors状态   
    ceph mon dump  #查看Monitors映射信息   
    ceph quorum_status  #查看集群法定人数状态   
    ceph mds stat  #查看MDS 服务器的状态   
    ceph df  #查看ceph存储空间   
    ceph auth list #查看ceph集群中的认证用户及相关的key   
 ```
## 1.2 pool 大概可以理解为命名空间
1. 查看

    ```
        rados df   #显示集群中pool的详细信息
        ceph osd lspools  #列出所有存储池
        ceph osd pool ls  #列出所有存储池
        ceph osd pool stats  #查看存储池状态
    ```
1. 增加删除pool

    ```
        ceph osd pool create data1 16 16  #创建一个存储池 ‘data1’,第一个 16 是 PG组数量,第二个 16 是归置组数量
        ceph osd pool delete  data1  data1  --yes-i-really-really-mean-it    #存储池的名字"data1"要重复两次确认，并跟上后缀 --yes-i-really-really-mean-it 。
                                                                #另外此步骤需要设置 mon_allow_pool_delete 为 true，可使用下面一条命令设置，然后再执行本命令即可

        ceph tell mon.\* injectargs '--mon-allow-pool-delete=true'   #设置所有的monitor允许删除 pool
    ```

1. 设置pool

    ```    
        ceph osd pool set data1 target_max_bytes 100000000000000   #设置data池的最大存储空间为100T（默认是1T)
        ceph osd pool set data1 size 3   #设置data池的副本数是3
        ceph osd pool set data1 min_size 2   #设置data池能接受写操作的最小副本为2
        ceph osd pool set data1 pg_num 32   #设置data池的pg数量，只能调大，不能调小
        ceph osd pool set data1 pgp_num 32   #设置data池的pgp数量
    ```

一些其他的命令：  
~~ceph osd pool get data pg_num  #查看data池的pg数量~~
## 1.3 Monitor
1. 查看状态  

    ```
        ceph mon stat  #查看Monitors状态  
        ceph mon dump  #查看Monitors映射信息
    ```

1. 增删节点

    ```
        ceph mon remove node1  #删除一个mon节点  
        ceph-deploy mon destroy {host-name [host-name]...}  #ceph-deploy删除mon节点  
        ceph mon add node1 node1_ip   #添加一个mon节点  
        ceph-deploy mon create {host-name [host-name]...}  #ceph-deploy添加mon节点  
    ```
>  注：mon节点的/var/lib/ceph/mon/ceph-node2/store.db文件内容一致，添加mon注意先改配置目录配置文件，再推送到所有节点  
    ` ceph-deploy --overwrite-conf config push node1 node2 node3 `

## 1.4 MDS
```
    ceph mds stat   #查看msd状态
    ceph mds dump   #msd的映射信息
    ceph mds rm 0 mds.node1   #删除一个mds节点   
    ceph-deploy mds create {host-name}[:{daemon-name}] [{host-name}[:{daemon-name}] ...]   #ceph-deploy 增加一个mds节点 
```
## 1.5 OSD
1. 查看状态  
    ```
        ceph osd stat   #查看osd状态
        ceph osd dump   #osd的映射信息
        ceph osd tree   #查看osd目录树
    ```
1. 增删节点
    ```
        ceph osd down 0   #down掉osd.0节点
        ceph osd rm 0     #集群删除一个osd硬盘

        ceph osd crush remove osd.4     #删除标记

        ceph osd getmaxosd   #查看最大osd个数
        ceph osd setmaxosd 10   #设置osd的个数

        ceph osd out osd.3      #把一个osd节点逐出集群
        ceph osd in osd.3       #把逐出的osd加入集群
        
        ceph osd pause          #暂停osd （暂停后整个集群不再接收数据）
        ceph osd unpause        #再次开启osd （开启后再次接收数据）
    ```
1. ceph-deploy 操作 OSD
    ```
        ceph-deploy disk zap {osd-server-name}:{disk-name}   #擦净磁盘
        ceph-deploy osd prepare {node-name}:{disk}[:{path/to/journal}]  #准备磁盘
        如： ceph-deploy osd prepare osdserver1:sdb:/dev/ssd1  
        ceph-deploy osd activate {node-name}:{path/to/disk}[:{path/to/journal}]  #激活磁盘
        如： ceph-deploy osd activate osdserver1:/dev/sdb1:/dev/ssd1  
    ```       
1. 其他操作
    ```
        ceph-deploy config push {host-name [host-name]...}  #把改过的配置文件分发给集群内各主机
        ceph-deploy gatherkeys host1 host2 host3   #收集密钥
        ceph-deploy admin host1 host2 host3      #将密钥环文件和配置文件拷贝到各个主机
        ceph osd getcrushmap -o MAP    #获取一个CRUSH映射
        crushtool -d MAP -o MAP.TXT    #反编译一个CRUSH映射
        crushtool -c MAP.TXT -o MAP    #编译一个CRUSH映射
        ceph osd setcrushmap -i MAP    #设置一个CRUSH映射
    ```

## 1.6 PG归置组
```
    ceph pg stat          #查看pg状态
    ceph pg dump          #查看pg组的映射信息
    ceph pg map 0.3f      #查看一个pg的map
    ceph pg  0.26 query   #查看pg详细信息
    ceph pg dump --format plain  #显示一个集群中的所有的pg统计
```
## 1.7 RADOS
1. 查看命令
    ```
        rados lspools  #查看ceph集群中有多少个pool（只是查看pool)
        rados df   #查看ceph集群中有多少个pool,并且每个pool容量及利用情况
    ```
1. 操作命令

    ```
        rados mkpool testpool   #创建一个pool,名为 testpool
        rados create test1 -p testpool   #在testpool中创建一个对象test1 (也可以不创建对象名，在上传时指定，将会自动创建)
        rados put test1 ceph.log --pool=testpool  #在testpool池中创建一个对象test1，并上传对象内容

        rados lspools  #查看池 
        rados -p testpool ls  #查看testpool池的内容 

        rados get test1 download.txt --pool=testpool  #获取testpool池的内容并存入download.txt
        tail download.txt  #本地查看内容

        rados rm test1 -p testpool   #在testpool中删除一个test1对象 
        rados -p testpool ls  #查看 test pool 中的对象(对象已被删除)
        ceph osd pool rm testpool testpool --yes-i-really-really-mean-it  #删除存储池testpool(需设置mon_allow_pool_delete为true)
    ```

## 1.8 CephFS
```
    ceph fs new <fs_name> <metadata> <data> #创建文件系统
    ceph fs ls  #列出文件
```

## 1.9 RBD
1. 查看命令
    ```
        rbd ls {poolname} -l        # 列出块设备
        rbd ls pool_name   #查看ceph中一个pool里的所有镜像
        rbd info -p {pool_name} --image {image_name}   #查看ceph pool中一个镜像的信息
        rbd info {pool_name}/{image_name}
        rbd showmapped   #查看已映射块设备
    ```
    块设备查看命令相关例子：
    ```
        rbd ls mytest -l        # 列出块设备
        rbd ls mytest   #查看ceph中一个pool里的所有镜像
        rbd info -p mytest --image test_image   #查看ceph pool中一个镜像的信息
        rbd info mytest/test_image
        rbd showmapped   #查看已映射块设备
    ```        
1. 块设备操作命令
    ```
        rbd create {image-name}  --size {megabytes}  --pool {pool-name}   #创建块设备

        rbd info mytest/test_image   #检索块信息
        rbd resize --image {image-name} --size {megabytes} --allow-shrink    #更改块大小,--allow-shrink可以允许缩容，如果不加 --allow-shrink 只能增加容量

        rbd rm {image-name}  #删除块设备

        rbd map {image-name} --pool {pool-name} --id {user-name}   #映射块设备
        rbd showmapped   #查看已映射块设备
        rbd unmap /dev/rbd/{poolname}/{imagename}   #取消映射
    ```
    > 注：块设备命令中单位为M，默认在rbd pool中  

    块设备操作命令相关例子：
    ```
        rbd create -p mytest --size 1000 test_image   #在test池中创建一个命名为test_image的1000M的镜像,默认单位是 M,可以用 M/G/T
        rbd --image test_image info --pool=mytest   #检索test_image镜像块信息
        rbd resize -p mytest --size 500 test_image --allow-shrink   #调整一个镜像的尺寸,--allow-shrink可以允许缩容
        rbd rm -p mytest  test_image   #删除 test_image 镜像
    ```    
1. 块设备快照和克隆相关命令
    ```
        rbd --pool {pool-name} snap create --snap {snap-name} {image-name}   #创建快照
        rbd snap create {pool-name}/{image-name}@{snap-name}   #创建快照

        rbd --pool {pool-name} snap rollback --snap {snap-name} {image-name}   #快照回滚
        rbd snap rollback {pool-name}/{image-name}@{snap-name}   #快照回滚

        rbd --pool {pool-name} snap purge {image-name}  #清除快照
        rbd snap purge {pool-name}/{image-name}  #清除快照

        rbd --pool {pool-name} snap rm --snap {snap-name} {image-name}  #删除快照
        rbd snap rm {pool-name}/{image-name}@{snap-name}   #删除快照

        rbd --pool {pool-name} snap ls {image-name}  #列出快照
        rbd snap ls {pool-name}/{image-name}   #列出快照

        rbd --pool {pool-name} snap protect --image {image-name} --snap {snapshot-name}  #保护快照
        rbd snap protect {pool-name}/{image-name}@{snapshot-name}  #保护快照

        rbd --pool {pool-name} snap unprotect --image {image-name} --snap {snapshot-name}   #取消保护快照
        rbd snap unprotect {pool-name}/{image-name}@{snapshot-name}   #取消保护快照

        rbd clone {pool-name}/{parent-image}@{snap-name} {pool-name}/{child-image-name}   #快照克隆

        rbd --pool {pool-name} children --image {image-name} --snap {snap-name}  #查看快照的克隆
        rbd children {pool-name}/{image-name}@{snapshot-name}   #查看快照的克隆
    ```

    快照克隆相关例子：
    ```
        rbd  snap create vms/yjk01@yjk01_s1  #创建快照
        rbd snap list  --pool vms yjk01  #列出快照
        rbd snap rollback vms/yjk01@yjk01_s1   #快照回滚 (先卸载已挂载目录)
        rbd snap rm vms/yjk01@yjk01_s2(单个)  #删除快照
        rbd snap purge vms/yjk01   #清除快照(所有)
        rbd snap protect vms/yjk01@yjk01_s1  #保护快照
        rbd snap unprotect vms/yjk01@yjk01_s1   #取消保护
        rbd clone vms/yjk01@yjk01_s3 vms/yjk01_s3_clone1   #快照克隆
        rbd children vms/yjk01@yjk01_s3   #查看克隆
    ```
    > 注：克隆只能基于快照，并且只能快照处于保护状态，而且ceph仅支持克隆format 2映像。

1. 创建块设备完整例子
    ```
    #on Admin Node
    ceph osd pool create kube2 32 32   #创建一个池
    rbd pool init kube2  #未创建块设备初始化池

    # on Client
    sudo scp root@micros-k8s-6:/etc/ceph/ceph.conf /etc/ceph/ceph.conf   #从远程复制conf文件
    sudo scp root@micros-k8s-6:/etc/ceph/ceph.client.admin.keyring /etc/ceph/ceph.client.admin.keyring  #从远程复制keyring文件
    sudo chown -R cephuser: /etc/ceph

    sudo rbd create test_image -p kube2 --size 1G  \
    --image-feature layering -m 172.31.33.109:6789 -k /etc/ceph/ceph.client.admin.keyring   #create a block device image test_image
    sudo rbd device map kube2/test_image --name client.admin -m 172.31.33.109:6789 -k /etc/ceph/ceph.client.admin.keyring  #map the image to a block device，/dev/rbd0
    sudo mkfs.ext4 -m0 /dev/rbd0   #Use the block device by creating a file system

    sudo mkdir /mnt/ceph-block-device   
    sudo mount /dev/rbd0 /mnt/ceph-block-device  
    cd /mnt/ceph-block-device
    ```