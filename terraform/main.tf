variable "region" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

provider "aws" {
  region      = var.region 
  access_key  = var.access_key 
  secret_key  = var.secret_key 
}

resource "aws_vpc" "VPC_cluster_kubernetes" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
  tags = {
      Name = "VPC Cluster Kubernetes"
  }
} 

resource "aws_subnet" "Public_subnet" {
  vpc_id                  = aws_vpc.VPC_cluster_kubernetes.id
  cidr_block              = var.publicsCIDRblock
  tags = {
    Name = "Public subnet"
  }
}

resource "aws_internet_gateway" "IGW_teste" {
 vpc_id = aws_vpc.VPC_cluster_kubernetes.id
 tags = {
        Name = "Internet gateway teste"
  }
} 

resource "aws_route_table" "Public_RT" {
 vpc_id = aws_vpc.VPC_cluster_kubernetes.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_teste.id
  }

 tags = {
        Name = "Public Route table"
  }
} 

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.Public_RT.id
  destination_cidr_block = var.publicdestCIDRblock
  gateway_id             = aws_internet_gateway.IGW_teste.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.Public_subnet.id
  route_table_id = aws_route_table.Public_RT.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "kubernetes_master01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  count = 2
  key_name = "kubernetes_cluster_key" # Insira o nome da chave criada antes.
  subnet_id = aws_subnet.Public_subnet.id
  vpc_security_group_ids = [aws_security_group.permitir_ssh_http_nodes.id]
  associate_public_ip_address = true

  tags = {
    Name = "node-${count.index}"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("../kubernetes_cluster_key.pem")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "${count.index} == 0 curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--tls-san ${self.public_ip}' sh -",
      "sudo hostnamectl set-hostname node-${self.private_ip}",
      "${count.index} == 0 ? export KUBECONFIG=/etc/rancher/k3s/k3s",
      #"${count.index} == 1 ? curl -sfL https://get.k3s.io | K3S_URL=${var.k3s_url} K3S_TOKEN=${var.k3s_token} sh -"
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh -i ../kubernetes_cluster_key.pem ubuntu@${aws_instance.kubernetes_master01.public_ip} \
        "echo k3s_url=https://${aws_instance.kubernetes_master01.private_ip}:6443 && \
         echo k3s_token=\$(cat /var/lib/rancher/k3s/server/node-token)" \
        > ./k3s_variables.auto.tfvars
    EOT
  }
}

resource "aws_security_group" "master_security_group" {
  name        = "master_security_group"
  vpc_id      = aws_vpc.VPC_cluster_kubernetes.id

    ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3S to EC2"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "K3S to EC2-1"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet metrics"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet2"
    from_port   = 16443
    to_port     = 16443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flannel Wireguard "
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master_security_group"
  }

}

data "aws_instances" "k3s_workers" {
  instance_state_names = ["running"]
}

output "instances" {
  value = "${data.aws_instances.k3s_workers.ids}"
}