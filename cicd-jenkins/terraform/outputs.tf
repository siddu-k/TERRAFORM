output "instance_id" {
  value = aws_instance.jenkins.id
}

output "public_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

output "jenkins_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}

output "flask_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:8000"
}

output "express_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:3000"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.jenkins_eip.public_ip}"
}
