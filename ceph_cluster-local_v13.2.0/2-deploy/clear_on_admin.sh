#!/bin/bash
ceph-deploy purge ceph190 ceph191 ceph192 ceph185
ceph-deploy purgedata ceph190 ceph191 ceph192  ceph185
ceph-deploy forgetkeys
rm -rf ceph.*