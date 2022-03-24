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
 
env:
  {{- range .Values.env }}
  - name: {{ .name }}
    value: {{ .value }}
  {{- end }}
위 내용을 Deployment 파일에 추가해주면 됩니다. 물론, Deployment 파일의 형식은 지켜주셔야 합니다. env 필드는 spec.template.spec.containers.env 에 위치해야 합니다. 추가로 range는 해당 값이 리스트 형태로 정의되어 있을 때, 해당 리스트를 순회하면서 하나씩 데이터를 넣어주게 됩니다. 일종의 for문이라고 생각하시면 됩니다.

여기서 정의한 .Values.env 에 대응할 수 있도록 values.yaml 파일에도 env 필드를 추가해주어야 합니다. 예를 들어, values.yaml 에 다음과 같이 정의해두었다면, helm으로 Kubernetes Manifest를 생성했을 때, env 필드가 채워져서 들어가게 됩니다.


alues.yaml 파일을 살펴보겠습니다. 사실 살펴볼 것도 없이 굉장히 명확합니다. 이 파일에 기록되는 데이터는 후에 설명 드릴 를 만들게 됩니다.


```




Helm의 기본 구조는 다음과 같습니다. (Helm 3.0 기준으로 확인한 내용입니다)

 ![image](https://user-images.githubusercontent.com/39255123/156928682-13fd42aa-99bc-4333-a812-d4d6f13b0cc6.png)

Helm 3 Architecture  
출처: https://freestrokes.tistory.com/151  

- Charts
yaml 파일을 묶어서 정의한 package입니다. kubernetes app 빌드를 위한 리소스가 정의되어 있습니다. 
- Repository
생성된 차트들의 저장소입니다.
- Release
kubernetes 클러스터에 로드된 chart instance들의 버전입니다. chart로 배포된 app들은 각각 고유한 버전을 갖고 있습니다. 


### Install
```bash
$ curl -fsSL -I -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

[root@centos8-1 ~]# chmod 700 get_helm.sh
[root@centos8-1 ~]# ./get_helm.sh
Downloading https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm

```


### Helm REPO 등록

- dockerhub와 같이 chart들이 저장된 자장소를 말한다.
```bash
# helm repo list  #등록된 Repo list 확인
# helm repo add stable https://charts.helm.sh/stable  #stable chart 저장소
# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest #Rancher 

```

- CLI 확인
```bash
[root@centos8-1 ~]#  helm version
version.BuildInfo{Version:"v3.8.0", GitCommit:"d14138609b01886f544b2025f5000351c9eb092e", GitTreeState:"clean", GoVersion:"go1.17.5"}

[root@centos8-1 ~]# helm repo list
NAME            URL                                              
rancher-latest  https://releases.rancher.com/server-charts/latest
jetstack        https://charts.jetstack.io                       
stable          https://charts.helm.sh/stable   

```
### bitnami/apache 예제
```bash
# REPO 등록
#helm repo add bitnami https://charts.bitnami.com/bitnami

# LIST 확인
[root@centos8-1 ~]# helm repo list
NAME    URL                               
bitnami https://charts.bitnami.com/bitnami

# Install 
[root@centos8-1 ~]# helm install my-release bitnami/apache
NAME: my-release
LAST DEPLOYED: Mon Mar  7 22:46:07 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: apache
CHART VERSION: 9.0.6
APP VERSION: 2.4.52

** Please be patient while the chart is being deployed **

1. Get the Apache URL by running:

** Please ensure an external IP is associated to the my-release-apache service before proceeding **
** Watch the status using: kubectl get svc --namespace default -w my-release-apache **

  export SERVICE_IP=$(kubectl get svc --namespace default my-release-apache --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
  echo URL            : http://$SERVICE_IP/


WARNING: You did not provide a custom web application. Apache will be deployed with a default page. Check the README section "Deploying your custom web application" in https://github.com/bitnami/charts/blob/master/bitnami/apache/README.md#deploying-your-custom-web-application.


-- Chart를 이용하여 install 되었으며, svc 와 deployment가 default namespace에서 실행이 됨을 확인할수 있다
[root@centos8-1 ~]# kubectl get svc
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kubernetes          ClusterIP      10.96.0.1       <none>        443/TCP                      2d20h
my-release-apache   LoadBalancer   10.107.253.79   <pending>     80:31418/TCP,443:31489/TCP   3m2s

[root@centos8-1 ~]# kubectl get pods  -n default
NAME                                READY   STATUS    RESTARTS   AGE
my-release-apache-6659d5986-wcz5s   1/1     Running   0          4m15s

[root@centos8-1 ~]# kubectl get deployment  -n default
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
my-release-apache   1/1     1            1           4m36s

```

- 삭제
```bash
[root@centos8-1 ~]# helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-release      default         1               2022-03-07 22:46:07.697797878 +0900 KST deployed        apache-9.0.6    2.4.52     
[root@centos8-1 ~]# 
[root@centos8-1 ~]# helm uninstall my-release 
release "my-release" uninstalled
[root@centos8-1 ~]# helm ls
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
[root@centos8-1 ~]# kubectl get svc -n default
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d20h
[root@centos8-1 ~]# kubectl get deployment -n default
No resources found in default namespace.
```

helm install --replace --tiller-namespace=system --namespace=system -n somepackage

Helm Chart Directory 생성
