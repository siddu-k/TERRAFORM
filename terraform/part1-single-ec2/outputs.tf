output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.web_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "flask_url" {
  description = "URL to access Flask backend"
  value       = "http://${aws_eip.web_eip.public_ip}:5000"
}

output "express_url" {
  description = "URL to access Express frontend"
  value       = "http://${aws_eip.web_eip.public_ip}:3000"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.web_eip.public_ip}"
}
