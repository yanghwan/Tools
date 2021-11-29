# CEPH  

Reliable Automatic Distributed Object Store 
- Ceph cluster의 모니터링, 관리 그리고 data의 저장 및 분산과 같은 Ceph의 실질적인 기능 제공한다.  




특히 RedHat8 and ProLinux8 부터는 기본 NTP로 패키징되어 있으며, 타임서버 리스트(Stratum)에 대해서는   
Address : kr.pool.ntp.org / time.bora.net / time.nuri.net
많이 사용을 하고 있지만, 국내 타임서버 리스트는  http://time.ewha.or.kr/domestic.html에서 정보를 확인할수 있습니다.  

*	NTP (TimeServer) 구성
 ![ntp_1](https://user-images.githubusercontent.com/39255123/141034679-0bf319f8-286f-4691-9eb1-847bf0f6bacd.jpg)
 
내부에 fail over를 위해 Stratum 3 level의 Time server 2대를 구성하고, private network 안에 있는 server/client 들이 이 time server를 통해서 시간 동기화를 하도록 구성을 하도록 합니다.
그리고, 2대의 Time server 간에는 peer 구성을 하여 서로 동기화를 하게 할 수 있지만, Time service 특성상 peer 구성 보다는 그냥 master 2대로 구성하는 것이 관리상 더 편했던 것 같습니다. 그래서 여기서는 peer 구성은 하지 않고 그냥 time server 2대를 독립적으로 구성하되, sync할 stratum 2 level의 서버를 동일하게 지정하여 peer 설정을 한 것과 비슷하게 구성을 할 것입니다.

Chrony는 기본적으로 UDP 123번 포트를 사용하기 때문에 Time Server1/Time Server2에 대한 포트를 Allow 해줘야 되며, 방화벽은 반드시 확인이 필요하다.
* 설정파일  
```bash
[root@master2 etc]# cat /etc/chrony.conf
pool 2.pl.pool.ntp.org iburst

# Record the rate at which the system clock gains/losses time.  # 시간오차치를 보존해두는 파일정보
driftfile /var/lib/chrony/drift
# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3
# Enable kernel synchronization of the real-time clock (RTC).
rtcsync
# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *
# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2
# Allow NTP client access from local network.
allow 192.168.0.0/16
# Serve time even if not synchronized to a time source.
local stratum 3
# Specify file containing keys for NTP authentication.
keyfile /etc/chrony.keys
# Get TAI-UTC offset and leap seconds from the system tz database.
#leapsectz right/UTC
# Specify directory for log files.
logdir /var/log/chrony
# Select which information is logged.
#log measurements statistics tracking
# restrict 127.xxx.xxx.xxx  #Peer들이 본서버로 Sync를 하는 것을 제한
```    
서버 및 Clinet의 참조하는 주소를 변경하여 시간 동기화를 할수있으며, Client는 아래 옵션을 주석처리해서 재기동하면 됩니다.
```bash
# Allow NTP client access from local network. – 제외
# Serve time even if not synchronized to a time source. – 제외
#server  xxx.xxx.xxx.xxx  iburst – chrony server ip 

ex)
#allow 192.168.0.0/16  
##local stratum 3  
server 192.168.178.44 iburst  
```  

* 서비스종료 / 시작  
``` bash
[root@master1 etc]# systemctl stop  chronyd
[root@master1 etc]# systemctl start  chronyd
[root@master1 etc]# systemctl restart  chronyd
[root@master1 etc]# systemctl enstart  chronyd
```  
