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
- 로그 관리 방안 필요. 
```



