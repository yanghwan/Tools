## process 일괄 찾아서 죽이는 방법
```bash
[root@centos8-dns ~]# docker ps -a
CONTAINER ID   IMAGE                             COMMAND                  CREATED      STATUS                     PORTS     NAMES
32e4f0216585   rancher/healthcheck:v0.3.8        "/.r/r /rancher-entr…"   7 days ago   Exited (255) 3 days ago              r-healthcheck-healthcheck-1-cf4b00e2
c8fc2bba45ec   rancher/net:v0.13.17              "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-ipsec-ipsec-router-1-5e8ebd68
b0148fa9916d   rancher/net:v0.13.17              "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-ipsec-ipsec-connectivity-check-1-f7c0bdcb
9a462502fe72   rancher/dns:v0.17.4               "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-network-services-metadata-dns-1-104fa42c
bfc406b48897   rancher/net:holder                "/.r/r /rancher-entr…"   7 days ago   Exited (255) 3 days ago              r-ipsec-ipsec-1-90cd28a1
567b8a66e6ab   rancher/metadata:v0.10.4          "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-network-services-metadata-1-b50a952e
4b43cdb180f3   rancher/network-manager:v0.7.22   "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-network-services-network-manager-1-bdb2da05
e9f5064db411   rancher/net:v0.13.17              "/rancher-entrypoint…"   7 days ago   Exited (255) 3 days ago              r-ipsec-cni-driver-1-3dc177c4
b8cd81a591eb   rancher/agent:v1.2.11             "/run.sh run"            7 days ago   Exited (1) 3 seconds ago             rancher-agent
2b238edfbdfe   rancher/server                    "/usr/bin/entry /usr…"   7 days ago   Created                              intelligent_panini
5571fe2f393b   rancher/server                    "/usr/bin/entry /usr…"   7 days ago   Exited (0) 22 hours ago              peaceful_lamarr
e7e061d206f8   rancher/server:stable             "/usr/bin/entry /usr…"   7 days ago   Exited (0) 7 days ago                upbeat_wilson

[root@centos8-dns ~]# docker ps -a | awk '{print $1}' 
CONTAINER
32e4f0216585
c8fc2bba45ec
b0148fa9916d
9a462502fe72
bfc406b48897
567b8a66e6ab
4b43cdb180f3
e9f5064db411
b8cd81a591eb
2b238edfbdfe
5571fe2f393b
e7e061d206f8

[root@centos8-dns ~]# docker ps -a | awk '{print $1}' | while read line; do  echo $line ; docker rm  $line;done
CONTAINER
32e4f0216585
32e4f0216585
c8fc2bba45ec
c8fc2bba45ec
b0148fa9916d
b0148fa9916d
9a462502fe72
9a462502fe72
bfc406b48897
bfc406b48897
567b8a66e6ab
567b8a66e6ab
4b43cdb180f3
4b43cdb180f3
e9f5064db411
e9f5064db411
b8cd81a591eb
b8cd81a591eb
2b238edfbdfe
2b238edfbdfe
5571fe2f393b
5571fe2f393b
e7e061d206f8
e7e061d206f8
[root@centos8-dns ~]# docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES


```
