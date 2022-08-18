# Playbook에서 Task 작성하기

플레이북이 task들이 어떻게 수행될지 정의한다.  
타겟 호스트로 실제 작업을 처리하는 단위로 이 모듈의 개념을 사용한다. 앤서블 모듈은 파이썬 코드로 작성 된다.  
위 플레이북 예시에서 apt가 우분투에서 사용되는 모듈이다. 구글에서 ansible all modules를 검색해보면 모듈 목록과 사용법을 확인 할 수 있다.  


- Task 작성방법
```bash
- name: [태스크를 알기 쉽게 정한 이름>
  [module name]:
    [module arg1]: [arg value1]
    [module arg2]: [arg value2]
    ...
  [task directive2]: [directive value2]
  
```

\-name - 실행할 태스크 이름. 필수 항목은 아니지만, 플레이북에서 가독성/유지 보수성을 높이고 로그를 쉽게 확인하기 위해 모든 태스크에 이름을 입력하는 것이 좋습니다.  
\-module_name - 사용하는 모듈의 이름. 앤서블에는 기본으로 500개가 넘는 모듈들이 내장돼 있어서 "앤서블 공식 문서의 모듈 인덱스" 또는 ansible-doc -l 명령어로 참조할 수 있음  
\- module_arg - 모듈에 건네주는 인수. 인수의 형식은 모듈별로 정해져 있으므로 모듈별 문서를 참조해서 설정값을 확인해야 합니다.  
\- task_directive - 태스크를 실행 단위별로 지정할 수 있는 지시자가 여기에 기술됨.  

- Example 
```bash
- name: install the latest version of Apache
  yum:
    name: httpd
    state: latest
    
```

Module Reference :  
\- https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html   
\- https://docs.ansible.com/ansible/latest/collections/index_module.html  
