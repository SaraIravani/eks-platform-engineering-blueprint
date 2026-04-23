#terraform {
#  backend "s3" {
#    bucket = "eks-platform-sara-20260327"
#    key    = "dev/terraform.tfstate"
#    region = "ca-central-1"
#  }
#}
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
