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

### MGR  초기화



특히 RedHat8 and ProLinux8 부터는 기본 NTP로 패키징되어 있으며, 타임서버 리스트(Stratum)에 대해서는   
Address : kr.pool.ntp.org / time.bora.net / time.nuri.net
많이 사용을 하고 있지만, 국내 타임서버 리스트는  http://time.ewha.or.kr/domestic.html에서 정보를 확인할수 있습니다.  

*	NTP (TimeServer) 구성
 ![ntp_1](https://user-images.githubusercontent.com/39255123/141034679-0bf319f8-286f-4691-9eb1-847bf0f6bacd.jpg)
 
내부에 fail over를 위해 Stratum 3 level의 Time server 2대를 구성하고, private network 안에 있는 server/client 들이 이 time server를 통해서 시간 동기화를 하도록 구성을 하도록 합니다.
그리고, 2대의 Time server 간에는 peer 구성을 하여 서로 동기화를 하게 할 수 있지만, Time service 특성상 peer 구성 보다는 그냥 master 2대로 구성하는 것이 관리상 더 편했던 것 같습니다. 그래서 여기서는 peer 구성은 하지 않고 그냥 time server 2대를 독립적으로 구성하되, sync할 stratum 2 level의 서버를 동일하게 지정하여 peer 설정을 한 것과 비슷하게 구성을 할 것입니다.

Chrony는 기본적으로 UDP 123번 포트를 사용하기 때문에 Time Server1/Time Server2에 대한 포트를 Allow 해줘야 되며, 방화벽은 반드시 확인이 필요하다.
* 설정파일  
```bash
[root@master2 etc]# cat /etc/chrony.conf
pool 2.pl.pool.ntp.org iburst

# Record the rate at which the system clock gains/losses time.  # 시간오차치를 보존해두는 파일정보
driftfile /var/lib/chrony/drift
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3
# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *
# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2
# Allow NTP client access from local network.
allow 192.168.0.0/16
# Serve time even if not synchronized to a time source.
local stratum 3
# Specify file containing keys for NTP authentication.
keyfile /etc/chrony.keys
# Get TAI-UTC offset and leap seconds from the system tz database.
#leapsectz right/UTC
# Specify directory for log files.
logdir /var/log/chrony
# Select which information is logged.
#log measurements statistics tracking
# restrict 127.xxx.xxx.xxx  #Peer들이 본서버로 Sync를 하는 것을 제한
```    
서버 및 Clinet의 참조하는 주소를 변경하여 시간 동기화를 할수있으며, Client는 아래 옵션을 주석처리해서 재기동하면 됩니다.
```bash
# Allow NTP client access from local network. – 제외
# Serve time even if not synchronized to a time source. – 제외
#server  xxx.xxx.xxx.xxx  iburst – chrony server ip 

ex)
#allow 192.168.0.0/16  
##local stratum 3  
server 192.168.178.44 iburst  
```  

* 서비스종료 / 시작  
``` bash
[root@master1 etc]# systemctl stop  chronyd
[root@master1 etc]# systemctl start  chronyd
[root@master1 etc]# systemctl restart  chronyd
[root@master1 etc]# systemctl enstart  chronyd
```  
