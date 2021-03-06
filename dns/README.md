##DNS Server Install

CentOS에 DNS를 설정하기 위해서 순서대로 설치 및 환경을 세팅한다.



- DNS 서버 IP 확인과 DNS Server IP를 확인한다.
```bash
[root@centos8-dns named]# ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.137.120  netmask 255.255.255.0  broadcast 192.168.137.255
        inet6 fe80::a00:27ff:fe65:d5c  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:65:0d:5c  txqueuelen 1000  (Ethernet)
        RX packets 3120  bytes 265921 (259.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1817  bytes 236134 (230.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

 #vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
 
[root@localhost ~]# cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 192.167.137.120
```

- networkmanager setting
```bash
#  「main」 항목에 「dns=none」를 추가하여 「resolv.conf」 파일에서 네임서버 정보가 관리하도록 설정.
[root@localhost ~]# vi /etc/NetworkManager/NetworkManager.conf
[main]
#plugins=ifcfg-rh
dns=none  

# networkmanager restart
[root@localhost ~]# systemctl restart NetworkManager

```

- 설치
``` bash
# 패키지를 설지 진행함.
# dnf -y install bind*
```

- 환경설정.
```bash
# vi /etc/named.conf
options {
        listen-on port 53 { any; };                 #변경
        listen-on-v6 port 53 { none; };             #변경
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        allow-query     { any; };                   #변경
        //allow-query     { localhost;192.168.137.0/24; };
~~~
~~~
};
```
- 정방향 조회 영역 파일과 역방향 조회 영역을 파일을 지정
```bash

```bash
#vi /etc/named.rfc1912.zones
# 정방향 추가
zone "rancherui.com" IN {
        type master;
        file "rancherui.com.db";
        allow-update { none; };
};
#역방향추가
zone "120.137.168.192.in-addr.arpa" IN {
        type master;
        file "rancherui.com.rdb";
        allow-update { none; };
};

```
- 정방향&역방향 File 생성후 설정
```bash
# named.localhost라는 정방향 조회파일을 복사후 수정
# named.loopback이라는 역방향 조회파일을 복사후 수정

[root@centos8-dns named]# cd /var/named
[root@centos8-dns named]# ls
rancherui.com.db  rancherui.com.rdb  
```
- DNS 환경설정
```bash
root@centos8-dns named]# vi rancherui.com.db
$TTL 1D
@       IN SOA  @ www.rancherui.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       192.168.137.120
ns      A       192.168.137.120
www     A       192.168.137.102


[root@centos8-dns named]# cat rancherui.com.rdb 
$TTL 1D
@       IN SOA  @ www.rancherui.com. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       192.168.137.102
        PTR     ns.rancherui.com.
 

```
- named restart
```bash
systemctl restart named
systemctl enable named

```

- service check
```bash
# DNS 설정이후 named status check
[root@centos8-dns named]# resolvectl status
Global
       LLMNR setting: yes
MulticastDNS setting: yes
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes
  Current DNS Server: 192.168.137.120
         DNS Servers: 192.168.137.120
          DNSSEC NTA: 10.in-addr.arpa
                      16.172.in-addr.arpa
                      168.192.in-addr.arpa
                      17.172.in-addr.arpa
                      18.172.in-addr.arpa
                      19.172.in-addr.arpa
                      20.172.in-addr.arpa
                      21.172.in-addr.arpa
                      22.172.in-addr.arpa
                      23.172.in-addr.arpa
                      24.172.in-addr.arpa
                      25.172.in-addr.arpa
                      26.172.in-addr.arpa
                      27.172.in-addr.arpa
                      28.172.in-addr.arpa
                      29.172.in-addr.arpa
                      30.172.in-addr.arpa
                      31.172.in-addr.arpa
                      corp
                      d.f.ip6.arpa
                      home
                      internal
                      intranet
                      lan
                      local
                      private
                      test

Link 3 (virbr0)
      Current Scopes: none
       LLMNR setting: yes
MulticastDNS setting: no
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes

Link 2 (enp0s3)
      Current Scopes: DNS LLMNR/IPv4 LLMNR/IPv6
       LLMNR setting: yes
MulticastDNS setting: no
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes
  Current DNS Server: 192.168.137.120
         DNS Servers: 192.168.137.120

[root@centos8-dns named]# resolvectl 
Failed to get global data: Unit dbus-org.freedesktop.resolve1.service not found.

# Error 발생시 Check
[root@centos8-dns named]# sudo systemctl status  systemd-resolved
● systemd-resolved.service - Network Name Resolution
   Loaded: loaded (/usr/lib/systemd/system/systemd-resolved.service; enabled; vendor preset: disabled)
   Active: active (running) since Wed 2022-03-16 21:29:57 KST; 4min 44s ago
     Docs: man:systemd-resolved.service(8)
           https://www.freedesktop.org/wiki/Software/systemd/resolved
           https://www.freedesktop.org/wiki/Software/systemd/writing-network-configuration-managers
           https://www.freedesktop.org/wiki/Software/systemd/writing-resolver-clients
 Main PID: 2584 (systemd-resolve)
   Status: "Processing requests..."
    Tasks: 1 (limit: 4771)
   Memory: 3.8M
   CGroup: /system.slice/systemd-resolved.service
           └─2584 /usr/lib/systemd/systemd-resolved

 3월 16 21:29:57 centos8-dns systemd[1]: Starting Network Name Resolution...
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: Positive Trust Anchors:
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: . IN DS 19036 8 2 49aac11d7b6f6446702e54a1607371607a1a41855200fd2ce1cdde32f24e8fb5
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: . IN DS 20326 8 2 e06d44b80b8f1d39a95c0b0d7c65d08458e880409bbc683457104237c7f8ec8d
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: Negative trust anchors: 10.in-addr.arpa 16.172.in-addr.arpa 17.172.in-addr.arpa 18.172.in-addr.arpa 19.172.in-addr.arpa 20.172.in-addr.arpa 21.172.in-addr.arpa 22.172.in-addr.arpa 23>
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: Using system hostname 'centos8-dns'.
 3월 16 21:29:57 centos8-dns systemd[1]: Started Network Name Resolution.
 3월 16 21:29:57 centos8-dns systemd-resolved[2584]: request_name_destroy_callback n_ref=1
lines 1-22/22 (END)

```

- Client에서 Test 진행
```bash
# Client에서는 DNS에 해당 DNS 서버를 추가한다.
[root@centos8-nfs ~]#  resolvectl status
Global
       LLMNR setting: yes
MulticastDNS setting: yes
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes
  Current DNS Server: 192.168.137.120
         DNS Servers: 192.168.137.120
                      168.126.63.1
                      
# Test
[root@centos8-nfs ~]# nslookup
> www.rancherui.com
Server:         192.168.137.120
Address:        192.168.137.120#53

Name:   www.rancherui.com
Address: 192.168.137.102
> www.google.com  
Server:         192.168.137.120
Address:        192.168.137.120#53

Non-authoritative answer:
Name:   www.google.com
Address: 142.250.204.68
Name:   www.google.com
Address: 2404:6800:4005:813::2004

```
## 삭제
```bash
#sudo systemctl disable systemd-resolved.service
#sudo systemctl stop systemd-resolved
  
#Then put the following line in the [main] section of your /etc/NetworkManager/NetworkManager.conf:

dns=default

#Delete the symlink /etc/resolv.conf

#rm /etc/resolv.conf
#Restart network-manager

  sudo service network-manager restart
```  
