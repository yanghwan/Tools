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

# Environment Setup  

- Installation Process  
  1. control machine : 다른 머신을 관리하기 위한 머신  
  2. Remote machine : 컨트롤머신에 의해서 제어/핸들된 머신  
  하나의 Control Machine에서 다중 Remote Machine를 관리할수 있으며,   
  Remote Machine를 관리하기 위해서는 Control Machine에는 Ansible를 설치해야한다.  

- Control Machine Requirements  
   1. Python 2 (versions 2.6 or 2.7) or r Python 3 (versions 3.5 and higher)  
   2. 컨트롤머신은 윈도우를 지원하지 않는다.   
   3. Apt, yum, pkg, pip, OpenCSW,pacman etc 를 이용해서 최신 버전을 설치할수 있다.  

- Ubuntu Install
```bash
  $ sudo apt-get update
  $ sudo apt-get install software-properties-common
  $ sudo apt-add-repository ppa:ansible/ansible
  $ sudo apt-get update
  $ sudo apt-get install ansible
```
#  Ansible – YAML Basics    
안시블은 플레이북들을 표현하기 위해서는 YAML 문법을 사용한다.  
다른 JSON & XML 데이타 포맷과 비교했을때, Read / Write 가 쉽기 때문에 YAML를 사용한다.  
YAML는 데이터를 표현하기 위해서는 아래의 규칙을 따른다.  

- YAML 규칙   
  1. 시작 :  "---"  
  2. 종료 :  "..."   
  3. Key - value 쌍으로 구성되며  ":"  으로 구분됨.  
  4. 목록(LIST형) 표현 : "-" 시작 . 
  5. key에 대한 값을 리스트형으로 관리 할수 있다.  
  6. Boolean는 True / false 로 표현하며,  대소문자 구분하지 않는다.  
  7. "|" - 블록 안에서 줄바꿈  
  8. "|-" : 마지막 줄바꿈은 제외  
  9. ">" 불럭내에 줄바꿈을 무시함.  
  
#  Ansible – Ad hoc Commands  
Ad hoc commands:  playbook 을 작성하지 않고 command-line 에서 직접 앤서블 모듈을 호출해서 실행하는 방식을 말함.  

\- 빠른기능를 수행하기 위해, 개별적으로 수행할수 있는 명령어임.  
\- 명령을 한번만 사용하기 때문에 구성관리 및 배포에는 사용하지 않는다.   
\- ansible-playbook : 구성관리 및 배포에 사용  

```
$ ansible [host-group] [option] [command] 
$ ansible-doc -l    # 모듈 리스트 확인
$ ansible-doc file  # 특정모듈 도움말.
```
- example hosts file
```bash
[abc]
centos8-140 ansible_host=192.168.137.140 ansible_port=22 
centos8-141 ansible_host=192.168.137.141 ansible_port=22 
```  
- Ad hoc Commands (example)    
  1. reboot  
    $ Ansible abc -a "/sbin/reboot" -f 12 -u username  
  2.  Transferring file  
    $ Ansible abc -m copy -a "src=/etc/yum.conf dest=/tmp/yum.conf" 
  3.  Creating new directory  
    $ Ansible abc -m file -a "dest=/path/user1/new mode=777 owner=user1 group=user1 state=directory"
  4.  Deleting whole directory and files    
    $ Ansible abc -m file -a "dest=/path/user1/new state=absent"
  5.  yum using    
    $ ansible abc -m yum -a "name=demo-tomcat-1 state=present"  
    $ ansible abc -m yum -a "name=demo-tomcat-1 state=absent"  
    $ ansible abc -m yum -a "name=demo-tomcat-1 state=latest"  
  6. Gathering Facts    
    $ Ansible all -m setup  
    
# Ansible – Playbooks 

