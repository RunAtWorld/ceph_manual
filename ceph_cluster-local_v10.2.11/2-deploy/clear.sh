#!/bin/bash
#创建目录
ceph-deploy purgedata ceph191 ceph192 ceph190 ceph185
ceph-deploy forgetkeys

ceph-deploy purge ceph190 ceph191 ceph192 ceph185