** Volume 
LVM(Logical Volume Manager)을 이용하면, 데이터의 손실 없이 복수의 HDD를 연결하여 하나의 통합된 파티션을 구성하는 것이 가능하다.
LVM의 기본은, 복수의 HDD(엄밀히 말하자면 Physical Volume)로부터 구성되는 기억장치의 유닛들을 통합한 Logical Volume을 생성하고, 이를 각 파티션에 할당하는 것이다.
여기에, 파티션 영역을 조정해야 할 필요가 생겼을 때 유닛을 추가/삭제 함으로써 파티션영역을 위한 공간을 확대/축소 하는 것이 가능하다.

 ![lvm](https://user-images.githubusercontent.com/39255123/141877514-51664512-d69a-4a58-978b-873212e23613.png)

물리 매체 (Physical Media) : 대체로 하드디스크라고 보면 된다. /dev/sda, /dev/hda 같은 것들이다.
물리 볼륨 (Physical Volume, PV) : 물리 매체의 연속된 블록을 지칭하는 것으로, 쉽게 말하자면 HDD전체 일 수도 있고, HDD의 일부분 일 수도 있다. 중요한 건 HDD의 연속된 블록 1개 = PV 라는 개념이다.
물리 확장 (Physical Extend, PE) : 다음에 설명할 논리 볼륨을 잘게 썰어 놓은 것의 일부이다. 보통 4MB 단위로 썰어져 있다.
논리 볼륨 (Logical Volume, LV) : 오늘의 주인공. 흔히 말하는 파티션과 거의 같은 개념이다.
볼륨 그룹 (Volume Group, VG) : 복수의 논리 볼륨들의 그룹을 뜻한다.
논리볼륨(LV)를 생성하기 위해서는 fdisk를 이용하여 생성할수 있다.

2. Repo 설정
[root@master1 yum.repos.d]# pwd
/etc/yum.repos.d
[root@master1 yum.repos.d]# cat *
[BaseOS]
name=ProLinux-$releasever - BaseOS
baseurl=http://prolinux-repo.tmaxos.com/prolinux/8/os/x86_64/BaseOS
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-prolinux-$releasever-release
gpgcheck=1

[AppStream]
name=ProLinux-$releasever - AppStream
baseurl=http://prolinux-repo.tmaxos.com/prolinux/8/os/x86_64/AppStream
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-prolinux-$releasever-release
gpgcheck=1
Linux에서 Package를 받아오기위한 기본 Repository를 설정을 하여야 하며 dnf repolist 명령어를 통해서 확인할수 있다.
