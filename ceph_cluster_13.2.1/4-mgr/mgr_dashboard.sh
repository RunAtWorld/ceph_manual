#!/bin/bash
ceph mgr module enable dashboard
ceph dashboard create-self-signed-cert

# ceph config set mgr mgr/dashboard/server_addr $IP
ceph config set mgr mgr/dashboard/server_port 8092

# ceph mgr fail mgr
ceph mgr module disable dashboard
ceph mgr module enable dashboard
ceph dashboard set-login-credentials ceph admin