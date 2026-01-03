terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#####################
# PROVIDER
#####################

provider "aws" {
  region = "us-east-1"
}

#####################
# VARIABLE
#####################

variable "key_name" {
  description = "Existing AWS key pair name (us-east-1)"
  type        = string
}

#####################
# UBUNTU 22.04 AMI
#####################

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#####################
# SECURITY GROUP
#####################

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Jenkins Security Group"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#####################
# EC2 INSTANCE
#####################

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"   # Free Tier
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id
  ]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              ################################
              # SYSTEM UPDATE
              ################################
              apt update -y
              apt upgrade -y

              hostnamectl set-hostname jenkins-server

              ################################
              # BASE TOOLS
              ################################
              apt install -y \
                git \
                curl \
                unzip \
                ca-certificates \
                gnupg \
                lsb-release

              ################################
              # JAVA 17 (Jenkins)
              ################################
              apt install -y openjdk-17-jdk

              ################################
              # JENKINS
              ################################
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
                | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                https://pkg.jenkins.io/debian-stable binary/ \
                | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

              apt update -y
              apt install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins

              ################################
              # DOCKER
              ################################
              apt install -y docker.io
              systemctl enable docker
              systemctl start docker

              usermod -aG docker ubuntu
              usermod -aG docker jenkins

              ################################
              # DOCKER COMPOSE
              ################################
              curl -SL https://github.com/docker/compose/releases/download/v2.29.4/docker-compose-linux-x86_64 \
                -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              ################################
              # PYTHON
              ################################
              apt install -y python3-pip python3-venv python3-dev

              pip3 install --upgrade pip
              pip3 install ansible boto3 botocore

              ################################
              # TERRAFORM
              ################################
              wget https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_linux_amd64.zip
              unzip terraform_1.13.1_linux_amd64.zip -d /usr/local/bin
              chmod +x /usr/local/bin/terraform
              rm terraform_1.13.1_linux_amd64.zip
              EOF

  tags = {
    Name = "jenkins-full-server"
  }
}

#####################
# OUTPUTS
#####################

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

