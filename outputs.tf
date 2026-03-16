output "webapp_public_ip" {
  value       = aws_eip.webapp_ip.public_ip
  description = "Public IP of the web app instance"
}

output "webapp_url" {
  value       = "http://${aws_eip.webapp_ip.public_ip}"
  description = "URL to access web app over HTTP"
}

output "rds_endpoint_from_remote_state" {
  value       = data.terraform_remote_state.rds.outputs.db_endpoint
  description = "RDS endpoint retrieved from the proto repo state"
}
