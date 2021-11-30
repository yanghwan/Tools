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

[root@master1 yaml]# ceph orch apply -i osd3.yaml --dry-run
WARNING! Dry-Runs are snapshots of a certain point in time and are bound 
to the current inventory setup. If any on these conditions changes, the 
preview will be invalid. Please make sure to have a minimal 
timeframe between planning and applying the specs.
####################
SERVICESPEC PREVIEWS
####################
+---------+------+--------+-------------+
|SERVICE  |NAME  |ADD_TO  |REMOVE_FROM  |
+---------+------+--------+-------------+
+---------+------+--------+-------------+
################
OSDSPEC PREVIEWS
################
+---------+-------------+---------+----------+----+-----+
|SERVICE  |NAME         |HOST     |DATA      |DB  |WAL  |
+---------+-------------+---------+----------+----+-----+
|osd      |osd_master3  |master3  |/dev/sdb  |-   |-    |
|osd      |osd_master3  |master3  |/dev/sdc  |-   |-    |
|osd      |osd_master3  |master3  |/dev/sdd  |-   |-    |
+---------+-------------+---------+----------+----+-----+

ceph orch apply : cephadm은 새로운 Device가 감지되는 즉시 OSD를 생성
unmanaged: True : OSD 자동생성이 비활성화 됨.
ceph orch daemon add : OSD를 생성하지만 OSD 서비스를 추가하지 않음.
```
좀더 명확한 서비스 구분을 위해서 장치 유형(SSD 또는 HDD), 장치 모델 이름, 크기 및 장치가 있는 호스트가 포함해서 구축을 할수가 있다.  



2. OSD 제거  
클러스터에서 OSD를 제거하려면,  OSD내에 PG 제거  / PG 없는 OSD 제거   단계로 진행이 됩니다.

```bash
#기존 Data의 분산되는것을 막은후 진행 (nobackfill , noout , norecover , norebalance)

#ceph orch osd rm <osd_id(s)> [--replace] [--force] # OSD 제거
#ceph osd crush remove  <osd_id(s)>   #crushmap 삭제
#ceph auth del <osd_id(s)> #auth key 삭제
updated

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

[root@master3 ~]# ceph osd crush remove osd.5
removed item id 3 name 'osd.3' from crush map

[root@master3 podman]# ceph auth del osd.5
updated

```
3. Device 지우기 
OSD 제거/Crush MAP 제거/Key 삭제 이후에는 Device를 초기화후  YAML를 이용하여 추가하면 된다.
```bash
#ceph orch device zap <hostname> <path>
[root@master1 yaml]# ceph orch device zap master3 /dev/sdd --force
/bin/podman:stderr --> Zapping: /dev/sdd
/bin/podman:stderr --> Zapping lvm member /dev/sdd. lv_path is /dev/ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b/osd-block-4fb051be-5218-4b75-b22e-38aa7f057cdf
/bin/podman:stderr Running command: /usr/bin/dd if=/dev/zero of=/dev/ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b/osd-block-4fb051be-5218-4b75-b22e-38aa7f057cdf bs=1M count=10 conv=fsync
/bin/podman:stderr  stderr: 10+0 records in
/bin/podman:stderr 10+0 records out
/bin/podman:stderr 10485760 bytes (10 MB, 10 MiB) copied, 0.0811722 s, 129 MB/s
/bin/podman:stderr --> Only 1 LV left in VG, will proceed to destroy volume group ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b
/bin/podman:stderr Running command: /usr/sbin/vgremove -v -f ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b
/bin/podman:stderr  stderr: Removing ceph--6c7681fd--3bdf--46f0--a5ef--4742cbba491b-osd--block--4fb051be--5218--4b75--b22e--38aa7f057cdf (253:3)
/bin/podman:stderr  stderr: Archiving volume group "ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b" metadata (seqno 5).
/bin/podman:stderr  stderr: Releasing logical volume "osd-block-4fb051be-5218-4b75-b22e-38aa7f057cdf"
/bin/podman:stderr  stderr: Creating volume group backup "/etc/lvm/backup/ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b" (seqno 6).
/bin/podman:stderr  stdout: Logical volume "osd-block-4fb051be-5218-4b75-b22e-38aa7f057cdf" successfully removed
/bin/podman:stderr  stderr: Removing physical volume "/dev/sdd" from volume group "ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b"
/bin/podman:stderr  stdout: Volume group "ceph-6c7681fd-3bdf-46f0-a5ef-4742cbba491b" successfully removed
/bin/podman:stderr Running command: /usr/bin/dd if=/dev/zero of=/dev/sdd bs=1M count=10 conv=fsync
/bin/podman:stderr  stderr: 10+0 records in
/bin/podman:stderr 10+0 records out
/bin/podman:stderr 10485760 bytes (10 MB, 10 MiB) copied, 0.0707635 s, 148 MB/s
/bin/podman:stderr --> Zapping successful for: <Raw Device: /dev/sdd>
```


5. 확인작업
```bash
# 가능한 Device 확인 
[root@master3 podman]# ceph orch device ls  
Hostname  Path      Type  Serial                Size   Health   Ident  Fault  Available  
master1   /dev/sdb  hdd   Z4F12FBR0000C6489RFU  4000G  Unknown  N/A    N/A    No         
master2   /dev/sdc  hdd   Z4F12MKF0000C649JVAN  4000G  Unknown  N/A    N/A    No         
master2   /dev/sdd  hdd   Z4F1344G0000C6489VCL  4000G  Unknown  N/A    N/A    No         
master3   /dev/sdb  hdd   Z4F133SJ0000C6489T37  4000G  Unknown  N/A    N/A    No         
master3   /dev/sdc  hdd   Z4F1340B0000C6489VYX  4000G  Unknown  N/A    N/A    No         
master3   /dev/sdd  hdd   Z4F133V40000C6489V47  4000G  Unknown  N/A    N/A    No         

# OSD ID
[root@master3 podman]# ceph osd tree
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
 
```
