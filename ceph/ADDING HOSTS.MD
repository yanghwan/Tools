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
# 등록된 Host에 대해서 확인가능
#ceph orch host ls [--format yaml]

```
<font color='dodgerblue'> 예쁜 파랑 </font>

