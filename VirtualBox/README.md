# VirtualBox 
Windows PC환경에서 여래개의 VM을 생성하여 다양한 테스트가 가능하다.  
기본 구성 및 네트웍에 대한 기본개념을 이해하고 구축을 하면 쉽고 빠르게 구축을 할수 있다.  

![image](https://user-images.githubusercontent.com/39255123/155870608-f946a1b3-6b80-4b6b-9778-1c40f59c43a3.png)

위의 기본적인 구성을 위해서는 아래와 같은 단계로 구성을 진행한다.  
![image](https://user-images.githubusercontent.com/39255123/155870665-96c42490-41f2-4bc6-bf17-33fb3e8fd31a.png)


## 1. VirtualBox Install 
``` bash
1. Site 
   https://www.virtualbox.org/wiki/Downloads
```

## 2. Host Virtual Network 
VirtualBox를 설치하게 되면 가상인터페이스(VirtualBox Host-Only Network)가 생성된것을 확인할수 있으며, 해당 인터페이스가 G/W 역활을 해주면서 통신 및 인터넷이 가능하다.  
![image](https://user-images.githubusercontent.com/39255123/155871008-e7811bf7-81f8-484a-b5b9-1453c7ea92de.png)

-- VirtualBox Host-Only Network : HOST PC 와 Virtual Machine 들간의 Network 통신을 위한 인터페이스 역활를 수행한다.  
-- VM은 해당 IP(192.168.137.1)를 G/W IP로 설정한다.    
![image](https://user-images.githubusercontent.com/39255123/155871386-91f0c502-5d9b-48a4-b5c3-62d36619ecf7.png)

