# Production recommendation:
# Configure remote state per environment (dev/staging/prod) with S3 + DynamoDB lock table,
# versioning, SSE-KMS, and public access block on the backend bucket.
# Example backend config file usage:
# terraform init -backend-config=environments/dev/backend.hcl
terraform {
  backend "s3" {}
}
