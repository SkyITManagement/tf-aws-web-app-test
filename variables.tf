variable "aws_region" {
  description = "AWS region for deploy."
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  description = "AWS profile name for provider authentication."
  type        = string
  default     = "default"
}

variable "rds_terraform_state_path" {
  description = "Path to RDS terraform state path."
  type        = string
  default     = "../tf-aws-rds-schema-test/terraform.tfstate"
}

variable "app_ecr_repo_name" {
  description = "Name of ECR repository to deploy app image."
  type        = string
  default     = "gse-web-app"
}

variable "app_image_tag" {
  description = "Docker image tag for ECS task."
  type        = string
  default     = "latest"
}

variable "app_container_port" {
  description = "Container port for application service."
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Fargate task memory (MB)."
  type        = number
  default     = 1024
}

variable "desired_count" {
  description = "Desired ECS task count."
  type        = number
  default     = 1
}

variable "container_env" {
  description = "Additional environment variables for app container."
  type        = map(string)
  default     = {}
}
# ------------------
# VPC VARIABLES
# ------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet A"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_b_cidr" {
  description = "CIDR block for private subnet B"
  type        = string
  default     = "10.0.11.0/24"
}
