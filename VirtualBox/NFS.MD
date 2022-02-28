# NFS 생성  
NFS 구축은 기본적으로 서버 / Client 형태로 구축이 되어야 되며  
서버설치 및 설정  / 클라이언트 설치 및 설정 하는 형태로 진행이 되어야 된다.   

- Server  Install 및 Setting

1. Network Setting
```bash
[root@centos8-3 ~]# vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
DEFROUTE=yes
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=enp0s3
UUID=da58744e-999f-4199-b06c-b26d8062e882
DEVICE=enp0s3
ONBOOT=yes
IPADDR=192.168.137.110
PREFIX=24
GATEWAY=192.168.137.1
DNS1=168.126.63.1
DNS2=8.8.8.8

[root@centos8-3 ~]# vi /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.137.101 centos8-1
192.168.137.102 centos8-2
192.168.137.103 centos8-3
192.168.137.110 centos8-nfs
```


- Install & Environment  
```bash
# Package Install
[root@centos8-nfs NFS]# dnf  install nfs-utils  -y
 
# Folder Create
[root@centos8-nfs NFS]# mkdir /data/NFS

# Setting 
[root@centos8-nfs NFS]# vi /etc/exports
/data/NFS 192.168.137.*(rw,sync,no_root_squash)
```

2. Service 확인
```bash
# 시작
[root@centos8-nfs NFS]# systemctl start nfs-server.service
# 등록
[root@centos8-nfs NFS]# systemctl enable nfs-server.service
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
# 상태
[root@centos8-nfs NFS]# systemctl status nfs-server.service
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Mon 2022-02-28 22:38:31 KST; 29s ago
 Main PID: 2443 (code=exited, status=0/SUCCESS)
    Tasks: 0 (limit: 23505)
   Memory: 0B
   CGroup: /system.slice/nfs-server.service

 2월 28 22:38:30 centos8-nfs systemd[1]: Starting NFS server and services...
 2월 28 22:38:31 centos8-nfs systemd[1]: Started NFS server and services.

# Folder 설정.
[root@centos8-nfs NFS]# exportfs -v
/data/NFS       192.168.137.*(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
[root@centos8-nfs NFS]# 
[root@centos8-nfs NFS]# exportfs -s
/data/NFS  192.168.137.*(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
[root@centos8-nfs NFS]# exportfs -arv
exporting 192.168.137.*:/data/NFS

```

