terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

########################
# VARIABLES
########################
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name"
  type        = string
}

########################
# PROVIDER
########################
provider "aws" {
  region = var.aws_region
}

########################
# UBUNTU 22.04 AMI
########################
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

########################
# SECURITY GROUP
########################
resource "aws_security_group" "base_sg" {
  name        = "base-instance-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

########################
# EC2 INSTANCE
########################
resource "aws_instance" "base_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.base_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y

    hostnamectl set-hostname five-microservis-dev-server

    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      git \
      openjdk-11-jdk

    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker

    usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "ubuntu-microservice-instance"
  }
}

########################
# OUTPUT
########################
output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.base_ec2.public_ip
}
