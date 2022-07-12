- 노드 간 연결를 위해서 SSH Key 생성  

```bash
[root@centos8-140 ~]# ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:7CMQc1cq1+H6HoIDYXfVPjx0rPHfN636qjhph5R1hTE root@centos8-140
The key's randomart image is:
+---[RSA 3072]----+
|          +.E+   |
|         * .=.+  |
|    = + = o+ *   |
|   . * * .. B .  |
|    o   So . o .o|
|     o oo.     .=|
|      +.+oo    .o|
|       o==..  .  |
|       ..oo.o+.  |
+----[SHA256]-----+
[root@centos8-140 ~]#
```

![image](https://user-images.githubusercontent.com/39255123/178524117-e1a1bcc6-5150-4480-9dbc-f5c63d05f4fc.png)

- Public key copy     
```bash
[root@centos8-140 ~]# ssh-copy-id root@192.168.137.143
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host '192.168.137.143 (192.168.137.143)' can't be established.
ECDSA key fingerprint is SHA256:rPfQ9Sy/cWkheC8pGpOMapTcaJPtHQS/FQ9gxATwUsI.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@192.168.137.143's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@192.168.137.143'"
and check to make sure that only the key(s) you wanted were added.

[root@centos8-140 ~]# ssh 'root@192.168.137.143'
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Jul 13 00:08:31 2022 from 192.168.137.1
[root@centos8-143 ~]# exit
logout
Connection to 192.168.137.143 closed.
[root@centos8-140 ~]#   
```
