# Terraform  

## aws_provider.tf
```bash
#aws_key_pair, aws_security_group, aws_instance, aws_db_instance
# 접속하기 위해서 IAM KEY를 생성하여 등록을 해야 접속이 가능

provider "aws" {
  access_key = "AKIA4YH663E5SYW47XVG"
  secret_key = "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"
  region     = var.aws_used_region
  #"ap-southeast-1"
  #ap-southeast-1a
  #region     = "us-east-2"
}

resource "aws_key_pair" "terraform_admin" {
  key_name = "terraform_admin"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB ~~~~"
  #public_key = file(".ssh/web_admin.pub")
}

```
## main.tf
```bash
terraform {
  required_version = "0.15.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }

}

resource "aws_instance" "vm-node" {
  ami = "ami-084be8fbdbd21b027" #cent8싱가폴
  instance_type = "t2.micro"  #"t2.large" #
  key_name = aws_key_pair.terraform_admin.key_name
  subnet_id  = aws_subnet.subnet_public_zone.id
  count = var.master-node-count
  private_ip = "${element(keys(var.node-list[count.index]), 0)}"
  associate_public_ip_address = true
  #      aws_security_group.sg-cluster.id,
  vpc_security_group_ids = [
      aws_security_group.sg-front.id,
      aws_security_group.sg-nfs.id
  ]
   user_data = element(data.template_file.runtime-init-script.*.rendered, count.index)
  tags =  {
    Name = "vm-node"
  }
}


```

## aws_var.tf
```bash
data "aws_availability_zones" "all" {}

variable "aws_used_zone" {
  default = "ap-southeast-1a"
}
variable "aws_used_region" {
  default = "ap-southeast-1"
}
variable "master-node-count" {
  default = 4
}
variable "node-list" {
  type = list
  default = [
    { "10.10.10.10"="vm-node1" },
    { "10.10.10.11"="vm-node2" },
    { "10.10.10.12"="vm-node3" },
    { "10.10.10.13"="vm-node4" },
    { "10.10.10.14"="vm-node5" },
  ]
}

variable "nfs-ips" {
  default = {
    "0" = "10.10.10.30"
  }
}

data "template_file" "runtime-init-script" {
  template = file("./shell_install_nginx.sh")
  count=var.master-node-count
  vars = {
    instance_ipaddress="${element(keys(var.node-list[count.index]), 0)}"
    instance_hostname="${element(values(var.node-list[count.index]), 0)}"
    all_host_info=replace(replace(jsonencode(var.node-list), "\"", ""), ":", "=")
    nfs_address=lookup(var.nfs-ips,0)

  }
}

```

## aws_lb.tf
```bash
# Node off-line lb
# LB -10.10.10.200 - 80 - > 80 (Instance VM)
resource "aws_lb" "master-lb" {
  name               = "node-lb"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.subnet_public_zone.id
    private_ipv4_address = "10.10.10.200"
  }
  enable_deletion_protection = false
  #  subnets            = aws_subnet.subnet_public_zone.*.id
  enable_cross_zone_load_balancing = false
  internal = true
}

resource "aws_lb_listener" "master-lb-listener" {
  load_balancer_arn = aws_lb.master-lb.arn
  protocol          = "TCP"
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.master-lb-tg.arn
  }
}
resource "aws_lb_target_group" "master-lb-tg" {
  port        = "80"
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
  health_check {
    protocol = "TCP"
    port     = "80"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }
  depends_on = [
    aws_lb.master-lb
  ]
  lifecycle {
    create_before_destroy = true
  }
}
// Get the instance ids of the NLB members
resource "aws_lb_target_group_attachment" "master-lb-tg-attach" {
  count = var.master-node-count
  target_group_arn = aws_lb_target_group.master-lb-tg.arn
  target_id = aws_instance.vm-node[count.index].private_ip
  availability_zone = var.aws_used_zone
  port              = "80"
  depends_on = [
    aws_instance.vm-node
  ]
}

#service elb 생성 [8080 - > 80 ]
resource "aws_elb" "front-web" {
  name               = "elb-frontweb"
  instances = split(",", join(",", aws_instance.vm-node.*.id))
  subnets = [aws_subnet.subnet_public_zone.id]
  security_groups    = [aws_security_group.sg-front.id]
  internal = false
  listener {
    lb_port           = "8080"
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  depends_on = [
    aws_security_group.sg-front
  ]
}

```

