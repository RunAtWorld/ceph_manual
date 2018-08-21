sudo cat >/etc/hosts <<EOM
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

#将这里的Hots换成自己的
172.31.39.148 micros-k8s-1 aa
172.31.22.118 micros-k8s-2 bb
172.31.25.125 micros-k8s-3 cc
172.31.21.32 micros-k8s-5 dd
172.31.33.109 micros-k8s-6 ee
EOM
