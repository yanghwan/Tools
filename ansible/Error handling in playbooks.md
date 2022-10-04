# Error handling in playbooks 
Error 발생 ( a non-zero return code from a command / a failure from a module)시에는 기본적으로 해당호스트에서는 실행이 중지가 되고,  
다른 호스트에서 계속 실행하게 된다. 상황에 따라서 다르게 동작하기를 원할때 사용한다.    
예를 들어서 non-zero Return 코드를 성공으로 판단하거나  / 한 호스트에서 Failure 발생시 모든 호스트에서 중지하기를 원할수도 있습니다.  
Task 실행결과에 따라서  failed /  success(changed) 변경을 할수 있도록    상황에 맞는 handles를 세팅할수 있도록 제공한다.  

### 1. 옵션
ignore_errors: yes  :  실패하면 호스트에서 작업 실행을 중지합니다.  ignore_errors하여 실패에도 불구하고 계속 수행.  
Defining failure  

failed_when : 실패조건을 재정의 
ex)
```
1. Shell Script 안에서 true ㅅ
   echo 3.1 Result; netstat -an | grep  $(echo $s|awk -F',' '{print $2}')  || /bin/true
   echo 3.2 Result;systemctl status $(echo $s|awk -F',' '{print $1}' )  || /bin/true
--> shell 실행후 실패하면 /bin/true 실행이 되면서 항상 성공.

2. failed_when 으로 조건
      with_items: 
        - "{{ cmservice_hostname2 }}"
#      when : ("{{ hostvars[inventory_hostname].ansible_host }}" == "centos8-110")
      register: rt_service
      ignore_errors: yes
      failed_when: '"Failed" in rt_service.stderr_lines'
--> stderr_lines Message중 failed String이 있을때만 failed 상태로 변경. 
```
