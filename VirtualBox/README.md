# VirtualBox 
Windows PC환경에서 여래개의 VM을 생성하여 다양한 테스트가 가능하다.  
기본 구성 및 네트웍에 대한 기본개념을 이해하고 구축을 하면 쉽고 빠르게 구축을 할수 있다.  

![image](https://user-images.githubusercontent.com/39255123/155870608-f946a1b3-6b80-4b6b-9778-1c40f59c43a3.png)

위의 기본적인 구성을 위해서는 아래와 같은 단계로 구성을 진행한다.  
![image](https://user-images.githubusercontent.com/39255123/155870665-96c42490-41f2-4bc6-bf17-33fb3e8fd31a.png)


## 1. VirtualBox Install 
``` bash
1. Site 
   https://www.virtualbox.org/wiki/Downloads
```

## 2. Host Virtual Network 
VirtualBox를 설치하게 되면 가상인터페이스(VirtualBox Host-Only Network)가 생성된것을 확인할수 있으며, 인터페이스가 Host PC까지 Gateway 역활를 수행해준다.  
생성한 VM이 외부통신을 위해서는 Wifi 및 Ethernet를 사용해야되며, 공유되도록 설정이 필요하다.  
![image](https://user-images.githubusercontent.com/39255123/155871008-e7811bf7-81f8-484a-b5b9-1453c7ea92de.png)

- VirtualBox Host-Only Network  
VirtualBox Host-Only Network : HOST PC 와 Virtual Machine 들간의 Network 통신을 위한 인터페이스 역활를 수행한다.  
VM은 해당 IP(192.168.137.1)를 G/W IP로 설정한다.    
![image](https://user-images.githubusercontent.com/39255123/155871386-91f0c502-5d9b-48a4-b5c3-62d36619ecf7.png)
  
Cli를 이용하여 ip 확인  
```bash
c:\>ipconfig
Windows IP 구성

이더넷 어댑터 VirtualBox Host-Only Network:

   연결별 DNS 접미사. . . . :
   링크-로컬 IPv6 주소 . . . . : fe80::c895:844a:68c5:229f%15
   IPv4 주소 . . . . . . . . . : 192.168.137.1
   서브넷 마스크 . . . . . . . : 255.255.255.0
   기본 게이트웨이 . . . . . . :
   
```
- Wifi 및 Ethernet Shared Setting 
해당 인터페이스를 이용해서 외부 통신을 하기 위해서는 사용하는 인터페이스에서 공유설정을 활성화 해줘야 된다.  
![image](https://user-images.githubusercontent.com/39255123/155872644-8589cfa3-df4c-41fe-9460-5fccb4e40b5a.png)



 
## 3. VirtualBox Host Network
- VM 생성  
![image](https://user-images.githubusercontent.com/39255123/155873014-2d44e6bb-110c-48ad-aae7-de79c7cf9ac5.png)

- 호스트 네트워크 관리자  
![image](https://user-images.githubusercontent.com/39255123/155873291-ac247aab-b741-4372-a65a-482e60f35f95.png)

- 각 VM별 네트워크설정  
![image](https://user-images.githubusercontent.com/39255123/155873398-48ebdacb-2954-46cd-a33a-9a029045e73a.png)



## 4. VM 네트웍 및 System 설정

- 고정 IP 설정   
아래의 방법으로 동일한 방식으로 3ea의 VM에 IP를 설정하여 인터페이스를 재기동 한다.  
```bash
[root@redhat84 ~]# cd /etc/sysconfig/network-scripts/

[root@redhat84 network-scripts]# ls
ifcfg-enp0s3
[root@redhat84 network-scripts]# cat ifcfg-enp0s3  # 변경
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static        # 고정IP 설정으로 변경
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=enp0s3
UUID=c9aa78ce-cf21-4dc0-97ee-39320dbe7675
DEVICE=enp0s3
ONBOOT=yes              # Booting시 설정(no로 되어 있으면 yes로 변경)
IPADDR=192.168.137.101  # IP
NETMASK=255.255.255.0   # subnet 
GATEWAY=192.168.137.1   # G/W 
DNS1=168.126.63.1       # DNS
DNS2=8.8.8.8
PREFIX=24

# 인터페이스명 (enp0s3) 재기동하여 적용  
root@redhat84 network-scripts]# nmcli con up enp0s3
연결이 성공적으로 활성화되었습니다 (D-버스 활성 경로: /org/freedesktop/NetworkManager/ActiveConnection/4)

```

- 호스트명 변경
```bash
[root@redhat84 network-scripts]# hostnamectl set-hostname redhat84-1
[root@redhat84 network-scripts]# uname -a
Linux redhat84-1 4.18.0-305.el8.x86_64 #1 SMP Thu Apr 29 08:54:30 EDT 2021 x86_64 x86_64 x86_64 GNU/Linux

[root@redhat84 network-scripts]# hostname
redhat84-1

# 호스트이름을 변경후 서버를 재기동해야 정상적으로 적용이 된다.
```

- etc/hosts file 등록
```bash
[root@redhat84 etc]# vi hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.137.101 redhat84-1
192.168.137.102 redhat84-2
192.168.137.103 redhat84-3
```



## 4. host 및 VM Test  
```bash
# CLI 방식으로 IP 확인
[root@redhat84 network-scripts]# ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.137.101  netmask 255.255.255.0  broadcast 192.168.137.255
        inet6 fe80::a00:27ff:fe43:f3fd  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:43:f3:fd  txqueuelen 1000  (Ethernet)
        RX packets 2063  bytes 181818 (177.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 718  bytes 84910 (82.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 52  bytes 4632 (4.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 52  bytes 4632 (4.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:8d:38:21  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        
# hostname 확인
[root@redhat84 network-scripts]# hostname
redhat84-1
[root@redhat84 network-scripts]# hostnamectl
   Static hostname: redhat84-1
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 278f88458ea344f18268f715bf141eff
           Boot ID: 0d09be55335e4f82957cff5f52bea7b1
    Virtualization: oracle
  Operating System: Red Hat Enterprise Linux 8.4 (Ootpa)
       CPE OS Name: cpe:/o:redhat:enterprise_linux:8.4:GA
            Kernel: Linux 4.18.0-305.el8.x86_64
      Architecture: x86-64

# 각 서버의 ping check
[root@redhat84 etc]# ping redhat84-1
PING redhat84-1 (192.168.137.101) 56(84) bytes of data.
64 bytes from redhat84-1 (192.168.137.101): icmp_seq=1 ttl=64 time=0.081 ms

[root@redhat84 etc]# ping redhat84-2
PING redhat84-2 (192.168.137.102) 56(84) bytes of data.
64 bytes from redhat84-2 (192.168.137.102): icmp_seq=1 ttl=64 time=0.344 ms


[root@redhat84 etc]# ping redhat84-3
PING redhat84-3 (192.168.137.103) 56(84) bytes of data.
64 bytes from redhat84-3 (192.168.137.103): icmp_seq=1 ttl=64 time=0.681 ms

```
