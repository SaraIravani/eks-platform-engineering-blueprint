# EKS Platform Engineering Blueprint

Enterprise-grade Terraform blueprint for secure, scalable, and cost-optimized Amazon EKS foundations.

## Architecture Overview
- Multi-environment structure (`dev`, `staging`, `production`) with separate state paths/backends.
- Reusable modules for VPC, EKS, IAM, add-ons, and managed node groups.
- Private EKS API endpoint defaults, KMS encryption, control plane audit logging, and IRSA.
- Mixed node strategy (On-Demand + Spot) with autoscaler discovery tags.

## Modules
- `modules/vpc`: VPC, subnet tiers, NAT (single or per-AZ), S3/DynamoDB gateway endpoints, optional ECR interface endpoints.
- `modules/eks`: EKS cluster, KMS key, encrypted control plane logs, OIDC provider.
- `modules/iam`: Cluster/node roles and EBS CSI IRSA role.
- `modules/addons`: Managed add-ons (VPC CNI, CoreDNS, kube-proxy, EBS CSI).
- `modules/node_groups`: Managed node groups with labels/taints and rolling update settings.

## Security Design Principles
- Least-privilege IAM role segmentation.
- Cluster secrets encryption with dedicated KMS key rotation.
- Private endpoint-only control plane by default.
- Interface endpoint SG limited to VPC CIDR.

## CI/CD & Policy Checks
- GitHub Actions: `terraform fmt`, `init`, `validate`, `tflint`, `tfsec`.
- Pre-commit hooks for local IaC validation before push.

## Usage
```bash
cd environments/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Backend & State
Use per-environment S3 backend configs with:
- SSE-KMS encryption
- versioning
- public access block
- DynamoDB lock table

## Cost Optimization
- Dev defaults to single NAT gateway.
- Spot node groups for interruption-tolerant workloads.
- Scale-to-zero batch groups via `min_size=0`.

## Troubleshooting
- Ensure AWS auth and region are correct.
- Validate subnet-to-AZ alignment.
- If IRSA fails, verify OIDC provider exists and trust policy subject matches service account.
