output "instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.project_server.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.project_server.public_ip
}

output "application_url" {
  description = "Application URL after successful deployment"
  value       = "http://${aws_instance.project_server.public_ip}:30080"
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ../id_ed25519 ubuntu@${aws_instance.project_server.public_ip}"
}