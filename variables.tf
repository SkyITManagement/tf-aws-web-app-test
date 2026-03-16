variable "aws_region" {
  description = "AWS region to deploy the web app in."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name for local credentials."
  type        = string
  default     = ""
}

variable "rds_terraform_state_path" {
  description = "Path to the RDS repo terraform state file to read db endpoint from."
  type        = string
  default     = "../tf-aws-rds-schema-test/terraform.tfstate"
}

variable "webapp_instance_type" {
  description = "EC2 instance type for the web app."
  type        = string
  default     = "t3.micro"
}

variable "webapp_ssh_key_name" {
  description = "Optional EC2 key pair name for SSH into web app instance (leave empty to skip)."
  type        = string
  default     = ""
}
