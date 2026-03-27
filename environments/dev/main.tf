module "vpc" {
  source = "../../modules/vpc"

  cidr_block      = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