Playbook은 ansible의 핵심기능중 하나이며, 실행할 작업목록(Task0를 포함하고 있다.  
Playbooks은 STEP(특정한 머신에 실행을 원하는 단계)를 포함하고 있고, 순차적으로 실행한다.  
PlayBook 구조는 하나이상의 플레이를 실행할수 있는 집합으로 구성이 되어 있으며, 하나이상 실행할수 있다.   
Playbook는 yaml로 작성을 하며,작성하는 동안 주의가 필요하다.  

- Create a Playbook  (YAML Example)  
```bash

---
  name: install and configure DB
  hosts: testServer
  become: yes
  
  vars:
    oracle_db_port_value : 1521
  
  tasks:
  -name: Install the Oracle DB
  yum: <code to install the DB>    
  
  -name: Ensure the installed service is enabled and running
  
  service:
  name: <your service name>

```   
1. name : playbook 논리적인 이름  
2. hosts : 수행할 호스트 및 호스트그룹   
3. vars : 플레이북에서 사용할 변수, 다른 프로그램에서 사용방식과 동일함.  
4. Task : 모든 플레이북에서 실행할 작업 또는 작업 목록을 말함.  
              
# Ansible – Roles 
\- 독립적인 프레임웍을 제공,  의존적인 모듈 집합(variables, tasks, files, templates)  
\-  리소스들을 표준화된  디렉토리 구조로 패키징  
\- 플레이북을 여러 파일로 나누어 사용하는  기본 메커니즘.  
\- 복작합 플레이북을 단순화 하고,  재사용 하기 쉽게 만든다.  
\- 재사용이 가능한 컴포런트로 플레이북을 논리적으로 분할해서 사용할수 있다.  

- Creating a New Role  
\- Roles는  파일시스템에 구조화된 레이아웃을 가지고 있고, 기본구조를 바꿀수도 있다. (변경은 권장하지 않음)  
\- 디렉토리 트리구조로 되어 있다.

- 사용방법
```bash
1. Usage  
$ansible-galaxy [delete|import|info|init|install|list|login|remove|search|setup] [--help] [options]  

2. example
$ ansible-galaxy --help
usage: ansible-galaxy [-h] [--version] [-v] TYPE ...

Perform various Role and Collection related operations.

positional arguments:
  TYPE
    collection   Manage an Ansible Galaxy collection.
    role         Manage an Ansible Galaxy role.

optional arguments:
  --version      show program's version number, config file location, configured module search path, module
                 location, executable location and exit
  -h, --help     show this help message and exit
  -v, --verbose  verbose mode (-vvv for more, -vvvv to enable connection debugging)
  
  
$ ansible-galaxy init --force --offline ansible-example
- Role ansible-example was created successfully
$ ls
ansible-example

$tree ansible-example
ansible-example
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

8 directories, 8 files

```

# Ansible – Variables  
\- 모든 프로그래밍 언어에서 변수를 사용하는 것과 매우 유사합니다.  
\- 변수에 값을 사용 및 할당하고 플레이북에서 참조해서 사용할수 있다.  
\- 변수 값 주위에 조건을 설정하고 그에 따라 변수를 사용할 수 있다.  

```bash 
- hosts : <your hosts>
 vars:
 tomcat_port : 8080

- 변수를 tomcat_port를 설정하고 플레이북에서는 변수를 사용할수 있다.
- block : 인시블을을 실행할 불력
- block name : 로깅에 사용되며, 모든 블록을 디버깅하는데 도움이 된다.
- action : 실행할 작업
- register : 실행에 대한 출력를 변수로 등록하여 출력을 사용
- always: 안시블을 다시 시작함.
- msg : displays the message

Usage of variable - {{Output}}
- 변수의 값이 출력이 되며, 하위 속성(출력변경) 도 사용할수가 있음.
 
```

# Exception Handling in Playbooks
\ - 플레이북의 exception는 Application과 동일함.
java와 비교했을때  
try  - block  
catch - resource  
finally - always   

# Loop 사용법  
- with_items:  반복  

# Conditionals  
- when : 
 
# Ansible – Advanced Execution  

1. How to Limit Execution by Tasks  
- 특정한 서버만 실행을 하고자 할때, 태그를 기반으로 역할/작업을 실행할수 있다.  

- {role: start-tomcat, tags: ['install']}}  
--> ansible-playbook -i hosts <your yaml> --tags "install" -vvv  

2. How to Limit Execution by Hosts  

3. Alternate Solution  
-  --extra-vars 옵션으로 설정한 변수를 제외하는방법  

# Ansible – Advanced Execution  

1. How to Limit Execution by Tasks  
- 특정한 서버만 실행을 하고자 할때, 태그를 기반으로 역할/작업을 실행할수 있다.  

- {role: start-tomcat, tags: ['install']}}  
--> ansible-playbook -i hosts <your yaml> --tags "install" -vvv  

2. How to Limit Execution by Hosts  

3. Alternate Solution  
-  --extra-vars 옵션으로 설정한 변수를 제외하는방법  
  

# Ansible – Troubleshooting  
1.  Debug 
	 - You can run the commands with verbosity level one (-v) or two (-vv)
2. Register


  
  
# 추가정보  
  Environment Setup : [ansible/Environment Setup.md](https://github.com/yanghwan/Tools/blob/0de7d25de0de2730a68271de70e4e8341529d046/ansible/Environmen%20Setup.md)  
  Ansible – YAML Basics   
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
https://www.tutorialspoint.com/ansible/ansible_tutorial.pdf  
  
```bash  
  
Feature / Major changes
Add hashes for Kubernetes 1.24.0, 1.24.1, 1.21.12, v1.21.13, 1.22.8, 1.22.9, v1.22.10, 1.21.11, 1.23.5, 1.23.6, v1.23.7 and make kubernetes v1.23.7 default (#8628, #8746, #8783, #8876, #8760, @mzaian, @cristicalin)
[ansible] add support for ansible 5 (ansible-core 2.12) (#8512, @cristicalin)
[ansible] make ansible 5.x the new default version (#8660, @cristicalin)
[cert-manager] Update cert-manager to 1.6.1 (#8377, @electrocucaracha)
[cert-manager] Update cert-manager to v1.7.2 (#8648, @rtsp)
[cert-manager] Upgrade to v1.8.0 (#8688, @rtsp)
```  
