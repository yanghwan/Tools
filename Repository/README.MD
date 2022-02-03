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
