
## Docker Image(/usr/sbin/init)

Docker Image는 자체적으로 OS가 포함이 되어 있는 있으며, 구동이후 OS에 CLI를 통해서 접속을 할수가 있다.   
많은 official Image들은 경량화의 목적으로 백그라운드 서비스를 관리하는 systemd가 빠려 있는경우가 있다.  
ProLinux 기반의 경량화 이미지는 /usr/sbin/init를 생항하여 백그라운드 서비스를 관리할수 있다.  
많은 이미지들이 "exec /usr/sbin/init " 실행하여 백그라운 프로세서를 실행한다.  
"/usr/sbin/init" 으로 실행시에는 DockerFile로 생성한 ENV 설정내용이 Container Running 시에는 참조가 되지 않기 때문에  
주의가 필요하며, 환경변수의 인식이 필요할경우  /etc/environment 파일에 환경변수값을 기술하면 참조할수 있다.  

OS Booting시 Systemd 이름으로  PID1인 프로세서를 확인할수 있으며, Systemd는 OS Booting시 초기화 및 환경설정(서비스관리)등를 해주는 프로세서라고 보면 된다.  
Systemd 이전에는 init이라는 포로세서가 PID1를 차지하고 그역활을 해주었으며, 가장 먼저 시작하는 프로세서 이며 부모프로세서로 작동합니다.  
init의 한계를 극복하기 위해 Systemd가 등장하면서, 호환성과 병렬처리로 실행되어서 부팅속도가 빨라지고 다양한 기능을 제공한다.  
systemctl사용시 systemd를 이용하여 서비스를 시작/중지/재시작/리로드 등을 명령을 수행할수 있다.  


* Reference 
https://www.freedesktop.org/wiki/Software/systemd/

##  cat 명령어
* cat file
만들어 놓은 Docker Image에서 vi가 설치가 되어 있지 않는경우 cat 명령을 이용해서 파일을 만들고 사용할수 있다.  
```bash
* 존재할 경우 새로쓰기
 cat > [파일 경로/이름]
 
  Ctrl + D

* 존재할 결우 이어쓰기
cat >> [파일 경로 / 이름]

Ctrl + D
 
```

##  github txt 가져오기
github에서 YAML 및 설정파일를 하나씩 Copy하는것은 많은 어려움이 있다.
특정 Text를 다운받고자 할때 오른쪽 raw를 Click시 Text주소가 나타나고 다운받아 쉽게 사용할수 있다.

```bash
wget [주소]
$ wget https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus-kubernetes.yml
```


## curl data 가져오기
윈도우와 리눅스에 기본 설치되고 있는 웹 개발 툴로써 http, https, ftp, sftps, smtp, telnet 등의 다양한 프로토콜과 Proxy, Header, Cookie 등의 세부 옵션까지 쉽게 설정할 수 있습니다.  
이러한 장점 때문에 Client를 코딩을 시작하기 전에 curl 명령어로 서버 동작을 먼저 확인함으로써 좀 더 빠르게 개발을 진행할 수 있습니다.  

```bash
# -o --output <file>  : write output to file
# -k --insecure : https 사이트에 대해서 ssl certificate 검증없이 연결  #wget --no-check-certificate와 비슷한 역활을 수행  
curl -k https://raw.githubusercontent.com/prometheus/prometheus/main/documentation/examples/prometheus-kubernetes.yml  --output aaa
```
