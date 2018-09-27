#!/bin/bash
#Locate an Object
echo 'Test-data' > testfile.txt
ceph osd pool create mytest 8 8
rados put test-object-1 testfile.txt --pool=mytest

rados -p mytest ls
rados get test-object-1 download.txt --pool=mytest

#identify the object location:
# ceph osd map {pool-name} {object-name}
ceph osd map mytest test-object-1

# remove the test object
rados rm test-object-1 --pool=mytest
# delete the mytest pool
ceph osd pool rm mytest