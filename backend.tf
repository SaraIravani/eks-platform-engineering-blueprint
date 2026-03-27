terraform {
  backend "s3" {
    bucket = "eks-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ca-central-1"
  }
}
