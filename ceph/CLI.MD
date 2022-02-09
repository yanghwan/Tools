## cephfs subvolume 사용량 확인 방법
이건 ceph 단에서 각각의 subvolume 별로 사용량을 확인하고 싶을때 사용하는 cli 명령어입니다. rbd 는 ceph rbd du -p replicapool 또는 ceph rbd du {replicapool}/{image_name} 로 확인하실 수 있습니다.

###ceph fs subvolume의 사용량 확인 방법
### 기능
- ceph v15.2.2부터 도입된 기능임
	- cephfs,mgr: mgr/volumes: Add interface to get subvolume metadata (pr#34681, Kotresh HR)
		- https://github.com/ceph/ceph/pull/34681
- 명령어
	- ceph fs subvolume info <vol_name> <sub_name> [<group_name>]
		- 특정 subvolume(pvc로 인해 생성되는 ceph fs 내 volume)에 대한 quota 및 현재 사용량을 조회하는 명령어로, 현재로서는 subvolume 단위의 조회만 가능합니다.
		- 현재 hypercloud에서는 cephfs의 cephfs pvc 생성 시 vol_name은 myfs, group_name은 csi로 생성됩니다.
		- pvc에 해당하는 subvolume의 이름인 sub_name은 kubectl describe pv의 VolumeHandle 값을 통해 알 수 있습니다.
			- VolumeHandle:      0001-0009-rook-ceph-0000000000000001-2c079863-4ef6-11eb-b195-0242ac110008 라면 앞 부분 '0001-0009-rook-ceph-0000000000000001'을 제외하고, 'csi-vol'을 붙여 'csi-vol-2c079863-4ef6-11eb-b195-0242ac110008'이 subvolume의 이름니다.
	
- 사용 예시
	- 1G짜리 pvc 생성하고, 사용량 확인 후, 100M 데이터 생성한 후 사용량 확인하는 예시
	```shell
	# cephfs의 subvolume 리스트 확인
	[root@rook-ceph-tools-56df7dc4b7-6jt92 /]# ceph fs subvolume ls myfs csi
	[
		{
			"name": "csi-vol-2c079863-4ef6-11eb-b195-0242ac110008"
		}
	]
	# 데이터 쓰기 전 사용량 확인
	[root@rook-ceph-tools-56df7dc4b7-6jt92 /]# ceph fs subvolume info myfs csi-vol-2c079863-4ef6-11eb-b195-0242ac110008 csi
	{
		"atime": "2021-01-05 01:34:37",
		"bytes_pcent": "0.00",
		"bytes_quota": 1073741824,		# quota 1G
		"bytes_used": 0,				# 사용량 0으로 확인됨
		"created_at": "2021-01-05 01:34:37",
		"ctime": "2021-01-05 01:34:54",
		"data_pool": "myfs-data0",
		"gid": 0,
		"mode": 16895,
		"mon_addrs": [
			"10.109.168.60:6789"
		],
		"mtime": "2021-01-05 01:34:37",
		"path": "/volumes/csi/csi-vol-2c079863-4ef6-11eb-b195-0242ac110008/29890b95-4ce7-4d4a-aab5-af6503df80df",
		"pool_namespace": "",
		"type": "subvolume",
		"uid": 0
	}
	...
	# 데이터 100M 작성 후 사용량 확인
	[root@rook-ceph-tools-56df7dc4b7-6jt92 /]# ceph fs subvolume info myfs csi-vol-2c079863-4ef6-11eb-b195-0242ac110008 csi
	{
		"atime": "2021-01-05 01:34:37",
		"bytes_pcent": "9.77",
		"bytes_quota": 1073741824,
		"bytes_used": 104857600,			# 사용량 100M
		"created_at": "2021-01-05 01:34:37",
		"ctime": "2021-01-05 01:36:25",
		"data_pool": "myfs-data0",
		"gid": 0,
		"mode": 16895,
		"mon_addrs": [
			"10.109.168.60:6789"
		],
		"mtime": "2021-01-05 01:36:25",
		"path": "/volumes/csi/csi-vol-2c079863-4ef6-11eb-b195-0242ac110008/29890b95-4ce7-4d4a-aab5-af6503df80df",
		"pool_namespace": "",
		"type": "subvolume",
		"uid": 0
	}
	```
