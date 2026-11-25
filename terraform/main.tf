
resource "aws_instance" "java_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.java_sg.id
  ]

  user_data = <<-EOF
    #!/bin/bash
    set -eux

    dnf update -y
    dnf install -y docker git

    systemctl enable docker
    systemctl start docker

    cd /opt

    git clone YOUR_PUBLIC_GITHUB_REPOSITORY_URL app

    cd app

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
