#!/bin/bash
hosts=$@
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 644 ~/.ssh/authorized_keys
#在admin节点上设置ssh登录信息
rm -rf ~/.ssh/config
for h in $hosts; do
    printf "Host $h\n\tHostname  $h\n\tUser root\n" >> ~/.ssh/config  #向~/.ssh/config集群主机密钥配置
    #拷贝ceph-rc-1的密钥到其他节点，如果使用的是非root用户，在操作过程中，当需要root权限时会提示输入用户密码，这里使用root用户
    sshpass -p 'micros_ceph' ssh-copy-id -i ~/.ssh/id_rsa.pub root@$h #向其他主机传输密钥
done 
chmod 644 ~/.ssh/config

#测试是否可无密钥登录
# ssh ceph@ceph-rc-1
# ssh ceph@ceph-rc-2
# ssh ceph@ceph-rc-3

exit 0