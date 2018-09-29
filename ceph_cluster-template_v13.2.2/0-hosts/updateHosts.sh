sed -i '3,$d' /etc/hosts
cat >>/etc/hosts <<EOM
172.31.18.88 ceph-rc-1 ec2-52-82-29-154.cn-northwest-1.compute.amazonaws.com.cn
172.31.17.193 ceph-rc-2 ec2-52-82-17-117.cn-northwest-1.compute.amazonaws.com.cn
172.31.20.221 ceph-rc-3 ec2-52-82-7-113.cn-northwest-1.compute.amazonaws.com.cn
EOM
cat /etc/hosts
