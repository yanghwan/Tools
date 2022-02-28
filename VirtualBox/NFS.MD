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
/data/NFS 192.168.137.1/24(rw,sync,no_root_squash)

# 클라이언트 옵션에는 다음이 포함됩니다(기본값이 먼저 나열됨):
ro / rw :
a) ro : 클라이언트가 공유에 대한 읽기 전용 액세스를 허용합니다.
b) rw : 클라이언트가 공유에 대한 읽기 쓰기 액세스를 허용합니다.
sync / async :
a) sync : NFS 서버는 이전 요청의 변경 사항이 디스크에 기록된 후에만 요청에 응답합니다.
b) async : 서버가 기다릴 필요가 없도록 지정합니다.
wdelay / no_wdelay
a) wdelay : NFS 서버는 다른 쓰기 요청이 임박한 것으로 의심되면 쓰기 요청 커밋을 지연합니다.
b) no_wdelay : 이 옵션을 사용하여 지연을 비활성화합니다. no_wdelay 옵션은 기본 동기화 옵션이 활성화 된 경우에만 활성화할 수 있습니다 .
no_all_squash / all_squash :
a) no_all_squash : 원격 사용자의 매핑을 변경하지 않습니다.
b) all_squash : 루트를 포함한 모든 원격 사용자를 스쿼시합니다.
root_squash / no_root_squash :
a) root_squash : 원격으로 연결된 루트 사용자가 루트 액세스 권한을 갖는 것을 방지합니다. 원격 루트 권한을 효과적으로 스쿼시합니다.
b) no_root_squash : 루트 스쿼싱을 비활성화합니다.

# firewall  
$ sudo firewall –cmd --state.
$ sudo systemctl stop firewalld.
$ sudo systemctl status firewalld.
$ sudo systemctl disable firewalld.
$ sudo systemctl status firewalld.
$ sudo systemctl mask --now firewalld.

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

- Client  Install 및 Setting
1. Client Install
```bash

# Package Install 
[root@centos8-3 ~]# dnf install -y nfs-utils nfs4-acl-tools
마지막 메타 데이터 만료 확인 :1 day, 2:45:40. 2022년 02월 27일 (일) 오후 08시 21분 05초 이전에 확인
패키지 nfs-utils-1:2.3.3-50.el8.x86_64이/가 이미 설치되어 있습니다.
종속성이 해결되었습니다.
====================================================================================================================
 패키지                          아키텍처                버전                         리포지터리               크기
====================================================================================================================
설치 중:
 nfs4-acl-tools                  x86_64                  0.3.5-3.el8                  baseos                   55 k

트랜잭션 요약
====================================================================================================================
설치  1 패키지

총 다운로드 크기 : 55 k
설치된 크기 : 193 k
패키지 다운로드중:
nfs4-acl-tools-0.3.5-3.el8.x86_64.rpm                                               743 kB/s |  55 kB     00:00    
--------------------------------------------------------------------------------------------------------------------
합계                                                                                148 kB/s |  55 kB     00:00     
CentOS Stream 8 - BaseOS                                                            1.3 MB/s | 1.6 kB     00:00    
GPG키 0x8483C65D 가져오는 중:
 사용자 ID     : "CentOS (CentOS Official Signing Key) <security@centos.org>"
  지문: 99DB 70FA E1D7 CE22 7FB6 4882 05B5 55B3 8483 C65D
 출처        : /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
키 가져오기에 성공했습니다
트랜잭션 확인 실행 중
트랜잭션 확인에 성공했습니다.
트랜잭션 테스트 실행 중
트랜잭션 테스트에 성공했습니다.
트랜잭션 실행 중
  준비 중          :                                                                                            1/1 
  설치 중          : nfs4-acl-tools-0.3.5-3.el8.x86_64                                                          1/1 
  scriptlet 실행 중: nfs4-acl-tools-0.3.5-3.el8.x86_64                                                          1/1 
  확인 중          : nfs4-acl-tools-0.3.5-3.el8.x86_64                                                          1/1 

설치됨:
  nfs4-acl-tools-0.3.5-3.el8.x86_64                                                                                 

완료되었습니다!


# Mount Folder Create
# mkdir /data/mountNFS 

```

- Mount
```bash
[root@centos8-3 data]# mount -t nfs -o nfsvers=3 -vvvv centos8-nfs:/data/NFS /data/mountNFS
[root@centos8-3 data]# mount -t nfs -o nfsvers=3 centos8-nfs:/data/NFS /data/mountNFS

# 재부팅시 마운트 설정
# cat /etc/fstab
  centos8-nfs:/data/NFS /data/mountNFS  nfs  defaults 0 0  ## 추가
```

- 정보확인
```bash
[root@centos8-3 data]# rpcinfo -p 192.168.137.110
   program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  54221  status
    100024    1   tcp  39099  status
    100005    1   udp  20048  mountd
    100005    1   tcp  20048  mountd
    100005    2   udp  20048  mountd
    100005    2   tcp  20048  mountd
    100005    3   udp  20048  mountd
    100005    3   tcp  20048  mountd
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100021    1   udp  49875  nlockmgr
    100021    3   udp  49875  nlockmgr
    100021    4   udp  49875  nlockmgr
    100021    1   tcp  40799  nlockmgr
    100021    3   tcp  40799  nlockmgr
    100021    4   tcp  40799  nlockmgr
    
[root@centos8-3 mountNFS]# mount | grep nfs
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
centos8-nfs:/data/NFS on /data/mountNFS type nfs (rw,relatime,vers=3,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.137.110,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.137.110)

[root@centos8-3 mountNFS]# showmount -e centos8-nfs
Export list for centos8-nfs:
/data/NFS 192.168.137.0/24

```


