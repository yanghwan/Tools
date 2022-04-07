## Example 작성

## 프로젝트 및 Directory 생성  
Helm Directory 구조를 파악후 용도 및 기능에 맞춰서 yaml 파일을 생성후 install 하면 배포할수가 있다.  

```bash
# helm create worklist

# 디렉토리 구조
# tree ./worklist /f 
PS C:\yanghwan\helm> tree worklist /f
C:\YANGHWAN\HELM\WORKLIST
│  .helmignore
│  Chart.yaml                                 # 
│  values.yaml
│
├─charts
└─templates
    │  deployment.yaml
    │  hpa.yaml
    │  ingress.yaml
    │  NOTES.txt
    │  service.yaml
    │  serviceaccount.yaml
    │  _helpers.tpl
    │
    └─tests
            test-connection.yaml

# 파일 설명
#1. Chart.yaml 
  - helm create를 수행하면 자동으로 생성되며, 기본적인 정보 관리
  - apiVersion, name, description, type, version, appVersion 필드등을 입력
#2. values.yaml 
  - template 디렉터리 밑에 위치한 Manifest Template 파일들과 결합하여 실제 Kubernetes Manifest 생성
#3. Template 폴더 
  - Chart를 통해 생성될 서비스 오프젝트 
  - ex) ConfigMap를 생성한다고 가정하며 ConfigMap.yaml 생성해서 정의에 맞게 수정하면 helm install시 적용이 된다.
  - templates/NOTES.txt: 차트 생성 시 나타나는 설명이 들어갑니다.
#4. charts Directory : 의존성이 있는 차트 패키지들이 설치됩니다.
#5. requirements.yaml: 의존성 차트들이 들어갑니다.

```

## Windows에서 Helm Chart 실행하기
1. kubectl download
```bash
c:\ curl -LO "https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe"

```

