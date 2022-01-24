## ansible.sh
```bash
#! /bin/bash
#fold creater
sudo mkdir -p /awx/docker/awx_compose
sudo mkdir -p /awx/projects
#mkdir -p /awx/postgres


sudo yum -y install epel-release
# default packer install
sudo yum -y install wget ansible git

sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
cd /etc/yum.repos.d/
ls -al | grep docker-ce.repo
sudo yum clean all
sudo yum-complete-transaction --cleanup-only
sudo yum repolist


#docker install
sudo yum remove -y docker docker-client docker-client-lates docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum install -y docker-ce docker-ce-cli containerd.io
#python
sudo yum install -y python3 python3-pip

sudo systemctl daemon-reload
sudo systemctl start docker
#docker pull nginx

#sudo pip3 uninstall docker docker-py docker-compose
#
#docker-compose install
sudo pip3 uninstall docker docker-py docker-compose

sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#sudo pip3 install docker-fabric
#sudo pip3 install docker docker-compose
sudo pip3 install docker-compose

#sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
#sudo dnf makecache

sudo git clone -b 17.0.1 https://github.com/ansible/awx.git /awx/awx

#awx_task_hostname=awx
#awx_web_hostname=awxweb
#postgres_data_dir=/awx/postgres
sudo sed -i 's/^postgres_data_dir=.*/postgres_data_dir=\/awx\/postgres/g' /awx/awx/installer/inventory
#host_port=80
#docker_compose_dir=/awx/docker/awx_compose
sudo sed -i 's/^docker_compose_dir=.*/docker_compose_dir=\/awx\/docker\/awx_compose/g' /awx/awx/installer/inventory
#admin_user=admin
# admin_password=test1234
sudo sed -i 's/^# admin_password=.*/admin_password=password/g' /awx/awx/installer/inventory
#!/usr/bin/env python3

sudo systemctl daemon-reload
sudo systemctl restart docker

sudo ansible-playbook -i /awx/awx/installer/inventory /awx/awx/installer/install.yml
```
