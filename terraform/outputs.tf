
output "ec2_public_ip" {
  value = aws_instance.java_server.public_ip
}

output "application_url" {
  value = "http://${aws_instance.java_server.public_ip}:8080"
}

output "health_check_url" {
  value = "http://${aws_instance.java_server.public_ip}:8080/health"
}
