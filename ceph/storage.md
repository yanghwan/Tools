```diff
- text in red
+ text in green
! text in orange
# text in gray
```

## OSD Device 
CEPH Cluster의 OSD를 배포하기 위해서는, Device를 확인해야 되며 CLI 명령어를 이용해서  저장장치 인벤토리를 확인할수 있다.  
#ceph orch device ls  

- 사용가능한 저장장치  
The device must have no partitions. 
The device must not have any LVM state.  
The device must not be mounted.  
The device must not contain a file system.  
The device must not contain a Ceph BlueStore OSD.  
The device must be larger than 5 GB.  


어떤 장치가 있는지와 OSD로 사용할 수 있는지 여부를 확인하기 위해 클러스터의 각 호스트를 스캔하며, CLI를 이용하여 확인이 가능하다.
```bash
#ceph orch device ls [--hostname=...] [--wide] [--refresh]
[root@master2 ceph]# ceph orch device ls --wide --refresh
Hostname  Path      Type  Transport  RPM      Vendor    Model             Serial                Size   Health   Ident  Fault  Available  Reject Reasons                           
master1   /dev/sdb  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F12FBR0000C6489RFU  4000G  Unknown  N/A    N/A    No         LVM detected, locked, Insufficient space (<10 extents) on vgs  
master2   /dev/sdc  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F12MKF0000C649JVAN  4000G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
master2   /dev/sdd  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F1344G0000C6489VCL  4000G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
master3   /dev/sdb  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F133SJ0000C6489T37  4000G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
master3   /dev/sdc  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F1340B0000C6489VYX  4000G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked  
master3   /dev/sdd  hdd   Unknown    Unknown  IBM-ESXS  ST4000NM0034   X  Z4F133V40000C6489V47  4000G  Unknown  N/A    N/A    No         Insufficient space (<10 extents) on vgs, LVM detected, locked 

# libstoragemgmt 가 하드웨어와 100% 호환되지 않을 수 있기 때문에 비활성화 되어 "Health", "Ident" , "Fault" 필드는 확인할수 없다.  
cephadm이 필드 를 포함 시키려면 다음과 같이 cephadm의 "enhanced device scan" 옵션 활성화가 필요하다.

#ceph config set mgr mgr/cephadm/device_enhanced_scan true ( 잘안됨)

```

1. Creating New OSDS
```bash
#ceph orch apply osd --all-available-devices  #사용가능한 Device에 추가
#ceph orch daemon add osd *<host>*:*<device-path>*  #특정HOST 및 Device 추가
#ceph orch apply -i spec.yml # 정의된 YAML 형태로 적용

For Example
#ceph orch daemon add osd host1:/dev/sdb

#YAML 
service_type: osd
service_id: osd_master3
service_name: osd.osd_master3
placement:
  hosts:
  - master3
spec:
  data_devices:
    paths:
    - /dev/sdb
    - /dev/sdc
    - /dev/sdd

ceph orch apply : cephadm은 새로운 Device가 감지되는 즉시 OSD를 생성
unmanaged: True : OSD 자동생성이 비활성화 됨.
ceph orch daemon add : OSD를 생성하지만 OSD 서비스를 추가하지 않음.
```
좀더 명확한 서비스 구분을 위해서 장치 유형(SSD 또는 HDD), 장치 모델 이름, 크기 및 장치가 있는 호스트가 포함해서 구축을 할수가 있다.  



2. OSD 제거  
클러스터에서 OSD를 제거하려면,  OSD내에 PG 제거  / PG 없는 OSD 제거   단계로 진행이 됩니다.


