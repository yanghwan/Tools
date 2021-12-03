# CEPH  

Open source distributed storage로써,  하나의 cluster에서  file, block, object storage 제공를 한다.
![ceph](https://user-images.githubusercontent.com/39255123/143794465-bb1d78c6-f664-4929-ab0e-dbe22e803118.PNG)  
- 구축 시에 device에 대한 제약이 거의 없으며, cluster 구축 및 확장이 매우 쉬우며 , Exabytes data 규모의 확장성 제공   
- CRUSH 알고리즘 바탕의 data 검색 및 저장 방식으로 사용하며,  Ceph client는 중앙 집중식 서버 또는 broker를 통하지 않고 OSD와  직접 통신하여 저장한다.
- Ceph cluster를 구성하는 daemon에 대한 다중화 지원  
- Data replication 및 erasure coding을 통해 data durability 지원  

##	CEPH  기본구성  
Ceph cluster의 모니터링, 관리 그리고 data의 저장 및 분산과 같은 Ceph의 실질적인 기능 제공한다.  
![ceph 구성](https://user-images.githubusercontent.com/39255123/143794034-dc018528-9e94-4d8f-b9f9-9cc2a7c71d79.PNG)  
RADOS는 기본적으로 OSD, MON, MGR 데몬으로 구성되며, 사용하는 storage type에  따라서 MDS와 RGW를 추가적으로 사용된다.  
Ceph Cluster를 구성하기 위해서는  MGR(Ceph Manager) , MON(Ceph Monitor) , ODS(Ceph Object Storage Daemon)이 하나이상 구축하여야 하며  
  Ceph FS(Ceph File System)를 사용할려면 MDS(Ceph Metadata Server)를 구축하여야 된다.  
  
  
* A Ceph Storage Cluster consists of multiple types of daemons:  
![image](https://user-images.githubusercontent.com/39255123/143796525-55b2af37-be01-4af9-9fc9-ef20b084d326.png)

Ceph Monitor : 클러스터 맵의 마스터 복사본을 유지 관리합니다. Ceph 모니터 클러스터는 모니터 데몬이 실패할 경우 고가용성을 보장합니다. 
               스토리지 클러스터 클라이언트는 Ceph Monitor에서 클러스터 맵의 복사본을 검색합니다.  
Ceph OSD : 데몬은 자신의 상태와 다른 OSD의 상태를 확인하고 모니터에 정보 전달.  
Ceph Manager : 모니터링, 오케스트레이션 및 플러그인 모듈를 사용하기 위한 EndPoint 제공.  
Ceph 메타데이터 서버(MDS) : CephFS를 사용하여 파일 서비스를 제공할 때 파일 메타데이터를 관리    
스토리지 클러스터 클라이언트와 각 Ceph OSD 데몬 은 중앙 조회 테이블에 의존하지 않고 CRUSH 알고리즘을 사용하여 데이터 위치에 대한 정보를 효율적으로 계산합니다.  
Ceph의 고급 기능에는 를 통한 Ceph Storage Cluster에 대한 기본 인터페이스(librados와 librados)를 사용한다.  

* A NEW CEPH CLUSTER  
- REQUIREMENTS  
( Python 3 , Systemd , Podman or Docker for running containers , Time synchronization (such as chrony or NTP) , LVM2 for provisioning storage devices )  
  
- New Ceph Cluster Install  
INSTALL CEPHADM >> ADDING HOSTS >> ADDING ADDITIONAL MONS >> ADDING STORAGE >> ENABLING OSD MEMORY AUTOTUNING >> USING CEPH (CephFS,RGW,NFS,iSCSI)  

Ceph를 설치하는 방법에는 여러 가지가 방법을 지원하지만, Cephadm은 CLI 및 대시보드 GUI와의 긴밀한 통합으로 컨테이너 및 systemd를 사용하여 Ceph 클러스터를 설치 및 관리합니다.  
```bash
# cephadm의 bootstrap 방식으로 구축시 쉡게 설치를 할수 있음.
#cephadm bootstrap --mon-ip *<mon-ip>*
```

* Ceph Status Check
```bash
# 전체적인 Ceph Health Check
# ceph -s
  cluster:
    id:     19ee1242-4c50-11ec-8dc3-6cae8b5ee7d0
    health: HEALTH_OK
 
  services:
    mon: 3 daemons, quorum master1,master2,master3 (age 3d)
    mgr: master1.laqvhu(active, since 2d)
    mds: myfs:1 {0=myfs.master3.yvcqtz=up:active} 1 up:standby
    osd: 6 osds: 6 up (since 2d), 6 in (since 2d)
 
  data:
    pools:   4 pools, 97 pgs
    objects: 32 objects, 11 KiB
    usage:   6.4 GiB used, 22 TiB / 22 TiB avail
    pgs:     97 active+clean
 
# Cluster 가용용량
[root@master1 ~]# ceph df
--- RAW STORAGE ---
CLASS  SIZE    AVAIL   USED     RAW USED  %RAW USED
hdd    22 TiB  22 TiB  413 MiB   6.4 GiB       0.03
TOTAL  22 TiB  22 TiB  413 MiB   6.4 GiB       0.03
 
--- POOLS ---
POOL                   ID  PGS  STORED   OBJECTS  USED     %USED  MAX AVAIL
device_health_metrics   1    1  122 KiB        9  366 KiB      0    6.9 TiB
replicapool_hdd         2   32     19 B        1  128 KiB      0     10 TiB
myfs-metadata           3   32   36 KiB       22  1.0 MiB      0     10 TiB
myfs-data0-hdd          4   32      0 B        0      0 B      0     10 TiB

# OSD 정보
[root@master1 ~]# ceph osd df
ID  CLASS  WEIGHT   REWEIGHT  SIZE     RAW USE  DATA     OMAP     META      AVAIL    %USE  VAR   PGS  STATUS
 2    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   69 MiB  200 KiB  1024 MiB  3.6 TiB  0.03  1.00   45      up
 0    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   69 MiB  203 KiB  1024 MiB  3.6 TiB  0.03  1.00   39      up
 1    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   68 MiB   12 KiB  1024 MiB  3.6 TiB  0.03  1.00   33      up
 3    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   69 MiB      0 B     1 GiB  3.6 TiB  0.03  1.00   35      up
 4    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   69 MiB      0 B     1 GiB  3.6 TiB  0.03  1.00   22      up
 5    hdd  3.63869   1.00000  3.6 TiB  1.1 GiB   69 MiB      0 B     1 GiB  3.6 TiB  0.03  1.00   21      up
                       TOTAL   22 TiB  6.4 GiB  413 MiB  416 KiB   6.0 GiB   22 TiB  0.03                   
MIN/MAX VAR: 1.00/1.00  STDDEV: 0
[root@master1 ~]# 
```

##	CEPH  구축하기  
### DISK 초기화

```bash
# disk는 /dev/sdb  Device name으로 fdisk로 확인
$ sgdisk --zap-all /dev/sdb  
$ dd if=/dev/zero of=/dev/sdb bs=1M count=100 oflag=direct,dsync
$ blkdiscard /dev/sdb

# 이전에 ceph를 설치한 노드라면 다음 커맨드 수행하여 삭제
$ ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
$ rm -rf /dev/ceph-*

# 초기화시 Cluster ID 정보가 로그에 기록때문에 해당 위치로 이동하여 삭제함.
[root@master2 ceph]# pwd
/var/log/ceph
[root@master2 ceph]# ls -artl
합계 1476
drwxr-xr-x. 10 root root    4096 11월 28 03:16 ..
drwxrwx---.  2 ceph ceph    4096 11월 29 03:51 19ee1242-4c50-11ec-8dc3-6cae8b5ee7d0
-rw-r--r--.  1 root ceph 1023942 11월 29 08:08 cephadm.log.1
drwxrws--T.  3 ceph ceph     106 11월 29 08:08 .
-rw-r--r--.  1 root ceph  478931 11월 29 10:22 cephadm.log
```  

### Ceph Manager 
ceph-ansible 또는 cephadm과 같은 일반 배포 도구를 사용하여 각 mon 노드에 ceph-mgr 데몬을 설정합니다.  
mgr 데몬을 mons와 동일한 노드에 배치하는 것은 필수는 아니지만 거의 같이 배포를 한다. 


Active - StandBy로 구성이 되며, "ceph mgr services"  Command를 활용해서 접속 URL를 확인할수 있다.


* mgr service Info 및 master change
```bash
# mgr yaml 정보 확인하기 
[root@master1 ~]# ceph orch ls --service-type  mgr --export  >> mgr.yaml
[root@master1 ~]# vi mgr.yaml
service_type: mgr
service_name: mgr
placement:
  hosts:
  - master1
  - master2


[root@master1 ceph]# ceph tell mgr status
{
    "metadata": {},
    "dentry_count": 0,
    "dentry_pinned_count": 0,
    "id": 0,
    "inst": {
        "name": {
            "type": "mgr",
            "num": 194100
        },
        "addr": {
            "type": "v1",
            "addr": "192.168.178.43:0",
            "nonce": 3462877193
        }
    },
    "addr": {
        "type": "v1",
        "addr": "192.168.178.43:0",
        "nonce": 3462877193
    },
    "inst_str": "mgr.194100 192.168.178.43:0/3462877193",
    "addr_str": "192.168.178.43:0/3462877193",
    "inode_count": 0,
    "mds_epoch": 0,
    "osd_epoch": 1677,
    "osd_epoch_barrier": 0,
    "blacklisted": false
}
[root@master1 ceph]# ceph mgr services
{
    "dashboard": "https://master1:8443/",
    "prometheus": "http://master1:9283/"
}
# DashBoard Server 및 Port 변경이 가능하다.
[root@master1 ~]# ceph config set mgr mgr/dashboard/server_addr master2
[root@master1 ~]# ceph config set mgr mgr/dashboard/server_port 8443

```

#### Ceph Monitoring
![image](https://user-images.githubusercontent.com/39255123/143828201-68d6c71c-ceff-4c22-a466-d4793d095549.PNG)




* 설정파일  
```bash

```  

* 서비스종료 / 시작  
``` bash

```  
