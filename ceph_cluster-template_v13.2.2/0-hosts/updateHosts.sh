sed -i '3,$d' /etc/hosts
cat >>/etc/hosts <<EOM
172.31.29.178 ceph-test-1 ec2-52-82-61-224.cn-northwest-1.compute.amazonaws.com.cn
172.31.18.65 ceph-test-2 ec2-52-82-37-222.cn-northwest-1.compute.amazonaws.com.cn
172.31.30.68 ceph-test-3 ec2-52-82-41-105.cn-northwest-1.compute.amazonaws.com.cn
EOM
cat /etc/hosts
