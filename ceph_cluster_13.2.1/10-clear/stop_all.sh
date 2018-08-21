#!/bin/bash
systemctl stop ceph-mon.target
systemctl stop ceph-osd.target
systemctl stop ceph-mds.target
ps -ef | grep ceph


systemctl start ceph-mon.target
systemctl start ceph-osd.target
systemctl start ceph-mds.target
ps -ef | grep ceph