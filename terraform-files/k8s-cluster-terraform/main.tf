
####################################
# UBUNTU 22.04 AMI (DATA SOURCE)
####################################
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

####################################
# K8s MASTER NODE
####################################
resource "aws_instance" "k8s_master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "k8s-master"
    Role = "master"
  }
}

####################################
# K8s WORKER NODES (2 ADET)
####################################
resource "aws_instance" "k8s_workers" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
  }
}

