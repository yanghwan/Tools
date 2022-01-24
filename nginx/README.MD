# nginx Install  

## REPO 설정
```bash
$sudo vi /etc/yum.repos.d/nginx.repo

[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1

```
## nginx Install
```bash
#sudo yum install -y nginx


```
## Port 개방 및 방화벽 Open
```bash
# 포트 개방
$ sudo firewall-cmd --permanent --zone=public --add-port=8888/tcp
# 방화벽 재시작
$ sudo firewall-cmd --reload
# 개방된 포트 목록 확인
$ sudo firewall-cmd --list-ports
```

## 재시작
```bash
$ sudo systemctl enable nginx
$ sudo systemctl start nginx
$ sudo systemctl restart nginx

```

## 설정
```bash
[root@mariadb nginx]# cat  nginx.conf

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
    server {
        listen 8888;
        location / {
            proxy_pass http://222.122.67.200:80; #Proxy 설정.
        }
    }
}

```
ex)
```bash
server {
    listen       8080;
    listen       [::]:8080;

    server_name  localhost; # 도메인 주소

    root /usr/share/nginx/frontend; # 배포된 프로젝트 경로
    index index.html index.htm;

    client_max_body_size 100M;
    location ^~ /api {
        proxy_pass       http://127.0.0.1:3100;  # backend url
        proxy_set_header Host       $http_host;
        proxy_set_header X-Real-IP  $remote_addr;
    }

    location ^~ /stream {
        proxy_pass       http://127.0.0.1:3100;  # backend url

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_cache_bypass $http_upgrade;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```
