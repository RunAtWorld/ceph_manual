#!/bin/bash
hosts=$@ #部署osd服务
counter=0
for host_elem in $hosts; do
	counter=0
	echo "----$host_elem---"
	# sudo ceph-deploy disk list $host_elem #查看HOST上有哪些Disk
	for blk in $(ssh ${host_elem} lsblk -l | awk '{if($6=="disk") print $1}');do #判断是否为硬盘类型
		((counter++))
		if [ $counter -eq 1 ];then  #主硬盘不操作
			continue
		fi
		echo $blk
		{
			ceph-deploy disk zap $host_elem /dev/$blk #清空Disk,注意只能是未使用的Disk  如果报错应使用 wipefs --all /dev/xvdb
			# ceph-deploy osd create --data /dev/$blk $host_elem
			#初始化集群信息
			if [ -d /etc/ceph ];then
			    echo "/etc/ceph exist"
			    ceph-deploy --overwrite-conf osd create --data /dev/$blk $host_elem	
			else
			    ceph-deploy osd create --data /dev/$blk $host_elem			
			fi
		}&
	done
	wait
done
unset counter

exit 0

#部署monitor服务
# ceph-deploy mon create ceph-rc-1
# ceph-deploy mon add ceph-rc-2 
# ceph-deploy mon add ceph-rc-3