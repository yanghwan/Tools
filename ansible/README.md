# ansible 이란    

1. 간단한 오픈소스 IT 엔진 (자동으로 Application deploy, 인프라 서비스 통합 , 많은 IT툴과 함께 클라우드 프로비저닝  
2. yaml (직관적인 언어이며 사람이 읽고 쓰고 이해하기 쉽다.  환경파일을 위해 일반적으로 사용함.)를 사용함.   
3. agentless이며, SSH 커텍션을 연결해서 간단한 모듈를 실행하고, 종료가 되면 제거가 된다.)  


# How Ansible Works?  
![ansible-2](https://user-images.githubusercontent.com/39255123/180646634-35389fd9-c1be-4511-bbbd-e2c8ba98586b.png)  

관리 노드: 플레이북의 전체 실행을 제어하는 제어하는 노드  
인벤토리 파일: Ansible 모듈이 있는 호스트 목록  (host 그룹화 / 플레이북을 특정 그룹에 실행가능)   
  
  
1. 간단한 방법으로 인벤토리와 플레이북으로 한번에 모두 설치한다.  
2. 인벤토리 :  노드의 IP주소 목록과 playbook 설치가된다.  
3. 컨트롤머신에서 플레이북이 실행이 될때, 모든 노드에 설치가 되고, 설치된다  
   SSH - small program copy -  module 실행 - 종료후 삭제 (복사한 코드)   
   데몬 / 데이터베이스가 필요하지 않음.
 


# ansible install  


- ansible 구성

ansible install 하면 기본적으로 Dirctory 구조로 생성이 된다.
```bash
[root@centos8-140 ansible]# pwd
/etc/ansible
[root@centos8-140 ansible]# tree
.
├── ansible.cfg
├── hosts
└── roles

1 directory, 2 files
```

- ansible 구성요소
```
1. inventory : 관리대상 서버리스트
2. Module : hosts에 특정 Action를 수행하는 패키지화된 Script 
3. play-book : 변수 및 Tashk를 관리호스트에 수행하기 위한 yaml 문법으로 정의된 파일
4. plug-in : 확장 기능 (email,logging.etc)를 제공
5. Custom module : 사용자가 직적 작성한 모듈
```

- inventory 생성방법
```
#--- INI File
[webservers]
www[01:50].example.com
 
#--- Yaml File
  webservers:
    hosts:
      www[01:50].example.com:
      
```

- 실행
```bash
#ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
```

```bash
[WARNING]: an unexpected error occurred during Jinja2 environment setup: unable to locate collection ansible.netcommon

TASK [Check that python netaddr is installed] **************************************************************************************************************************
fatal: [localhost]: FAILED! => {"msg": "The conditional check ''127.0.0.1' | ipaddr' failed. The error was: template error while templating string: unable to locate collection ansible.netcommon. String: {% if '127.0.0.1' | ipaddr %} True {% else %} False {% endif %}"}

PLAY RECAP *************************************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

[root@centos8-140 kubespray]# 

``` 
- ansible 옵션
```bash
-i  --inventory-file : 적용될 호스트들에 대한 파일 지정
-m  --module-name : 모듈을 선택할 수 있도록 설정
-k  --ask-pass : 패스워드를 물어보도록 설정
-K  --ask-become-pass : 관리자로 권한 상승
--list-hosts : 적용되는 호스트들을 확인
```

![image](https://user-images.githubusercontent.com/39255123/178524117-e1a1bcc6-5150-4480-9dbc-f5c63d05f4fc.png)
```
#ansible localhost -m ping
```
  

Reference :  
https://github.com/kubernetes-sigs/kubespray/releases  
https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v2.19.0.tar.gz  
```bash  
Feature / Major changes
Add hashes for Kubernetes 1.24.0, 1.24.1, 1.21.12, v1.21.13, 1.22.8, 1.22.9, v1.22.10, 1.21.11, 1.23.5, 1.23.6, v1.23.7 and make kubernetes v1.23.7 default (#8628, #8746, #8783, #8876, #8760, @mzaian, @cristicalin)
[ansible] add support for ansible 5 (ansible-core 2.12) (#8512, @cristicalin)
[ansible] make ansible 5.x the new default version (#8660, @cristicalin)
[cert-manager] Update cert-manager to 1.6.1 (#8377, @electrocucaracha)
[cert-manager] Update cert-manager to v1.7.2 (#8648, @rtsp)
[cert-manager] Upgrade to v1.8.0 (#8688, @rtsp)
```  
