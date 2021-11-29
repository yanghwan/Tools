## ADDING HOSTS  

To add each new host to the cluster, perform two steps:  
1. one step (public SSH key Copy)  
```bash
ssh-copy-id -f -i /etc/ceph/ceph.pub root@*<new-host>*

For example:
ssh-copy-id -f -i /etc/ceph/ceph.pub root@host2
ssh-copy-id -f -i /etc/ceph/ceph.pub root@host3
```
2. 신규 Node 추가

```bash
#ceph orch host add *<newhost>* [*<ip>*] [*<label1> ...*]

For example:
#ceph orch host add host2 10.10.0.102
#ceph orch host add host3 10.10.0.103

For Label ADD
#ceph orch host add host4 10.10.0.104 --labels master
```

3. 호스트 제거



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
