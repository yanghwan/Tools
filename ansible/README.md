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


Reference : https://github.com/kubernetes-sigs/kubespray/releases
