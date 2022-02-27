## Repository 
패키지 저장소를 말하며, Linux에서는 패키지를 Install할때 해당 저장소에서 패키지를 찾게 된다.  
Repo list는 Linux Local Machine에서 /etc/yum.repo.s/*.repo File에서 관리를 하게 되며, 인터넷이 되지 않는 환경에서  
local Repo를 구축 및 관리를 많이 한다.  

```bash
# Repo File 추가
# dnf config-manager --add-repo file://${LOCAL_REPO_PATH}
# CentOS7
# createrepo /root/local-repo/CentOS-7 #Local Repo 위치 지정


# Yum Repository 파일 설정  
# [root@/etc/yum.repos.d] ls
CentOS-Base.repo_org  docker-ce.repo  ProLinux.repo  root_local_repo.repo

# REPO 정보 수정
[CentOS7-local-repo]
name=CentOS Local Repository
baseurl=file:///root/local-repo/CentOS-7
gpgcheck=0
enabled=1

# repo 확인
# dnf repolist 
# yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
repo id                                                repo name                                               status
!base/7/x86_64                                         CentOS-7 - Base                                         10,072
!extras/7/x86_64                                       CentOS-7 - Extras                                          500
!localrepo                                             localrepo                                                  282
repolist: 10,854
```

### REPO 구조
``` base
# cat localrepo.repo
[localrepo]
name=localrepo
baseurl=file:///tmp/localrepo/
enabled=1
gpgcheck=0

[root@bscloudisp yum.repos.d]# tree -df /tmp/localrepo
/tmp/localrepo
├── /tmp/localrepo/common
│   └── /tmp/localrepo/common/createrepo
└── /tmp/localrepo/repodata
3 directories

repodata Directory에는  메타데이터가 생성이 되며, 다른 파일의 체크섬이나 gpg서명등과 같이 관련된 파일이 저장이 되어 구성이 된다. 
common Directory에는 Local Repo에서 사용하고자 하는 패키지들을 저장하여 사용할수 있도록 구성를 ㅎ한다.

# repodata의 대표적인 구성 파일
repomd.xml     : 기본적으로 아래에 나열된 다른 XML 메타 데이터 파일의 위치, 체크섬 및 타임 스탬프가 포함 된 인덱스다.
repomd.xml.asc : 이 파일은 위의 예와 같이 저장소 작성자가 GPG를 사용하여 repomd.xml 파일에 서명 한 경우에만 생성된다.
                 yum사용자가 pygpgme패키지를 설치 한 경우이 서명을 다운로드하여 확인합니다 .
primary.xml.gz : 리포지토리의 각 패키지에 대한 자세한 정보가 들어 있습니다. 이름, 버전, 라이센스, 종속성 정보, 타임 스탬프, 크기 등과 같은 정보를 찾을 수 있습니다.
filelists.xml.gz : 저장소의 각 패키지에있는 모든 파일 및 디렉토리에 대한 정보가 들어 있습니다.
other.xml.gz :리포지토리의 각 패키지에 대한 RPM SPEC 파일에있는 변경 로그 항목이 포함되어 있습니다.

[root@bscloudisp yum.repos.d]# tree -l /tmp/localrepo/repodata
/tmp/localrepo/repodata
├── 098d8aeee3f0abd348f07482b219a3fb62996d92fb8f49fd1f5bf0976ef6de44-other.sqlite.bz2
├── 47a5bdd0581061277a3bf50176ccc4e1c77ae830a0f8203adf7ad1308194544f-other.xml.gz
├── 4a4344e2233345893844be0bff2df57c48091410d056ea8c21ab33e4474b95fa-primary.xml.gz
├── 59625b3f9ce73791a87e2132f925a86ef341ce30539cec4936a0f0331dd55aa9-primary.sqlite.bz2
├── 7c4a272c3b5a458bdae8cc92338e9e5efad2a1368cc14d77fdb803d8070d489f-filelists.xml.gz
├── 8ae7159aaca913b8e53a1145f3ae49be22e2e65af650330bf0e4bfe186f69a17-filelists.sqlite.bz2
└── repomd.xml

0 directories, 7 files

```

### 명령어
```bash
#sudo dnf info <pkg_name>  ## <pkg_name> : 패키지의 이름으로 설치가능 여부를 확인할수 있습니다.
# sudo dnf install <pkg_name>  ## 패키지 설치명령어 이며, 특정 버전의 설치를 원하는 경우 패키지의 Name-Version-Release(NVR)을 모두 입력합니다.  

ex) 
[root@bscloudisp ~]# yum info  ftp-0.17-67.el7
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp.kaist.ac.kr
 * extras: ftp.kaist.ac.kr
Available Packages
Name        : ftp
Arch        : x86_64
Version     : 0.17
Release     : 67.el7

# sudo dnf remove <pkg_name> # 패키지를 삭제하고자 할때 사용합니다. <pkg_name>은 삭제할 패키지의 이름

```

## CentOS Repo 정보
```bash
[BaseOS]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=BaseOS&infra=$infra
#baseurl=http://mirror.centos.org/$contentdir/$releasever/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial


[AppStream]
name=CentOS-$releasever - AppStream
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=AppStream&infra=$infra
#baseurl=http://mirror.centos.org/$contentdir/$releasever/AppStream/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[extras]
name=CentOS-$releasever - Extras
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras&infra=$infra
#baseurl=http://mirror.centos.org/$contentdir/$releasever/extras/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

[cr]
name=CentOS-$releasever - cr
baseurl=http://mirror.centos.org/$contentdir/$releasever/cr/$basearch/os/
gpgcheck=1
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
```
