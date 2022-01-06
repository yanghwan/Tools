## tlskey 생성하기

### STEP
- 개인키 생성
  ```bash
  - openssl  genrsa  -out <키이름>   <비트 수> //암호없이 생성하는 방식

  $ openssl  genrsa  -out   tls_private.crt 2048  
  Generating RSA private key, 2048 bit long modulus (2 primes)
  ..................+++++
  ..................................................+++++
   e is 65537 (0x010001)
  $openssl rsa -text -in tls_private.key  //정보확인.
  
  $ openssl rsa -in tls_private.crt -pubout -out tls_pub.key // 공개키 생성.
  writing RSA key
 
  - openssl  genrsa  -<암호화알고리즘>  -out <키이름>  <비트수> //  
  $ openssl genrsa -aes256 -out tls.key 2048
  
  ```
  
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
```bash
#CSR을 명시적으로 넣어 인증서를 만드는 방법
#openssl  x509  -req  -days <유효날수>  -in <인증사인요청파일>  -signkey <개인키>  -out <인증서 파일명>

$ openssl  x509  -req  -days 365  -in cert.csr  -signkey cert.key  -out cert.crt
Signature ok
subject=C = AU, ST = test.ingress.co.kr, L = test.ingress.co.kr, O = test.ingress.co.kr, OU = test.ingress.co.kr, CN = test.ingress.co.kr, emailAddress = test.ingress.co.kr
Getting Private key
Enter pass phrase for cert.key:
$ ls
bin  boot  cert.crt  cert.csr  cert.key  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var


CSR을 넣지 않고 (암묵적으로 CSR을 생성/이용하여) 인증서를 만드는 방법
openssl req  -new  -x509  -days <유효날수>  -key <개인키>  -out <인증서파일명>
$openssl  req  -new  -x509  -days 365  -key cert.key  -out  cert.crt

```

### K8S TLS Key 생성하기.

```bash
-signkey cert.key  -out cert.crt
kubectl create secret tls -n yanghwankim secret_ingress-tls --cert cert.key --key cert.crt

```


