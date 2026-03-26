output "app_url" {
  value       = "http://${aws_lb.app.dns_name}"
  description = "ALB URL for deployed app"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "ECR repository URL"
}

output "rds_endpoint" {
  value       = data.terraform_remote_state.rds.outputs.db_endpoint
  description = "RDS endpoint retrieved from remote state"
}
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnets" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  description = "Public subnet IDs"
}

output "private_subnets" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  description = "Private subnet IDs"
}
