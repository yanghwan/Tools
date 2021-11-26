# Chrony  

chrony는 NTP(Network Time Protocol)을 구현한 server/client 형태로 구성을 하며, 기준 리눅스의 NTPD를 대체합니다.
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
*	Chronyd 상태확인  
```bash
[root@master1 ~]# service chronyd status
Redirecting to /bin/systemctl status chronyd.service
[0m chronyd.service - NTP client/server
   Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2021-11-04 00:30:30 EDT; 4 days ago
     Docs: man:chronyd(8)
           man:chrony.conf(5)
  Process: 1015 ExecStartPost=/usr/libexec/chrony-helper update-daemon (code=exited, status=0/SUCCESS)
  Process: 974 ExecStart=/usr/sbin/chronyd $OPTIONS (code=exited, status=0/SUCCESS)
Main PID: 985 (chronyd)
    Tasks: 1 (limit: 47933)
   Memory: 3.9M
   CGroup: /system.slice/chronyd.service
           985 /usr/sbin/chronyd

1104 00:30:28 master1 systemd[1]: Starting NTP client/server...
1104 00:30:29 master1 chronyd[985]: chronyd version 3.5 starting (+CMDMON +NTP +REFCLOCK +RTC +PRIVDROP +SCFILTER +SIGND +ASYNCDNS +SECHASH +IPV6 +DEBUG)
1104 00:30:29 master1 chronyd[985]: Frequency 0.000 +/- 1000000.000 ppm read from /var/lib/chrony/drift
1104 00:30:29 master1 chronyd[985]: Using right/UTC timezone to obtain leap second data
1104 00:30:30 master1 systemd[1]: Started NTP client/server.
1104 00:30:45 master1 chronyd[985]: Selected source 109.173.170.112
1104 00:30:45 master1 chronyd[985]: System clock TAI offset set to 37 seconds
1104 00:30:45 master1 chronyd[985]: System clock wrong by -29.389047 seconds, adjustment started
1104 00:30:16 master1 chronyd[985]: System clock was stepped by -29.389047 s
```  

* TimeDate 확인
```bash  
[root@master1 ~]# timedatectl
               Local time: 2021-11-08 05:20:19 EST
           Universal time: 2021-11-08 10:20:19 UTC
                 RTC time: 2021-11-08 10:20:19
                Time zone: America/New_York (EST, -0500)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```  

* chronyc 설정  
```bash  
root@master1 ~]# chronyc
chrony version 3.5
Copyright (C) 1997-2003, 2007, 2009-2019 Richard P. Curnow and others
chrony comes with ABSOLUTELY NO WARRANTY.  This is free software, and
you are welcome to redistribute it under certain conditions.  See the
GNU General Public License version 2 for details.

chronyc> sources -v
210 Number of sources = 4

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
/ .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^+ 96-7.cpe.smnt.pl              2  10   377   715  -1353us[-1375us] +/-  184ms
^* main.jakspzoo.pl              2  10   377   263    +19ms[  +19ms] +/-  151ms
^+ old.histeria.pl               2  10   377   758    -15ms[  -15ms] +/-  177ms
^+ d170-112.icpnet.pl            1  10   377   491  -3240us[-3262us] +/-  160ms

M Info – ( ^ 서버 / = 피어 / # 로컬) 
S Info – ( * 현재 동기화중 / + 등록한 소스와 동기화 가능 / - 등록한 소스와 동기화 불가능 / ? or blank(빈칸) : 응답 없음(unreachable) / x 서버와 시간차이가 큼) 
```

* 실시간 시간동기화 
```bash  
[root@master1 etc]# chronyc -a makestep
200 OK

[root@master2 etc]# chronyc sources
210 Number of sources = 4
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^+ 46.175.224.7.maxnet.net.>     2   6    37    48  -4800us[-4225us] +/-  179ms
^+ ntp.ifj.edu.pl                1   6    37    47  +1266us[+1266us] +/-  149ms
^- ntp2.tktelekom.pl             2   6    37    47   +513us[ +513us] +/-  165ms
^* ntp.coi.pw.edu.pl             1   6    37    48   +558us[+1133us] +/-  148ms
```  

*	상태확인 
```bash  
- Server
[root@master2 etc]# chronyc sources
210 Number of sources = 4
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^+ 46.175.224.7.maxnet.net.>     2   6    37    48  -4800us[-4225us] +/-  179ms
^+ ntp.ifj.edu.pl                1   6    37    47  +1266us[+1266us] +/-  149ms
^- ntp2.tktelekom.pl             2   6    37    47   +513us[ +513us] +/-  165ms
^* ntp.coi.pw.edu.pl             1   6    37    48   +558us[+1133us] +/-  148ms

- Client
[root@master3 etc]# chronyc sources 
210 Number of sources = 2
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
^+ 192.168.178.43                3   6    17    26  +8928us[+8928us] +/-  169ms
^* 192.168.178.44                2   6    17    26  -7974us[-7983us] +/-  151ms

```

* NTP Tracking 
```bash
[root@master3 etc]# chronyc tracking
Reference ID    : C0A8B22B (192.168.178.43)
Stratum         : 5
Ref time (UTC)  : Tue Nov 09 07:49:39 2021
System time     : 0.000563108 seconds fast of NTP time
Last offset     : +0.000047939 seconds
RMS offset      : 0.002824150 seconds
Frequency       : 35.006 ppm fast
Residual freq   : +0.046 ppm
Skew            : 1.389 ppm
Root delay      : 0.172546864 seconds
Root dispersion : 0.002234325 seconds
Update interval : 64.2 seconds
Leap status     : Normal
```
