#!/bin/bash
ceph-deploy purge micros-k8s-6 micros-k8s-3 micros-k8s-5
sudo ceph-deploy purgedata micros-k8s-6 micros-k8s-3 micros-k8s-5
sudo ceph-deploy forgetkeys
sudo rm -rf ceph.*
sudo rm -rf /etc/ceph/*
