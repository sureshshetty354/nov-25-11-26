
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security Group
resource "aws_security_group" "java_sg" {
  name        = "java-docker-sg"
  description = "Allow application traffic"

  ingress {
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

# EC2 Instance
resource "aws_instance" "java_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.java_sg.id]

  user_data = <<-EOF
    #!/bin/bash

    dnf update -y
    dnf install docker git -y

    systemctl enable docker
    systemctl start docker

    cd /opt

    git clone ${var.github_repo_url} java-app

    cd /opt/java-app

    docker build -t java-demo-app .

    docker run -d \
      --name java-container \
      --restart always \
      -p 8080:8080 \
      java-demo-app
  EOF

  tags = {
    Name = "Java-Docker-Server"
  }
}
