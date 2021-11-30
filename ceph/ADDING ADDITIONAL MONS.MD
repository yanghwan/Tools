```diff
- text in red
+ text in green
! text in orange
# text in gray
```

## MON SERVICE
Ceph 클러스터에는 서로 다른 호스트에 걸쳐 3~5개의 모니터 데몬이 있습니다. 클러스터에 5개 이상의 노드가 있는 경우 5개의 모니터를 배포하는 것이 좋습니다
동일한 서브넷에 있는 경우 ceph 모니터 데몬을 수동으로 관리할 필요가 없으며, 지정된 개수많큼 자동으로 추가가 된다.
cephadm으로 자동 배포시  _no_schedule레이블 이 있는 호스트에 데몬을 배포하지 않습니다

```bash
# 배포 자동화 기능을 비활성화
#ceph orch apply mon --unmanaged

# 배포 자동화 기능을 활성화
#ceph orch apply mon --placement="newhost1,newhost2,newhost3" --dry-run

```

1. Subnet 지정
```bash
#ceph config set mon public_network *<mon-cidr-network>*
#ceph config set mon public_network *<mon-cidr-network1>,<mon-cidr-network2>*

For example:
#ceph config set mon public_network 10.1.2.0/24
#ceph config set mon public_network 10.1.2.0/24,192.168.0.1/24
```

2. 신규 Node 추가

```bash
#ceph orch host add *<newhost>* [*<ip>*] [*<label1> ...*]

For example:
#ceph orch host add host2 10.10.0.102
#ceph orch host add host3 10.10.0.103

For Label ADD
#ceph orch host add host4 10.10.0.104 --labels master

# YAML를 이용하여 일괄등록하는 방식

# YAML 파일로 저장하고 ceph orch apply -i yaml명 을 이용하여 일괄저장할수 있다.
service_type: host
hostname: node-00
addr: 192.168.0.10
labels:
- example1
- example2
---
service_type: host
hostname: node-01
addr: 192.168.0.11
labels:
- grafana
---
service_type: host
hostname: node-02
addr: 192.168.0.12

```


3. 호스트 제거

```bash
# 호스트는 클러스터에서 모든 데몬이 제거되면 클러스터에서 안전하게 제거하는 방식
#ceph orch host drain *<host>*
#ceph orch osd rm status (OSD 상태)
#ceph orch ps <host> (완전삭제)

# Off-Line 상태에서 강제 제거하는 방식
#ceph orch host rm <host>  --force
```

4. 확인작업
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

```diff
- SPECIAL HOST LABELS (_no_schedule , _no_autotune_memory , _admin )를 이용하여 drain으로 관리방법  
- 로그 관리방법
```



