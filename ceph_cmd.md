# 1.Ceph相关命令

## 1.1 查看监控集群状态:

    ceph health  
    ceph status   
    ceph osd stat  
    ceph osd dump  
    ceph osd tree  
	ceph osd lspools  #查看已经存在的pools
    ceph mon dump  
    ceph quorum_status  
    ceph mds stat  #查看MDS 服务器的状态
    ceph mds dump  

## 1.2 pools 大概可以理解为命名空间

    ceph osd pool get data <pg_num>  #查看data pool中的pg_num属性
    ceph osd pool create test-pool 256 256  #创建一个存储池 ‘test-pool’
    ceph fs new <fs_name> <metadata> <data> #创建文件系统
	ceph fs ls #列出文件
