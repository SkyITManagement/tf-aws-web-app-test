# tf-aws-web-app-test

This repository deploys a simple EC2-based web app and retrieves the RDS endpoint from the `tf-aws-rds-schema-test` repo via Terraform remote state.

## Prerequisites

1. AWS CLI configured with credentials and profile.
2. `terraform init` and `terraform apply` in `tf-aws-rds-schema-test` to create RDS and generate state.

## Usage

From this repo:

```bash
terraform init
terraform apply -var 'aws_region=us-east-1' -var 'aws_profile=default' -var 'rds_terraform_state_path=../tf-aws-rds-schema-test/terraform.tfstate'
```

After apply, open the web app URL from output `webapp_url`.

## Notes

- This demo uses `terraform_remote_state` local backend. For production, use remote state (S3) and lock (DynamoDB).
- If you need RDS endpoint from a separate state file or backend, update `rds_terraform_state_path` or the data `terraform_remote_state` backend config.
