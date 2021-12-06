```diff
- text in red
+ text in green
! text in orange
# text in gray
```

## Pool, PG , CRUSH  구성  
Ceph Client는 데이터를 Pool에 저장을 하며,  Pool의 PG 및 Crush 구성에 따라서 OSD에 데이터를 저장을 하게 된다.  
데이터를 저장하기 위한 논리적인 파티션인 Pool이라는 개념으로 지원을 하고 있으며, 클라이언트가 데이터를 저장할 I/O 인터페이스를 생성하여 제공합니다.  
풀을 생성하고 풀의 배치 그룹 수를 설정할 때 Ceph는 특별히 기본값을 재정의하지 않는 경우 기본값을 사용합니다.   
특히 풀의 복제본 크기를 설정, 기본 배치 그룹 수를 재정의하는 것이 좋으며, 풀 명령을 실행할 때 이러한 값을 구체적으로 설정할 수 있습니다  

* 일반적으로 설정작업은   
1. CEPH Pool >> 2. PG   >> 3. CRUSH   으로 진행  

* Pool 기능  
Resilience (replicas ,erasure code profile)  , / Placement Groups(OSD당 PG Group 개수)  / CRUSH Rules /   Snapshots / Quotas  (Pool 최대개수)

ceph Pool Information
```bash 
# ceph osd lspools
1 device_health_metrics
2 replicapool_hdd
3 myfs-metadata
4 myfs-data0-hdd

# ceph osd pool stats
pool device_health_metrics id 1
  nothing is going on
pool replicapool_hdd id 2
  nothing is going on
pool myfs-metadata id 3
  nothing is going on
pool myfs-data0-hdd id 4
  nothing is going on

# ceph osd pool ls  detail
pool 1 'device_health_metrics' replicated size 3 min_size 2 crush_rule 1 object_hash rjenkins pg_num 1 pgp_num 1 autoscale_mode on last_change 1734 flags hashpspool stripe_width 0 pg_num_min 1 application mgr_devicehealth
pool 2 'replicapool_hdd' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1360 lfor 0/1360/1358 flags hashpspool,selfmanaged_snaps stripe_width 0 application rbd
pool 3 'myfs-metadata' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1506 flags hashpspool stripe_width 0 pg_autoscale_bias 4 pg_num_min 16 recovery_priority 5 application cephfs
pool 4 'myfs-data0-hdd' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1547 lfor 0/1547/1545 flags hashpspool stripe_width 0 application cephfs

# ceph osd pool autoscale-status
POOL                     SIZE  TARGET SIZE  RATE  RAW CAPACITY   RATIO  TARGET RATIO  EFFECTIVE RATIO  BIAS  PG_NUM  NEW PG_NUM  AUTOSCALE  
device_health_metrics  121.9k                3.0        22356G  0.0000                                  1.0       1              on         
replicapool_hdd           19                 2.0        22356G  0.0000                                  1.0      32              off        
myfs-metadata          37037                 2.0        22356G  0.0000                                  4.0      32              off        
myfs-data0-hdd             0                 2.0        22356G  0.0000                                  1.0      32              off 

```

* 1. Pool Create
```bash

#ceph osd pool create {pool-name} [{pg-num} [{pgp-num}]] [replicated] [crush-rule-name] [expected-num-objects]
#ceph osd pool create {pool-name} [{pg-num} [{pgp-num}]]   erasure [erasure-code-profile] [crush-rule-name] [expected_num_objects] [--autoscale-mode=<on,off,warn>]

# For Example
# ceph osd pool create hdd_pool_1 #추가 파라메터를 넣지 않으면 Default Setting
pool 'hdd_pool_1' created

```

* 2. Pool Delete
```bash
#ceph osd pool delete <pool-name> [<pool-name> --yes-i-really-really-mean-it]
- 
# mon_allow_pool_delete 옵션에 대해 true 설정
#ceph tell mon.\* injectargs '--mon-allow-pool-delete=false' #변경
#ceph auth ls | grep -C 5 {pool-name}
#ceph auth del {user}
```

