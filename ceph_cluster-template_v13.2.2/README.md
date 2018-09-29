# Ceph集群自动部署脚本使用指南
## 0. 修改设定每个节点的  `/etc/hosts`
1. 如果没有除 ceph 节点外的其他节点，可修改 [`./0-hosts/updateHosts.sh`](./0-hosts/updateHosts.sh) 中的节点 主机名别名、ip、主机域名。然后在各个节点上运行 
```
sh 0_updateHosts.sh
```
2. 如果有除 ceph 节点外的其他节点，请手动修改每个主机的 `/etc/hosts` 文件,添加 ceph 集群各个节点的主机名别名、ip、主机域名

## 1. 节点环境自检与初始化
在所有节点上运行 
```
sh 1_check_node.sh
```

## 2. 部署 Ceph 集群
1. 修改 `2_install_cluster.sh` 中第2行的host数组为 ceph 集群中的主机名别名，如本模板脚本中使用的3台主机分别为`'ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3'`,则修改为
```
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')
```
2. 部署Ceph集群，在 Admin节点上执行以下代码
```
sh 2_install_cluster.sh
```
>任何一个节点都可以成为 Admin 节点，只要在上面执行了上述脚本，此节点就会成为 Admin 节点
**注：这个过程需要输入各个节点的root密码用于 Admin节点和其他节点之间的 ssh 免密钥登录**

## 3. 部署 CephFS
1. 修改 `3_deploy_cephfs.sh` 中第2行的host数组为 ceph 集群中的主机名别名，如本模板脚本中使用的3台主机分别为`'ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3'`,则修改为
```
host_array=('ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3')
```
2. 在 Admin 节点上执行以下代码，部署 CephFS
```
sh 3_deploy_cephfs.sh
```

-----
如果以上3步执行成功，集群中的部署配置为：
1. 全部节点的块设备被初始化为 osd , momitor
2. 第一个节点被部署为 mgr ,并开启 8092 端口的dashboard,登录账户为 `ceph`,密码为 `admin`
3. 集群部署了一个 CephFS 且最后一个节点被部署为 mds , 客户端为 client.foo
以本模板中的3个节点分别为 `'ceph-rc-1' 'ceph-rc-2' 'ceph-rc-3'` 为例，最后部署结果为：

hostname  | Services 
--------  | --------
ceph-rc-1 | mon.ceph-rc-1, osd.0, mgr.ceph-rc-1
ceph-rc-2 | mon.ceph-rc-2, osd.1
ceph-rc-3 | mon.ceph-rc-3, osd.2, mds.ceph-rc-3

如需访问 dashboard ,在浏览器中输入 https://<ceph-rc-1的ip>:8092 ;

## 4. 安装Ceph客户端
执行
```
sh ./3-client_use/install_client.sh
```

## 5. 清理集群
如果你已经不再需要ceph集群或者，安装过程中出现问题，需要清理安装环境，重装时，可以使用以下脚本。     
以下脚本会清理掉所有节点上的 ceph安装文件、数据、集群配置、释放占用的块设备等，在Admin节点的 cepf.conf 所在目录下执行
```
sh 9_clear.sh
```
