## Windows Trouble Guide

### Process kill
```bash
# Error Message
Web server failed to start. Port 8080 was already in use.

#find
C:\Users\yangh>netstat -ano |find "8080"
  TCP    127.0.0.1:8080         0.0.0.0:0              LISTENING       6916

# kill 
C:\Users\yangh>taskkill /pid 6916 /f
성공: 프로세스(PID 6916)가 종료되었습니다.


```
