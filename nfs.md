
生产环境：

服务端：

1.两个主要的程序：portmap、nfs-utils

2.网络访问正常，假设IP地址192.168.1.98/24

客户端：

1.主要的程序：portmap

2.网络访问正常，假设IP地址192.168.1.99/24



配置过程：

服务端：

1.检查portmap和nfs-utils是否安装

#rmp -aq portmap nfs-utils

2.首先启动portmap服务，然后启动nfs服务 ，一般情况下设置开机自动启动

#/etc/rc.d/init.d/portmap start  (or:#service portmap start)

#/etc/rc.d/init.d/nfs start   (or:#service nfs start)

#chkconfig portmap on

#chkconfig nfs on

3.建立共享文件目录/tmp/serverdir，修改满足最大需求的最小权限

#mkdir -p /tmp/serverdir

4.nfs配置文件/etc/exports，设定满足最大需求的最小权限

#vi /etc/exports

添加一段内容：

格式：共享目录绝对路径 共享给那些主机(设定的权限)

eg：##将/tmp/serverdir共享给192.168.1.0/24这个网段的主机可读写、同步写到磁盘、默认的匿名访问

/tmp/serverdir 192.168.1.0/24(rm,sync)

5.让配置文件/etc/exports生效方法：

方法1.#exportfs -rv (推荐使用)

方法2.#/etc/rc.d/init.d/nfs reload   (or:#service nfs reload) (推荐使用)

方法3.#/etc/rc.d/init.d/nfs restart   (or:#service nfs restart) (不推荐使用)



客户端：

1.检查portmap是否安装

#rmp -aq portmap 

2.启动portmap服务，一般情况下设置开机自动启动

#/etc/rc.d/init.d/portmap start  (or:#service portmap start)

#chkconfig portmap on

3.建立挂载目录/tmp/clientdir，修改满足最大需求的最小权限

#mkdir -p /tmp/clientdir

4.使用/usr/bin/showmount -e 服务器的IP地址，查看服务器机导出的所有远程目录的列表

#/usr/bin/showmount -e 192.168.1.98

5.使用/bin/mount挂载服务器共享的目录到本地/tmp/clientdir目录

#/bin/mount -t nfs 192.168.1.98:/tmp/serverdir /tmp/clientdir

6.挂载后情况使用命令dh -h查看挂载的情况

#df -h



NFS文件系统的优缺点：
优点：
1.简单：配置简单，容易上手掌握
2.方便：部署非常快速，维护简单
3.可靠：在软件层面上看，数据比较可靠，经久耐用

缺点：
a.容易发生单点故障，及server机宕机了所有客户端都不能访问
b.在高并发下NFS效率/性能有限
c.客户端没用用户认证机制，且数据是通过明文传送，安全性一般（一般建议在局域网内使用）
d.NFS的数据是明文的，对数据完整性不做验证
e.多台机器挂载NFS服务器时，连接管理维护麻烦

# 参考
http://blog.51cto.com/crazyday/1705176