#!/bin/bash
#centos7 dist

#make dashboard manager module is enabled
ceph mgr module enable dashboard

#SSL/TLS Support
#generate and install a self-signed certificate
ceph dashboard create-self-signed-cert
#generate a key pair
openssl req -new -nodes -x509 \
  -subj "/O=IT/CN=ceph-mgr-dashboard" -days 3650 \
  -keyout dashboard.key -out dashboard.crt -extensions v3_ca
ceph config-key set mgr mgr/dashboard/crt -i dashboard.crt
ceph config-key set mgr mgr/dashboard/key -i dashboard.key

#bind dashboard to a TCP/IP address and TCP port
# $ ceph config set mgr mgr/dashboard/server_addr $IP
ceph config set mgr mgr/dashboard/server_port 8000

#check dashboard service
ceph mgr services
#restart the Ceph manager processes manually after changing the SSL certificate and key. 
# ceph mgr fail mgr
ceph mgr module disable dashboard
ceph mgr module enable dashboard

#set Username and password
ceph dashboard set-login-credentials cephuser admin


