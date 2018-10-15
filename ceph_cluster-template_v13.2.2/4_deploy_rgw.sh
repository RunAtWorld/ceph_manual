#!/bin/bash
host_array=()
while read line
do
    host=`echo $line | awk '{print $1}'`
    host_array=("${host_array[*]}" $host)
done < name_pwd
echo "---------------hosts:${host_array[*]}-------------"
# 安装 rgw
sh ./2-deploy/rgw.sh ${host_array[1]}
if [ $? -eq 0 ];then
 echo '---------------rgw success---------------'
else
 echo 'rgw fail'
 exit 1
fi