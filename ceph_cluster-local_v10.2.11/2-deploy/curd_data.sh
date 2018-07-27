#!/bin/bash
#centos7 dist
#存入/检出对象数据
#练习：定位某个对象
##作为练习，我们先创建一个对象，用 rados put 命令加上对象名、一个有数据的测试文件路径、并指定存储池。例如：
echo 'It is first demo for envision!' | tee  testfile.txt
#rados put {object-name} {file-path} --pool=data
rados put test-object-1 testfile.txt --pool=data
#为确认 Ceph 存储集群存储了此对象，可执行：
rados -p data ls

##定位对象：
#ceph osd map {pool-name} {object-name}
ceph osd map data test-object-1
##Ceph 应该会输出对象的位置，例如：
#osdmap e537 pool 'data' (0) object 'test-object-1' -> pg 0.d1743484 (0.4) -> up [1,0] acting [1,0]

##用``rados rm`` 命令可删除此测试对象，例如：
rados rm test-object-1 --pool=data