2. 원격 클러스터를 사용하기 위한 환경설정.
```bash
# home directory 이동
C:\Users\yangh>cd %USERPROFILE%
# .kube directory 생성
C:\Users\yangh>mkdir .kube
C:\Users\yangh>cd .kube

# Config 환경설정 (default를 사용하지 않는경우)
# windows cmd 창에서 kubectl 명령어 수행가능
# set KUBECONFIG=C:\helm-3.8.1\kube 


# Master Server에서 config File Copy
C:\Users\yangh\.kube>sftp root@192.168.137.101
root@192.168.137.101's password:
Connected to 192.168.137.101.
sftp> cd .kube
sftp> ls
cache   config
sftp> get config
Fetching /root/.kube/config to config
/root/.kube/config                                                                    100% 5599     1.5MB/s   00:00
sftp> q

# kubectl 명령어로 Status 상태확인
PS C:\yanghwan\helm> kubectl get nodes;
NAME        STATUS     ROLES                  AGE   VERSION
centos8-1   Ready      control-plane,master   20d   v1.21.10
centos8-2   Ready      <none>                 20d   v1.21.10
centos8-3   NotReady   <none>                 19d   v1.21.10

#namespace 생성
[root@centos8-1 ~]# kubectl create namespace yanghwan
namespace/yanghwan created

  
#serviceaccount & role & rolebinding
apiVersion: v1
kind: ServiceAccount
metadata:
  name: yanghwan
  namespace: yanghwan
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: helm-manager
  namespace: yanghwan  
rules:
  - apiGroups: ["", "batch", "extensions", "apps"]
    resources: ["*"]
    verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: helm-binding
  namespace: yanghwan  
subjects:
  - kind: ServiceAccount
    name: yanghwan
    namespace: yanghwan    
roleRef:
  kind: Role
  name: helm-manager
  apiGroup: rbac.authorization.k8s.io
  
# Namespace Default Setting  
#kubectl config set-context --current --namespace=yanghwan


# helm init(serviceaccount setting)

# K8S RootCA로 부터 인증서 발급받기
1. private key 생성 / 2. private key를 이용하여 csr 생성 / 
3. csr File를 base64로 encoding한 문자열을 이용하여 Kubernetes의 CertificateSigningRequest Manifest 작성 및 인증서 발급 요청
인증서를 이용하여 PKI 생성
4. 인증서 발급 요청 수락


1.  private key 생성 
# openssl genrsa -out yanghwan.key 4096

2. 2. private key를 이용하여 csr 생성
# openssl req -new -key yanghwan.key -out yanghwan.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:kr
State or Province Name (full name) []:seoul
Locality Name (eg, city) [Default City]:seoul
Organization Name (eg, company) [Default Company Ltd]:hana
Organizational Unit Name (eg, section) []:hana
Common Name (eg, your name or your server's hostname) []:yanghwan       # 실제 사용할 계정
Email Address []:yanghwankim@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:yanghwan
An optional company name []:yanghwan

3. CSR Base64 Encoding 
# cat yanghwan.csr | base64 | tr -d "\n"
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJRS9EQ0NBdVFDQVFBd2dZUXhDekFKQmdOVkJBWVRBbXR5TVE0d0RBWURWUVFJREFWelpXOTFiREVPTUF3RwpBMVVFQnd3RmMyVnZkV3d4RFRBTEJnTlZCQW9NQkdoaGJtRXhEVEFMQmdOVkJBc01CR2hoYm1FeEVUQVBCZ05WCkJBTU1DSGxoYm1kb2QyRnVNU1F3SWdZSktvWklodmNOQVFrQkZoVjVZVzVuYUhkaGJtdHBiVUJuYldGcGJDNWoKYjIwd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUURvcHNQNlRQeHlFS0lJYWpQdQpkN0syUnZIc3o2b3BNMDE5czhQOEpBeDdvK1o3SGx5UVF3N01NdEtvY0xvTzg3UHdtS0RaZnI4cTJNZC9PRm1jCm0yd1A0cDludHA4ZG00d1dRSDVSSllsSmxsNnB2NXN4R210RWVSdWFyN25Ia3k1THpBSzFLTkVYTEFaYXdQNWwKRVI0OFRDR0trbzltbC9vaGkvbVNSMXR5dFJ3NDFtQTgrNGpOYVNvZGl3Z1RVWCtTcUlBZy9SRHBJZGVwbDJweQptNklLMm5PZXM0aUIzK0RwQngzQzJucWRBamhzOWRCcDBrcWE0dERrR3RDYjd3MjIxWXIwemV3cXh5VEpjTmFqCjZFUjZ3RkRYMml1OU90Sy9MMk1qMXdQMitVcEFUcHZJbnlGQmx6S25YWHV3aUNUa0Y3RjBBaW1GSUNOekM0VXkKWHF3Z1pkUDgzSmtSeERabjBrOFphUm1lRktQdWhvc1ZkODlZcmY2d1V4NkJSNHpyRmlrUjdXbjU2YmRnekdYbQprVUM1TE5JOFkrNlg0dzFzU3IvV3ZQT1lSclhIR2JsVDhnVnpJcDIxalI0bzdhV3hUdTNZRjNtRExmQ2dvMFo4CmRwVHlKQkx6SnlSS2R2RWh0VjMwcXM2TnFJQmhCUjFPb1VGMG9HS0VVZFh3OU9XbDRhTDQySVJlS0VQRjhyNHQKWC9yRWFsbE55bUpHaEt4bVJHK21QZjhzdy9qZzlBVkRUUWVLK09sY3kxZkxLNzVjdUJSV3pJblIwY2c4VTV2SQp2NlUwdU1VOHkybXZ2T2ZyQkxjQ3VDUmNiMURycllMQ0ZsYzR5WHN4S21DRTFmNVBoeExYOUpNWkZmbmVjR1l2CkNQMkp3UktJaEVVZnFxd0Zqa0FFTkdLOSt3SURBUUFCb0RJd0Z3WUpLb1pJaHZjTkFRa0NNUW9NQ0hsaGJtZG8KZDJGdU1CY0dDU3FHU0liM0RRRUpCekVLREFoNVlXNW5hSGRoYmpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQWdFQQpUWE4rdVhPaERhbVVOL1ltWW9WSnpLTEE5cFFFZ29BZUVpcWZJZlB6SUVMejc1bGUzZjYzbHB6R0dtVnV4aGM2CkpabTNmS0lJR2NWeEQ4RTQxVnZpUzFKK0NwZHNZekU0MDQzUHdoOWZkb2NmQTRlSTBOMW55Wm83TjFETWJiWmYKQTIxeVkzSWZvdXI1ZzNnNXI4Mm5vKytUVTI5dmNFbDM2amIxbXIrRkFyb1JZK3VMZGx5UnhKZnA4amdFc21TUwprcS9QMXdwWG94SStqVStOVHV1clh6RS9MTElPWVlXRTErMXd1YXppL3p2cnV6SmdmWWtXWTB6Ylc2c0RPcmF4Cm1zU1E3YkdtZFRkeExwVXY0OFNKYVRlR3JsdndkOFgrYnRGOTJsMy96L3Z4dnJ5UkpraVJ6emthTTE5MUpRWXUKcVRkelJEbzJuemZUMFYvaUw3UDhCVncybG91VXRIOWJlcmt3QzNkMHNIbmNyZytWVks0bGR2a2U0Q1JtdjkzMAp2aVhnZWhqbGlXdlZXOCs2MWFoM0tZdWdPZzRKVDRmdWFqU0FtQzRuRnlFNlBTNXdDdFVrODNacmtvMVFxYmtICkhLYnhtc1RoZFNFd1dXRktodmlRMjZvczBES1JJVExuVkdXT1ZCMFBSY3RuMGJIRXF5aHhxQm02bVl1NjAvT1UKS1hXWjZqbThSWlUyYWpBd08wbDBSTUFWcVhDS2l4dTJHWHBjaWNLVkNQaGxCMlhEYVRLNW9DVDBtUFZFYjQ1TgpwdmZMQkwyK2xwcWxBcG13aXE1YUsyK1BlOEJGUjFzWjBkZktHSVVjcXJMaUVsUWhjS0lheUhidUxPTkFxZ1Z3ClVpbUZhMjlYWUtEN2lSUmxRWitySGdLVWU0aE5sSkg1RFg2NDBNL01lcWc9Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=

# cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: yanghwan
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJRS9EQ0NBdVFDQVFBd2dZUXhDekFKQmdOVkJBWVRBbXR5TVE0d0RBWURWUVFJREFWelpXOTFiREVPTUF3RwpBMVVFQnd3RmMyVnZkV3d4RFRBTEJnTlZCQW9NQkdoaGJtRXhEVEFMQmdOVkJBc01CR2hoYm1FeEVUQVBCZ05WCkJBTU1DSGxoYm1kb2QyRnVNU1F3SWdZSktvWklodmNOQVFrQkZoVjVZVzVuYUhkaGJtdHBiVUJuYldGcGJDNWoKYjIwd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUURvcHNQNlRQeHlFS0lJYWpQdQpkN0syUnZIc3o2b3BNMDE5czhQOEpBeDdvK1o3SGx5UVF3N01NdEtvY0xvTzg3UHdtS0RaZnI4cTJNZC9PRm1jCm0yd1A0cDludHA4ZG00d1dRSDVSSllsSmxsNnB2NXN4R210RWVSdWFyN25Ia3k1THpBSzFLTkVYTEFaYXdQNWwKRVI0OFRDR0trbzltbC9vaGkvbVNSMXR5dFJ3NDFtQTgrNGpOYVNvZGl3Z1RVWCtTcUlBZy9SRHBJZGVwbDJweQptNklLMm5PZXM0aUIzK0RwQngzQzJucWRBamhzOWRCcDBrcWE0dERrR3RDYjd3MjIxWXIwemV3cXh5VEpjTmFqCjZFUjZ3RkRYMml1OU90Sy9MMk1qMXdQMitVcEFUcHZJbnlGQmx6S25YWHV3aUNUa0Y3RjBBaW1GSUNOekM0VXkKWHF3Z1pkUDgzSmtSeERabjBrOFphUm1lRktQdWhvc1ZkODlZcmY2d1V4NkJSNHpyRmlrUjdXbjU2YmRnekdYbQprVUM1TE5JOFkrNlg0dzFzU3IvV3ZQT1lSclhIR2JsVDhnVnpJcDIxalI0bzdhV3hUdTNZRjNtRExmQ2dvMFo4CmRwVHlKQkx6SnlSS2R2RWh0VjMwcXM2TnFJQmhCUjFPb1VGMG9HS0VVZFh3OU9XbDRhTDQySVJlS0VQRjhyNHQKWC9yRWFsbE55bUpHaEt4bVJHK21QZjhzdy9qZzlBVkRUUWVLK09sY3kxZkxLNzVjdUJSV3pJblIwY2c4VTV2SQp2NlUwdU1VOHkybXZ2T2ZyQkxjQ3VDUmNiMURycllMQ0ZsYzR5WHN4S21DRTFmNVBoeExYOUpNWkZmbmVjR1l2CkNQMkp3UktJaEVVZnFxd0Zqa0FFTkdLOSt3SURBUUFCb0RJd0Z3WUpLb1pJaHZjTkFRa0NNUW9NQ0hsaGJtZG8KZDJGdU1CY0dDU3FHU0liM0RRRUpCekVLREFoNVlXNW5hSGRoYmpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQWdFQQpUWE4rdVhPaERhbVVOL1ltWW9WSnpLTEE5cFFFZ29BZUVpcWZJZlB6SUVMejc1bGUzZjYzbHB6R0dtVnV4aGM2CkpabTNmS0lJR2NWeEQ4RTQxVnZpUzFKK0NwZHNZekU0MDQzUHdoOWZkb2NmQTRlSTBOMW55Wm83TjFETWJiWmYKQTIxeVkzSWZvdXI1ZzNnNXI4Mm5vKytUVTI5dmNFbDM2amIxbXIrRkFyb1JZK3VMZGx5UnhKZnA4amdFc21TUwprcS9QMXdwWG94SStqVStOVHV1clh6RS9MTElPWVlXRTErMXd1YXppL3p2cnV6SmdmWWtXWTB6Ylc2c0RPcmF4Cm1zU1E3YkdtZFRkeExwVXY0OFNKYVRlR3JsdndkOFgrYnRGOTJsMy96L3Z4dnJ5UkpraVJ6emthTTE5MUpRWXUKcVRkelJEbzJuemZUMFYvaUw3UDhCVncybG91VXRIOWJlcmt3QzNkMHNIbmNyZytWVks0bGR2a2U0Q1JtdjkzMAp2aVhnZWhqbGlXdlZXOCs2MWFoM0tZdWdPZzRKVDRmdWFqU0FtQzRuRnlFNlBTNXdDdFVrODNacmtvMVFxYmtICkhLYnhtc1RoZFNFd1dXRktodmlRMjZvczBES1JJVExuVkdXT1ZCMFBSY3RuMGJIRXF5aHhxQm02bVl1NjAvT1UKS1hXWjZqbThSWlUyYWpBd08wbDBSTUFWcVhDS2l4dTJHWHBjaWNLVkNQaGxCMlhEYVRLNW9DVDBtUFZFYjQ1TgpwdmZMQkwyK2xwcWxBcG13aXE1YUsyK1BlOEJGUjFzWjBkZktHSVVjcXJMaUVsUWhjS0lheUhidUxPTkFxZ1Z3ClVpbUZhMjlYWUtEN2lSUmxRWitySGdLVWU0aE5sSkg1RFg2NDBNL01lcWc9Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
  usages:
  - client auth
EOF

#인증서 상태
[root@centos8-1 ~]# kubectl get csr
NAME       AGE   SIGNERNAME                     REQUESTOR          CONDITION
yanghwan   75s   kubernetes.io/legacy-unknown   kubernetes-admin   Pending

4. 승인 
[root@centos8-1 ~]# kubectl certificate approve yanghwan
certificatesigningrequest.certificates.k8s.io/yanghwan approved
[root@centos8-1 ~]# kubectl get csr
NAME       AGE   SIGNERNAME                     REQUESTOR          CONDITION
yanghwan   15m   kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issued
[root@centos8-1 ~]# 

5. 생성한 인증서 저장.
[root@centos8-1 ~]# kubectl get csr
NAME       AGE   SIGNERNAME                     REQUESTOR          CONDITION
yanghwan   19m   kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issued
[root@centos8-1 ~]# kubectl get csr/yanghwan -o json  | jq -r .status.certificate | base64 --decode > yanghwan.crt
[root@centos8-1 ~]# cat yanghwan.crt
-----BEGIN CERTIFICATE-----
MIIEQzCCAyugAwIBAgIQLLtEh6D8XT9Fm652d+N4oTANBgkqhkiG9w0BAQsFADAV
MRMwEQYDVQQDEwprdWJlcm5ldGVzMB4XDTIyMDMzMTE0NTMzM1oXDTIzMDMzMTE0
NTMzM1owXjELMAkGA1UEBhMCa3IxDjAMBgNVBAgTBXNlb3VsMQ4wDAYDVQQHEwVz
ZW91bDENMAsGA1UEChMEaGFuYTENMAsGA1UECxMEaGFuYTERMA8GA1UEAxMIeWFu
Z2h3YW4wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDopsP6TPxyEKII
ajPud7K2RvHsz6opM019s8P8JAx7o+Z7HlyQQw7MMtKocLoO87PwmKDZfr8q2Md/
OFmcm2wP4p9ntp8dm4wWQH5RJYlJll6pv5sxGmtEeRuar7nHky5LzAK1KNEXLAZa
wP5lER48TCGKko9ml/ohi/mSR1tytRw41mA8+4jNaSodiwgTUX+SqIAg/RDpIdep
l2pym6IK2nOes4iB3+DpBx3C2nqdAjhs9dBp0kqa4tDkGtCb7w221Yr0zewqxyTJ
cNaj6ER6wFDX2iu9OtK/L2Mj1wP2+UpATpvInyFBlzKnXXuwiCTkF7F0AimFICNz
C4UyXqwgZdP83JkRxDZn0k8ZaRmeFKPuhosVd89Yrf6wUx6BR4zrFikR7Wn56bdg
zGXmkUC5LNI8Y+6X4w1sSr/WvPOYRrXHGblT8gVzIp21jR4o7aWxTu3YF3mDLfCg
o0Z8dpTyJBLzJyRKdvEhtV30qs6NqIBhBR1OoUF0oGKEUdXw9OWl4aL42IReKEPF
8r4tX/rEallNymJGhKxmRG+mPf8sw/jg9AVDTQeK+Olcy1fLK75cuBRWzInR0cg8
U5vIv6U0uMU8y2mvvOfrBLcCuCRcb1DrrYLCFlc4yXsxKmCE1f5PhxLX9JMZFfne
cGYvCP2JwRKIhEUfqqwFjkAENGK9+wIDAQABo0YwRDATBgNVHSUEDDAKBggrBgEF
BQcDAjAMBgNVHRMBAf8EAjAAMB8GA1UdIwQYMBaAFNO4sVRB10pCNVZuOFRdRaKK
lk//MA0GCSqGSIb3DQEBCwUAA4IBAQBtAEbchbbR4c/u1329jtIXVIanNk9adRkQ
oI2nhGpa4+Um+Z6aIcoT9cpC9xzc7VG+JoQhaBlF6YRC0R/OXe/tLgR0h5UYxjhx
rxXpLTrjl6QdzazgIv8gI8vA0/XqH4Nn3/gMOAMbpsEYl5mLn1FV+UvmKliuc7JQ
HMwbvoNLKVrtI7gswc2G/frU6BwsBpTsjLWMqxGUIdtz4lBTg8qEiAXNKpakSxFy
XVk93T7HJqJ+UJo7wbpA/N4M8lnlfqnrUGSViwMrjw87yUmAyp8GSQt6vIOKWWVJ
YafEx/AC+2/jRtaz6+0IMq3VczvGXTLUktENLCVxPeQn/n0OX/oJ
-----END CERTIFICATE-----



#인증을 위한 사용자 정보 등록 (key, crt 로 접속)
# kubectl config set-credentials yanghwan@helm --client-certificate=/root/yanghwan.crt --client-key=/root/yanghwan.key --embed-certs=true
 

# Kubectl config context 생성
# kubectl config get-clusters NAME cluster.local 
#context 생성
# kubectl config set-context yanghwan@helm --cluster=kubernetes --user=yanghwan --namespace=yanghwan



```




## Helm Chart 실행
```bash
https://blog.naver.com/mantechbiz/221447296981
https://blog.naver.com/isc0304/222513958747
https://ssup2.github.io/theory_analysis/Kubernetes_CSR/
```