```bash
#ceph orch osd rm <osd_id(s)> [--replace] [--force]

For example:
[root@master1 yaml]# ceph  osd tree
ID  CLASS  WEIGHT    TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         21.83212  root default                               
-5          3.63869      host master1                           
 2    hdd   3.63869          osd.2         up   1.00000  1.00000
-3          7.27737      host master2                           
 0    hdd   3.63869          osd.0         up   1.00000  1.00000
 1    hdd   3.63869          osd.1         up   1.00000  1.00000
-7         10.91606      host master3                           
 3    hdd   3.63869          osd.3         up   1.00000  1.00000
 4    hdd   3.63869          osd.4         up   1.00000  1.00000
 5    hdd   3.63869          osd.5         up   1.00000  1.00000
[root@master1 yaml]# 
[root@master1 yaml]# ceph orch osd rm 5
Scheduled OSD(s) for removal

```
2. OSD 교체  
클러스터에서 OSD를 제거하려면,  OSD내에 PG 제거  / PG 없는 OSD 제거   단계로 진행이 됩니다.
```bash
#기존 Data의 분산되는것을 막은후 진행 (nobackfill , noout , norecover , norebalance)
#ceph orch osd rm <osd_id(s)> [--replace] [--force]
#ceph osd crush remove  <osd_id(s)>   crushmap

For example:
[root@master1 yaml]# ceph  osd tree
ID  CLASS  WEIGHT    TYPE NAME         STATUS  REWEIGHT  PRI-AFF
-1         21.83212  root default                               
-5          3.63869      host master1                           
 2    hdd   3.63869          osd.2         up   1.00000  1.00000
-3          7.27737      host master2                           
 0    hdd   3.63869          osd.0         up   1.00000  1.00000
 1    hdd   3.63869          osd.1         up   1.00000  1.00000
-7         10.91606      host master3                           
 3    hdd   3.63869          osd.3         up   1.00000  1.00000
 4    hdd   3.63869          osd.4         up   1.00000  1.00000
 5    hdd   3.63869          osd.5         up   1.00000  1.00000
[root@master1 yaml]# 
[root@master1 yaml]# ceph orch osd rm 5
Scheduled OSD(s) for removal


```

2. MOVING MONITORS TO A DIFFERENT NETWORK

```bash
#ceph orch apply mon --unmanaged #비활성화
#ceph orch daemon add mon *<newhost1:ip-or-network1>* #신규추가
#ceph orch daemon rm *mon.<oldhost1>* #제거
#ceph config set mon public_network *<mon-cidr-network>* #Update
#ceph orch apply mon --placement="newhost1,newhost2,newhost3" --dry-run # 활성화
#ceph orch apply mon --placement="newhost1,newhost2,newhost3" #위치적용
```
3. MOM Host 추가
```bash
#ceph orch apply mon host1
#ceph orch apply mon host2
#ceph orch apply mon host3

#ceph orch apply mon "host1,host2,host3" #일괄등록
```

4. YAML를 이용하여 일괄등록하는 방식  
```bash
# YAML 파일로 저장하고 ceph orch apply -i yaml명 을 이용하여 일괄저장할수 있다.  
service_type: mon
placement:
  hosts:
   - host1
   - host2
   - host3
```

5. 확인작업
```bash
# 
[root@master1 var]# ceph orch ls --service_type mon 
NAME  RUNNING  REFRESHED  AGE  PLACEMENT                        IMAGE NAME                   IMAGE ID      
mon       3/3  103s ago   3d   master1;master2;master3;count:3  docker.io/ceph/ceph:v15.2.8  5553b0cb212c  

[root@master1 var]# ceph orch ps | grep mon
mon.master1              master1  running (20h)  2m ago     6d   15.2.8   docker.io/ceph/ceph:v15.2.8           5553b0cb212c  d4fe5be4fb08  
mon.master2              master2  running (20h)  2m ago     3d   15.2.8   docker.io/ceph/ceph:v15.2.8           5553b0cb212c  0d8c1e4d955d  
mon.master3              master3  running (20h)  2m ago     3d   15.2.8   docker.io/ceph/ceph:v15.2.8           5553b0cb212c  5a69a0eb944d  

```

6. 준비가 되어 있는 특정NODE에 데몬 실행 
```bash
#orch apply prometheus --placement="host1 host2 host3" #HOSTNAME 사용
#orch apply prometheus --placement="label:mylabel"  #LABEL 사용
#orch apply prometheus --placement='myhost[1-3]' #패턴 매칭
#orch apply node-exporter --placement='*' 
#orch apply prometheus --placement=3 #데몬수 지정
#orch apply prometheus --placement="2 host1 host2 host3" #데몬수 지정

#YAML (HostName)
service_type: prometheus
placement:
  hosts:
    - host1
    - host2
    - host3
    
#YAML 패턴패칭
service_type: prometheus
placement:
  host_pattern: "myhost[1-3]"
  
#YAML Label 
service_type: prometheus
placement:
  label: "mylabel"

#YAML HOST 패턴(전체)
service_type: node-exporter
placement:
  host_pattern: "*"
  
#YAML 개수 지정
service_type: prometheus
placement:
  count: 3
```

```diff
- ADVANCED OSD SERVICE SPECIFICATIONS 를 이용해서 다양한 구성방식 검토 필요.
```
