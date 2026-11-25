
provider "aws" {
  region = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "java_sg" {
  name        = "java-docker-sg"
  description = "Allow Java application traffic"

  ingress {
    description = "Java application"
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

  tags = {
    Name = "java-docker-sg"
  }
}

resource "aws_instance" "java_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.java_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    exec > /var/log/app-deploy.log 2>&1

    dnf update -y
    dnf install -y docker git

    systemctl enable --now docker

    cd /opt
    git clone ${var.github_repo_url} app

    cd /opt/app

    docker build -t java-docker-app .

    docker run -d \
      --restart always \
      --name java-app \
      -p 8080:8080 \
      java-docker-app
  EOF

  tags = {
    Name = "Java-Docker-Server"
  }
}
