# terraform shell script to use k8s

## k8s_runtime.sh
```bash
#! /bin/bash
#NFS Create
sudo yum -y install nfs-utils
sudo mkdir /source
sudo mount -t nfs4 ${nfs_address}:/ /source

echo "instance_ipaddress=${instance_ipaddress}" > /tmp/info
echo "nfs_address=${nfs_address}" >> /tmp/info
echo "instance_hostname=${instance_hostname}" >> /tmp/info
echo "k8s_VERSION=${k8s_VERSION}" >> /tmp/info
echo "all_host_info=${all_host_info}" >> /tmp/info

sudo hostnamectl set-hostname ${instance_hostname}
sudo sed -e 's/\[//g' -e 's/\]//g' -e 's/{//g' -e 's/}//g' -e 's/\=/        /g' -e 's/,/\r\n/g' <<< ${all_host_info} >> /etc/hosts
#sudo echo "${instance_ipaddress}  ${instance_hostname}" >> /etc/hosts
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo swapoff -a

#ubuntu
#
# sudo apt-get update && sudo apt-get install -y \
#  docker-ce=5:20.10.5~3-0~ubuntu-$(lsb_release -cs) \
#  docker-ce-cli=5:20.10.5~3-0~ubuntu-$(lsb_release -cs)

sudo sed -i 's/\/dev\/mapper\/centos-swap/#\/dev\/mapper\/centos-swap/g' /etc/fstab
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/g' /etc/selinux/config
sudo modprobe overlay
sudo modprobe br_netfilter

sudo cat <<-"EOF" | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system


sudo dnf -y install 'dnf-command(copr)'
sudo dnf -y copr enable rhcontainerbot/container-selinux
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${k8s_VERSION}.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${k8s_VERSION}/CentOS_8/devel:kubic:libcontainers:stable:cri-o:${k8s_VERSION}.repo

sudo yum -y install cri-o
sudo systemctl enable --now cri-o
sudo systemctl start crio

# network plugin & vitural interface 충돌.
sudo rm -rf  /etc/cni/net.d/100-crio-bridge.conf
sudo rm -rf  /etc/cni/net.d/200-loopback.conf
sudo rm -rf /etc/cni/net.d/87-podman-bridge.conflist

#crio registry info
sudo sed -i "s/^\#insecure_registries = \[\]/insecure_registries = \[\"${REGISTRY_IP}:${REGISTRY_PORT}\"\]/g" /etc/crio/crio.conf
sudo sed -i "s/^#registries = \[/registries = \[\"${REGISTRY_IP}:${REGISTRY_PORT}\"\]/g" /etc/crio/crio.conf

sudo sed -i "s/^pids_limit = [0-9]*/pids_limit = 32768/g" /etc/crio/crio.conf
sudo systemctl restart crio

#kubeadm, kubelet, kubectl
sudo cat <<-"EOF" | sudo tee -a /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum install -y kubeadm-1.19.4 kubelet-1.19.4-0 kubectl-1.19.4-0
sudo systemctl enable kubelet


```
