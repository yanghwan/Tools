### GitHub 활용 
Helm은 기본적으로 Chart를 이용하여 Install 하여 서비스를 디플로이 한다.  
외부 저장소 github를 이용하여 간단하게  Helm chart repository를 구성 관리할수 있다.  
사전에  https://github.com/ 으로 접근하여 계정생성후 진행하면 된다.  

![image](https://user-images.githubusercontent.com/39255123/157247381-66c23137-9f7f-4c08-b676-02902161396b.png)

1. GitHub repository 생성  
![image](https://user-images.githubusercontent.com/39255123/157247967-133915b5-49c5-4694-a176-f0ee222bb976.png)

Helm에서 사용할 Repository를 생성한다. 

2. Repository Branch 생성  
![image](https://user-images.githubusercontent.com/39255123/157248988-9ae9a8d3-03f0-469f-a8c3-dd3eead99d53.png)
Branch 생성이후 사용할 Git 주소를 이용하여 Chart Upload 및 Helm Repository를 등록한다.  


-  예제 샘플 생성하기  
```bash
[root@centos8-1 ~]# helm repo list
NAME    URL                               
bitnami https://charts.bitnami.com/bitnami

# 폴더 구조 생성 및 fetch
[root@centos8-1 ~]# tree helm-charts/
helm-charts/
├── README.md
└── stable

# 예제 download
[root@centos8-1 stable]# helm fetch bitnami/apache -d /root/helm-charts/stable/

#  index.yaml 생성
[root@centos8-1 stable]# helm repo index /root/helm-charts/stable
[root@centos8-1 stable]# ls -artl

# fetch / index 실행시 아래와 같은 구조로 생성됨.
[root@centos8-1 ~]# tree helm-charts/
helm-charts/
├── README.md
└── stable
    ├── apache-9.0.6.tgz
    ├── index.yaml

1 directory, 4 files

```

- Github 샘플 Push 
```bash
[root@centos8-1 ~]# git init

[root@centos8-1 ~]# git remote add master https://github.com/yanghwan/helm-charts.git

[root@centos8-1 ~]# git remote -v
master  https://github.com/yanghwan/helm-charts.git (fetch)
master  https://github.com/yanghwan/helm-charts.git (push)

[root@centos8-1 ~]# git add /root/helm-charts/

[root@centos8-1 ~]# git commit -m "commit first chart"

[root@centos8-1 ~]# git remote -v
master  https://github.com/yanghwan/helm-charts.git (fetch)
master  https://github.com/yanghwan/helm-charts.git (push)


[root@centos8-1 ~]# git branch
* master

# branch 생성 
[root@centos8-1 ~]# git branch origin
[root@centos8-1 ~]# git branch -a
* master
  origin
  
# 소스 push시에 token 입력을 위해서는 github에서 토큰생성후 입력한다.    
[root@centos8-1 ~]# git push  master origin 
Password for 'https://yanghwankim@gmail.com@github.com': 
오브젝트 나열하는 중: 11, 완료.
오브젝트 개수 세는 중: 100% (11/11), 완료.
Delta compression using up to 3 threads
오브젝트 압축하는 중: 100% (7/7), 완료.
오브젝트 쓰는 중: 100% (11/11), 85.34 KiB | 7.76 MiB/s, 완료.
Total 11 (delta 0), reused 0 (delta 0), pack-reused 0
remote: 
remote: Create a pull request for 'origin' on GitHub by visiting:
remote:      https://github.com/yanghwan/helm-charts/pull/new/origin
remote: 
To https://github.com/yanghwan/helm-charts.git
 * [new branch]      origin -> origin
token : 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
```


### GitHub를 이용한 Lopo설정

