## tlskey 생성하기

### STEP
- 개인키 생성
  ```bash
  - openssl  genrsa  -out <키이름>   <비트 수> //암호없이 생성하는 방식

  $ openssl  genrsa  -out   tls_private.crt 2048  
  Generating RSA private key, 2048 bit long modulus (2 primes)
  ..................+++++
  ...............................................................................................................................................................+++++
   e is 65537 (0x010001)
  $openssl rsa -text -in tls_private.key  //정보확인.
  
  $ openssl rsa -in tls_private.crt -pubout -out tls_pub.key // 공개키 생성.
  writing RSA key
 
  - openssl  genrsa  -<암호화알고리즘>  -out <키이름>  <비트수> //  
  $ openssl genrsa -aes256 -out tls.key 2048
  
  ```
 kubectl create secret tls -n yanghwankim secret_ingress-tls --cert tls.crt --key tls.key
 
- CSR (인증서명요청. Certificate Signing Request)
```bash
# 개인키를 입력하여 CSR 생성하기
openssl  req  -new  -key <개인키>  -out <CSR 파일>

# 개인key도 같이 생성하는 방법.
# openssl  req  -new  -out <CSR 파일>  -keyout <개인키 파일>  -newkey  rsa:<키 비트수>
$ openssl req -new -out cert.csr -keyout cert.key -newkey rsa:2048
Generating a RSA private key
..................................+++++
..............................+++++
writing new private key to 'cert.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:test.ingress.co.kr
Locality Name (eg, city) []:test.ingress.co.kr
Organization Name (eg, company) [Internet Widgits Pty Ltd]:test.ingress.co.kr
Organizational Unit Name (eg, section) []:test.ingress.co.kr
Common Name (e.g. server FQDN or YOUR name) []:test.ingress.co.kr
Email Address []:test.ingress.co.kr

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:ingress
An optional company name []:test.ingress.co.kr  


```

- 인증서를 만든

To add each new host to the cluster, perform two steps:  
1. one step (public SSH key Copy)  
```bash
ssh-copy-id -f -i /etc/ceph/ceph.pub root@*<new-host>*

For example:
ssh-copy-id -f -i /etc/ceph/ceph.pub root@host2
ssh-copy-id -f -i /etc/ceph/ceph.pub root@host3
```
2. 신규 Node 추가

```bash
#ceph orch host add *<newhost>* [*<ip>*] [*<label1> ...*]

For example:
#ceph orch host add host2 10.10.0.102
#ceph orch host add host3 10.10.0.103

For Label ADD
#ceph orch host add host4 10.10.0.104 --labels master

# YAML를 이용하여 일괄등록하는 방식

# YAML 파일로 저장하고 ceph orch apply -i yaml명 을 이용하여 일괄저장할수 있다.
service_type: host
hostname: node-00
addr: 192.168.0.10
labels:
- example1
- example2
---
service_type: host
hostname: node-01
addr: 192.168.0.11
labels:
- grafana
---
service_type: host
hostname: node-02
addr: 192.168.0.12

```


3. 호스트 제거

```bash
# 호스트는 클러스터에서 모든 데몬이 제거되면 클러스터에서 안전하게 제거하는 방식
#ceph orch host drain *<host>*
#ceph orch osd rm status (OSD 상태)
#ceph orch ps <host> (완전삭제)

# Off-Line 상태에서 강제 제거하는 방식
#ceph orch host rm <host>  --force
```

4. 확인작업
```bash
# 등록된 Host에 대해서 확인가능
#ceph orch host ls [--format yaml]

```

```diff
- SPECIAL HOST LABELS (_no_schedule , _no_autotune_memory , _admin )를 이용하여 drain으로 관리방법  
- 로그 관리방법
```



