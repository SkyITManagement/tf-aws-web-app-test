# tf-aws-web-app-test

This Terraform repo deploys a Dockerized app to ECS Fargate behind an ALB and reads RDS endpoint from remote state.

## Prerequisites

1. AWS CLI configured with credentials and profile.
2. `terraform init` and `terraform apply` in `tf-aws-rds-schema-test` to create RDS and generate state.
3. Build and push your app image to ECR with repo name `gse-web-app` (or override variable).

## Usage

From this repo:

```bash
terraform init
terraform apply \
  -var 'aws_region=us-east-1' \
  -var 'aws_profile=default' \
  -var 'rds_terraform_state_path=../tf-aws-rds-schema-test/terraform.tfstate' \
  -var 'app_ecr_repo_name=gse-web-app' \
  -var 'app_image_tag=latest' \
  -auto-approve
```

Then get URL:

```bash
terraform output app_url
```

## Notes

- For production, use remote state backend (S3 + DynamoDB).
- Pass DB password via `-var 'container_env={DB_PASS="mypassword"}'`.