## aws_etf.tf
```bash
# 공유볼륨 설정.
resource "aws_efs_file_system" "master-efs"{
  creation_token = "master-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"
  #depends_on = [ aws_security_group.sg-nfs,aws_instance.k8s-master]
  depends_on = [ aws_security_group.sg-nfs,aws_instance.vm-node]
  tags = {
    Name = "NFS-Share-volume"
  }
}
resource "aws_efs_mount_target" "master-efs-mt"{
  file_system_id = aws_efs_file_system.master-efs.id
  subnet_id = aws_subnet.subnet_public_zone.id
  ip_address =  lookup(var.nfs-ips,0)
  security_groups = [ aws_security_group.sg-nfs.id]
  depends_on = [aws_efs_file_system.master-efs]
}
```
## aws_vpc.tf

```bash

# VPC and
variable "vpc_cidr_info" {
  description = "VPC CIDR BLOCK : x.x.x.x/x"
  default = "10.10.0.0/16"
}
variable "subnet_cidr_info" {
  description = "VPC SUBNET CIDR BLOCK : x.x.x.x/x"
  default = "10.10.10.0/24"
}

resource "aws_vpc" "vpc" {
  cidr_block  = var.vpc_cidr_info
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "Public VPC Zone"
  }
}

resource "aws_subnet" "subnet_public_zone" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_info
  map_public_ip_on_launch = true
  availability_zone = var.aws_used_zone
  tags = {
    Name = "Public Zone subnet "
  }
}
```  
## aws_security.tf
```bash
# Management
resource "aws_security_group" "sg_default" {
  name = "sg_default"
  #  id = "sg-030cbf7c01bfb9b00"
  vpc_id = aws_vpc.vpc.id
  description = "Allow SSH port from all"
  tags = {
    name = "allow"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_default.id
  lifecycle { create_before_destroy = true }
}
resource "aws_security_group_rule" "icmp" {
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "ICMP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_default.id
  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_default.id
  lifecycle { create_before_destroy = true }
}


#K8S Cluster Open
resource "aws_security_group" "sg-cluster" {
  name = "sg_cluster-default"
  vpc_id = aws_vpc.vpc.id
  description = "All Port Open from Cluster zone"
  tags = {
    name = "allow"
  }
}
# subnet 간 통신 허용
resource "aws_security_group_rule" "cluster-all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.10.0.0/16"]
  security_group_id = aws_security_group.sg-cluster.id
  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "cluster-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-cluster.id
  lifecycle { create_before_destroy = true }
}

# keycloak ui
resource "aws_security_group" "sg-front" {
  name = "sg_frontweb"
  vpc_id = aws_vpc.vpc.id
  description = "All Port Open from Cluster zone"
  tags = {
    name = "allow"
  }
}
resource "aws_security_group_rule" "front-ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-front.id
  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "front-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-front.id
  lifecycle { create_before_destroy = true }
}

# NFS Storage
resource "aws_security_group" "sg-nfs" {
  name = "sg_nfs"
  vpc_id = aws_vpc.vpc.id
  description = "All Port Open from Cluster zone"
  tags = {
    name = "allow"
  }
}
resource "aws_security_group_rule" "nfs-ingress" {
  type              = "ingress"
  from_port         = 0 #2049
  to_port           = 0 #2049
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-nfs.id
  lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "nfs-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-nfs.id
  lifecycle { create_before_destroy = true }
}
```

## aws_router.tf 
```bash
# NAT 및 Router 설정.
resource "aws_internet_gateway" "vpc_gw"  {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private Zone Internet_GateWay"
  }
}
resource "aws_route" "side_effect_internet_access" {
  route_table_id = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc_gw.id
}
# associate subnets to route tables
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.subnet_public_zone.id
  route_table_id = aws_vpc.vpc.main_route_table_id
}

# eip for NAT
resource "aws_eip" "vpc_nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.vpc_gw]
}
# NAT gateway
resource "aws_nat_gateway" "private_nat" {
  allocation_id = aws_eip.vpc_nat_eip.id
  subnet_id = aws_subnet.subnet_public_zone.id
  depends_on = [aws_internet_gateway.vpc_gw]
}
```

## shell_install_nginx.sh
```bash
#! /bin/bash

echo "instance_ipaddress = ${instance_ipaddress}" > /tmp/iplist
echo "instance_hostname = ${instance_hostname}" >> /tmp/iplist
echo "all_host_info = ${all_host_info}" >> /tmp/iplist
echo "nfs_address = ${nfs_address}" >> /tmp/iplist

echo "-----BEGIN RSA PRIVATE KEY-----
" > /tmp/ssh_key
#sudo yum -y install epel-release redhat-lsb

#sudo apt-get -y update
sudo yum -y install nginx
sudo yum -y net-tools
sudo service nginx start
sudo yum -y install nfs-utils
sudo mkdir /source
sudo mount -t nfs4 ${nfs_address}:/ /source
sudo chown centos:centos /tmp/ssh_key
sudo chmod 400 /tmp/ssh_key
sudo mkdir /root/.ssh
sudo cp /home/centos/.ssh/authorized_keys /root/.ssh/authorized_keys
sudo systemctl restart sshd
```