* 3. Applcation Enabled / Disable (pool information setting)
cephfs for the Ceph Filesystem. / rbd for the Ceph Block Device / rgw for the Ceph Object Gateway 사용용도에 맞춰서 설정 필요  
```bash
#ceph health detail -f json-pretty 
#ceph osd pool application enable <poolname> <app> {--yes-i-really-mean-it}
#app는 cephfs / rbd / rgw 용도에 맞춰서 설정.

#Disable Application
# ceph osd pool application disable <poolname> <app> {--yes-i-really-mean-it}


For Examples
[root@master1 ~]# ceph osd pool ls detail | grep hdd_pool_1
pool 6 'hdd_pool_1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1827 flags hashpspool stripe_width 0

# ceph osd pool application enable hdd_pool_1 cephfs --yes-i-really-mean-it
enabled application 'cephfs' on pool 'hdd_pool_1'

# ceph osd pool ls detail | grep hdd_pool_1
pool 6 'hdd_pool_1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1832 flags hashpspool stripe_width 0 application cephfs

# ceph osd pool application disable hdd_pool_1 cephfs --yes-i-really-mean-it
disable application 'cephfs' on pool 'hdd_pool_1'
# ceph osd pool ls detail | grep hdd_pool_1
pool 6 'hdd_pool_1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1834 flags hashpspool stripe_width 0

```
* 4. pool replicas setting 
```bash
#ceph osd pool set <poolname> size <num-replicas>
# ceph osd dump | grep 'replicated size'
```

* 5. pool value get / set
```bash
#ceph osd pool set {pool-name} {key} {value}
#ceph osd pool get {pool-name} {key}

For Examples
# ceph osd pool set hdd_pool_1 pg_num 64
set pool 6 pg_num to 64
# ceph osd pool get hdd_pool_1 pg_num
```

* 5. Default value
```bash
# ceph osd erasure-code-profile get default
k=2
m=2
plugin=jerasure
technique=reed_sol_van
```

* 6. Information
```bash
[root@master1 ~]# rados df
POOL_NAME                 USED  OBJECTS  CLONES  COPIES  MISSING_ON_PRIMARY  UNFOUND  DEGRADED  RD_OPS       RD  WR_OPS       WR  USED COMPR  UNDER COMPR
device_health_metrics  366 KiB        9       0      27                   0        0         0      74   74 KiB      84  390 KiB         0 B          0 B
hdd_pool_1                 0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B
myfs-data0-hdd             0 B        0       0       0                   0        0         0       0      0 B       0      0 B         0 B          0 B
myfs-metadata          1.0 MiB       22       0      44                   0        0         0     125  141 KiB     116   78 KiB         0 B          0 B
replicapool_hdd        128 KiB        1       0       2                   0        0         0       0      0 B       2    2 KiB         0 B          0 B

total_objects    32
total_used       6.4 GiB
total_avail      22 TiB
total_space      22 TiB

# ceph osd pool ls detail
pool 2 'replicapool_hdd' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1360 lfor 0/1360/1358 flags hashpspool,selfmanaged_snaps stripe_width 0 application rbd
pool 3 'myfs-metadata' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1506 flags hashpspool stripe_width 0 pg_autoscale_bias 4 pg_num_min 16 recovery_priority 5 application cephfs
pool 4 'myfs-data0-hdd' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode off last_change 1547 lfor 0/1547/1545 flags hashpspool stripe_width 0 application cephfs
pool 5 'hdd_pool_1' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 32 pgp_num 32 autoscale_mode on last_change 1802 flags hashpspool stripe_width 0

#ceph osd pool get {pool-name} crush_rule  #pool의 crush_rule 확인 
[root@master1 ~]# ceph osd pool get hdd_pool_1 crush_rule
crush_rule: replicated_rule
```
