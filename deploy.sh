#!/usr/bin/env bash
set -euo pipefail

# Assumes tf-aws-rds-schema-test has already been applied.
cd "$(dirname "$0")/.."

terraform init
terraform apply \
  -var "aws_region=${AWS_REGION:-us-east-1}" \
  -var "aws_profile=${AWS_PROFILE:-default}" \
  -var "rds_terraform_state_path=${RDS_TERRAFORM_STATE_PATH:-../tf-aws-rds-schema-test/terraform.tfstate}" \
  -var "app_ecr_repo_name=${APP_ECR_REPO_NAME:-gse-web-app}" \
  -var "app_image_tag=${APP_IMAGE_TAG:-latest}" \
  -auto-approve

terraform output app_url
