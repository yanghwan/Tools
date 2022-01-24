# terraform shell script to use private registry

## private_registry.sh
```bash
#! /bin/bash
echo "ip_address = ${ip_address}" > /tmp/iplist
echo "nfs_address = ${nfs_address}" >> /tmp/iplist
echo "REGISTRY_LOCAL = ${REGISTRY_LOCAL}" >> /tmp/iplist
echo "REGISTRY_IP = ${REGISTRY_IP}" >> /tmp/iplist
echo "REGISTRY_PORT = ${REGISTRY_PORT}" >> /tmp/iplist

sudo mkdir ${REGISTRY_LOCAL}
#default package install
sudo yum -y install epel-release redhat-lsb

#default tools-install
sudo yum install -y net-tools git

#sudo yum install -y git make podman
# podman delete
sudo rm -rf /etc/containers/* /var/lib/containers/* /etc/docker /etc/subuid* /etc/subgid*
sudo yum remove -y buildah skopeo podman containers-common atomic-registries docker
sudo rm -rf /home/fatherlinux/.local/share/containers/

# List view
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum list docker-ce --showduplicates | sort -r | awk 'NR==2 {print $2}'
#3:20.10.6-3.el8
#sudo yum install -y  docker-ce-19.03.15 docker-ce-cli-19.03.15  containerd.io-1.3.9
sudo yum install -y docker-ce

sudo systemctl start docker
sudo systemctl enable docker

local_ip=$(sudo ifconfig eth0 | grep 'inet ' | awk '{ print $2}')
echo $local_ip
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "insecure-registries": ["ip:5000"]
}
EOF
sudo sed -i "s/ip/$local_ip/g" /etc/docker/daemon.json

sudo systemctl restart docker
#sudo systemctl status docker

######## version registry 구축 필요 ################
sudo git clone https://github.com/tmax-cloud/install-registry.git $REGISTRY_LOCAL
#cd $hc_registry
sudo docker load -i ${REGISTRY_LOCAL}/manifest/docker-registry.tar
sudo docker run -it -d -p ${REGISTRY_PORT}:5000 registry  -v /source/registry:/var/lib/registry/docker/registry/v2

# k8s Image etc... upload
sudo docker pull k8s.gcr.io/kube-proxy:v1.19.4
sudo docker pull k8s.gcr.io/kube-apiserver:v1.19.4
sudo docker pull k8s.gcr.io/kube-controller-manager:v1.19.4
sudo docker pull k8s.gcr.io/kube-scheduler:v1.19.4
sudo docker pull k8s.gcr.io/etcd:3.4.13-0
sudo docker pull k8s.gcr.io/coredns:1.7.0
sudo docker pull k8s.gcr.io/pause:3.2

sudo docker tag k8s.gcr.io/kube-apiserver:v1.19.4 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-apiserver:v1.19.4
sudo docker tag k8s.gcr.io/kube-proxy:v1.19.4 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-proxy:v1.19.4
sudo docker tag k8s.gcr.io/kube-controller-manager:v1.19.4 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-controller-manager:v1.19.4
sudo docker tag k8s.gcr.io/etcd:3.4.13-0 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/etcd:3.4.13-0
sudo docker tag k8s.gcr.io/coredns:1.7.0 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/coredns:1.7.0
sudo docker tag k8s.gcr.io/kube-scheduler:v1.19.4 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-scheduler:v1.19.4
sudo docker tag k8s.gcr.io/pause:3.2 ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/pause:3.2

sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-apiserver:v1.19.4
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-proxy:v1.19.4
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-controller-manager:v1.19.4
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/etcd:3.4.13-0
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/coredns:1.7.0
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/kube-scheduler:v1.19.4
sudo docker push ${REGISTRY_IP}:${REGISTRY_PORT}/k8s.gcr.io/pause:3.2


```
