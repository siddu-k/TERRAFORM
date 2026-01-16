output "backend_instance_id" {
  description = "ID of the backend EC2 instance"
  value       = aws_instance.backend.id
}

output "frontend_instance_id" {
  description = "ID of the frontend EC2 instance"
  value       = aws_instance.frontend.id
}

output "backend_public_ip" {
  description = "Public IP address of the backend instance"
  value       = aws_eip.backend_eip.public_ip
}

output "frontend_public_ip" {
  description = "Public IP address of the frontend instance"
  value       = aws_eip.frontend_eip.public_ip
}

output "flask_url" {
  description = "URL to access Flask backend"
  value       = "http://${aws_eip.backend_eip.public_ip}:8000"
}

output "express_url" {
  description = "URL to access Express frontend"
  value       = "http://${aws_eip.frontend_eip.public_ip}:3000"
}

output "backend_ssh_command" {
  description = "SSH command to connect to backend instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.backend_eip.public_ip}"
}

output "frontend_ssh_command" {
  description = "SSH command to connect to frontend instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.frontend_eip.public_ip}"
}
