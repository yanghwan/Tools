## Helm install

### 
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
[root@centos8-1 ~]# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
"rancher-latest" has been added to your repositories

[root@centos8-1 ~]#  helm repo list
NAME            URL                                              
rancher-latest  https://releases.rancher.com/server-charts/latest
[root@centos8-1 ~]# 


$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

[root@centos8-1 ~]# chmod 700 get_helm.sh
[root@centos8-1 ~]# ./get_helm.sh
Downloading https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm

```
- cert-manager
```bash
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml

```

```bash

[root@centos8-1 ~]# 
[root@centos8-1 ~]#  helm version
version.BuildInfo{Version:"v3.8.0", GitCommit:"d14138609b01886f544b2025f5000351c9eb092e", GitTreeState:"clean", GoVersion:"go1.17.5"}
[root@centos8-1 ~]# 
[root@centos8-1 ~]# 
[root@centos8-1 ~]# helm repo list
Error: no repositories to show
[root@centos8-1 ~]# 
[root@centos8-1 ~]# 
[root@centos8-1 ~]# helm repo add stable https://charts.helm.sh/stable

출처: https://freestrokes.tistory.com/151 [FREESTROKES DEVLOG]^C
[root@centos8-1 ~]# helm repo add stable https://charts.helm.sh/stable




^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# ^C
[root@centos8-1 ~]# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
"rancher-latest" has been added to your repositories
[root@centos8-1 ~]# helm repolist
Error: unknown command "repolist" for "helm"
Run 'helm --help' for usage.
[root@centos8-1 ~]#  helm repo list
NAME            URL                                              
rancher-latest  https://releases.rancher.com/server-charts/latest
[root@centos8-1 ~]# 
[root@centos8-1 ~]# 
[root@centos8-1 ~]# 
[root@centos8-1 ~]# kubectl create namespace cattle-system
namespace/cattle-system created
[root@centos8-1 ~]# kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
[root@centos8-1 ~]# kubectl create namespace cert-manager
namespace/cert-manager created
[root@centos8-1 ~]# helm repo add jetstack https://charts.jetstack.io
"jetstack" has been added to your repositories
[root@centos8-1 ~]#  helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "rancher-latest" chart repository
Update Complete. ⎈Happy Helming!⎈
[root@centos8-1 ~]# helm install \
>   cert-manager jetstack/cert-manager \
>   --namespace cert-manager \
>   --version v1.0.4

NAME: cert-manager
LAST DEPLOYED: Mon Mar  7 00:03:35 2022
NAMESPACE: cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
cert-manager has been deployed successfully!

In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them
can be found in our documentation:

https://cert-manager.io/docs/configuration/

For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:

https://cert-manager.io/docs/usage/ingress/
[root@centos8-1 ~]# 
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              0/1     ContainerCreating   0          16s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          16s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          16s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              0/1     ContainerCreating   0          19s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          19s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          19s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          21s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          21s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          21s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          22s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          22s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          22s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          23s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          23s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          23s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          25s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          25s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          25s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          26s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          26s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          26s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          27s
cert-manager-cainjector-55db655cd8-hsrlp   0/1     ContainerCreating   0          27s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          27s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          48s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          48s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          48s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          49s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          49s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          49s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          50s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          50s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          50s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          51s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          51s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          51s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          52s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          52s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          52s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          54s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          54s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          54s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          55s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          55s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          55s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS              RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running             0          56s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running             0          56s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     ContainerCreating   0          56s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          57s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          57s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     Running   0          57s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          59s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          59s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     Running   0          59s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          60s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          60s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     Running   0          60s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          62s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          62s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     Running   0          62s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          64s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          64s
cert-manager-webhook-7d8c86cb4c-hr86r      0/1     Running   0          64s
[root@centos8-1 ~]# kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-6d87886d5c-tzmzq              1/1     Running   0          85s
cert-manager-cainjector-55db655cd8-hsrlp   1/1     Running   0          85s
cert-manager-webhook-7d8c86cb4c-hr86r      1/1     Running   0          85s
[root@centos8-1 ~]# 

```
