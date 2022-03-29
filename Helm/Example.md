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

# ServiceAccount 생성
kubectl create serviceaccount yanghwan

#role & rolebinding
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: helm-manager
rules:
  - apiGroups: ["", "batch", "extensions", "apps"]
    resources: ["*"]
    verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: helm-binding
subjects:
  - kind: ServiceAccount
    name: yanghwan
roleRef:
  kind: Role
  name: helm-manager
  apiGroup: rbac.authorization.k8s.io
  
# helm init(serviceaccount setting)
helm init --service-account tiller 





```



## Helm Chart 실행
```bash
https://blog.naver.com/mantechbiz/221447296981
```
