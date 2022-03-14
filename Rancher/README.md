### Helm 기반 Rancher Deploy하기

- chart package download   
```
c:\helm-3.8.1>helm repo add jetstack https://charts.jetstack.io
"jetstack" has been added to your repositories

c:\helm-3.8.1>helm repo list
NAME            URL
jetstack        https://charts.jetstack.io
rancher-latest  https://releases.rancher.com/server-charts/latest


# download
c:\helm-3.8.1>helm fetch jetstack/cert-manager
c:\helm-3.8.1>helm fetch rancher-latest/rancher
c:\helm-3.8.1>curl https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml > cert-manager.crds.yaml

c:\helm-3.8.1>dir
 Volume in drive C has no label.
 Volume Serial Number is 5C45-3F0C

 Directory of c:\helm-3.8.1

2022-03-14  오후 11:00    <DIR>          .
2022-03-14  오후 10:42            59,048 cert-manager-v1.7.1.tgz
2022-03-14  오후 10:43               158 cert-manager.crds.yaml
2022-03-11  오후 10:00        46,249,984 helm.exe
2022-03-10  오전 06:28            11,373 LICENSE
2022-03-14  오후 11:00            13,108 rancher-2.6.3.tgz
2022-03-10  오전 06:28             3,367 README.md
               6 File(s)     46,337,038 bytes
               1 Dir(s)  141,065,134,080 bytes free
               
```

- Install  
```bash
# kubectl create namespace cattle-system
# kubectl create namespace cert-manager

# 

# helm install --generate-name  rancher-2.6.3.tgz

```
###  Rancher K8S에 올리기
- cert-manager
```bash
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.crds.yaml

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
